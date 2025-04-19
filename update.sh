#!/bin/bash

# ChatBot täzeleme skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}ChatBot Täzeleme Skripti${NC}"
echo "----------------------------------------"

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bu skripti root hökmünde işlediň (sudo ulanyň)${NC}"
  exit 1
fi

# Gurnalyş katalogy
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

# Katalog barlagy
if [ ! -d "$INSTALL_DIR" ]; then
  echo -e "${RED}ChatBot gurnalyşy tapylmady. Ilki bilen gurnalyş skriptini işlediň.${NC}"
  exit 1
fi

# Hyzmatyň işleýändigini barla
if systemctl is-active --quiet $SERVICE_NAME; then
  BOT_RUNNING=true
  echo -e "${YELLOW}Bot hyzmaty wagtlaýyn durdurylýar...${NC}"
  systemctl stop $SERVICE_NAME
else
  BOT_RUNNING=false
  echo -e "${YELLOW}Bot hyzmaty işlemeýär, täzelemeden soň başlatylmaz.${NC}"
fi

# Git ambaryna geç
cd $INSTALL_DIR

# Bar bolan konfigurasiýany ätiýaçla
echo -e "${YELLOW}Konfigurasiýa faýllary ätiýaçlanýar...${NC}"
if [ -f ".env" ]; then
  cp .env .env.backup
fi

# Täzelemeleri çek
echo -e "${YELLOW}Täzelemeleri barlaýar...${NC}"
git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
  echo -e "${GREEN}ChatBot eýýäm iň soňky wersiýasyndadyr.${NC}"
else
  echo -e "${YELLOW}Täzelemeler bar. Täzelenýär...${NC}"
  
  # Repository-ni täzele
  git pull
  
  # Baglylyky guramalary täzele
  echo -e "${YELLOW}Baglylyky guramalary täzelenýär...${NC}"
  source venv/bin/activate
  pip install -r requirements.txt
  
  echo -e "${GREEN}ChatBot üstünlikli täzelendi!${NC}"
  
  # Wersiýa maglumatyny görkez
  if [ -f "version.txt" ]; then
    VERSION=$(cat version.txt)
    echo -e "${GREEN}Täzelenen wersiýa: ${VERSION}${NC}"
  fi
fi

# Ätiýaçlanan konfigurasiýany dikelt
if [ -f ".env.backup" ]; then
  cp .env.backup .env
  rm .env.backup
fi

# Eger işleýän bolsa, hyzmaty täzeden başlat
if [ "$BOT_RUNNING" = true ]; then
  echo -e "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC}"
  systemctl start $SERVICE_NAME
fi

echo -e "${GREEN}Prosess tamamlandy.${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}" 