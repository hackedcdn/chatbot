#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot üçin .env faýlyny düzediji skript

import os
import re
import sys
import time

def clear_screen():
    """Ekrany arassala"""
    os.system('cls' if os.name == 'nt' else 'clear')

def get_bot_token():
    """
    Telegram Bot token alyp barlaýar
    """
    while True:
        clear_screen()
        print("=" * 60)
        print("TELEGRAM BOT TOKEN".center(60))
        print("=" * 60)
        print("\nBot tokenini almak üçin Telegram-da @BotFather bilen habarlaşyň.")
        print("Meselem: 5432109876:ABCDEfghijKLmnopQRSTUvwxYZ123456789")
        print("\nBot tokenini giriziň (çykmak üçin Ctrl+C):")
        token = input("> ").strip()
        
        if not token:
            print("\nToken boş bolup bilmez. Täzeden synanyşyň.")
            time.sleep(2)
            continue
        
        # Token formatyny barla
        if re.match(r'^\d+:[\w-]+$', token):
            return token
        else:
            print("\nNädogry token formaty. Nusga: 5432109876:ABCDEfghijKLmnopQRSTUvwxYZ123456789")
            time.sleep(2)

def get_admin_id():
    """
    Admin ID-ni alyp barlaýar
    """
    while True:
        clear_screen()
        print("=" * 60)
        print("ADMIN ID".center(60))
        print("=" * 60)
        print("\nAdmin ID-ni almak üçin Telegram-da @userinfobot bilen habarlaşyň.")
        print("Ol size ID-ňizi berer: 123456789")
        print("\nAdmin ID-ni giriziň (çykmak üçin Ctrl+C):")
        admin_id = input("> ").strip()
        
        if not admin_id:
            print("\nAdmin ID boş bolup bilmez. Täzeden synanyşyň.")
            time.sleep(2)
            continue
        
        # ID formatyny barla - san bolmaly
        if admin_id.isdigit():
            return admin_id
        else:
            print("\nNädogry ID formaty. ID diňe sanlardan ybarat bolmaly.")
            time.sleep(2)

def find_env_path():
    """
    .env faýlyny gözle
    """
    # Mümkin bolan ýerler
    possible_paths = [
        os.path.join(os.getcwd(), ".env"),
        os.path.join(os.getcwd(), "config", ".env"),
        "/opt/chatbot/.env",
        "/opt/chatbot/config/.env"
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    # Tapylmasa, özüň ýer döret
    for path in possible_paths:
        try:
            # Katalogyny döret
            os.makedirs(os.path.dirname(path), exist_ok=True)
            # Faýl düzmäge synanyş
            with open(path, 'w') as f:
                f.write("# ChatBot konfigurasiýa faýly\n")
            return path
        except:
            continue
    
    # Hiç tapylmasa, şu wagtky kataloga ýaz
    return os.path.join(os.getcwd(), ".env")

def read_existing_config(env_path):
    """
    Bar bolan .env faýlyndan konfigurasiýany oka
    """
    config = {
        'BOT_TOKEN': '',
        'ADMIN_ID': '',
        'MONGODB_URI': 'mongodb://localhost:27017',
        'DATABASE_NAME': 'chatbot'
    }
    
    if os.path.exists(env_path):
        try:
            with open(env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        key, value = line.split('=', 1)
                        config[key.strip()] = value.strip()
        except:
            pass
    
    return config

def main():
    try:
        # .env faýlyny tap
        env_path = find_env_path()
        
        # Bar bolan konfigurasiýany oka
        config = read_existing_config(env_path)
        
        clear_screen()
        print("=" * 60)
        print("CHATBOT KONFIGURASIÝA DÜZEDIJI".center(60))
        print("=" * 60)
        print(f"\n.env faýly: {env_path}")
        
        # Bot token we admin ID-ni ulanyjydan al
        token = get_bot_token()
        admin_id = get_admin_id()
        
        # Konfigurasiýany täzele
        config['BOT_TOKEN'] = token
        config['ADMIN_ID'] = admin_id
        
        # MongoDB konfigurasiýasyny sor
        clear_screen()
        print("=" * 60)
        print("MONGODB KONFIGURASIÝASY".center(60))
        print("=" * 60)
        print("\nMongoDB ulanmak isleýärsiňizmi? (y/n)")
        print("(SQLite ulanmak üçin 'n' saýlaň)")
        use_mongodb = input("> ").strip().lower() == 'y'
        
        if use_mongodb:
            print("\nMongoDB URI-ni giriziň (enterlemek üçin boş goýuň):")
            print("Bellenen: mongodb://localhost:27017")
            mongodb_uri = input("> ").strip()
            if mongodb_uri:
                config['MONGODB_URI'] = mongodb_uri
            
            print("\nMongoDB baza adyny giriziň (enterlemek üçin boş goýuň):")
            print("Bellenen: chatbot")
            db_name = input("> ").strip()
            if db_name:
                config['DATABASE_NAME'] = db_name
        
        # .env faýlyny ýaz
        with open(env_path, 'w') as f:
            f.write("# ChatBot konfigurasiýa faýly\n")
            f.write(f"BOT_TOKEN={config['BOT_TOKEN']}\n")
            f.write(f"ADMIN_ID={config['ADMIN_ID']}\n")
            f.write(f"MONGODB_URI={config['MONGODB_URI']}\n")
            f.write(f"DATABASE_NAME={config['DATABASE_NAME']}\n")
        
        # Üstünlikli habar
        clear_screen()
        print("=" * 60)
        print("KONFIGURASIÝA ÜSTÜNLIKLI DÜZEDILDI".center(60))
        print("=" * 60)
        print(f"\n.env faýly: {env_path}")
        print("\nTäze konfigurasiýa:")
        print(f"BOT_TOKEN=...{token[-10:]}")  # Howpsuzlyk üçin diňe soňky 10 belgisi görkezilýär
        print(f"ADMIN_ID={admin_id}")
        print(f"MONGODB_URI={config['MONGODB_URI']}")
        print(f"DATABASE_NAME={config['DATABASE_NAME']}")
        
        print("\nIndi boty täzeden işlediň.")
        print("\nPanelde awtomatiki täzelenme dowam etse, fix_panel.py skriptini işlediň:")
        print("python fix_panel.py")
        
        input("\nDowam etmek üçin ENTER düwmä basyň...")
        
    except KeyboardInterrupt:
        clear_screen()
        print("=" * 60)
        print("AMALY BES EDILDI".center(60))
        print("=" * 60)
        print("\nUlanyjy tarapyndan bes edildi.")
        sys.exit(0)
    except Exception as e:
        print(f"\nÝalňyşlyk ýüze çykdy: {e}")
        print("Bu ýalňyşlygy hackedcdn@gmail.com emailina iberiň.")
        input("\nDowam etmek üçin ENTER düwmä basyň...")
        sys.exit(1)

if __name__ == "__main__":
    main() 