#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot - Konfigurasiýa düzediş skripti
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

import os
import re
import sys
import logging
import subprocess
from datetime import datetime
import platform

# Ulgam ýollaryny kesgitle - Windows/Linux üçin aýratyn
is_windows = platform.system() == "Windows"
if is_windows:
    # Windows ýollary
    INSTALL_DIR = os.path.dirname(os.path.abspath(__file__))
else:
    # Linux ýollary
    INSTALL_DIR = "/opt/chatbot"

ENV_FILE = os.path.join(INSTALL_DIR, ".env")
ENV_BACKUP = os.path.join(INSTALL_DIR, f".env.backup.{datetime.now().strftime('%Y%m%d%H%M%S')}")

# Logging düzgünleşdir
log_file = os.path.join(INSTALL_DIR, "config_fix.log")
os.makedirs(os.path.dirname(log_file), exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def create_backup():
    """Öňki konfigurasiýa faýlynyň ätiýaçlyk nusgasyny döret"""
    if os.path.exists(ENV_FILE):
        try:
            # Windows/Linux üçin aýratyn göçürme buýrugy
            if is_windows:
                import shutil
                shutil.copy2(ENV_FILE, ENV_BACKUP)
            else:
                os.system(f"cp {ENV_FILE} {ENV_BACKUP}")
                
            logger.info(f"Ätiýaçlyk nusgasy döredildi: {ENV_BACKUP}")
            return True
        except Exception as e:
            logger.error(f"Ätiýaçlyk nusgasy döredilip bilinmedi: {str(e)}")
    return False

def fix_env_file():
    """Bot .env faýlyny düzet"""
    logger.info("Bot konfigurasiýa faýly düzedilýär...")
    
    # Öňki .env faýlyny ätiýaçla
    create_backup()
    
    # Konfigurasiýa maglumatlaryny taýýarla
    config = {
        "BOT_TOKEN": "TOKEN_PLACEHOLDER",
        "MONGODB_URI": "mongodb://localhost:27017",
        "DATABASE_NAME": "chatbot_db",
        "ADMIN_ID": "123456789"
    }
    
    # Öňki .env faýlyndan maglumatlary al
    if os.path.exists(ENV_FILE):
        try:
            with open(ENV_FILE, 'r') as f:
                content = f.read()
                
            # Token we Admin ID maglumatlaryny çykar
            token_match = re.search(r'BOT_TOKEN[=:](.*?)[\n\r]', content + "\n")
            mongo_match = re.search(r'MONGO.*URI[=:](.*?)[\n\r]', content + "\n") 
            db_match = re.search(r'DATABASE.*NAME[=:](.*?)[\n\r]', content + "\n")
            admin_match = re.search(r'ADMIN.*ID[=:](.*?)[\n\r]', content + "\n")
            
            if token_match:
                config["BOT_TOKEN"] = token_match.group(1).strip()
            if mongo_match:
                config["MONGODB_URI"] = mongo_match.group(1).strip()
            if db_match:
                config["DATABASE_NAME"] = db_match.group(1).strip()
            if admin_match:
                config["ADMIN_ID"] = admin_match.group(1).strip()
                
            # Artykmaç simwollary arassala
            config["BOT_TOKEN"] = re.sub(r'[^a-zA-Z0-9\.:_-]', '', config["BOT_TOKEN"])
            config["MONGODB_URI"] = re.sub(r'[^a-zA-Z0-9\.:_\/@-]', '', config["MONGODB_URI"])
            config["DATABASE_NAME"] = re.sub(r'[^a-zA-Z0-9\.:_-]', '', config["DATABASE_NAME"])
            config["ADMIN_ID"] = re.sub(r'[^0-9]', '', config["ADMIN_ID"])
            
            # Boş bolsa, düzet
            if not config["ADMIN_ID"]:
                config["ADMIN_ID"] = "123456789"
                logger.warning("ADMIN_ID boş, standart baha ulanylýar: 123456789")
            
            logger.info(f"Konfigurasiýa maglumatlary alyndy: TOKEN={len(config['BOT_TOKEN'])>0}, ADMIN_ID={config['ADMIN_ID']}")
                
        except Exception as e:
            logger.error(f"Öňki konfigurasiýany okap bolmady: {str(e)}")
    else:
        logger.warning(f".env faýly tapylmady: {ENV_FILE}. Täze faýl döredilýär.")
    
    # Täze konfigurasiýa faýlyny ýaz
    try:
        with open(ENV_FILE, 'w') as f:
            for key, value in config.items():
                f.write(f"{key}={value}\n")
        
        # Rugsat hukuklaryny düzet (diňe Linux-da)
        if not is_windows:
            os.system(f"chmod 644 {ENV_FILE}")
            
        logger.info("Täze konfigurasiýa faýly döredildi")
        
        # Bot kodyna hem düzediş giriz
        fix_bot_code()
        
        return True
    except Exception as e:
        logger.error(f"Täze konfigurasiýa faýlyny döredip bolmady: {str(e)}")
        return False

def fix_bot_code():
    """Bot.py dosyasyny düzet - ADMIN_ID int() dönüşümü problemasyny çöz"""
    bot_file = os.path.join(INSTALL_DIR, "bot.py")
    
    if os.path.exists(bot_file):
        try:
            with open(bot_file, 'r') as f:
                content = f.read()
            
            # ADMIN_ID int() dönüşümünü düzet
            if "ADMIN_ID = int(os.getenv" in content:
                fixed_content = content.replace(
                    "ADMIN_ID = int(os.getenv(\"ADMIN_ID\", 0))",
                    'try:\n    admin_id_str = os.getenv("ADMIN_ID", "0").strip()\n    admin_id_str = \'\'.join([c for c in admin_id_str if c.isdigit()])\n    ADMIN_ID = int(admin_id_str) if admin_id_str else 0\nexcept ValueError:\n    ADMIN_ID = 0'
                )
                
                with open(bot_file, 'w') as f:
                    f.write(fixed_content)
                    
                logger.info("Bot kodyna ADMIN_ID düzedişi girizildi")
            else:
                logger.info("Bot kodynda ADMIN_ID int() dönüşümi barlandy, düzedişe zerurlyk ýok")
        except Exception as e:
            logger.error(f"Bot kodyna düzediş girizilip bilinmedi: {str(e)}")
    else:
        logger.warning(f"Bot.py faýly tapylmady: {bot_file}")

def check_mongodb():
    """MongoDB serweriniň işleýändigini barla"""
    logger.info("MongoDB hyzmaty barlanýar...")
    
    # Windows-da MongoDB-ni barlamak başgaça işleýär
    if is_windows:
        try:
            # Windows services command
            result = subprocess.run(["sc", "query", "MongoDB"], 
                                  stdout=subprocess.PIPE, 
                                  stderr=subprocess.PIPE,
                                  text=True)
            
            if "RUNNING" in result.stdout:
                logger.info("MongoDB işleýär (Windows)")
                return True
            else:
                logger.warning("MongoDB işlemeýär (Windows), ýöne bu gurşawda düzedilip bilinmeýär")
                return False
        except Exception as e:
            logger.error(f"MongoDB hyzmaty barlananda ýalňyşlyk (Windows): {str(e)}")
            return False
    else:
        # Linux üçin systemctl bilen barla
        try:
            # MongoDB işleýärmi?
            result = subprocess.run(["systemctl", "is-active", "mongod"], 
                                  stdout=subprocess.PIPE, 
                                  stderr=subprocess.PIPE,
                                  text=True)
            
            if "active" in result.stdout:
                logger.info("MongoDB işleýär")
                return True
            else:
                logger.warning("MongoDB işlemeýär, işledilmäge synanyşylýar...")
                
                # MongoDB işlet
                start_result = subprocess.run(["systemctl", "start", "mongod"], 
                                            stdout=subprocess.PIPE, 
                                            stderr=subprocess.PIPE,
                                            text=True)
                
                # Netijäni barla
                if start_result.returncode == 0:
                    logger.info("MongoDB üstünlikli işledildi")
                    return True
                else:
                    logger.error(f"MongoDB işledilip bilinmedi: {start_result.stderr}")
                    return False
                    
        except Exception as e:
            logger.error(f"MongoDB hyzmaty barlananda ýalňyşlyk ýüze çykdy: {str(e)}")
            return False

def check_bot_service():
    """Bot hyzmatynyň işleýändigini barla we täzeden başlat"""
    logger.info("Bot hyzmaty barlanýar...")
    
    # Windows-da hyzmaty barlamak başgaça işleýär
    if is_windows:
        logger.info("Windows gurşawynda, bot hyzmaty barlagy sallanyp geçilýär")
        return True
    else:
        # Linux üçin systemctl bilen barla
        try:
            # Hyzmaty täzeden başlat
            restart_result = subprocess.run(["systemctl", "restart", "chatbot"], 
                                          stdout=subprocess.PIPE, 
                                          stderr=subprocess.PIPE,
                                          text=True)
            
            if restart_result.returncode == 0:
                logger.info("Bot hyzmaty täzeden başladyldy")
                return True
            else:
                logger.error(f"Bot hyzmaty täzeden başladylyp bilinmedi: {restart_result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"Bot hyzmatyny täzeden başladanda ýalňyşlyk ýüze çykdy: {str(e)}")
            return False

def main():
    """Esasy funksiýa - ähli düzedişleri utgaşdyr"""
    logger.info("Bot konfigurasiýa düzediş skripti başladylýar...")
    logger.info(f"Işleýän gurşaw: {platform.system()}, {platform.release()}")
    logger.info(f"Katalog: {INSTALL_DIR}")
    
    # .env faýlyny düzet
    env_fixed = fix_env_file()
    
    # MongoDB-ni barla
    mongodb_ok = check_mongodb()
    
    # Bot hyzmatyny täzeden başlat
    bot_restarted = check_bot_service()
    
    # Netijäni görkezmek
    if env_fixed:
        if is_windows:
            logger.info("Windows gurşawynda düzedişler tamamlandy!")
            print("Konfigurasiýa faýly düzgün döredildi✓")
            print("BELLIK: Bu Windows gurşawy, konfigurasiýa faýllary düzedildi, ýöne hyzmatlara täsir edilmedi.")
            return 0
        elif mongodb_ok and bot_restarted:
            logger.info("Ähli düzedişler üstünlikli tamamlandy!")
            print("Konfigurasiýa faýly düzgün döredildi✓")
            return 0
        else:
            logger.warning("Käbir düzedişler tamamlanmady. Gündelige (log) serediň.")
            print("Konfigurasiýa düzedildi, ýöne käbir problemalar galdy.")
            return 1
    else:
        logger.error("Konfigurasiýa faýly düzedilip bilinmedi!")
        print("Konfigurasiýa faýly düzedilip bilinmedi!")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 