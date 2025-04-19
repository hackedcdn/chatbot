#!/bin/bash

# ChatBot gurnalyş skripti - Aňsat, bir buýruk bilen
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

# ===== BU SKRIPTI GURNAMAK ÜÇIN: =====
# curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/install.sh | sudo bash
# ======================================

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Reňki nol et

echo -e "${BLUE}"
echo "   _____ _           _   ____        _   "
echo "  / ____| |         | | |  _ \      | |  "
echo " | |    | |__   __ _| |_| |_) | ___ | |_ "
echo " | |    | '_ \ / _\` | __|  _ < / _ \| __|"
echo " | |____| | | | (_| | |_| |_) | (_) | |_ "
echo "  \_____|_| |_|\__,_|\__|____/ \___/ \__|"
echo -e "${NC}"
echo -e "${GREEN}ChatBot Awtomatiki Gurnalyş Skripti${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}"
echo "----------------------------------------"

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bu skripti root hökmünde işlediň gerek.${NC}"
  echo -e "${YELLOW}Aşakdaky buýrugy ulanmagyňyz maslahat berilýär:${NC}"
  echo -e "${GREEN}curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/install.sh | sudo bash${NC}"
  echo -e "${YELLOW}Ýa-da:${NC}"
  echo -e "${GREEN}sudo bash install.sh${NC}"
  exit 1
fi

echo -e "${GREEN}GÖRKEZME: Bu gurnalyş awtomatiki bolup, diňe bir gezek 'Enter' düwmesine basmak bilen dowam eder.${NC}"
echo -e "${GREEN}Ýörite gurnalyş sazlamalary isleseňiz, olar düýpli sazlamalardan soň özgerdilip bilner.${NC}"
echo -e "${GREEN}Aňsat gurnalyş üçin, diňe bir gezek ENTER düwmesine basyň...${NC}"
read -t 5 -p "" CHOICE

# Parametrleri ýygnamak üçin funksiýa
get_telegram_token() {
  echo -e "${YELLOW}Telegram Bot Token alynýar...${NC}"
  echo -e "${GREEN}1. https://t.me/BotFather açyň${NC}"
  echo -e "${GREEN}2. /newbot buýrugy bilen täze bot dörediň${NC}"
  echo -e "${GREEN}3. Bot adyny we ulanyjy adyny giriziň${NC}"
  echo -e "${GREEN}4. BotFather-den gelen tokeni göçürip alyň${NC}"
  echo -e "${YELLOW}Botfather-den alnan tokeniňizi ýazyň (eger boş goýsaňyz, testiň üçin nädogry token ulanyljakdyr)${NC}"
  read -p "Token (Enter düwmesine basyp geçip bilersiňiz): " token
  if [ -z "$token" ]; then
    token="TOKEN_PLACEHOLDER"
    echo -e "${YELLOW}Nädogry token ulanylar. Täze bot döretmek isleseňiz soňra konfigurasiýany üýtgediň.${NC}"
  fi
  echo "$token"
}

get_admin_id() {
  echo -e "${YELLOW}Admin ID alynýar...${NC}"
  echo -e "${GREEN}1. Öz Telegram hasabyňyzda https://t.me/myidbot açyň${NC}"
  echo -e "${GREEN}2. /getid buýrugy iberiň${NC}"
  echo -e "${GREEN}3. Bot berýän ID belgiňizi göçürip alyň${NC}"
  echo -e "${YELLOW}Öz Telegram ID belgiňizi ýazyň (eger boş goýsaňyz, standart baha 123456789 ulanyljakdyr)${NC}"
  read -p "Admin ID (Enter düwmesine basyp geçip bilersiňiz): " admin_id
  if [ -z "$admin_id" ]; then
    admin_id="123456789"
    echo -e "${YELLOW}Standart ID ulanylar. Admin hukuklaryny peýdalanmak isleseňiz soňra konfigurasiýany üýtgediň.${NC}"
  fi
  echo "$admin_id"
}

# Ulgam taýýarlamak
setup_system() {
  echo -e "${YELLOW}Ulgam täzelenýär we zerur paketler gurnalyar...${NC}"
  apt update > /dev/null 2>&1
  apt install -y python3 python3-pip python3-venv git screen curl > /dev/null 2>&1
  
  # MongoDB gurnalyşy
  echo -e "${YELLOW}MongoDB gurnalyar...${NC}"
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - > /dev/null 2>&1
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1
  apt update > /dev/null 2>&1
  apt install -y mongodb-org > /dev/null 2>&1
  systemctl enable mongod > /dev/null 2>&1
  systemctl start mongod > /dev/null 2>&1
  
  echo -e "${GREEN}Ulgam taýýarlandy!${NC}"
}

# Gurnalyş işlemleri
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

# Öňki gurnalyş barlagy we arassalamak
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Öňki gurnalyş tapyldy. Awtomatiki täzelenýär...${NC}"
  rm -rf "$INSTALL_DIR"
fi

# Gerekli bolan maglumatlary almak
telegram_token=$(get_telegram_token)
admin_id=$(get_admin_id)
mongodb_uri="mongodb://localhost:27017"
db_name="chatbot_db"

# Ulgamy taýýarlamak
setup_system

# Gurnalyş katalogyny döret
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Bot kodlaryny ýükle
echo -e "${YELLOW}Bot kodlary ýüklenýär...${NC}"
git clone https://github.com/hackedcdn/chatbot.git . > /dev/null 2>&1

# Wirtual gurşaw döret we baglylyky guramalary gurna
echo -e "${YELLOW}Python wirtual gurşawy döredilýär...${NC}"
python3 -m venv venv > /dev/null 2>&1
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1

# Konfigurasiýa faýlyny döret
echo -e "${YELLOW}Konfigurasiýa faýly döredilýär...${NC}"
cat > .env << EOL
BOT_TOKEN=$telegram_token
MONGODB_URI=$mongodb_uri
DATABASE_NAME=$db_name
ADMIN_ID=$admin_id
EOL
  
echo -e "${GREEN}Konfigurasiýa faýly üstünlikli döredildi${NC}"

# Hyzmat faýlyny döret
echo -e "${YELLOW}Ulgam hyzmaty döredilýär...${NC}"
cat > /etc/systemd/system/chatbot.service << EOL
[Unit]
Description=ChatBot Telegram Bot Service
After=network.target mongod.service

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python3 $INSTALL_DIR/bot.py
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=chatbot

[Install]
WantedBy=multi-user.target
EOL

# Dolandyryş paneli skripti
echo -e "${YELLOW}Dolandyryş paneli skripti döredilýär...${NC}"
cp -f panel.sh /usr/local/bin/chatbot > /dev/null 2>&1
chmod +x /usr/local/bin/chatbot

# Symbolik baglanyşyk döret
ln -sf /usr/local/bin/chatbot /usr/bin/chatbot > /dev/null 2>&1

# Täzeleme skripti
echo -e "${YELLOW}Täzeleme skripti döredilýär...${NC}"
cat > "$INSTALL_DIR/update.sh" << EOL
#!/bin/bash
# ChatBot täzeleme skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/update.sh | sudo bash
EOL

chmod +x "$INSTALL_DIR/update.sh"

# Hyzmaty başlat
echo -e "${YELLOW}Hyzmat başladylýar...${NC}"
systemctl daemon-reload
systemctl enable chatbot.service > /dev/null 2>&1
systemctl start chatbot.service

echo -e "${GREEN}------------------------------------------------------------${NC}"
echo -e "${GREEN}ChatBot üstünlikli guruldy!${NC}"
echo -e "${GREEN}Boty dolandyrmak üçin diňe ${YELLOW}chatbot${GREEN} diýip ýazyň${NC}"
echo -e "${GREEN}Bot şu wagt işleýär we ulanmaga taýýar.${NC}"
echo -e "${GREEN}Telegram-da özüňiziň botňyzy açyp, /start buýrugy iberiň.${NC}"
echo -e "${GREEN}------------------------------------------------------------${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}"

# Dolandyryş panelini awtomatiki aç
echo -e "${YELLOW}Dolandyryş paneli açylýar...${NC}"
sleep 2
/usr/bin/chatbot 