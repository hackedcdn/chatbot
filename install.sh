#!/bin/bash

# ChatBot gurnalyş skripti
# Copyright (c) 2023-2024 hackedcdn

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # Reňki nol et

echo -e "${GREEN}ChatBot Gurnalyş Skripti${NC}"
echo "----------------------------------------"

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bu skripti root hökmünde işlediň (sudo ulanyň)${NC}"
  exit 1
fi

# Ulgam täzelenmesi
echo -e "${YELLOW}Ulgam täzelenýär...${NC}"
apt update && apt upgrade -y

# Zerur paketleriň gurnalyşy
echo -e "${YELLOW}Zerur paketler gurnalyar...${NC}"
apt install -y python3 python3-pip python3-venv git screen

# Gurnalyş katalogy
INSTALL_DIR="/opt/chatbot"

# Öňki gurnalyş barlagy
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Öňki gurnalyş tapyldy. Näme etmek isleýärsiňiz?${NC}"
  echo "1) Aýyr we täzeden gurna"
  echo "2) Çyk"
  read -p "Saýlawyňyz (1/2): " choice
  
  if [ "$choice" = "1" ]; then
    echo -e "${YELLOW}Öňki gurnalyş aýrylýar...${NC}"
    rm -rf "$INSTALL_DIR"
  else
    echo -e "${YELLOW}Gurnalyş ýatyryldy.${NC}"
    exit 0
  fi
fi

# Gurnalyş katalogyny döret
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Bot kodlaryny ýükle
echo -e "${YELLOW}Bot kodlary ýüklenýär...${NC}"
git clone https://github.com/hackedcdn/chatbot.git .

# Wirtual gurşaw döret we baglylyky guramalary gurna
echo -e "${YELLOW}Python wirtual gurşawy döredilýär...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Konfigurasiýa faýlyny döret
echo -e "${YELLOW}Konfigurasiýa faýly döredilýär...${NC}"
if [ ! -f ".env" ]; then
  echo -e "${GREEN}Bot konfigurasiýasyny sazlalyň${NC}"
  read -p "Telegram Bot Token: " bot_token
  read -p "MongoDB URI (mysaly: mongodb://localhost:27017): " mongodb_uri
  read -p "MongoDB Maglumat Bazasynyň Ady: " db_name
  read -p "Admin Ulanyjy ID: " admin_id
  
  cat > .env << EOL
BOT_TOKEN=$bot_token
MONGODB_URI=$mongodb_uri
DATABASE_NAME=$db_name
ADMIN_ID=$admin_id
EOL
  
  echo -e "${GREEN}Konfigurasiýa faýly üstünlikli döredildi${NC}"
else
  echo -e "${YELLOW}Bar bolan .env faýly goraldy${NC}"
fi

# Hyzmat faýlyny döret
echo -e "${YELLOW}Ulgam hyzmaty döredilýär...${NC}"
cat > /etc/systemd/system/chatbot.service << EOL
[Unit]
Description=ChatBot Telegram Bot Service
After=network.target

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
cat > /usr/local/bin/botpanel << EOL
#!/bin/bash

# ChatBot Dolandyryş Paneli
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "\${GREEN}ChatBot Dolandyryş Paneli\${NC}"
echo "----------------------------------------"

# Bot ýagdaýyny barla
if systemctl is-active --quiet chatbot.service; then
  echo -e "Bot Ýagdaýy: \${GREEN}Işleýär\${NC}"
else
  echo -e "Bot Ýagdaýy: \${RED}Durdurylan\${NC}"
fi

echo ""
echo "1) Boty başlat"
echo "2) Boty durdur"
echo "3) Boty täzeden başlat"
echo "4) Bot loglaryny görkez"
echo "5) Konfigurasiýany redaktirle"
echo "6) Boty täzele"
echo "7) Çykyş"
echo ""
read -p "Saýlawyňyz: " choice

case \$choice in
  1)
    systemctl start chatbot.service
    echo -e "\${GREEN}Bot başladyldy\${NC}"
    ;;
  2)
    systemctl stop chatbot.service
    echo -e "\${YELLOW}Bot durduryldy\${NC}"
    ;;
  3)
    systemctl restart chatbot.service
    echo -e "\${GREEN}Bot täzeden başladyldy\${NC}"
    ;;
  4)
    journalctl -u chatbot.service -f
    ;;
  5)
    nano $INSTALL_DIR/.env
    echo -e "\${YELLOW}Konfigurasiýa täzelendi, täzeden başladylýar...\${NC}"
    systemctl restart chatbot.service
    ;;
  6)
    cd $INSTALL_DIR
    git pull
    source venv/bin/activate
    pip install -r requirements.txt
    systemctl restart chatbot.service
    echo -e "\${GREEN}Bot täzelendi we täzeden başladyldy\${NC}"
    ;;
  7)
    exit 0
    ;;
  *)
    echo -e "\${RED}Nädogry saýlaw\${NC}"
    ;;
esac
EOL

# Dolandyryş paneli skriptini işledilýän et
chmod +x /usr/local/bin/botpanel

# Täzeleme skripti
echo -e "${YELLOW}Täzeleme skripti döredilýär...${NC}"
cat > "$INSTALL_DIR/update.sh" << EOL
#!/bin/bash
cd $INSTALL_DIR
git pull
source venv/bin/activate
pip install -r requirements.txt
systemctl restart chatbot.service
echo "ChatBot täzelendi"
EOL

chmod +x "$INSTALL_DIR/update.sh"

# Hyzmaty başlat
echo -e "${YELLOW}Hyzmat başladylýar...${NC}"
systemctl daemon-reload
systemctl enable chatbot.service
systemctl start chatbot.service

echo -e "${GREEN}ChatBot üstünlikli guruldy!${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}" 