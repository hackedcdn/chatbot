# ChatBot Ulanmak Gollanmasy

Bu dokument, ChatBot-y nähili ulanmalydygy barada maglumat berýär.

## Başlangyç

Bot gurlandan we işledilenden soň, Telegram-da botuňyzy gözläp we onuň bilen aragatnaşyk saklap bilersiňiz.

1. Telegram-y açyň
2. BotFather-den alan bot ulanyjy adyňyzy gözläň (@YourBotName)
3. Boty başlatmak üçin `/start` buýrugyny iberiň

## Elýeterli Buýruklar

Bot, aşakdaky buýruklary goldaýar:

- `/start` - Boty başladýar we hoş geldiňiz habaryny görkezýär
- `/help` - Kömek menýusyny görkezýär
- `/settings` - Bot sazlamalaryny görkezýär we üýtgetmäge mümkinçilik berýär

## Admin Buýruklary

Admin ID bilen kesgitlenen ulanyjylar goşmaça şu buýruklary ulanyp bilýärler:

- `/stats` - Bot statistikalaryny görkezýär
- `/ban [sebäp]` - Ulanyjyny gadagan edýär (bir habara jogap bereniňizde)
- `/unban` - Ulanyjynyň gadaganlygyny aýyrýar
- `/mute [minut]` - Ulanyjyny bellenen wagt üçin sessiz edýär
- `/unmute` - Ulanyjynyň sessizligini aýyrýar

## Topar Dolandyryşy

Bot, Telegram toparlaryna administrator hökmünde goşulanda şu mümkinçilikleri hödürleýär:

1. Agza dolandyryşy
2. Sessiz etmek/Gadagan etmek dolandyryşy
3. Topar statistikalaryny yzarlamak

## Bot Dolandyryş Paneli

Bot, buýruk setirinde dolandyryş panelini hödürleýär. Bu panele girmek üçin:

### Linux

```
chatbot
```

ýa-da

```
cd /opt/chatbot && python panel.py
```

### Windows

Iş stoluňyzdaky "ChatBot_Panel.bat" faýlyny işlediň.

## Panel Mümkinçilikleri

Dolandyryş paneli aşakdaky işleri ýerine ýetirmäge mümkinçilik berýär:

1. Bot ýagdaýyny barlamak
2. Boty başlatmak/durdurmak
3. Habar statistikalaryny görmek
4. Ulanyjy sanawyny görmek
5. Konfigurasiýany redaktirlemek
6. Bot-y täzelemek
7. Ulgam loglaryny görmek

## Meseleleri çözmek

Köplenç duş gelýän meseleler üçin:

1. Bot jogap bermeýän bolsa, onuň ýagdaýyny barlaň (panel ýa-da `systemctl status chatbot`)
2. MongoDB baglanyşyk meseleleri üçin, MongoDB hyzmaty işleýändigini anyklaň
3. Token meseleleri üçin, BotFather-den dogry tokeny alandygyňyzy anyklaň

## Bot Täzelemek

Boty täzelemek üçin:

```
python scripts/install_update.py
```

Saýlawlardan "Täzelemek" saýlawyny saýlaň.

## Goşmaça Maglumatlar

Türkmenistan üçin taýýarlanan bu ChatBot, esasy topar dolandyryş mümkinçiliklerini goldaýar we Türkmen dilinde hyzmat edýär. Bot-y ulanmak boýunça has köp sazlamak isleseňiz, çeşme koduna serediň. 