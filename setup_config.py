#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot konfigurasiýasyny döretmek üçin interaktiw skript

import os
import sys
import subprocess
import re
import time
from pathlib import Path

def validate_token(token):
    """
    Telegram Bot Token format we dogry bolmagyny barlaýar
    """
    if not token:
        return False
    
    # Standart token formaty: 123456789:ABCDefgh1234567890_AbcDEFghijk
    token_pattern = r'^\d+:[A-Za-z0-9_-]+$'
    return bool(re.match(token_pattern, token))

def validate_admin_id(admin_id):
    """
    Admin ID diňe sandan bolmagyny barlaýar
    """
    if not admin_id:
        return False
    
    return admin_id.isdigit()

def create_env_file(env_path):
    """
    .env faýlyny döredýär we gerekli maglumatlary ulanyjydan soraýar
    """
    print("\n=== ChatBot Konfigurasiýa Düzüji ===\n")
    
    # Eger faýl bar bolsa, onda bar bolan maglumatlary okaýarys
    env_vars = {}
    if os.path.exists(env_path):
        try:
            with open(env_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if '=' in line and not line.startswith('#'):
                        try:
                            key, value = line.split('=', 1)
                            env_vars[key.strip()] = value.strip().strip('"\'')
                        except ValueError:
                            # '=' işareti bar, ýöne bölünip bilinmeýär
                            print(f"Nädogry setir görneýär: {line}")
                            continue
        except Exception as e:
            print(f"Bar bolan .env faýlyny okamakda ýalňyşlyk: {e}")
            # Ýalňyşlyk bolsa ýöne dowam et, täze faýl döredilýär

    # Bot token
    bot_token = env_vars.get('BOT_TOKEN', '')
    if bot_token == "TOKEN_PLACEHOLDER":
        bot_token = ""
    
    # Bot token soramak
    while True:
        print("\n--- TELEGRAM BOT TOKEN ---")
        print("1. https://t.me/BotFather açyň")
        print("2. /newbot buýrugy bilen täze bot dörediň")
        print("3. Bot adyny we ulanyjy adyny giriziň")
        print("4. BotFather-den gelen tokeni göçürip alyň")
        
        if bot_token:
            token_input = input(f"Bot Token [{'*'*10}{bot_token[-5:] if len(bot_token) > 5 else bot_token}]: ") or bot_token
        else:
            token_input = input("Bot Token (zorunly): ")
        
        if token_input and validate_token(token_input):
            bot_token = token_input
            break
        else:
            print("Nädogry token format! Token 123456789:ABCDefgh1234_AbcDEF formatynda bolmaly.")
    
    # Admin ID
    admin_id = env_vars.get('ADMIN_ID', '')
    if admin_id == "123456789":
        admin_id = ""
    
    # Admin ID soramak
    while True:
        print("\n--- TELEGRAM ADMIN ID ---")
        print("1. Öz Telegram hasabyňyzda https://t.me/myidbot açyň")
        print("2. /getid buýrugy iberiň")
        print("3. Bot berýän ID belgiňizi göçürip alyň")
        
        if admin_id:
            admin_id_input = input(f"Admin ID [{admin_id}]: ") or admin_id
        else:
            admin_id_input = input("Admin ID (zorunly): ")
        
        if admin_id_input and validate_admin_id(admin_id_input):
            admin_id = admin_id_input
            break
        else:
            print("Nädogry Admin ID! Diňe sanlardan durýan ID bolmaly.")
    
    # MongoDB URI
    mongodb_uri = env_vars.get('MONGODB_URI', 'mongodb://localhost:27017')
    print("\n--- MONGODB BAGLANYŞYGY ---")
    mongodb_uri = input(f"MongoDB URI [{mongodb_uri}]: ") or mongodb_uri
    
    # Database ady
    database_name = env_vars.get('DATABASE_NAME', 'chatbot_db')
    database_name = input(f"Database ady [{database_name}]: ") or database_name
    
    # Ýazylyş .env faýly
    with open(env_path, 'w', encoding='utf-8') as f:
        f.write(f"BOT_TOKEN={bot_token}\n")
        f.write(f"ADMIN_ID={admin_id}\n")
        f.write(f"MONGODB_URI={mongodb_uri}\n")
        f.write(f"DATABASE_NAME={database_name}\n")
    
    print(f"\n.env faýly üstünlikli döredildi: {env_path}")
    print(f"Girizilen maglumatlar:\n- Bot Token: {'*'*10}{bot_token[-5:] if len(bot_token) > 5 else bot_token}")
    print(f"- Admin ID: {admin_id}")
    print(f"- MongoDB URI: {mongodb_uri}")
    print(f"- Database: {database_name}")
    return True

def check_mongodb():
    """
    MongoDB-niň gurnalandygyny we işleýändigini barlaýar
    """
    print("\n=== MongoDB Ýagdaýyny Barlaýaryn ===\n")
    
    mongodb_working = False
    try:
        # MongoDB gurnalandygyny barlaýarys
        mongo_check = subprocess.run(['mongod', '--version'], 
                                    stdout=subprocess.PIPE, 
                                    stderr=subprocess.PIPE,
                                    text=True)
        
        if mongo_check.returncode == 0:
            print("MongoDB gurnalandyr!\n")
            
            # MongoDB serweriniň işleýändigini barlaýarys
            try:
                mongo_status = subprocess.run(['systemctl', 'status', 'mongod'], 
                                        stdout=subprocess.PIPE, 
                                        stderr=subprocess.PIPE,
                                        text=True, timeout=5)
                
                if "active (running)" in mongo_status.stdout:
                    print("MongoDB serweri işleýär!")
                    mongodb_working = True
                else:
                    print("MongoDB serweri işlemeýär.")
                    start = input("MongoDB serweri başlatmakmy? (y/n): ")
                    if start.lower() == 'y':
                        try:
                            subprocess.run(['systemctl', 'start', 'mongod'], timeout=10)
                            time.sleep(3)  # MongoDB-niň başlamasy üçin wagt berýäris
                            
                            # Başladylandan soň täzeden barla
                            mongo_status = subprocess.run(['systemctl', 'status', 'mongod'], 
                                                stdout=subprocess.PIPE, 
                                                stderr=subprocess.PIPE,
                                                text=True, timeout=5)
                            
                            if "active (running)" in mongo_status.stdout:
                                print("MongoDB serweri başladyldy!")
                                mongodb_working = True
                            else:
                                print("MongoDB serweri başladylyp bilinmedi!")
                        except subprocess.TimeoutExpired:
                            print("MongoDB serwerini başlatmak wagt talap edýär, soňrak täzeden synanyşyň.")
            except subprocess.TimeoutExpired:
                print("MongoDB ýagdaýyny barlamak üçin wagty gutardy, ulgam meşgul bolmagy mümkin.")
                try:
                    # Service kontrol edip bolmasa, doğrudan port barlagy
                    import socket
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    s.settimeout(1)
                    result = s.connect_ex(('127.0.0.1', 27017))
                    if result == 0:
                        print("MongoDB porty açyk, serwer işleýär!")
                        mongodb_working = True
                    else:
                        print("MongoDB porty ýapyk, serwer işlemeýär.")
                    s.close()
                except:
                    pass
        else:
            print("MongoDB gurnalanmadyk ýa-da path-da tapylmady.")
            
            # Operasion ulgamy anykla
            os_release = ""
            if os.path.exists("/etc/os-release"):
                with open("/etc/os-release", "r") as f:
                    os_release = f.read().lower()
            
            if "ubuntu" in os_release or "debian" in os_release:
                print("Ubuntu/Debian ulgamyny anykladym")
                install = input("MongoDB gurmakmy? (y/n): ")
                if install.lower() == 'y':
                    print("\nMongoDB gurmagy başladýaryn...")
                    
                    # Keyserver we repo goşulyşy
                    print("MongoDB açar faýly alynýar...")
                    subprocess.run(['wget', '-qO', '-', 'https://www.mongodb.org/static/pgp/server-6.0.asc', '|', 'apt-key', 'add', '-'])
                    
                    # Ulanyjy kodnamesi
                    codename = subprocess.run(['lsb_release', '-cs'], 
                                            stdout=subprocess.PIPE, 
                                            stderr=subprocess.PIPE,
                                            text=True).stdout.strip()
                    
                    # Repo goşulyşy
                    print(f"Kodname: {codename}")
                    
                    try:
                        with open("/etc/apt/sources.list.d/mongodb-org-6.0.list", "w") as f:
                            f.write(f"deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu {codename}/mongodb-org/6.0 multiverse")
                    except Exception:
                        print("MongoDB repo list döredip bolamadym, alternatiw usul ulanylyar.")
                    
                    # Paketleri gurna
                    print("Paket depolary täzelenýär...")
                    subprocess.run(['apt-get', 'update'])
                    
                    print("MongoDB paketleri gurnalyar...")
                    subprocess.run(['apt-get', 'install', '-y', 'mongodb-org'])
                    
                    # Serwisi başlat
                    print("MongoDB serweri başladylýar...")
                    subprocess.run(['systemctl', 'daemon-reload'])
                    subprocess.run(['systemctl', 'enable', 'mongod'])
                    subprocess.run(['systemctl', 'start', 'mongod'])
                    
                    # Barla
                    time.sleep(5)  # MongoDB-niň başlamasy üçin wagt berýäris
                    mongo_status = subprocess.run(['systemctl', 'status', 'mongod'], 
                                                stdout=subprocess.PIPE, 
                                                stderr=subprocess.PIPE,
                                                text=True)
                    
                    if "active (running)" in mongo_status.stdout:
                        print("\nMongoDB üstünlikli guruldy we işledildi!")
                        mongodb_working = True
                    else:
                        print("\nMongoDB guruldy, emma işledilip bilinmedi. Ulgamy restart ediň ýa-da:")
                        print("sudo systemctl start mongod")
            else:
                print("MongoDB gurmak barada giňişleýin maglumat üçin:")
                print("https://www.mongodb.com/docs/manual/administration/install-community/")
                
            if not mongodb_working:
                print("\nBot SQLite maglumat bazasy bilen hem işläp bilýär, MongoDB hökman däl.")
    except Exception as e:
        print(f"MongoDB-ni barlamakda ýalňyşlyk: {e}")
    
    return mongodb_working

def check_bot_py_file(bot_path):
    """Bot.py faýlyndaky potensial meseleleri düzet"""
    if not os.path.exists(bot_path):
        print(f"DUÝDURYŞ: {bot_path} faýly tapylmady!")
        return False
    
    print("\n=== Bot.py faýlyny barlaýaryn ===")
    
    try:
        with open(bot_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        modified = False
        
        # ADMIN_ID işleýşi barla
        if 'ADMIN_ID = int(os.getenv("ADMIN_ID", 0))' in content:
            content = content.replace(
                'ADMIN_ID = int(os.getenv("ADMIN_ID", 0))',
                'try:\n    admin_id_str = os.getenv("ADMIN_ID", "0")\n    # Diňe san bolsa, integer-e öwür\n    admin_id_str = admin_id_str.strip() if isinstance(admin_id_str, str) else "0"\n    admin_id_str = \'\'.join(c for c in admin_id_str if c.isdigit()) # diňe sanlar\n    ADMIN_ID = int(admin_id_str) if admin_id_str else 0\nexcept Exception as e:\n    print(f"Admin ID öwrülip bilmedi: {str(e)}")\n    ADMIN_ID = 0'
            )
            print("ADMIN_ID işlenişi düzedildi")
            modified = True
        
        # .env ýüklemesini barla
        if 'load_dotenv()' in content and 'try:\n    load_dotenv()' not in content:
            content = content.replace(
                'load_dotenv()',
                'try:\n    load_dotenv()\nexcept Exception:\n    try:\n        load_dotenv(".env.test")\n    except Exception as e:\n        print(f"Konfigurasiýa ýüklenip bilmedi: {str(e)}")'
            )
            print(".env ýüklenişi düzedildi")
            modified = True
        
        # Eger üýtgeşme bar bolsa faýly ýaz
        if modified:
            with open(bot_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Bot.py faýly üstünlikli düzedildi")
        else:
            print("Bot.py faýly ok ýagdaýda - düzetme gerek däl")
        
        return True
    except Exception as e:
        print(f"Bot.py faýlyny barlamakda ýalňyşlyk: {e}")
        return False

def test_mongodb_connectivity(uri="mongodb://localhost:27017"):
    """MongoDB bilen baglanyşyk synanyşygy"""
    print(f"\n=== MongoDB baglanyşygyny barlaýaryn: {uri} ===")
    
    # URI boş bolsa standart baha ulan
    if not uri or uri.strip() == "":
        uri = "mongodb://localhost:27017"
        print(f"URI boş, standart baha ulanylyar: {uri}")
    
    try:
        import pymongo
        from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
        
        print("MongoDB baglanyşygy synanyşylýar...")
        client = pymongo.MongoClient(uri, serverSelectionTimeoutMS=5000)
        # Baglanyşygy barla
        client.admin.command('ping')
        print("MongoDB bilen baglanyşyk üstünlikli!")
        return True
    except ImportError:
        print("pymongo kitaphanasy tapylmady, gurnalyp başlanylýar...")
        try:
            subprocess.run([sys.executable, '-m', 'pip', 'install', 'pymongo'])
            print("pymongo guruldy, täzeden synanyşylýar...")
            return test_mongodb_connectivity(uri)
        except Exception as e:
            print(f"pymongo gurnamakda ýalňyşlyk: {e}")
            return False
    except (ConnectionFailure, ServerSelectionTimeoutError) as e:
        print(f"MongoDB bilen baglanyşyk edip bolmady: {e}")
        print("Sebäpler:")
        print("1. MongoDB serweri işläp duran bolmagy mümkin")
        print("2. Firewall baglanşyga päsgel berýän bolmagy mümkin")
        print("3. URI nädogry bolmagy mümkin")
        print("\nMaslahat: SQLite ulanmak isleseňiz, bot SQLite bilen hem işläp bilýär.")
        return False
    except Exception as e:
        print(f"MongoDB-ni barlamakda näbelli ýalňyşlyk: {e}")
        return False

def main():
    """
    Esasy işleýiş funksiýasy
    """
    # Eger /opt/chatbot katalogynda işleýän bolsa şol ýerden, bolmasa häzirki katalogdan
    chatbot_dir = "/opt/chatbot" if os.path.exists("/opt/chatbot") else os.getcwd()
    env_path = os.path.join(chatbot_dir, ".env")
    bot_path = os.path.join(chatbot_dir, "bot.py")
    
    print(f"ChatBot katalogy: {chatbot_dir}")
    
    # Bot.py faýlyny barla
    check_bot_py_file(bot_path)
    
    # .env faýlyny döredýäris
    create_env_file(env_path)
    
    # MongoDB baglanyşygyny barla
    if check_mongodb():
        # .env faýlyndan MongoDB URI al
        mongodb_uri = None
        if os.path.exists(env_path):
            with open(env_path, 'r', encoding='utf-8') as f:
                for line in f:
                    if line.startswith('MONGODB_URI='):
                        mongodb_uri = line.strip().split('=', 1)[1]
                        break
        
        if mongodb_uri:
            test_mongodb_connectivity(mongodb_uri)
        else:
            test_mongodb_connectivity()
    
    print("\n=== Sazlama tamamlandy! ===")
    print("Indi boty täzeden işledip bilersiňiz:")
    print("systemctl restart chatbot.service")

if __name__ == "__main__":
    main() 