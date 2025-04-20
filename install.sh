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
  echo -e "${RED}---------------------------------------------------------------------${NC}"
  echo -e "${YELLOW}Botfather-den alnan tokeniňizi ýazyň${NC}"
  echo -e "${RED}BU ADYMDA GIRIŞ ETMEGIŇIZ HÖKMAN ZERUR!${NC}"
  echo -e "${RED}---------------------------------------------------------------------${NC}"
  read -e -p "Token: " token
  
  # Boş ýa-da nädogry token barlagy
  while [[ -z "$token" || "$token" != *":"* ]]; do
    echo -e "${RED}Nädogry format! Token umuman 'xxxxxxx:yyyyyyyyyyy' görnüşinde bolmaly.${NC}"
    echo -e "${YELLOW}Dogry tokeni giriziň ýa-da ${RED}CTRL+C${YELLOW} düwmesine basyp çykyň:${NC}"
    read -e -p "Token: " token
  done
  
  echo "$token"
}

get_admin_id() {
  echo -e "${YELLOW}Admin ID alynýar...${NC}"
  echo -e "${GREEN}1. Öz Telegram hasabyňyzda https://t.me/myidbot açyň${NC}"
  echo -e "${GREEN}2. /getid buýrugy iberiň${NC}"
  echo -e "${GREEN}3. Bot berýän ID belgiňizi göçürip alyň${NC}"
  echo -e "${RED}---------------------------------------------------------------------${NC}"
  echo -e "${YELLOW}Öz Telegram ID belgiňizi ýazyň${NC}"
  echo -e "${RED}BU ADYMDA GIRIŞ ETMEGIŇIZ HÖKMAN ZERUR!${NC}"
  echo -e "${RED}---------------------------------------------------------------------${NC}"
  read -e -p "Admin ID: " admin_id
  
  # Diňe san barlagy
  while [[ -z "$admin_id" || ! "$admin_id" =~ ^[0-9]+$ ]]; do
    echo -e "${RED}Nädogry format! Admin ID diňe sanlardan ybarat bolmaly.${NC}"
    echo -e "${YELLOW}Dogry ID giriziň ýa-da ${RED}CTRL+C${YELLOW} düwmesine basyp çykyň:${NC}"
    read -e -p "Admin ID: " admin_id
  done
  
  echo "$admin_id"
}

# Gurnalyş wagtynda ähli näsazlyklary awtomatiki düzet
autofix_all_issues() {
  echo -e "${YELLOW}Ulgam awtomatiki barlanýar we konfigurasiýa täzelenýär...${NC}"
  
  # MongoDB işleýşini barla we düzet
  echo -ne "${YELLOW}MongoDB ýagdaýy barlanýar... ${NC}"
  if ! systemctl is-active --quiet mongod; then
    echo -e "${RED}MongoDB işlemeýär!${NC}"
    echo -ne "${YELLOW}MongoDB işledilýär... ${NC}"
    systemctl start mongod || true
    sleep 3
    
    if ! systemctl is-active --quiet mongod; then
      echo -e "${RED}MongoDB işledilip bilinmedi. Täzeden gurnamaga synanyşylýar.${NC}"
      
      # Ulgamyň distro kesgitle
      if [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        CODENAME=$DISTRIB_CODENAME
      elif [ -f /etc/os-release ]; then
        source /etc/os-release
        CODENAME=$(lsb_release -cs 2>/dev/null || echo "focal")
      else
        CODENAME="focal"
      fi
      
      # MongoDB depo açaryny al
      apt-key del 656408E390CFB1F5 > /dev/null 2>&1 || true
      apt-key del 6D9BEB20FB066DF1 > /dev/null 2>&1 || true
      wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - > /dev/null 2>&1 || true
      
      # MongoDB depo listi döret
      echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $CODENAME/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 || true
      
      # Paketleri täzele we MongoDB gurna
      apt-get update > /dev/null 2>&1 || true
      apt-get install -y mongodb-org > /dev/null 2>&1 || true
      
      # MongoDB serwis faýlyny döret (ýok bolsa)
      if [ ! -f /lib/systemd/system/mongod.service ]; then
        cat > /lib/systemd/system/mongod.service << EOMONGOSERVICE
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network-online.target
Wants=network-online.target

[Service]
User=mongodb
Group=mongodb
EnvironmentFile=-/etc/default/mongod
ExecStart=/usr/bin/mongod --config /etc/mongod.conf
PIDFile=/var/run/mongodb/mongod.pid
LimitFSIZE=infinity
LimitCPU=infinity
LimitAS=infinity
LimitNOFILE=64000
LimitNPROC=64000
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOMONGOSERVICE
      fi
      
      # Systemd täzelep, MongoDB işlet
      systemctl daemon-reload > /dev/null 2>&1 || true
      systemctl enable mongod > /dev/null 2>&1 || true
      systemctl start mongod > /dev/null 2>&1 || true
      sleep 3
    fi
  fi
  
  if systemctl is-active --quiet mongod; then
    echo -e "${GREEN}MongoDB işleýär ✓${NC}"
  else
    echo -e "${RED}MongoDB gurnamak bolmady. Panel açylanda awtomatiki düzediler.${NC}"
  fi
  
  echo -e "${GREEN}Ulgam awtomatiki sazlama tamamlandy ✓${NC}"
}

# Awtomatiki dogry .env faýlyny döret
create_correct_env_file() {
  ENV_FILE="$INSTALL_DIR/.env"
  echo -e "${YELLOW}Dogry formatda .env faýly döredilýär...${NC}"
  
  # Konfigurasiýa faýly dogry formatda döret
  echo "BOT_TOKEN=$telegram_token" > "$ENV_FILE"
  echo "MONGODB_URI=mongodb://localhost:27017" >> "$ENV_FILE"
  echo "DATABASE_NAME=chatbot_db" >> "$ENV_FILE"
  echo "ADMIN_ID=$admin_id" >> "$ENV_FILE"
  
  # Faýl rugsat hukuklary düzet
  chmod 644 "$ENV_FILE"
  
  # Barlag ýagdaýda, ".env.test" hem döret 
  echo "BOT_TOKEN=$telegram_token" > "$INSTALL_DIR/.env.test"
  echo "MONGODB_URI=mongodb://localhost:27017" >> "$INSTALL_DIR/.env.test"
  echo "DATABASE_NAME=chatbot_db" >> "$INSTALL_DIR/.env.test"
  echo "ADMIN_ID=$admin_id" >> "$INSTALL_DIR/.env.test"
  
  # bot.py faýlyny düzet - .env formaty üýtget, ýalňyşlyk bar bolsa täze .env üçin barla
  if [ -f "$INSTALL_DIR/bot.py" ]; then
    # .env.test ulanmagy üçin ýa-da .env-iň barlygy ätiýaçlyk bilen barla
    sed -i 's/load_dotenv()/try:\n    load_dotenv()\nexcept Exception:\n    try:\n        load_dotenv(".env.test")\n    except Exception:\n        pass/' "$INSTALL_DIR/bot.py" || true
    
    # int() çevirimi bilen mesele bar bolsa, ADMIN_ID-ni almak işini düzet
    sed -i 's/ADMIN_ID = int(os.getenv("ADMIN_ID", 0))/try:\n    admin_id_str = os.getenv("ADMIN_ID", "0").strip()\n    ADMIN_ID = int(admin_id_str) if admin_id_str else 0\nexcept ValueError:\n    ADMIN_ID = 0/' "$INSTALL_DIR/bot.py" || true
  fi
  
  echo -e "${GREEN}Konfigurasiýa faýly düzgün döredildi✓${NC}"
}

# MongoDB gurnalyşy
install_mongodb() {
  echo -e "${YELLOW}MongoDB gurnalyşy başladylýar...${NC}"
  
  # MongoDB gurnalandygyny barla
  if command -v mongod &> /dev/null; then
    echo -e "${GREEN}MongoDB eýýäm gurnalandyr!${NC}"
    
    # MongoDB serweriniň işleýändigini barla
    if systemctl is-active --quiet mongod || systemctl is-active --quiet mongodb; then
      echo -e "${GREEN}MongoDB serweri işleýär.${NC}"
      return 0
    else
      echo -e "${YELLOW}MongoDB serweri işlemeýär. Işledilýär...${NC}"
      if systemctl start mongod 2>/dev/null || systemctl start mongodb 2>/dev/null; then
        echo -e "${GREEN}MongoDB serweri üstünlikli işledildi!${NC}"
        return 0
      else
        echo -e "${RED}MongoDB serwerini işledip bolmady. Täzeden gurnamaga synanyşylýar...${NC}"
      fi
    fi
  fi
  
  echo -e "${YELLOW}MongoDB gurnalyar...${NC}"
  
  # Ulgam görnüşini anykla
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_TYPE=$ID
  else
    OS_TYPE="unknown"
  fi
  
  case $OS_TYPE in
    ubuntu|debian)
      # MongoDB açar faýlyny al
      echo -ne "${YELLOW}MongoDB açar faýly alynýar...${NC} "
      wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - > /dev/null 2>&1 || true
      echo -e " ${GREEN}✓${NC}"
      
      # MongoDB depo listi döret
      echo -ne "${YELLOW}MongoDB depo listi goşulýar...${NC} "
      if [ "$OS_TYPE" = "ubuntu" ]; then
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 || true
      else 
        echo "deb http://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 || true
      fi
      echo -e " ${GREEN}✓${NC}"
      
      # Depony täzelä
      echo -ne "${YELLOW}Depolar täzelenýär...${NC} "
      apt-get update -y > /dev/null 2>&1 || true
      echo -e " ${GREEN}✓${NC}"
      
      # MongoDB gurna
      echo -e "${YELLOW}MongoDB gurnalyar...${NC}"
      apt-get install -y mongodb-org > /dev/null 2>&1 || apt-get install -y mongodb > /dev/null 2>&1 || true
      
      # Serwis gurulşyny barla
      if [ ! -f /lib/systemd/system/mongod.service ] && [ ! -f /etc/systemd/system/mongod.service ]; then
        echo -ne "${YELLOW}MongoDB serwisi döredilýär...${NC} "
        cat > /etc/systemd/system/mongod.service << EOMONGOSERVICE
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network-online.target
Wants=network-online.target

[Service]
User=mongodb
Group=mongodb
EnvironmentFile=-/etc/default/mongod
ExecStart=/usr/bin/mongod --config /etc/mongod.conf
PIDFile=/var/run/mongodb/mongod.pid
LimitFSIZE=infinity
LimitCPU=infinity
LimitAS=infinity
LimitNOFILE=64000
LimitNPROC=64000
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOMONGOSERVICE
        echo -e " ${GREEN}✓${NC}"
      fi
      
      # MongoDB serwisini başlat
      echo -ne "${YELLOW}MongoDB serwisi işledilýär...${NC} "
      systemctl daemon-reload > /dev/null 2>&1
      systemctl enable mongod > /dev/null 2>&1 || systemctl enable mongodb > /dev/null 2>&1
      systemctl start mongod > /dev/null 2>&1 || systemctl start mongodb > /dev/null 2>&1
      echo -e " ${GREEN}✓${NC}"
      ;;
      
    centos|fedora|rhel)
      # MongoDB repo faýly
      echo -ne "${YELLOW}MongoDB depo faýly döredilýär...${NC} "
      cat > /etc/yum.repos.d/mongodb-org-6.0.repo << EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF
      echo -e " ${GREEN}✓${NC}"
      
      # MongoDB gurna
      echo -e "${YELLOW}MongoDB gurnalyar...${NC}"
      yum install -y mongodb-org > /dev/null 2>&1 || true
      
      # MongoDB serwisini başlat
      echo -ne "${YELLOW}MongoDB serwisi işledilýär...${NC} "
      systemctl daemon-reload > /dev/null 2>&1
      systemctl enable mongod > /dev/null 2>&1
      systemctl start mongod > /dev/null 2>&1
      echo -e " ${GREEN}✓${NC}"
      ;;
      
    *)
      # Dogry MongoDB gurnamak üçin alternatiw ýol
      echo -e "${YELLOW}Bu ulgamda awtomatiki MongoDB gurnalyp bilinmedi.${NC}"
      echo -e "${YELLOW}Alternatiw ýol bilen MongoDB gurnamak synanyşylýar...${NC}"
      
      # Basit mongodb kurulumu
      apt-get update -y > /dev/null 2>&1 || true
      apt-get install -y mongodb > /dev/null 2>&1 || true
      
      if command -v mongod &> /dev/null; then
        echo -e "${GREEN}MongoDB üstünlikli guruldy!${NC}"
        systemctl enable mongodb > /dev/null 2>&1 || true
        systemctl start mongodb > /dev/null 2>&1 || true
      else
        echo -e "${RED}MongoDB gurnamak bolmady. Bot SQLite bilen işlejekdir.${NC}"
      fi
      ;;
  esac
  
  # Işleýşini barla
  sleep 5  # MongoDB-niň başlamasy üçin garaş
  
  if systemctl is-active --quiet mongod || systemctl is-active --quiet mongodb; then
    echo -e "${GREEN}MongoDB serweri üstünlikli işledildi!${NC}"
    return 0
  else 
    echo -e "${RED}MongoDB serwerini işledip bolmady. Bot SQLite bilen işlejekdir.${NC}"
    return 1
  fi
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
  for package in python3 python3-pip python3-venv git screen curl wget bc gnupg lsb-release python3-dev; do
    echo -ne "${YELLOW}Guralýar: ${CYAN}$package${NC} "
    apt install -y $package > /dev/null 2>&1 &
    PID=$!
    spin $PID
    wait $PID
    echo -e " ${GREEN}✓${NC}"
  done
  
  # MongoDB gurnalyşy
  install_mongodb
  
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

# Konfigurasiýany dogry formatda ýaz
create_correct_env_file

# .env faýly dogry döredilendigi barla
if [ -f "$INSTALL_DIR/.env" ]; then
  echo -e "${GREEN}.env faýly üstünlikli döredildi ✓${NC}"
  cat "$INSTALL_DIR/.env"
else
  # Ýönekeý usul bilen täzeden döret
  echo "BOT_TOKEN=$telegram_token" > $INSTALL_DIR/.env
  echo "MONGODB_URI=mongodb://localhost:27017" >> $INSTALL_DIR/.env
  echo "DATABASE_NAME=chatbot_db" >> $INSTALL_DIR/.env
  echo "ADMIN_ID=$admin_id" >> $INSTALL_DIR/.env
  echo -e "${YELLOW}Konfigurasiýa faýly standart formatda döredildi.${NC}"
fi

# Aýdyňlaşdyryjy habar - awtomatiki işlemeýän ýagdaýda 
if [ "$telegram_token" = "TOKEN_PLACEHOLDER" ] || [ "$admin_id" = "123456789" ]; then
  echo -e "${YELLOW}╔════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║       WAJYP KONFIGURASIÝA MAGLUMATLARY         ║${NC}"
  echo -e "${YELLOW}║                                                ║${NC}"
  if [ "$telegram_token" = "TOKEN_PLACEHOLDER" ]; then
    echo -e "${YELLOW}║  ${RED}• Bot tokeni girizilmedi!${NC}                    ║${NC}"
  fi
  if [ "$admin_id" = "123456789" ]; then
    echo -e "${YELLOW}║  ${RED}• Admin ID girizilmedi!${NC}                      ║${NC}"
  fi
  echo -e "${YELLOW}║                                                ║${NC}"
  echo -e "${YELLOW}║  Botdan peýdalanmak üçin:                      ║${NC}"
  echo -e "${YELLOW}║  ${GREEN}• Dolandyryş paneli açyň: ${CYAN}chatbot${NC}             ║${NC}"
  echo -e "${YELLOW}║  ${GREEN}• \"7) Konfigurasiýany redaktirle\" saýlaň${NC}       ║${NC}"
  echo -e "${YELLOW}║  ${GREEN}• Bot tokeni we Admin ID-ňizi giriziň${NC}          ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════════════╝${NC}"
  
  # Birleşdirilmek islenýän ýagdaýynda, wagt gaçyrma
  echo -e "${YELLOW}Bu habar 10 sekuntdan soň awtomatiki ýapylar${NC}"
  sleep 10
fi

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

# Awtomatiki düzeltme üçin Python skriptini ýükle (eger ýok bolsa)
if [ ! -f "$INSTALL_DIR/fix_configs.py" ]; then
  cat > "$INSTALL_DIR/fix_configs.py" << EOPYTHON
#!/usr/bin/env python3
import os
import re
import sys

# Ana .env dosyasının yolunu belirtin
env_file = "/opt/chatbot/.env"
env_backup = "/opt/chatbot/.env.backup"

# .env dosyası var mı kontrol et
if os.path.exists(env_file):
    try:
        # Yedek al
        os.system(f"cp {env_file} {env_backup}")
        
        # Dosyayı oku
        with open(env_file, 'r') as f:
            content = f.read()
        
        # Düzeltilmiş içeriği hazırla
        fixed_content = ""
        
        # Token ve Admin ID değerlerini çıkar
        token_match = re.search(r'BOT_TOKEN[=:](.*?)[\n\r]', content + "\n")
        mongo_match = re.search(r'MONGO.*URI[=:](.*?)[\n\r]', content + "\n")
        db_match = re.search(r'DATABASE.*NAME[=:](.*?)[\n\r]', content + "\n")
        admin_match = re.search(r'ADMIN.*ID[=:](.*?)[\n\r]', content + "\n")
        
        bot_token = token_match.group(1).strip() if token_match else "TOKEN_PLACEHOLDER"
        mongodb_uri = mongo_match.group(1).strip() if mongo_match else "mongodb://localhost:27017"
        db_name = db_match.group(1).strip() if db_match else "chatbot_db"
        admin_id = admin_match.group(1).strip() if admin_match else "123456789"
        
        # Gereksiz karakterleri temizle
        bot_token = re.sub(r'[^a-zA-Z0-9\.:_-]', '', bot_token)
        mongodb_uri = re.sub(r'[^a-zA-Z0-9\.:_\/@-]', '', mongodb_uri)
        db_name = re.sub(r'[^a-zA-Z0-9\.:_-]', '', db_name)
        admin_id = re.sub(r'[^0-9]', '', admin_id)
        
        # Düzgün .env dosyası oluştur
        with open(env_file, 'w') as f:
            f.write(f"BOT_TOKEN={bot_token}\n")
            f.write(f"MONGODB_URI={mongodb_uri}\n")
            f.write(f"DATABASE_NAME={db_name}\n")
            f.write(f"ADMIN_ID={admin_id}\n")
        
        print("Konfigürasyon dosyası başarıyla düzeltildi.")
        
    except Exception as e:
        print(f"Hata oluştu: {str(e)}")
        # Hata durumunda yeni bir dosya oluştur
        with open(env_file, 'w') as f:
            f.write("BOT_TOKEN=TOKEN_PLACEHOLDER\n")
            f.write("MONGODB_URI=mongodb://localhost:27017\n")
            f.write("DATABASE_NAME=chatbot_db\n")
            f.write("ADMIN_ID=123456789\n")
else:
    # Dosya yoksa yeni bir tane oluştur
    with open(env_file, 'w') as f:
        f.write("BOT_TOKEN=TOKEN_PLACEHOLDER\n")
        f.write("MONGODB_URI=mongodb://localhost:27017\n")
        f.write("DATABASE_NAME=chatbot_db\n")
        f.write("ADMIN_ID=123456789\n")
    print("Yeni konfigürasyon dosyası oluşturuldu.")

# İzinleri düzelt
os.system(f"chmod 644 {env_file}")
EOPYTHON

  chmod +x "$INSTALL_DIR/fix_configs.py"
fi

# Hyzmaty başlatmadan öňürdip, konfigurasiýany awtomatiki barla we düzet
python3 "$INSTALL_DIR/fix_configs.py" > /dev/null 2>&1 || true

systemctl start chatbot.service &
PID=$!
progress_bar "Bot hyzmaty başladylýar" $PID 3
wait $PID

# Başlandymy?
if ! systemctl is-active --quiet chatbot.service; then
  echo -e "${RED}Bot hyzmaty başladylyp bilinmedi. Awtomatiki täzelenmäge synanyşylýar...${NC}"
  # Konfigurasiýany täzeden döret
  create_correct_env_file
  # Bot hyzmatyny täzeden başlat
  systemctl restart chatbot.service
  sleep 3
fi

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