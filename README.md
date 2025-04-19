# ChatBot - Turkmenistan üçin Telegram boty 🤖

ChatBot, Telegram gruplaryny dolandyrmak üçin Türkmençe dilli çözgütdir. Turkmenistan üçin ýörite taýýarlanan bu bot bilen gruplarynyz aňsat we täsirli usulda dolandyryp bilersiňiz.

## Aýratynlyklar ✨

- **Topar Dolandyryş:** Agzalary gadagan etmek, sessiz etmek, duýduryş bermek ýaly esasy moderasiýa işleri
- **Awtomatik Moderasiýa:** Islenilmeýän mazmuny öňünden saklamak 
- **Türkmençe Interfeýs:** Türkmençe dil goldawy
- **Özelleşdirilýän Buýruklar:** Toparyňyz üçin ýörite buýruklar döredip bilmek
- **Hoş geldiňiz Habarlary:** Täze agzalar üçin özelleşdirilýän hoş geldiňiz habarlary
- **Statistikalar:** Topar işjeňliginiň statistikalaryny görmek
- **Diňe Administrator Buýruklary:** Diňe administratorlaryň ulanyp biljek ýörite buýruklar

## Gurnalyş 🛠️

### Ulgam Talaplary

- Python 3.8+
- MongoDB
- Telegram Bot Token (BotFather-dan alyp bolar)

### Awtomatik Gurnalyş (Ubuntu)

ChatBot-y Ubuntu serwerinizde gurmak üçin:

```bash
# Gurnalyş skriptini ýükläň
wget -O install.sh https://raw.githubusercontent.com/hackedcdn/chatbot/main/install.sh

# Ýerine ýetirmek ygtyýaryny beriň
chmod +x install.sh

# Gurnalyşy başladyň
sudo ./install.sh
```

Gurnalyş wizardy size Bot Token we beýleki gerekli maglumatlary sorar.

### El bilen Gurnalyş

1. Repony klonlaň:
   ```bash
   git clone https://github.com/hackedcdn/chatbot.git
   cd chatbot
   ```

2. Wirtual gurşaw döredip, baglylyky guramalary gurnap alyň:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. `.env` faýlyny dörediň:
   ```
   BOT_TOKEN=your_telegram_bot_token
   MONGODB_URI=mongodb://localhost:27017
   DATABASE_NAME=turkmenbot_db
   ADMIN_ID=your_telegram_id
   ```

4. Boty başladyň:
   ```bash
   python bot.py
   ```

## Ulanmak 📝

### Esasy Buýruklar

- `/start` - Boty başladyp, kömek menýusyny görkezýär
- `/help` - Elýeterli buýruklary görkezýär
- `/settings` - Bot sazlamalaryny düzedýär
- `/stats` - Topar statistikalaryny görkezýär
- `/version` - Bot wersiýasyny görkezýär

### Administrator Buýruklary

- `/ban` - Ulanyjyny topardan gadagan edýär
- `/unban` - Ulanyjynyň gadaganyny aýyrýar
- `/mute` - Ulanyjyny sessiz edýär
- `/unmute` - Ulanyjynyň sessizligini aýyrýar
- `/warn` - Ulanyjy duýduryş berýär
- `/unwarn` - Ulanyjynyň duýduryşyny aýyrýar
- `/pin` - Habary berkidýär
- `/unpin` - Berkidilen habary aýyrýar
- `/add_command` - Ýörite buýruk goşýar

## Dolandyryş Paneli 🖥️

ChatBot, aňsat dolandyrmak üçin terminal esasly dolandyryş panelini hödürleýär. Panele girmek üçin:

```bash
sudo botpanel
```

Dolandyryş paneli arkaly şulary edip bilersiňiz:
- Boty başlatmak, duruzmak we täzeden başlatmak
- Bot loglaryny görmek
- Konfigurasiýany redaktirlemek
- Boty täzelemek

## Täzelemek ⬆️

Boty täzelemek üçin dolandyryş panelini ulanyp bilersiňiz ýa-da şu buýrugy işledip bilersiňiz:

```bash
sudo /opt/turkmenbot/update.sh
```

## Ygtyýarnama 📄

Bu taslama [MIT Ygtyýarnamasy](LICENSE) bilen ygtyýarlandyrylan.

## Habarlaşmak 📞

Soraglaryňyz üçin:
- GitHub: [@hackedcdn](https://github.com/hackedcdn/chatbot)

---

**ChatBot** - Turkmenistan üçin döredilen Telegram boty! 
*Dolandyryjy: hackedcdn* 