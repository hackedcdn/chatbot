#!/bin/bash

# ChatBot täzeleme skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "   _____ _           _   ____        _   "
echo "  / ____| |         | | |  _ \      | |  "
echo " | |    | |__   __ _| |_| |_) | ___ | |_ "
echo " | |    | '_ \ / _\` | __|  _ < / _ \| __|"
echo " | |____| | | | (_| | |_| |_) | (_) | |_ "
echo "  \_____|_| |_|\__,_|\__|____/ \___/ \__|"
echo -e "${NC}"
echo -e "${GREEN}ChatBot Awtomatiki Täzeleme Skripti${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}"
echo "----------------------------------------"

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bu skripti root hökmünde işlediň (sudo ulanyň)${NC}"
  echo -e "${YELLOW}Buýruk: sudo curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/update.sh | sudo bash${NC}"
  exit 1
fi

# Gurnalyş katalogy
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

# Katalog barlagy
if [ ! -d "$INSTALL_DIR" ]; then
  echo -e "${RED}ChatBot gurnalyşy tapylmady. Ulgam awtomatiki gurnalyşy başladyar...${NC}"
  curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/install.sh | bash
  exit 0
fi

# Ulgamy täzele
echo -e "${YELLOW}Ulgam täzelenýär...${NC}"
apt update > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1
apt autoremove -y > /dev/null 2>&1

# MongoDB ýagdaýyny barla
if ! systemctl is-active --quiet mongod; then
  echo -e "${YELLOW}MongoDB işlemeýär, işledilýär...${NC}"
  systemctl start mongod > /dev/null 2>&1
  systemctl enable mongod > /dev/null 2>&1
fi

# Hyzmatyň işleýändigini barla
if systemctl is-active --quiet $SERVICE_NAME; then
  BOT_RUNNING=true
  echo -e "${YELLOW}Bot hyzmaty wagtlaýyn durdurylýar...${NC}"
  systemctl stop $SERVICE_NAME > /dev/null 2>&1
else
  BOT_RUNNING=false
  echo -e "${YELLOW}Bot hyzmaty işlemeýär, täzelemeden soň awtomatiki başladyljakdyr.${NC}"
fi

# Git ambaryna geç
cd $INSTALL_DIR

# Bar bolan konfigurasiýany ätiýaçla
echo -e "${YELLOW}Konfigurasiýa faýllary ätiýaçlanýar...${NC}"
if [ -f ".env" ]; then
  cp .env .env.backup
fi

# Zerur paketleri ýükle
echo -e "${YELLOW}Gerekli Python paketleri täzelenýär...${NC}"
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1

# Täzelemeleri çek
echo -e "${YELLOW}Täzelemeleri barlaýar...${NC}"
git fetch origin > /dev/null 2>&1
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
  echo -e "${GREEN}ChatBot eýýäm iň soňky wersiýasyndadyr.${NC}"
else
  echo -e "${YELLOW}Täzelemeler bar. Ulgam awtomatiki täzelenýär...${NC}"
  
  # Repository-ni täzele
  git pull > /dev/null 2>&1
  
  # Baglylyky guramalary täzele
  echo -e "${YELLOW}Baglylyky guramalary täzelenýär...${NC}"
  pip install -r requirements.txt > /dev/null 2>&1
  
  echo -e "${GREEN}ChatBot üstünlikli täzelendi!${NC}"
  
  # Wersiýa maglumatyny görkez
  if [ -f "version.txt" ]; then
    VERSION=$(cat version.txt)
    echo -e "${GREEN}Täzelenen wersiýa: ${VERSION}${NC}"
  fi

  # Dolandyryş buýrugyny täzele
  echo -e "${YELLOW}Dolandyryş buýrugyny täzeleýär...${NC}"
  cp -f panel.sh /usr/local/bin/chatbot > /dev/null 2>&1
  chmod +x /usr/local/bin/chatbot > /dev/null 2>&1
  ln -sf /usr/local/bin/chatbot /usr/bin/chatbot > /dev/null 2>&1
fi

# Ätiýaçlanan konfigurasiýany dikelt
if [ -f ".env.backup" ]; then
  cp .env.backup .env
  rm .env.backup
fi

# Hyzmatlary täzele
echo -e "${YELLOW}Hyzmatlar täzelenýär...${NC}"
systemctl daemon-reload

# Eger işlemeýän bolsa ýa-da updater ýapylan bolsa, boty işlet
if [ "$BOT_RUNNING" = true ] || [ "$BOT_RUNNING" = false ]; then
  echo -e "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC}"
  systemctl start $SERVICE_NAME > /dev/null 2>&1
  systemctl enable $SERVICE_NAME > /dev/null 2>&1

  # Bot ýagdaýyny barla
  if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}Bot hyzmaty üstünlikli işleýär!${NC}"
  else
    echo -e "${RED}Bot hyzmatyny başlatmak bolmady. Ýagdaýy barlap görüň.${NC}"
  fi
fi

echo -e "${GREEN}----------------------------------------${NC}"
echo -e "${GREEN}ChatBot we ulgam täzelemesi tamamlandy.${NC}"
echo -e "${GREEN}Boty dolandyrmak üçin 'chatbot' buýrugyny ulanyp bilersiňiz.${NC}"
echo -e "${GREEN}----------------------------------------${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}" 