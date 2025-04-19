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
  echo -e "${RED}Görünşine görä, .env faýly bozulan bolup biler.${NC}"
  echo -e "${YELLOW}Faýl täzeden döredilýär...${NC}"
  
  # Bar bolan .env faýlyny ätiýaçla
  if [ -f "$CONFIG_FILE" ]; then
    echo -ne "${YELLOW}Bar bolan .env faýly ätiýaçlanýar...${NC} "
    cp $CONFIG_FILE ${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S) &
    PID=$!
    spin $PID
    wait $PID
    echo -e " ${GREEN}✓${NC}"
  fi
  
  # Ulanyjydan täze konfigurasiýa üçin maglumatlary soramak
  echo -e "${YELLOW}Täze konfigurasiýa üçin gerekli maglumatlary giriziň:${NC}"
  
  # Bot Token
  read -p "Telegram Bot Token (boş goýsaňyz, TOKEN_PLACEHOLDER ulanyljakdyr): " BOT_TOKEN
  if [ -z "$BOT_TOKEN" ]; then
    BOT_TOKEN="TOKEN_PLACEHOLDER"
  fi
  
  # MongoDB URI
  read -p "MongoDB URI (boş goýsaňyz, 'mongodb://localhost:27017' ulanyljakdyr): " MONGODB_URI
  if [ -z "$MONGODB_URI" ]; then
    MONGODB_URI="mongodb://localhost:27017"
  fi
  
  # Database ady
  read -p "MongoDB maglumat bazasynyň ady (boş goýsaňyz, 'chatbot_db' ulanyljakdyr): " DB_NAME
  if [ -z "$DB_NAME" ]; then
    DB_NAME="chatbot_db"
  fi
  
  # Admin ID
  read -p "Telegram Admin ID (boş goýsaňyz, '123456789' ulanyljakdyr): " ADMIN_ID
  if [ -z "$ADMIN_ID" ]; then
    ADMIN_ID="123456789"
  fi
  
  # Täze .env faýlyny döret
  echo -ne "${YELLOW}Täze konfigurasiýa faýly döredilýär...${NC} "
  cat > $CONFIG_FILE << EOL
BOT_TOKEN=$BOT_TOKEN
MONGODB_URI=$MONGODB_URI
DATABASE_NAME=$DB_NAME
ADMIN_ID=$ADMIN_ID
EOL
  echo -e " ${GREEN}✓${NC}"
  
  # Bot hyzmaty täzeden başlat
  echo -e "${YELLOW}Bot hyzmaty täzeden başladylýar...${NC}"
  restart_bot
  
  echo -e "${GREEN}Konfigurasiýa faýly üstünlikli düzedildi!${NC}"
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