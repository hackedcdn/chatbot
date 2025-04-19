#!/bin/bash

# ChatBot täzeleme skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

# Reňk kesgitlemeleri
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

clear
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

# Täzeleme prosesi başlady, animasiýaly
echo -e "${YELLOW}ChatBot täzeleme prosesi başlady!${NC}"
echo ""
echo -ne "${YELLOW}Täzeleme başlady...${NC}"
for i in {1..25}; do
  echo -ne "${GREEN}>${NC}"
  sleep 0.02
done
echo -e " ${GREEN}✓${NC}"

# Ulgamy täzele
echo -e "${YELLOW}Ulgam täzelenýär...${NC}"
apt update > /dev/null 2>&1 &
PID=$!
progress_bar "Ulgam maglumatlary täzelenýär" $PID 3
wait $PID

apt upgrade -y > /dev/null 2>&1 &
PID=$!
progress_bar "Ulgam paketleri täzelenýär" $PID 5
wait $PID

echo -ne "${YELLOW}Ulgam artykmaç paketleri aýrylýar${NC} "
apt autoremove -y > /dev/null 2>&1 &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

# MongoDB ýagdaýyny barla
if ! systemctl is-active --quiet mongod; then
  echo -ne "${YELLOW}MongoDB işlemeýär, işledilýär...${NC} "
  systemctl start mongod > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  
  systemctl enable mongod > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
fi

# Hyzmatyň işleýändigini barla
if systemctl is-active --quiet $SERVICE_NAME; then
  BOT_RUNNING=true
  echo -ne "${YELLOW}Bot hyzmaty wagtlaýyn durdurylýar...${NC} "
  systemctl stop $SERVICE_NAME > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
else
  BOT_RUNNING=false
  echo -e "${YELLOW}Bot hyzmaty işlemeýär, täzelemeden soň awtomatiki başladyljakdyr.${NC}"
fi

# Git ambaryna geç
cd $INSTALL_DIR

# Bar bolan konfigurasiýany ätiýaçla
echo -ne "${YELLOW}Konfigurasiýa faýllary ätiýaçlanýar...${NC} "
if [ -f ".env" ]; then
  cp .env .env.backup &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
fi

# Zerur paketleri ýükle
echo -ne "${YELLOW}Gerekli Python paketleri täzelenýär...${NC} "
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1 &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

# Täzelemeleri çek
echo -ne "${YELLOW}Täzelemeleri barlaýar...${NC} "
git fetch origin > /dev/null 2>&1 &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
  echo -e "${GREEN}ChatBot eýýäm iň soňky wersiýasyndadyr.${NC}"
else
  echo -e "${YELLOW}Täzelemeler bar. Ulgam awtomatiki täzelenýär...${NC}"
  
  # Repository-ni täzele
  echo -ne "${YELLOW}Täzelemeler ýüklenýär...${NC} "
  git pull > /dev/null 2>&1 &
  PID=$!
  progress_bar "Kod täzelenýär" $PID 3
  wait $PID
  
  # Baglylyky guramalary täzele
  echo -ne "${YELLOW}Baglylyky guramalary täzelenýär...${NC} "
  pip install -r requirements.txt > /dev/null 2>&1 &
  PID=$!
  progress_bar "Python paketleri täzelenýär" $PID 4
  wait $PID
  
  echo -e "${GREEN}ChatBot üstünlikli täzelendi!${NC}"
  
  # Wersiýa maglumatyny görkez
  if [ -f "version.txt" ]; then
    VERSION=$(cat version.txt)
    echo -e "${GREEN}Täzelenen wersiýa: ${CYAN}$VERSION${NC}"
  fi

  # Dolandyryş buýrugyny täzele
  echo -ne "${YELLOW}Dolandyryş buýrugyny täzeleýär...${NC} "
  cp -f panel.sh /usr/local/bin/chatbot > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  
  chmod +x /usr/local/bin/chatbot &
  PID=$!
  spin $PID
  wait $PID
  
  ln -sf /usr/local/bin/chatbot /usr/bin/chatbot > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
fi

# Ätiýaçlanan konfigurasiýany dikelt
if [ -f ".env.backup" ]; then
  echo -ne "${YELLOW}Konfigurasiýa faýllary dikeldilýär...${NC} "
  cp .env.backup .env &
  PID=$!
  spin $PID
  wait $PID
  
  rm .env.backup &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
fi

# Hyzmatlary täzele
echo -ne "${YELLOW}Hyzmatlar täzelenýär...${NC} "
systemctl daemon-reload &
PID=$!
spin $PID
wait $PID
echo -e " ${GREEN}✓${NC}"

# Eger işlemeýän bolsa ýa-da updater ýapylan bolsa, boty işlet
if [ "$BOT_RUNNING" = true ] || [ "$BOT_RUNNING" = false ]; then
  echo -ne "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC} "
  systemctl start $SERVICE_NAME > /dev/null 2>&1 &
  PID=$!
  progress_bar "Bot işledilýär" $PID 2
  wait $PID
  
  systemctl enable $SERVICE_NAME > /dev/null 2>&1 &
  PID=$!
  spin $PID
  wait $PID

  # Bot ýagdaýyny barla
  if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e " ${GREEN}Bot hyzmaty üstünlikli işleýär!${NC}"
  else
    echo -e " ${RED}Bot hyzmatyny başlatmak bolmady. Ýagdaýy barlap görüň.${NC}"
  fi
fi

echo -e ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      ChatBot we ulgam täzelemesi tamamlandy    ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║  Boty dolandyrmak üçin diňe ${YELLOW}chatbot${GREEN} diýip ýazyň  ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║  Dolandyryjy: hackedcdn                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}" 