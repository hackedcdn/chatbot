#!/bin/bash

# TurkmenBot kurulum betiği
# Copyright (c) 2023 TurkmenBot

# Renk tanımlamaları
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # Rengi sıfırla

echo -e "${GREEN}TurkmenBot Kurulum Betiği${NC}"
echo "----------------------------------------"

# Root kontrolü
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Lütfen bu betiği root olarak çalıştırın (sudo kullanın)${NC}"
  exit 1
fi

# Sistem güncellemesi
echo -e "${YELLOW}Sistem güncelleniyor...${NC}"
apt update && apt upgrade -y

# Gerekli paketlerin kurulumu
echo -e "${YELLOW}Gerekli paketler kuruluyor...${NC}"
apt install -y python3 python3-pip python3-venv git screen

# Kurulum dizini
INSTALL_DIR="/opt/turkmenbot"

# Önceki kurulum kontrolü
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Önceki kurulum tespit edildi. Ne yapmak istersiniz?${NC}"
  echo "1) Kaldır ve yeniden kur"
  echo "2) Çık"
  read -p "Seçiminiz (1/2): " choice
  
  if [ "$choice" = "1" ]; then
    echo -e "${YELLOW}Önceki kurulum kaldırılıyor...${NC}"
    rm -rf "$INSTALL_DIR"
  else
    echo -e "${YELLOW}Kurulum iptal edildi.${NC}"
    exit 0
  fi
fi

# Kurulum dizinini oluştur
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Bot kodlarını indir
echo -e "${YELLOW}Bot kodları indiriliyor...${NC}"
git clone https://github.com/USERNAME/TurkmenBot.git .

# Sanal ortam oluştur ve bağımlılıkları kur
echo -e "${YELLOW}Python sanal ortamı oluşturuluyor...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Yapılandırma dosyası oluştur
echo -e "${YELLOW}Yapılandırma dosyası oluşturuluyor...${NC}"
if [ ! -f ".env" ]; then
  echo -e "${GREEN}Bot yapılandırmasını ayarlayalım${NC}"
  read -p "Telegram Bot Token: " bot_token
  read -p "MongoDB URI (örn: mongodb://localhost:27017): " mongodb_uri
  read -p "MongoDB Veritabanı Adı: " db_name
  read -p "Admin Kullanıcı ID: " admin_id
  
  cat > .env << EOL
BOT_TOKEN=$bot_token
MONGODB_URI=$mongodb_uri
DATABASE_NAME=$db_name
ADMIN_ID=$admin_id
EOL
  
  echo -e "${GREEN}Yapılandırma dosyası başarıyla oluşturuldu${NC}"
else
  echo -e "${YELLOW}Mevcut .env dosyası korundu${NC}"
fi

# Servis dosyası oluştur
echo -e "${YELLOW}Sistem servisi oluşturuluyor...${NC}"
cat > /etc/systemd/system/turkmenbot.service << EOL
[Unit]
Description=TurkmenBot Telegram Bot Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python3 $INSTALL_DIR/bot.py
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=turkmenbot

[Install]
WantedBy=multi-user.target
EOL

# Yönetim paneli betiği
echo -e "${YELLOW}Yönetim paneli betiği oluşturuluyor...${NC}"
cat > /usr/local/bin/botpanel << EOL
#!/bin/bash

# TurkmenBot Yönetim Paneli
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "\${GREEN}TurkmenBot Yönetim Paneli\${NC}"
echo "----------------------------------------"

# Bot durumunu kontrol et
if systemctl is-active --quiet turkmenbot.service; then
  echo -e "Bot Durumu: \${GREEN}Çalışıyor\${NC}"
else
  echo -e "Bot Durumu: \${RED}Durduruldu\${NC}"
fi

echo ""
echo "1) Botu başlat"
echo "2) Botu durdur"
echo "3) Botu yeniden başlat"
echo "4) Bot loglarını göster"
echo "5) Yapılandırmayı düzenle"
echo "6) Botu güncelle"
echo "7) Çıkış"
echo ""
read -p "Seçiminiz: " choice

case \$choice in
  1)
    systemctl start turkmenbot.service
    echo -e "\${GREEN}Bot başlatıldı\${NC}"
    ;;
  2)
    systemctl stop turkmenbot.service
    echo -e "\${YELLOW}Bot durduruldu\${NC}"
    ;;
  3)
    systemctl restart turkmenbot.service
    echo -e "\${GREEN}Bot yeniden başlatıldı\${NC}"
    ;;
  4)
    journalctl -u turkmenbot.service -f
    ;;
  5)
    nano $INSTALL_DIR/.env
    echo -e "\${YELLOW}Yapılandırma güncellendi, yeniden başlatılıyor...\${NC}"
    systemctl restart turkmenbot.service
    ;;
  6)
    cd $INSTALL_DIR
    git pull
    source venv/bin/activate
    pip install -r requirements.txt
    systemctl restart turkmenbot.service
    echo -e "\${GREEN}Bot güncellendi ve yeniden başlatıldı\${NC}"
    ;;
  7)
    exit 0
    ;;
  *)
    echo -e "\${RED}Geçersiz seçim\${NC}"
    ;;
esac
EOL

# Yönetim paneli betiğini çalıştırılabilir yap
chmod +x /usr/local/bin/botpanel

# Güncelleme betiği
echo -e "${YELLOW}Güncelleme betiği oluşturuluyor...${NC}"
cat > "$INSTALL_DIR/update.sh" << EOL
#!/bin/bash
cd $INSTALL_DIR
git pull
source venv/bin/activate
pip install -r requirements.txt
systemctl restart turkmenbot.service
echo "TurkmenBot güncellendi"
EOL

chmod +x "$INSTALL_DIR/update.sh"

# Servisi başlat
echo -e "${YELLOW}Servis başlatılıyor...${NC}"
systemctl daemon-reload
systemctl enable turkmenbot.service
systemctl start turkmenbot.service

echo -e "${GREEN}TurkmenBot başarıyla kuruldu!${NC}"
echo -e "Yönetim paneline erişmek için ${YELLOW}sudo botpanel${NC} komutunu kullanabilirsiniz."
echo "----------------------------------------" 