#!/bin/bash

# ChatBot - Turkmenistan üçin chatbot
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

# Reňk kesgitlemeleri
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Gurnalyş katalogy
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

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

# Root barlagy
if [ "$EUID" -ne 0 ]; then
  clear
  echo -e "${RED}Näsazlyk: Bu skripti root hökmünde işlediň!${NC}"
  echo -e "${YELLOW}Buýruk: sudo chatbot${NC}"
  exit 1
fi

# Ekrany arassala
clear

# Ätiýaçly bolmak üçin awtomatiki düzediş funksiýany başda çagyr
# systemctl komandasy näsazlyklary ekrana görkezmez ýaly çağyr
echo -ne "${YELLOW}Botda näsazlyk barmy diýip barlanýar...${NC}"
if ! systemctl is-active --quiet $SERVICE_NAME 2>/dev/null || ! systemctl is-active --quiet mongod 2>/dev/null; then
  echo -e " ${RED}Hawa${NC}"
  echo -e "${YELLOW}Awtomatiki näsazlyk düzediji işledilýär... (Bu biraz wagt alyp biler)${NC}"
  autofix_common_issues
  sleep 1
  echo -e "${GREEN}Näsazlyklar düzedildi!${NC}"
  echo -e "${YELLOW}Panel 3 sekuntdan soň açylar... ${NC}"
  sleep 3
else
  echo -e " ${GREEN}Ýok${NC}"
fi

clear

# Banner görkez
echo -e "${BLUE}"
echo "   _____ _           _   ____        _   "
echo "  / ____| |         | | |  _ \      | |  "
echo " | |    | |__   __ _| |_| |_) | ___ | |_ "
echo " | |    | '_ \ / _\` | __|  _ < / _ \| __|"
echo " | |____| | | | (_| | |_| |_) | (_) | |_ "
echo "  \_____|_| |_|\__,_|\__|____/ \___/ \__|"
echo -e "${NC}"
echo -e "${YELLOW}ChatBot Dolandyryş Paneli${NC}"
echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}"
echo "----------------------------------------"

# Funksiýalar
check_status() {
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}Bot işleýär${NC}"
    else
        echo -e "${RED}Bot işlemeýär${NC}"
    fi
}

start_bot() {
    echo -ne "${YELLOW}Bot hyzmaty başladylýar...${NC} "
    systemctl start $SERVICE_NAME > /dev/null 2>&1 &
    PID=$!
    progress_bar "Bot işledilýär" $PID 2
    wait $PID
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}Bot üstünlikli işledildi!${NC}"
    else
        echo -e "${RED}Boty işletmek bolmady. Loglar üçin journalctl -u $SERVICE_NAME ulanyň${NC}"
    fi
}

stop_bot() {
    echo -ne "${YELLOW}Bot hyzmaty durdurylýar...${NC} "
    systemctl stop $SERVICE_NAME > /dev/null 2>&1 &
    PID=$!
    spin $PID
    wait $PID
    
    if ! systemctl is-active --quiet $SERVICE_NAME; then
        echo -e " ${GREEN}Bot üstünlikli durduryldy!${NC}"
    else
        echo -e " ${RED}Boty durdurmak bolmady. Loglar üçin journalctl -u $SERVICE_NAME ulanyň${NC}"
    fi
}

restart_bot() {
    echo -ne "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC} "
    systemctl restart $SERVICE_NAME > /dev/null 2>&1 &
    PID=$!
    progress_bar "Bot täzeden işledilýär" $PID 3
    wait $PID
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}Bot üstünlikli täzeden başladyldy!${NC}"
    else
        echo -e "${RED}Boty täzeden başladyp bolmady. Loglar üçin journalctl -u $SERVICE_NAME ulanyň${NC}"
    fi
}

update_bot() {
    echo -e "${YELLOW}Bot täzelenýär...${NC}"
    echo -e "${YELLOW}Täzeleme skripti başladylýar, bu biraz wagt alyp biler...${NC}"
    
    # Animasiýaly täzeleme başlangyç
    echo -ne "${YELLOW}Täzeleme skripti ýüklenýär${NC} "
    for i in {1..20}; do
        echo -ne "${GREEN}>${NC}"
        sleep 0.05
    done
    echo -e " ${GREEN}✓${NC}"
    
    # Aýdyňlaşdyryjy habary görkez, soňra 3 sekunt sakla
    echo -e "${YELLOW}Täzeleme skripti işledilýär. Bu ekran ýapylandan soň täzeleme skripti açylar.${NC}"
    echo -e "${YELLOW}Täzeleme tamamlanandan soň, dolandyryş paneli täzeden açylar.${NC}"
    for i in {3..1}; do
        echo -ne "${YELLOW}$i sekunt galdyramsoň täzeleme başlar...${NC}\r"
        sleep 1
    done
    echo -e "${GREEN}Täzeleme başlanýar!${NC}"
    sleep 1
    
    # Täzeleme skriptini işlet
    bash -c "curl -sSL https://raw.githubusercontent.com/hackedcdn/chatbot/main/update.sh | sudo bash && sudo chatbot"
    exit 0
}

view_logs() {
    echo -e "${BLUE}Soňky 50 log ýazgysy görkezilýär...${NC}"
    journalctl -u $SERVICE_NAME -n 50 --no-pager
    echo -e "\n${BLUE}Dowam etmek üçin Enter düwmesine basyň...${NC}"
    read
}

edit_config() {
    echo -e "${BLUE}Bot konfigurasiýasy redaktirlenýär...${NC}"
    
    # Bar bolan tokeni al
    BOT_TOKEN=$(grep "BOT_TOKEN" $INSTALL_DIR/.env | cut -d= -f2)
    
    # Täze bahany sora
    echo -e "${YELLOW}Bar bolan Token: $BOT_TOKEN${NC}"
    echo -e "${YELLOW}Täze Token ýazyň (üýtgetmek islemeseňiz boş goýuň):${NC}"
    read -p "Bot Token: " NEW_TOKEN
    
    # Bar bolan admin ID-ni al
    ADMIN_ID=$(grep "ADMIN_ID" $INSTALL_DIR/.env | cut -d= -f2)
    
    # Täze bahany sora
    echo -e "${YELLOW}Bar bolan Admin ID: $ADMIN_ID${NC}"
    echo -e "${YELLOW}Täze Admin ID ýazyň (üýtgetmek islemeseňiz boş goýuň):${NC}"
    read -p "Admin ID: " NEW_ADMIN
    
    # Bahalary täzele
    if [ ! -z "$NEW_TOKEN" ]; then
        sed -i "s/BOT_TOKEN=.*/BOT_TOKEN=$NEW_TOKEN/" $INSTALL_DIR/.env
    fi
    
    if [ ! -z "$NEW_ADMIN" ]; then
        sed -i "s/ADMIN_ID=.*/ADMIN_ID=$NEW_ADMIN/" $INSTALL_DIR/.env
    fi
    
    echo -e "${GREEN}Konfigurasiýa täzelendi.${NC}"
    echo -e "${YELLOW}Üýtgeşmeleriň täsirli bolmagy üçin boty täzeden başladyň.${NC}"
    
    echo -e "\n${BLUE}Boty şu wagt täzeden başlatmak isleýärsiňizmi? (e/ý)${NC}"
    read -p "" RESTART
    if [[ $RESTART == "e" || $RESTART == "E" ]]; then
        restart_bot
    fi
    
    echo -e "\n${BLUE}Dowam etmek üçin Enter düwmesine basyň...${NC}"
    read
}

uninstall_bot() {
    echo -e "${RED}ÜNS BERIŇ: Bot doly aýrylýar we ähli maglumatlar pozulýar!${NC}"
    echo -e "${YELLOW}Bu amaly tassyklaýarsyňyzmy? (hawa/ýok)${NC}"
    read -p "" CONFIRM
    
    if [[ $CONFIRM == "hawa" ]]; then
        echo -e "${BLUE}Bot hyzmaty durdurylýar...${NC}"
        systemctl stop $SERVICE_NAME
        systemctl disable $SERVICE_NAME
        
        echo -e "${BLUE}Hyzmat faýly aýrylýar...${NC}"
        rm -f /etc/systemd/system/$SERVICE_NAME.service
        systemctl daemon-reload
        
        echo -e "${BLUE}Bot faýllary aýrylýar...${NC}"
        rm -rf $INSTALL_DIR
        
        echo -e "${BLUE}Dolandyryş paneli buýrugy aýrylýar...${NC}"
        rm -f /usr/local/bin/chatbot
        rm -f /usr/bin/chatbot
        
        echo -e "${GREEN}ChatBot üstünlikli aýryldy.${NC}"
        exit 0
    else
        echo -e "${BLUE}Aýyrma amaly ýatyryldy.${NC}"
    fi
    
    echo -e "\n${BLUE}Dowam etmek üçin Enter düwmesine basyň...${NC}"
    read
}

# Konfigurasiýa faýlyny düzet
fix_env_file() {
  CONFIG_FILE="$INSTALL_DIR/.env"
  
  echo -e "${YELLOW}Konfigurasiýa faýly näsazlygy düzedilýär...${NC}"
  
  # Öňki .env faýlyny ätiýaçla
  if [ -f "$CONFIG_FILE" ]; then
    cp -f "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
    echo -e "${GREEN}Öňki .env faýlynyň ätiýaçlyk nusgasy döredildi.${NC}"
  fi
  
  # Ýagdaýda variable bahalaryny alyp biler
  BOT_TOKEN=""
  ADMIN_ID=""
  
  # Öňki .env faýlyny barla
  if [ -f "$CONFIG_FILE" ]; then
    # Variable bahalaryny alyp bileris
    BOT_TOKEN=$(grep -i "BOT_TOKEN" "$CONFIG_FILE" | sed 's/BOT_TOKEN=//g' | tr -d ' "'\''$' || echo "")
    MONGODB_URI=$(grep -i "MONGO.*URI" "$CONFIG_FILE" | sed 's/.*URI=//g' | tr -d ' "'\''$' || echo "mongodb://localhost:27017")
    DB_NAME=$(grep -i "DATABASE_NAME" "$CONFIG_FILE" | sed 's/.*NAME=//g' | tr -d ' "'\''$' || echo "chatbot_db")
    ADMIN_ID=$(grep -i "ADMIN_ID" "$CONFIG_FILE" | sed 's/ADMIN_ID=//g' | tr -d ' "'\''$' || echo "")
    
    # Çykaryş görkez
    echo -e "${YELLOW}Öňki konfigurasiýa:${NC}"
    echo -e "Bot Token: ${CYAN}$BOT_TOKEN${NC}"
    echo -e "MongoDB URI: ${CYAN}$MONGODB_URI${NC}"
    echo -e "DB Ady: ${CYAN}$DB_NAME${NC}"
    echo -e "Admin ID: ${CYAN}$ADMIN_ID${NC}"
    echo
  fi
  
  # Ulanyjydan täze maglumatlary almak ýa-da öňkülerini saklamak
  echo -e "${YELLOW}Täze konfigurasiýa maglumatlary (boş goýsaňyz, öňküsi ulanyljakdyr):${NC}"
  
  # Bot Token
  echo -ne "${GREEN}Bot Token${NC} [Häzirki: $BOT_TOKEN]: "
  read NEW_TOKEN
  if [ -z "$NEW_TOKEN" ]; then
    if [ -z "$BOT_TOKEN" ]; then
      echo -ne "${YELLOW}Bot tokeni boş. Dogry tokeni ýazyň:${NC} "
      read NEW_TOKEN
      if [ -z "$NEW_TOKEN" ]; then
        NEW_TOKEN="TOKEN_PLACEHOLDER"
        echo -e "${RED}Token girizilmedi. TOKEN_PLACEHOLDER ulanylýar, bot işlemez!${NC}"
      fi
    else
      NEW_TOKEN="$BOT_TOKEN"
    fi
  fi
  
  # Admin ID
  echo -ne "${GREEN}Admin ID${NC} [Häzirki: $ADMIN_ID]: "
  read NEW_ADMIN
  if [ -z "$NEW_ADMIN" ]; then
    if [ -z "$ADMIN_ID" ]; then
      echo -ne "${YELLOW}Admin ID boş. Dogry Admin ID ýazyň:${NC} "
      read NEW_ADMIN
      if [ -z "$NEW_ADMIN" ]; then
        NEW_ADMIN="123456789"
        echo -e "${RED}Admin ID girizilmedi. 123456789 ulanylýar.${NC}"
      fi
    else
      NEW_ADMIN="$ADMIN_ID"
    fi
  fi
  
  # Admin ID-niň sanlygyny barla
  if ! [[ "$NEW_ADMIN" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Girilen Admin ID sanda däl! Standart 123456789 ulanyljakdyr.${NC}"
    NEW_ADMIN="123456789"
  fi
  
  # Täze .env faýlyny dogry formatda döret
  echo "BOT_TOKEN=$NEW_TOKEN" > "$CONFIG_FILE"
  echo "MONGODB_URI=$MONGODB_URI" >> "$CONFIG_FILE"
  echo "DATABASE_NAME=$DB_NAME" >> "$CONFIG_FILE"
  echo "ADMIN_ID=$NEW_ADMIN" >> "$CONFIG_FILE"
  
  chmod 644 "$CONFIG_FILE"
  
  echo -e "${GREEN}Täze konfigurasiýa faýly döredildi:${NC}"
  cat "$CONFIG_FILE"
  
  # Bot.py faýlyna täze howpsuzlyk düzedişleri goş
  if [ -f "$INSTALL_DIR/bot.py" ]; then
    echo -e "${YELLOW}Bot koduna howpsuzlyk düzedişleri goşulýar...${NC}"
    cp -f "$INSTALL_DIR/bot.py" "$INSTALL_DIR/bot.py.backup" 2>/dev/null || true
    
    # ADMIN_ID konwersiýasy üçin howpsuzlyk kody goş
    sed -i '/ADMIN_ID = int(os.getenv("ADMIN_ID", 0))/c\try:\n    admin_id_str = os.getenv("ADMIN_ID", "0")\n    admin_id_str = admin_id_str.strip() if isinstance(admin_id_str, str) else "0"\n    ADMIN_ID = int(admin_id_str) if admin_id_str.isdigit() else 0\nexcept Exception:\n    ADMIN_ID = 0' "$INSTALL_DIR/bot.py" 2>/dev/null || true
    
    # load_dotenv() işini has howpsuz et
    sed -i '/load_dotenv/c\try:\n    load_dotenv()\nexcept Exception:\n    try:\n        load_dotenv(".env.test")\n    except Exception as e:\n        print(f"Konfigurasiýa ýüklenip bilmedi: {str(e)}")' "$INSTALL_DIR/bot.py" 2>/dev/null || true
    
    echo -e "${GREEN}Bot kody üstünlikli düzedildi✓${NC}"
  fi
  
  # Ätiýaçlyk .env.test faýlyny hem döret
  echo "BOT_TOKEN=$NEW_TOKEN" > "$INSTALL_DIR/.env.test"
  echo "MONGODB_URI=$MONGODB_URI" >> "$INSTALL_DIR/.env.test"
  echo "DATABASE_NAME=$DB_NAME" >> "$INSTALL_DIR/.env.test"
  echo "ADMIN_ID=$NEW_ADMIN" >> "$INSTALL_DIR/.env.test"
  chmod 644 "$INSTALL_DIR/.env.test"
  
  # Bot hyzmatyny täzeden başlat
  echo -e "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC}"
  systemctl restart $SERVICE_NAME
  sleep 3
  
  # Bot işleýärmi barla
  if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}Bot hyzmaty üstünlikli işleýär✓${NC}"
  else
    echo -e "${RED}Bot hyzmaty işläp başlamady! Log ýazgylaryny barlaň:${NC}"
    journalctl -u $SERVICE_NAME -n 10 --no-pager
  fi
}

# MongoDB näsazlyklary we .env faýlynyň formatyny awtomatiki barla we düzet
autofix_common_issues() {
  # Ätiýaçly bolmak üçin howpsuz ýerinde amaly ýerine ýetir
  (
    echo -e "${YELLOW}Awtomatiki näsazlyk düzediş başlaýar...${NC}"
  
    # MongoDB işleýşini barla we düzet
    if ! systemctl is-active --quiet mongod; then
      echo -e "${YELLOW}MongoDB işlemeýär, işledilýär...${NC}"
      systemctl start mongod > /dev/null 2>&1 || true
      sleep 2
    
      if ! systemctl is-active --quiet mongod; then
        echo -e "${YELLOW}MongoDB işlemeýär, täzeden gurnamaga synanyşylýar...${NC}"
        
        # Önce şimdiki ubuntu/debian sürümünü belirleyip doğru depoyu ekleyelim
        if [ -f /etc/lsb-release ]; then
          source /etc/lsb-release
          CODENAME=$DISTRIB_CODENAME
        elif [ -f /etc/os-release ]; then
          source /etc/os-release
          CODENAME=$(lsb_release -cs 2>/dev/null || echo "")
        fi
        
        # MongoDB deposunu ekleyelim
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - > /dev/null 2>&1 || true
        
        # Uygun depo URL'sini oluşturalım
        if [ ! -z "$CODENAME" ]; then
          echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $CODENAME/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 || true
        else
          echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list > /dev/null 2>&1 || true
        fi
        
        # Depoları güncelleyip MongoDB'yi kuralım
        apt-get update > /dev/null 2>&1 || true
        apt-get install -y mongodb-org > /dev/null 2>&1 || true
        
        # Servis dosyasını oluşturalım (yoksa)
        if [ ! -f /lib/systemd/system/mongod.service ]; then
          cat > /lib/systemd/system/mongod.service << EOL
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
# file size
LimitFSIZE=infinity
# cpu time
LimitCPU=infinity
# virtual memory size
LimitAS=infinity
# open files
LimitNOFILE=64000
# processes/threads
LimitNPROC=64000
# locked memory
LimitMEMLOCK=infinity
# total threads (user+kernel)
TasksMax=infinity
TasksAccounting=false
# Recommended limits for mongod as specified in
# https://docs.mongodb.com/manual/reference/ulimit/#recommended-ulimit-settings

[Install]
WantedBy=multi-user.target
EOL
        fi
        
        # Servis dosyasını etkinleştirip başlatalım
        systemctl daemon-reload > /dev/null 2>&1 || true
        systemctl enable mongod > /dev/null 2>&1 || true
        systemctl start mongod > /dev/null 2>&1 || true
        
        sleep 3
      fi
    fi
  
    # .env faýlynyň formatyny barla we düzet
    CONFIG_FILE="$INSTALL_DIR/.env"
    echo -e "${YELLOW}.env faýly täzelenýär...${NC}"
  
    # .env faýlynyň formaty barla - dikkatli üçin daha güvenli yedek alalım
    if [ -f "$CONFIG_FILE" ]; then
      # Güvenli bir yedekleme dosyası oluşturalım
      cp -f "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
      
      # Bu dosyayı bir geçici dosyaya kopyalayıp, sorunlu karakterleri kaldıralım
      cp -f "$CONFIG_FILE" "${CONFIG_FILE}.tmp" 2>/dev/null || true
      
      # Dosyada sorunlu karakterleri temizleyelim
      tr -d '\r' < "${CONFIG_FILE}.tmp" > "${CONFIG_FILE}.clean" 2>/dev/null || true
      
      # Dosyadan token ve admin ID değerlerini çıkaralım (her iki format içinde)
      BOT_TOKEN=$(grep -i "BOT_TOKEN" "${CONFIG_FILE}.clean" 2>/dev/null | sed 's/.*BOT_TOKEN=//g; s/[^a-zA-Z0-9\.:_-]//g' || echo "TOKEN_PLACEHOLDER")
      MONGODB_URI=$(grep -i "MONGO.*URI\|MONGODB_URI\|MONGO_URI" "${CONFIG_FILE}.clean" 2>/dev/null | sed 's/.*URI=//g; s/[^a-zA-Z0-9\.:_\/@-]//g' || echo "mongodb://localhost:27017")
      DB_NAME=$(grep -i "DB_NAME\|DATABASE\|DATABASE_NAME" "${CONFIG_FILE}.clean" 2>/dev/null | sed 's/.*NAME=//g; s/[^a-zA-Z0-9\.:_-]//g' || echo "chatbot_db")
      ADMIN_ID=$(grep -i "ADMIN.*ID\|ADMIN_ID" "${CONFIG_FILE}.clean" 2>/dev/null | sed 's/.*ID=//g; s/[^0-9]//g' || echo "123456789")
      
      # Geçici dosyaları temizleyelim
      rm -f "${CONFIG_FILE}.tmp" "${CONFIG_FILE}.clean" 2>/dev/null || true
    else
      # Standart maglumatlar
      BOT_TOKEN="TOKEN_PLACEHOLDER"
      MONGODB_URI="mongodb://localhost:27017"
      DB_NAME="chatbot_db"
      ADMIN_ID="123456789"
    fi
    
    # Admin ID'si sayı değilse düzeltelim
    if ! [[ "$ADMIN_ID" =~ ^[0-9]+$ ]]; then
      ADMIN_ID="123456789"
    fi
  
    # Temiz bir .env dosyası oluşturalım
    echo "BOT_TOKEN=$BOT_TOKEN" > "$CONFIG_FILE"
    echo "MONGODB_URI=$MONGODB_URI" >> "$CONFIG_FILE"
    echo "DATABASE_NAME=$DB_NAME" >> "$CONFIG_FILE"
    echo "ADMIN_ID=$ADMIN_ID" >> "$CONFIG_FILE"
    
    # Dosya izinlerini düzeltelim
    chmod 644 "$CONFIG_FILE" 2>/dev/null || true
    echo -e "${GREEN}Konfigurasiýa faýly täzelendi ✓${NC}"
  
    # Systemd konfigurasiýany düzet
    if [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
      if grep -q "StandardOutput=syslog" /etc/systemd/system/$SERVICE_NAME.service 2>/dev/null; then
        echo -e "${YELLOW}Bot hyzmaty konfigurasiýasy täzelenýär...${NC}"
        # Köne syslog → journal konwertasiýa
        sed -i 's/StandardOutput=syslog/StandardOutput=journal/g' /etc/systemd/system/$SERVICE_NAME.service 2>/dev/null || true
        sed -i 's/StandardError=syslog/StandardError=journal/g' /etc/systemd/system/$SERVICE_NAME.service 2>/dev/null || true
        systemctl daemon-reload > /dev/null 2>&1 || true
      fi
    fi
  
    echo -e "${GREEN}Ähli näsazlyklar düzedildi.${NC}"
  
    # Bot hyzmatyny täzeden başlat
    systemctl restart $SERVICE_NAME > /dev/null 2>&1 || true
    sleep 3
  ) # &>/dev/null bu satırı kaldırıp hatalar görülsün
  
  echo -e "${GREEN}Awtomatiki düzedişler tamamlandy!${NC}"
  sleep 1
}

# Menu funksiýasy
show_menu() {
    clear
    echo -e "${BLUE}"
  echo -e "   _____ _           _   ____        _   "
  echo -e "  / ____| |         | | |  _ \      | |  "
  echo -e " | |    | |__   __ _| |_| |_) | ___ | |_ "
  echo -e " | |    | '_ \ / _\` | __|  _ < / _ \| __|"
  echo -e " | |____| | | | (_| | |_| |_) | (_) | |_ "
  echo -e "  \_____|_| |_|\__,_|\__|____/ \___/ \__|"
    echo -e "${NC}"
  echo -e "${GREEN}ChatBot Dolandyryş Paneli${NC}"
  echo -e "${GREEN}Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)${NC}"
  echo -e "----------------------------------------"
  
  # Ýagdaýlary görkez
  if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}Bot ýagdaýy: Işleýär ✓${NC}"
  else
    echo -e "${RED}Bot ýagdaýy: Duruzdyrylan ✗${NC} - Konfigurasiýa mesele bolup biler [7, 10]"
  fi
  
  if systemctl is-active --quiet mongod; then
    echo -e "${GREEN}MongoDB ýagdaýy: Işleýär ✓${NC}"
  else
    echo -e "${RED}MongoDB ýagdaýy: Duruzdyrylan ✗${NC}"
  fi
  
  # Wersiýa maglumaty
  if [ -f "$INSTALL_DIR/version.txt" ]; then
    VERSION=$(cat $INSTALL_DIR/version.txt)
    echo -e "${GREEN}Wersiýa: ${CYAN}$VERSION${NC}"
  else
    echo -e "${YELLOW}Wersiýa: Näbelli${NC}"
  fi
  
  echo -e "----------------------------------------"
  echo -e "${YELLOW}Saýlanyň:${NC}"
  echo -e "${GREEN}1)${NC} Boty başlat"
  echo -e "${GREEN}2)${NC} Boty durdur"
  echo -e "${GREEN}3)${NC} Boty täzeden başlat"
  echo -e "${GREEN}4)${NC} Bot loglaryny görkez"
  echo -e "${GREEN}5)${NC} Bot statusyny görkez"
  echo -e "${GREEN}6)${NC} Täzeleme"
  echo -e "${GREEN}7)${NC} Konfigurasiýany redaktirle"
  echo -e "${GREEN}8)${NC} Ulgam statusyny görkez"
  echo -e "${GREEN}9)${NC} Boty aýyr"
  echo -e "${GREEN}10)${NC} .env faýlyny düzet (Bot ýagdaýy näsazlyk bar bolsa)"
  echo -e "${GREEN}0)${NC} Çykyş"
  echo -e "----------------------------------------"
  echo -e "${CYAN}Panel özbaşdak ýapylmaz. Çykmak üçin diňe [0] basyň!${NC}"
  echo -ne "${CYAN}Saýlaňyzyň belgisini giriziň [0-10]: ${NC}"
}

# Bot statusyny görkez
show_status() {
  echo -e "${YELLOW}Bot ýagdaýy barlanýar...${NC}"
  
  # Konfigurasiýa faýlyny barla
  echo -ne "${YELLOW}.env faýlyny barlaýar...${NC} "
  if [ -f "$INSTALL_DIR/.env" ]; then
    echo -e " ${GREEN}Konfigurasiýa faýly bar ✓${NC}"
    echo -e "${YELLOW}Konfigurasiýa maglumatlary:${NC}"
    cat "$INSTALL_DIR/.env"
    echo ""
    
    # ADMIN_ID-ni barla
    ADMIN_ID=$(grep "ADMIN_ID" $INSTALL_DIR/.env | cut -d= -f2)
    if [ -z "$ADMIN_ID" ] || [ "$ADMIN_ID" = "" ]; then
      echo -e "${RED}NÄSAZLYK: ADMIN_ID boş! Bot işläp bilmez.${NC}"
      echo -e "${YELLOW}Bu meseläni düzetmek üçin '10) .env faýlyny düzet' saýlawyň.${NC}"
    else
      echo -e "${GREEN}ADMIN_ID: $ADMIN_ID✓${NC}"
    fi
  else
    echo -e " ${RED}Konfigurasiýa faýly ýok!${NC}"
    echo -e "${YELLOW}Bu meseläni düzetmek üçin '10) .env faýlyny düzet' saýlawyň.${NC}"
  fi
  
  echo -ne "${YELLOW}Hyzmat ýagdaýy soralaýar...${NC} "
  systemctl status $SERVICE_NAME --no-pager > /tmp/bot_status &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  echo -e "\n${GREEN}Bot hyzmaty ýagdaýy:${NC}"
  cat /tmp/bot_status
  rm /tmp/bot_status
  
  echo -e "\n${YELLOW}Process ID barlanýar...${NC}"
  if systemctl is-active --quiet $SERVICE_NAME; then
    PID=$(systemctl show -p MainPID --value $SERVICE_NAME)
    if [ "$PID" != "0" ]; then
      echo -ne "${YELLOW}Process maglumatlary soralaýar...${NC} "
      ps -p $PID -o pid,ppid,cmd,%cpu,%mem --no-headers > /tmp/bot_process &
      PPID=$!
      spin $PPID
      wait $PPID
      echo -e " ${GREEN}✓${NC}"
      
      echo -e "\n${GREEN}Process maglumatlary:${NC}"
      echo -e "${CYAN}PID     PPID    CMD                             CPU     MEM${NC}"
      cat /tmp/bot_process
      rm /tmp/bot_process
    else
      echo -e "${RED}PID tapylmady!${NC}"
    fi
  else
    echo -e "${RED}Bot hyzmaty işlemeýär!${NC}"
    # Bot loglaryndan näsazlyk sebäpleri barla
    echo -e "${YELLOW}Loglardan näsazlyk sebäplerini barlaýar...${NC}"
    journalctl -u $SERVICE_NAME -n 20 | grep -i "error\|failed\|ValueError" > /tmp/bot_errors
    if [ -s "/tmp/bot_errors" ]; then
      echo -e "${RED}Tapylan näsazlyklar:${NC}"
      cat /tmp/bot_errors
      echo ""
      echo -e "${YELLOW}Bu meseläni düzetmek üçin '10) .env faýlyny düzet' saýlawyň.${NC}"
    fi
    rm -f /tmp/bot_errors
  fi
  
  # Diskdäki ýeri barla
  echo -e "\n${YELLOW}Disk ulanylyşy barlanýar...${NC}"
  echo -ne "${YELLOW}Bot katalogyndaky disk ulanylyşy...${NC} "
  du -sh $INSTALL_DIR > /tmp/bot_disk &
  PID=$!
  spin $PID
  wait $PID
  echo -e " ${GREEN}✓${NC}"
  
  echo -e "\n${GREEN}Disk ulanylyşy:${NC}"
  cat /tmp/bot_disk
  rm /tmp/bot_disk
  
  # Netije
  echo -e "\n${GREEN}Bot ýagdaýy maglumatlary üstünlikli görkezildi${NC}"
}

# Esasy menýu döwri
while true; do
    show_menu
    read -r choice
    
    # Menýu soňunda, her saýlaw soňunda awtomatiki düzeldiş funksiýasyny çagyrmaly däl
    case $choice in
        1)
            start_bot
            ;;
        2)
            stop_bot
            ;;
        3)
            restart_bot
            ;;
        4)
            view_logs
            ;;
        5)
            show_status
            ;;
        6)
            update_bot
            ;;
        7)
            edit_config
            ;;
        8)
            system_status
            ;;
        9)
            uninstall_bot
            ;;
        10)
            fix_env_file
            ;;
        0)
            clear
            echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║      ChatBot dolandyryş panelinden çykylýar    ║${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}║  Ýene girmek üçin diňe ${YELLOW}chatbot${GREEN} diýip ýazyň   ║${NC}"
            echo -e "${GREEN}║                                                ║${NC}"
            echo -e "${GREEN}║  Dolandyryjy: hackedcdn                        ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ýalňyş saýlaw. Täzeden synanyşyň.${NC}"
            sleep 1
            ;;
    esac
    
    # Esasy menýuwa gaýtmazdan öň, dowam etmek üçin "Enter" talapy
    echo
    echo -ne "${YELLOW}Esasy menýuwa gaýtmak üçin Enter basyň...${NC}"
    read dummy
done 