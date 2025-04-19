#!/bin/bash

# Reňk kesgitlemeleri
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Gurnalyş katalogy
INSTALL_DIR="/opt/chatbot"
SERVICE_NAME="chatbot"

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
echo ""

# Root barlagy
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Bu amal üçin root ygtyýarlary gerek.${NC}"
    echo -e "${YELLOW}sudo botpanel${NC} buýrugy bilen täzeden synanyşyň."
    exit 1
fi

# Funksiýalar
check_status() {
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}Bot işleýär${NC}"
    else
        echo -e "${RED}Bot işlemeýär${NC}"
    fi
}

start_bot() {
    echo -e "${BLUE}Bot başladylýar...${NC}"
    systemctl start $SERVICE_NAME
    sleep 2
    check_status
}

stop_bot() {
    echo -e "${BLUE}Bot durdurylýar...${NC}"
    systemctl stop $SERVICE_NAME
    sleep 2
    check_status
}

restart_bot() {
    echo -e "${BLUE}Bot täzeden başladylýar...${NC}"
    systemctl restart $SERVICE_NAME
    sleep 2
    check_status
}

update_bot() {
    echo -e "${BLUE}Bot täzelenýär...${NC}"
    bash $INSTALL_DIR/update.sh
    echo -e "\n${BLUE}Dowam etmek üçin Enter düwmesine basyň...${NC}"
    read
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
        rm -f /usr/local/bin/botpanel
        
        echo -e "${GREEN}ChatBot üstünlikli aýryldy.${NC}"
        exit 0
    else
        echo -e "${BLUE}Aýyrma amaly ýatyryldy.${NC}"
    fi
    
    echo -e "\n${BLUE}Dowam etmek üçin Enter düwmesine basyň...${NC}"
    read
}

# Esasy menýu döwri
while true; do
    clear
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
    echo ""
    
    # Bot ýagdaýy
    echo -n "Ýagdaý: "
    check_status
    
    # Wersiýa maglumaty
    if [ -f "$INSTALL_DIR/version.txt" ]; then
        VERSION=$(cat $INSTALL_DIR/version.txt)
        echo -e "Wersiýa: ${CYAN}$VERSION${NC}"
    else
        echo -e "Wersiýa: ${CYAN}Näbelli${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Haýyş, bir amal saýlaň:${NC}"
    echo -e "${CYAN}1)${NC} Boty Başlat"
    echo -e "${CYAN}2)${NC} Boty Durdur"
    echo -e "${CYAN}3)${NC} Boty Täzeden Başlat"
    echo -e "${CYAN}4)${NC} Bot Täzelemelerini Barla"
    echo -e "${CYAN}5)${NC} Bot Loglaryny Görkez"
    echo -e "${CYAN}6)${NC} Bot Konfigurasiýasyny Redaktirle"
    echo -e "${CYAN}7)${NC} Boty Aýyr"
    echo -e "${CYAN}0)${NC} Çykyş"
    echo ""
    read -p "Saýlawyňyz [0-7]: " choice
    
    case $choice in
        1) start_bot ;;
        2) stop_bot ;;
        3) restart_bot ;;
        4) update_bot ;;
        5) view_logs ;;
        6) edit_config ;;
        7) uninstall_bot ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Nädogry saýlaw!${NC}"; sleep 2 ;;
    esac
done 