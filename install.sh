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
CYAN='\033[0;36m'
NC='\033[0m' # Reňki nol et

# Animasiýa üçin funksiýalar
spin() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  echo -n " "
  while ps -p $pid > /dev/null; do
    local temp=${spinstr#?}
    printf "[%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

progress_bar() {
  local title=$1
  local pid=$2
  local duration=$3
  local bar_size=40
  
  echo -ne "${YELLOW}${title}${NC} ["
  
  local i=0
  while ps -p $pid > /dev/null && [ $i -lt $bar_size ]; do
    echo -ne "${GREEN}#${NC}"
    sleep $(echo "$duration/$bar_size" | bc -l)
    ((i++))
  done
  
  # Dogry tamamlanýança galan bölegiň dolmagy
  for ((j=i; j<$bar_size; j++)); do
    if ps -p $pid > /dev/null; then
      echo -ne "${GREEN}#${NC}"
      sleep 0.01
    else
      echo -ne "${GREEN}#${NC}"
      sleep 0.005
    fi
  done
  
  echo -e "] ${GREEN}Tamamlandy!${NC}"
}

# Ekrany arassala
clear

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
  
  # Animasiýaly ýükleme
  apt update > /dev/null 2>&1 &
  PID=$!
  progress_bar "Ulgam maglumatlary täzelenýär" $PID 3
  wait $PID
  
  # Zerur paketleri gurnamak
  for package in python3 python3-pip python3-venv git screen curl wget; do
    echo -ne "${YELLOW}Guralýar: ${CYAN}$package${NC} "
    apt install -y $package > /dev/null 2>&1 &
    PID=$!
    spin $PID
    wait $PID
    echo -e " ${GREEN}✓${NC}"
  done
  
  # MongoDB gurnalyşy
  echo -e "${YELLOW}MongoDB gurnalyar...${NC}"
  echo -ne "${YELLOW}MongoDB açar faýly alynýar${NC} "
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  echo -ne "${YELLOW}MongoDB depo listi goşulýar${NC} "
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  apt update > /dev/null 2>&1 &
  PID=$!
  progress_bar "MongoDB paketleri täzelenýär" $PID 2
  wait $PID
  
  echo -ne "${YELLOW}MongoDB gurnalyşy edilýär${NC} "
  apt install -y mongodb-org > /dev/null 2>&1 &
  PID=$!
  progress_bar "MongoDB gurnalyşy" $PID 5
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  echo -ne "${YELLOW}MongoDB hyzmaty işledilýär${NC} "
  systemctl enable mongod > /dev/null 2>&1
  systemctl start mongod > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  echo -e "${GREEN}Ulgam taýýarlandy!${NC}"
}

# Gurnalyş işlemleri
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

# Öňki gurnalyş barlagy we arassalamak
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Öňki gurnalyş tapyldy. Awtomatiki täzelenýär...${NC}"
  echo -ne "${YELLOW}Öňki gurnalyş aýrylýar${NC} "
  rm -rf "$INSTALL_DIR" &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
fi

# Gerekli bolan maglumatlary almak
telegram_token=$(get_telegram_token)
admin_id=$(get_admin_id)
mongodb_uri="mongodb://localhost:27017"
db_name="chatbot_db"

# Ulgamy taýýarlamak
setup_system

# Gurnalyş katalogyny döret
echo -ne "${YELLOW}Gurnalyş katalogy döredilýär${NC} "
mkdir -p "$INSTALL_DIR" &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

cd "$INSTALL_DIR"

# Bot kodlaryny ýükle
echo -e "${YELLOW}Bot kodlary ýüklenýär...${NC}"
git clone https://github.com/hackedcdn/chatbot.git . > /dev/null 2>&1 &
PID=$!
progress_bar "Bot kodlary ýüklenýär" $PID 3
wait $PID

# Wirtual gurşaw döret we baglylyky guramalary gurna
echo -e "${YELLOW}Python wirtual gurşawy döredilýär...${NC}"
python3 -m venv venv > /dev/null 2>&1 &
PID=$!
progress_bar "Wirtual gurşaw döredilýär" $PID 2
wait $PID

source venv/bin/activate
echo -ne "${YELLOW}Python paketleri täzelenýär${NC} "
pip install --upgrade pip > /dev/null 2>&1 &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

echo -e "${YELLOW}Bot baglylyky guramalary gurnalyar...${NC}"
pip install -r requirements.txt > /dev/null 2>&1 &
PID=$!
progress_bar "Python paketleri gurnalyar" $PID 5
wait $PID

# Konfigurasiýa faýlyny döret
echo -ne "${YELLOW}Konfigurasiýa faýly döredilýär${NC} "
cat > .env << EOL
BOT_TOKEN=$telegram_token
MONGODB_URI=$mongodb_uri
DATABASE_NAME=$db_name
ADMIN_ID=$admin_id
EOL
echo -e " ${GREEN}✓${NC}"

# Hyzmat faýlyny döret
echo -ne "${YELLOW}Ulgam hyzmaty döredilýär${NC} "
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
echo -e " ${GREEN}✓${NC}"

# Dolandyryş paneli skripti
echo -ne "${YELLOW}Dolandyryş paneli skripti döredilýär${NC} "
cp -f panel.sh /usr/local/bin/chatbot > /dev/null 2>&1
chmod +x /usr/local/bin/chatbot
echo -e " ${GREEN}✓${NC}"

# Symbolik baglanyşyk döret
echo -ne "${YELLOW}Aňsat ulanmak üçin simwolik baglanyşyk döredilýär${NC} "
ln -sf /usr/local/bin/chatbot /usr/bin/chatbot > /dev/null 2>&1
echo -e " ${GREEN}✓${NC}"

# Täzeleme skripti
echo -ne "${YELLOW}Täzeleme skripti döredilýär${NC} "
cat > "$INSTALL_DIR/update.sh" << EOL
#!/bin/bash
# ChatBot täzeleme skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/update.sh | sudo bash
EOL
chmod +x "$INSTALL_DIR/update.sh"
echo -e " ${GREEN}✓${NC}"

# Hyzmaty başlat
echo -e "${YELLOW}Hyzmat başladylýar...${NC}"
systemctl daemon-reload &
PID=$!
spin $PID
wait $PID

systemctl enable chatbot.service > /dev/null 2>&1 &
PID=$!
spin $PID 
wait $PID

systemctl start chatbot.service &
PID=$!
progress_bar "Bot hyzmaty başladylýar" $PID 3
wait $PID

echo -e ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ChatBot üstünlikli guruldy!            ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║  Boty dolandyrmak üçin diňe ${YELLOW}chatbot${GREEN} diýip ýazyň  ║${NC}"
echo -e "${GREEN}║  Bot şu wagt işleýär we ulanmaga taýýar.      ║${NC}"
echo -e "${GREEN}║  Telegram-da \"/start\" buýrugy bilen botňyzy      ║${NC}"
echo -e "${GREEN}║  işlediň.                                      ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║  Dolandyryjy: hackedcdn                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"

# Biraz garaşmak üçin
sleep 3

# Aňsatlaşdyryjy habary görkez
echo -e "\n${YELLOW}WAJYP MAGLUMAT:${NC}"
echo -e "${CYAN}------------------------------${NC}"
echo -e "${CYAN}Dolandyryş buýruklary:${NC}"
echo -e "${GREEN}chatbot${NC} - Bot dolandyryş panelini açar"
echo -e "${GREEN}sudo su -c \"systemctl restart chatbot\"${NC} - Boty täzeden başlatmak"
echo -e "${GREEN}sudo su -c \"systemctl stop chatbot\"${NC} - Boty durdurmak"
echo -e "${GREEN}sudo su -c \"systemctl start chatbot\"${NC} - Boty başlatmak"
echo -e "${CYAN}------------------------------${NC}"
echo -e "${YELLOW}Häzir dolandyryş paneli 5 sekuntdan soň açylar...${NC}"

# 5 sekuntlap garaş we sekuntlary görkezilýär
for i in {5..1}; do
  echo -ne "${YELLOW}$i...${NC}\r"
  sleep 1
done

# Dolandyryş panelini awtomatiki aç
echo -e "${YELLOW}Dolandyryş paneli açylýar...${NC}"
sleep 1

echo -e "${GREEN}---------------------------------------------------------${NC}"
echo -e "${GREEN}DOLANDYRYŞ PANELI AÇYLÝAR, AZ GARAŞYŇ...${NC}"
echo -e "${GREEN}---------------------------------------------------------${NC}"
sleep 2

/usr/bin/chatbot 