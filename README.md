# TurkmenBot - Telegram Grup Yönetim Botu 🤖

TurkmenBot, Telegram gruplarınızı kolayca yönetmenizi sağlayan çok dilli bir bot çözümüdür. Üç dil desteği (Türkmence, Türkçe, Rusça) ile grup yönetimini basit ve etkili bir şekilde gerçekleştirebilirsiniz.

## Özellikler ✨

- **Grup Yönetimi:** Üyeleri yasaklama, susturma, uyarı verme gibi temel moderasyon işlemleri
- **Otomatik Moderasyon:** İstenmeyen içeriklere karşı otomatik koruma
- **Çok Dilli Destek:** Türkmence, Türkçe ve Rusça dil seçenekleri
- **Özelleştirilebilir Komutlar:** Grubunuza özel komutlar oluşturabilme
- **Karşılama Mesajları:** Yeni üyelere özelleştirilebilir karşılama mesajları
- **İstatistikler:** Grup aktivite istatistiklerini görüntüleme
- **Admin-Only Komutlar:** Yalnızca yöneticilerin kullanabileceği özel komutlar

## Kurulum 🛠️

### Sistem Gereksinimleri

- Python 3.8+
- MongoDB
- Telegram Bot Token (BotFather'dan alınabilir)

### Otomatik Kurulum (Ubuntu)

TurkmenBot'u Ubuntu sunucunuza kurmak için:

```bash
# Kurulum betiğini indirin
wget -O install.sh https://raw.githubusercontent.com/hackedzed/TurkmenBot/main/install.sh

# Yürütme iznini verin
chmod +x install.sh

# Kurulumu başlatın
sudo ./install.sh
```

Kurulum sihirbazı size Bot Token ve diğer gerekli bilgileri soracaktır.

### Manuel Kurulum

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/USERNAME/TurkmenBot.git
   cd TurkmenBot
   ```

2. Sanal ortam oluşturun ve bağımlılıkları yükleyin:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. `.env` dosyasını oluşturun:
   ```
   BOT_TOKEN=your_telegram_bot_token
   MONGODB_URI=mongodb://localhost:27017
   DATABASE_NAME=turkmenbot_db
   ADMIN_ID=your_telegram_id
   ```

4. Botu başlatın:
   ```bash
   python bot.py
   ```

## Kullanım 📝

### Temel Komutlar

- `/start` - Botu başlatır ve yardım menüsünü gösterir
- `/help` - Kullanılabilir komutları listeler
- `/settings` - Bot ayarlarını düzenler
- `/lang` - Bot dilini değiştirir
- `/stats` - Grup istatistiklerini görüntüler
- `/version` - Bot versiyonunu gösterir

### Admin Komutları

- `/ban` - Kullanıcıyı gruptan yasaklar
- `/unban` - Kullanıcının yasağını kaldırır
- `/mute` - Kullanıcıyı susturur
- `/unmute` - Kullanıcının susturmasını kaldırır
- `/warn` - Kullanıcıya uyarı verir
- `/unwarn` - Kullanıcının uyarısını kaldırır
- `/pin` - Mesajı sabitler
- `/unpin` - Sabitlenmiş mesajı kaldırır
- `/add_command` - Özel komut ekler

## Yönetim Paneli 🖥️

TurkmenBot, kolay yönetim için bir terminal tabanlı yönetim paneli sunar. Panele erişmek için:

```bash
sudo botpanel
```

Yönetim paneli aracılığıyla şunları yapabilirsiniz:
- Botu başlatma, durdurma ve yeniden başlatma
- Bot loglarını görüntüleme
- Yapılandırmayı düzenleme
- Botu güncelleme

## Güncelleme ⬆️

Botu güncellemek için yönetim panelini kullanabilir veya şu komutu çalıştırabilirsiniz:

```bash
sudo /opt/turkmenbot/update.sh
```

## Lisans 📄

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## İletişim 📞

Sorularınız için:
- Telegram: [@TurkmenBot_Support](https://t.me/TurkmenBot_Support)
- Email: info@turkmenbot.com

---

**TurkmenBot** - Telegram gruplarınızı daha güvenli ve daha kolay yönetin! 