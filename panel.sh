#!/bin/bash

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Kurulum dizini
INSTALL_DIR="/opt/turkmenbot"
SERVICE_NAME="turkmenbot"

# Ekranı temizle
clear

# Banner göster
echo -e "${BLUE}"
echo "  _______         _                          ____        _   "
echo " |__   __|       | |                        |  _ \      | |  "
echo "    | |_   _ _ __| | ___ __ ___   ___ _ __ | |_) | ___ | |_ "
echo "    | | | | | '__| |/ / '_ \` _ \ / _ \ '_ \|  _ < / _ \| __|"
echo "    | | |_| | |  |   <| | | | | |  __/ | | | |_) | (_) | |_ "
echo "    |_|\__,_|_|  |_|\_\_| |_| |_|\___|_| |_|____/ \___/ \__|"
echo -e "${NC}"
echo -e "${YELLOW}TurkmenBot Yönetim Paneli${NC}"
echo ""

# Root kontrolü
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Bu işlem için root yetkileri gerekiyor.${NC}"
    echo -e "Lütfen ${YELLOW}sudo botpanel${NC} komutu ile tekrar deneyin."
    exit 1
fi

# Fonksiyonlar
check_status() {
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}Bot çalışıyor${NC}"
    else
        echo -e "${RED}Bot çalışmıyor${NC}"
    fi
}

start_bot() {
    echo -e "${BLUE}Bot başlatılıyor...${NC}"
    systemctl start $SERVICE_NAME
    sleep 2
    check_status
}

stop_bot() {
    echo -e "${BLUE}Bot durduruluyor...${NC}"
    systemctl stop $SERVICE_NAME
    sleep 2
    check_status
}

restart_bot() {
    echo -e "${BLUE}Bot yeniden başlatılıyor...${NC}"
    systemctl restart $SERVICE_NAME
    sleep 2
    check_status
}

update_bot() {
    echo -e "${BLUE}Bot güncelleniyor...${NC}"
    bash $INSTALL_DIR/update.sh
    echo -e "\n${BLUE}Devam etmek için Enter tuşuna basın...${NC}"
    read
}

view_logs() {
    echo -e "${BLUE}Son 50 log kaydı görüntüleniyor...${NC}"
    journalctl -u $SERVICE_NAME -n 50 --no-pager
    echo -e "\n${BLUE}Devam etmek için Enter tuşuna basın...${NC}"
    read
}

edit_config() {
    echo -e "${BLUE}Bot yapılandırması düzenleniyor...${NC}"
    
    # Mevcut token'ı al
    BOT_TOKEN=$(grep "BOT_TOKEN" $INSTALL_DIR/.env | cut -d= -f2)
    
    # Yeni değeri iste
    echo -e "${YELLOW}Mevcut Token: $BOT_TOKEN${NC}"
    echo -e "${YELLOW}Yeni Token girin (değiştirmek istemiyorsanız boş bırakın):${NC}"
    read -p "Bot Token: " NEW_TOKEN
    
    # Mevcut admin ID'yi al
    ADMIN_ID=$(grep "ADMIN_ID" $INSTALL_DIR/.env | cut -d= -f2)
    
    # Yeni değeri iste
    echo -e "${YELLOW}Mevcut Admin ID: $ADMIN_ID${NC}"
    echo -e "${YELLOW}Yeni Admin ID girin (değiştirmek istemiyorsanız boş bırakın):${NC}"
    read -p "Admin ID: " NEW_ADMIN
    
    # Değerleri güncelle
    if [ ! -z "$NEW_TOKEN" ]; then
        sed -i "s/BOT_TOKEN=.*/BOT_TOKEN=$NEW_TOKEN/" $INSTALL_DIR/.env
    fi
    
    if [ ! -z "$NEW_ADMIN" ]; then
        sed -i "s/ADMIN_ID=.*/ADMIN_ID=$NEW_ADMIN/" $INSTALL_DIR/.env
    fi
    
    echo -e "${GREEN}Yapılandırma güncellendi.${NC}"
    echo -e "${YELLOW}Değişikliklerin etkili olması için botu yeniden başlatın.${NC}"
    
    echo -e "\n${BLUE}Botu şimdi yeniden başlatmak istiyor musunuz? (e/h)${NC}"
    read -p "" RESTART
    if [[ $RESTART == "e" || $RESTART == "E" ]]; then
        restart_bot
    fi
    
    echo -e "\n${BLUE}Devam etmek için Enter tuşuna basın...${NC}"
    read
}

uninstall_bot() {
    echo -e "${RED}DİKKAT: Bot tamamen kaldırılacak ve tüm veriler silinecek!${NC}"
    echo -e "${YELLOW}Bu işlemi onaylıyor musunuz? (evet/hayır)${NC}"
    read -p "" CONFIRM
    
    if [[ $CONFIRM == "evet" ]]; then
        echo -e "${BLUE}Bot servisi durduruluyor...${NC}"
        systemctl stop $SERVICE_NAME
        systemctl disable $SERVICE_NAME
        
        echo -e "${BLUE}Servis dosyası kaldırılıyor...${NC}"
        rm -f /etc/systemd/system/$SERVICE_NAME.service
        systemctl daemon-reload
        
        echo -e "${BLUE}Bot dosyaları kaldırılıyor...${NC}"
        rm -rf $INSTALL_DIR
        
        echo -e "${BLUE}Yönetim paneli komutu kaldırılıyor...${NC}"
        rm -f /usr/local/bin/botpanel
        
        echo -e "${GREEN}TurkmenBot başarıyla kaldırıldı.${NC}"
        exit 0
    else
        echo -e "${BLUE}Kaldırma işlemi iptal edildi.${NC}"
    fi
    
    echo -e "\n${BLUE}Devam etmek için Enter tuşuna basın...${NC}"
    read
}

# Ana menü döngüsü
while true; do
    clear
    echo -e "${BLUE}"
    echo "  _______         _                          ____        _   "
    echo " |__   __|       | |                        |  _ \      | |  "
    echo "    | |_   _ _ __| | ___ __ ___   ___ _ __ | |_) | ___ | |_ "
    echo "    | | | | | '__| |/ / '_ \` _ \ / _ \ '_ \|  _ < / _ \| __|"
    echo "    | | |_| | |  |   <| | | | | |  __/ | | | |_) | (_) | |_ "
    echo "    |_|\__,_|_|  |_|\_\_| |_| |_|\___|_| |_|____/ \___/ \__|"
    echo -e "${NC}"
    echo -e "${YELLOW}TurkmenBot Yönetim Paneli${NC}"
    echo ""
    
    # Bot durumu
    echo -n "Durum: "
    check_status
    
    # Versiyon bilgisi
    if [ -f "$INSTALL_DIR/version.txt" ]; then
        VERSION=$(cat $INSTALL_DIR/version.txt)
        echo -e "Versiyon: ${CYAN}$VERSION${NC}"
    else
        echo -e "Versiyon: ${CYAN}Bilinmiyor${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Lütfen bir işlem seçin:${NC}"
    echo -e "${CYAN}1)${NC} Botu Başlat"
    echo -e "${CYAN}2)${NC} Botu Durdur"
    echo -e "${CYAN}3)${NC} Botu Yeniden Başlat"
    echo -e "${CYAN}4)${NC} Bot Güncellemelerini Kontrol Et"
    echo -e "${CYAN}5)${NC} Bot Loglarını Görüntüle"
    echo -e "${CYAN}6)${NC} Bot Yapılandırmasını Düzenle"
    echo -e "${CYAN}7)${NC} Botu Kaldır"
    echo -e "${CYAN}0)${NC} Çıkış"
    echo ""
    read -p "Seçiminiz [0-7]: " choice
    
    case $choice in
        1) start_bot ;;
        2) stop_bot ;;
        3) restart_bot ;;
        4) update_bot ;;
        5) view_logs ;;
        6) edit_config ;;
        7) uninstall_bot ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Geçersiz seçim!${NC}"; sleep 2 ;;
    esac
done 