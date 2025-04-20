# ChatBot Gurnalyş Gollanmasy

Bu dokument ChatBot-y gurmak we sazlamak üçin ädimme-ädim görkezmeler berýär.

## Talaplar

- Python 3.7 ýa-da has ýokary
- MongoDB (hökmany däl, SQLite hem ulanyp bolýar)
- Internet baglanyşygy

## Gurnalyş Ädimleri

### 1. Awtomatiki Gurnalyş (Maslahat berilýär)

Iň aňsat gurnalyş usuly, awtomatiki gurnalyş skriptini ulanmakdyr:

#### Linux/Mac

```bash
sudo python3 scripts/install_update.py
```

#### Windows

PowerShell ýa-da Command Prompt-y Administrator hökmünde açyň we şu buýrugy ýerine ýetiriň:

```
python scripts\install_update.py
```

Skript, gurnalyş wagtynda sizden Bot Token we Admin ID sorar.

### 2. El bilen Gurnalyş

#### 1. Zerur paketleri gurmak:

```
pip install -r requirements.txt
```

#### 2. Konfigurasiýa faýlyny döretmek:

```
python tools/setup_config.py
```

#### 3. MongoDB gurluşyny barlaň:

MongoDB gurlup we işläp durýan bolmaly. Gurulmadyk bolsa, gurnalyş görkezmelerine serediň:
https://www.mongodb.com/docs/manual/administration/install-community/

#### 4. Boty başladyň:

```
python bot.py
```

## Meseleleri çözmek

### Indentation Ýalňyşlygy

Eger "indentation error" ýalňyşlygy alýan bolsa, indentation düzetmek guralyny işlediň:

```
python tools/fix_indentation.py bot.py
```

### MongoDB Baglanyşyk Meselesi

MongoDB baglanyşyk meselesi bolsa, şu ädimleri ýerine ýetiriň:

1. MongoDB-niň işleýändigini barlaň
2. URI-niň dogrudygyny barlaň
3. Gerek bolsa konfigurasiýa guralyny täzeden işlediň:

```
python tools/setup_config.py
```

## Hyzmat Hökmünde Bellemek (Linux)

Boty hyzmat hökmünde işletmek üçin, gurnalyş skripti bir hyzmat faýlyny döredýär. Şu buýruklary ulanyp bilersiňiz:

```
sudo systemctl start chatbot    # Boty başlat
sudo systemctl stop chatbot     # Boty durdur
sudo systemctl restart chatbot  # Boty täzeden başlat
sudo systemctl status chatbot   # Bot ýagdaýyny barla
```

## Windows-da Başlatmak

Windows-da bot, iş stolunda döredilen "ChatBot.bat" faýly bilen aňsat başladylyp bilner. 