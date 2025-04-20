#!/bin/bash

# ChatBot çalt düzediji skript
# Bu faýl install.sh skriptindäki token we ID meselesini çözýär

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Reňki nol et

# Ekrany arassala
clear

echo -e "${BLUE}"
echo "  ____ _           _   ____        _     ______ _       "
echo " / ___| |__   __ _| |_| __ )  ___ | |_  |  ___(_)_  __ "
echo "| |   | '_ \ / _\` | __|  _ \ / _ \| __| | |_  | \ \/ / "
echo "| |___| | | | (_| | |_| |_) | (_) | |_  |  _| | |>  <  "
echo " \____|_| |_|\__,_|\__|____/ \___/ \__| |_|   |_/_/\_\ "
echo -e "${NC}"
echo -e "${GREEN}ChatBot Çalt Düzediji Skript${NC}"
echo "----------------------------------------"

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bu skripti root hökmünde işlediň gerek.${NC}"
  echo -e "${GREEN}sudo bash quickfix.sh${NC}"
  exit 1
fi

# Ulgam ýerlerini kesgitle
INSTALL_DIR="/opt/chatbot"
ENV_FILE="$INSTALL_DIR/.env"
SERVICE_FILE="/etc/systemd/system/chatbot.service"

# .env faýly barmy?
if [ ! -d "$INSTALL_DIR" ]; then
  echo -e "${RED}Chatbot gurnalyşy tapylmady. Ilki bilen gurnalyş skriptini işlediň.${NC}"
  exit 1
fi

# Token alma funksiýasy
get_token() {
  local token=""
  
  while true; do
    echo -e "${YELLOW}Telegram Bot Token alynýar...${NC}"
    echo -e "${GREEN}1. https://t.me/BotFather açyň${NC}"
    echo -e "${GREEN}2. /newbot buýrugy bilen täze bot dörediň${NC}"
    echo -e "${GREEN}3. Bot adyny we ulanyjy adyny giriziň${NC}"
    echo -e "${GREEN}4. BotFather-den gelen tokeni göçürip alyň${NC}"
    echo -e "${RED}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Botfather-den alnan tokeniňizi ýazyň${NC}"
    echo -e "${RED}BU ADYMDA GIRIŞ ETMEGIŇIZ HÖKMAN ZERUR!${NC}"
    echo -e "${RED}---------------------------------------------------------------------${NC}"
    
    echo -n "Token: "
    read -r token
    
    if [[ -n "$token" && "$token" == *":"* ]]; then
      break
    else
      echo -e "${RED}Nädogry format! Täzeden synanyşyň.${NC}"
      sleep 2
    fi
  done
  
  echo "$token"
}

# Admin ID alma funksiýasy
get_admin_id() {
  local admin_id=""
  
  while true; do
    echo -e "${YELLOW}Admin ID alynýar...${NC}"
    echo -e "${GREEN}1. Öz Telegram hasabyňyzda https://t.me/myidbot açyň${NC}"
    echo -e "${GREEN}2. /getid buýrugy iberiň${NC}"
    echo -e "${GREEN}3. Bot berýän ID belgiňizi göçürip alyň${NC}"
    echo -e "${RED}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Öz Telegram ID belgiňizi ýazyň${NC}"
    echo -e "${RED}BU ADYMDA GIRIŞ ETMEGIŇIZ HÖKMAN ZERUR!${NC}"
    echo -e "${RED}---------------------------------------------------------------------${NC}"
    
    echo -n "Admin ID: "
    read -r admin_id
    
    if [[ -n "$admin_id" && "$admin_id" =~ ^[0-9]+$ ]]; then
      break
    else
      echo -e "${RED}Nädogry format! Täzeden synanyşyň.${NC}"
      sleep 2
    fi
  done
  
  echo "$admin_id"
}

# Ulgamyň abatlygyny barla
check_system() {
  echo -e "${YELLOW}Ulgam barlanýar...${NC}"
  
  # Bot faýly barmy
  if [ ! -f "$INSTALL_DIR/bot.py" ]; then
    echo -e "${RED}Bot faýly tapylmady. Täzeden gurnamak gerek.${NC}"
    exit 1
  fi
  
  # Hyzmat faýly barmy
  if [ ! -f "$SERVICE_FILE" ]; then
    echo -e "${YELLOW}Hyzmat faýly tapylmady. Täze faýl dörediler.${NC}"
    cat > "$SERVICE_FILE" << EOL
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
    systemctl daemon-reload
  fi
  
  echo -e "${GREEN}Ulgam barlagy tamamlandy.${NC}"
}

# Konfigurasiýa faýlyny döret
create_env_file() {
  local token="$1"
  local admin_id="$2"
  
  echo -e "${YELLOW}Konfigurasiýa faýly döredilýär...${NC}"
  
  # .env faýlyny ýaz
  echo "BOT_TOKEN=$token" > "$ENV_FILE"
  echo "ADMIN_ID=$admin_id" >> "$ENV_FILE"
  echo "MONGODB_URI=mongodb://localhost:27017" >> "$ENV_FILE"
  echo "DATABASE_NAME=chatbot_db" >> "$ENV_FILE"
  
  # Rugsat beriji et
  chmod 644 "$ENV_FILE"
  
  echo -e "${GREEN}Konfigurasiýa faýly döredildi!${NC}"
}

# Hyzmat işleýändigini barla
restart_service() {
  echo -e "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC}"
  
  systemctl daemon-reload
  systemctl restart chatbot.service
  
  sleep 3
  
  if systemctl is-active --quiet chatbot.service; then
    echo -e "${GREEN}Bot hyzmaty işleýär!${NC}"
  else
    echo -e "${RED}Bot hyzmatyny başladylyp bilinmedi. Log faýlyny barlap görüň.${NC}"
    echo -e "${YELLOW}systemctl status chatbot.service${NC}"
  fi
}

# Ana funksiýa
main() {
  echo -e "${YELLOW}Chatbot düzedilýär...${NC}"
  
  # Ulgamy barla
  check_system
  
  # Token we admin ID al
  echo -e "${YELLOW}Bot tokenini we admin ID-ni giriziň...${NC}"
  local token=$(get_token)
  local admin_id=$(get_admin_id)
  
  # Konfigurasiýa faýlyny döret
  create_env_file "$token" "$admin_id"
  
  # Hyzmaty täzeden başlat
  restart_service
  
  echo -e "${GREEN}Düzediş tamamlandy!${NC}"
  echo -e "${YELLOW}Telegram-da boty synap görüň.${NC}"
}

# Skripti başlat
main

echo -e "${GREEN}Tamamlandy! Dolandyryş paneli açylýar...${NC}"
sleep 2

# Panel işledip bilinerinmi?
if [ -f "/usr/bin/chatbot" ]; then
  /usr/bin/chatbot
else
  echo -e "${YELLOW}Dolandyryş paneli tapylmady. El bilen boty işlediň:${NC}"
  echo -e "${GREEN}systemctl start chatbot.service${NC}"
fi
