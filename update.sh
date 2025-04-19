#!/bin/bash

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner göster
echo -e "${BLUE}"
echo "  _______         _                          ____        _   "
echo " |__   __|       | |                        |  _ \      | |  "
echo "    | |_   _ _ __| | ___ __ ___   ___ _ __ | |_) | ___ | |_ "
echo "    | | | | | '__| |/ / '_ \` _ \ / _ \ '_ \|  _ < / _ \| __|"
echo "    | | |_| | |  |   <| | | | | |  __/ | | | |_) | (_) | |_ "
echo "    |_|\__,_|_|  |_|\_\_| |_| |_|\___|_| |_|____/ \___/ \__|"
echo -e "${NC}"
echo -e "${YELLOW}TurkmenBot Güncelleme Aracı${NC}"
echo ""

# Root kontrolü
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Bu işlem için root yetkileri gerekiyor.${NC}"
    echo -e "Lütfen ${YELLOW}sudo ./update.sh${NC} komutu ile tekrar deneyin."
    exit 1
fi

# Kurulum dizini
INSTALL_DIR="/opt/turkmenbot"

# Mevcut .env dosyasını yedekle
echo -e "\n${BLUE}Mevcut yapılandırmalar yedekleniyor...${NC}"
if [ -f "$INSTALL_DIR/.env" ]; then
    cp $INSTALL_DIR/.env $INSTALL_DIR/.env.backup
    echo -e "${GREEN}Yapılandırma dosyası yedeklendi: .env.backup${NC}"
fi

# Servisi durdur
echo -e "\n${BLUE}Bot servisi durduruluyor...${NC}"
systemctl stop turkmenbot

# Güncellemeleri kontrol et
echo -e "\n${BLUE}Güncellemeler kontrol ediliyor...${NC}"
cd $INSTALL_DIR
git fetch

# Değişiklikleri kontrol et
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    echo -e "${GREEN}Bot zaten güncel.${NC}"
else
    echo -e "${YELLOW}Yeni güncellemeler bulundu. İndiriliyor...${NC}"
    
    # Değişiklikleri kaydet
    git stash
    
    # Güncellemeleri al
    git pull
    
    # Python bağımlılıklarını güncelle
    echo -e "\n${BLUE}Python bağımlılıkları güncelleniyor...${NC}"
    pip3 install -r requirements.txt --upgrade
    
    echo -e "${GREEN}Güncelleme tamamlandı.${NC}"
fi

# Yedeklenen .env dosyasını geri yükle
if [ -f "$INSTALL_DIR/.env.backup" ]; then
    cp $INSTALL_DIR/.env.backup $INSTALL_DIR/.env
    echo -e "${GREEN}Yapılandırma dosyası geri yüklendi.${NC}"
fi

# Servisi yeniden başlat
echo -e "\n${BLUE}Bot servisi yeniden başlatılıyor...${NC}"
systemctl start turkmenbot

# Bot durumu
echo -e "\n${GREEN}Bot başarıyla güncellendi!${NC}"
echo -e "Bot durumu: $(systemctl is-active turkmenbot)"
echo "" 