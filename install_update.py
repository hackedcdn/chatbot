#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot - Awtomatiki gurnalyş we täzeleme ulgamy
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

import os
import sys
import subprocess
import platform
import shutil
import tempfile
import time
import re
from pathlib import Path

# Reňkler
class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    RED = '\033[0;31m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # Reňki nol et

    @staticmethod
    def disable_if_windows():
        if platform.system() == "Windows":
            Colors.GREEN = ""
            Colors.YELLOW = ""
            Colors.RED = ""
            Colors.BLUE = ""
            Colors.CYAN = ""
            Colors.NC = ""

# Windows-da reňkleri öçür
Colors.disable_if_windows()

def print_color(color, message):
    """Reňkli habar çap et"""
    print(f"{color}{message}{Colors.NC}")

def print_title(title):
    """Tituly formatla we görkezmek"""
    width = 60
    print("\n" + "=" * width)
    print(f"{Colors.BLUE}{title.center(width)}{Colors.NC}")
    print("=" * width)

def print_step(step):
    """Adym habaryny formatla we görkezmek"""
    print(f"\n{Colors.YELLOW}>> {step}{Colors.NC}")

def run_command(command, shell=True, check=False, timeout=None):
    """Komandany ýerine ýetirip, ýalňyşlyk barla"""
    try:
        result = subprocess.run(
            command, 
            shell=shell, 
            check=check, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout
        )
        return result
    except subprocess.TimeoutExpired:
        print_color(Colors.RED, f"Wagt gutardy: {command}")
        return None
    except Exception as e:
        print_color(Colors.RED, f"Komandada ýalňyşlyk: {e}")
        return None

def is_admin():
    """Root/admin hukuklary barla"""
    try:
        if platform.system() == "Windows":
            # Windows-da admin barlagy
            import ctypes
            return ctypes.windll.shell32.IsUserAnAdmin() != 0
        else:
            # Linux/Mac-da root barlagy
            return os.geteuid() == 0
    except:
        # Eger os.geteuid() ýok bolsa, admin däl diýip hasapla
        return False

def check_python_version():
    """Python wersiýasyny barla (min 3.7)"""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 7):
        print_color(Colors.RED, f"Python 3.7+ talap edilýär, sizde: {sys.version}")
        return False
    return True

def install_pip_package(package):
    """Pip bilen paket gurna"""
    print_step(f"{package} gurnalyar...")
    result = run_command([sys.executable, "-m", "pip", "install", package], shell=False)
    if result and result.returncode == 0:
        print_color(Colors.GREEN, f"{package} gurnalyp bolundy ✓")
        return True
    else:
        print_color(Colors.RED, f"{package} gurnalyp bolunmady!")
        if result:
            print(result.stderr)
        return False

def validate_bot_token(token):
    """Bot tokeni dogrula"""
    if not token:
        return False
    # 123456789:ABCDefgh1234567890_AbcDEFghijk
    pattern = r'^\d+:[A-Za-z0-9_-]+$'
    return bool(re.match(pattern, token))

def validate_admin_id(admin_id):
    """Admin ID dogrula - diňe sanlar bolmaly"""
    if not admin_id:
        return False
    return admin_id.isdigit()

def get_bot_token():
    """Ulanyjydan bot token al"""
    print_step("Telegram Bot Token alynýar...")
    print("1. https://t.me/BotFather açyň")
    print("2. /newbot buýrugy bilen täze bot dörediň")
    print("3. Bot adyny we ulanyjy adyny giriziň")
    print("4. BotFather-den gelen tokeni göçürip alyň")
    
    while True:
        token = input(f"{Colors.CYAN}Token: {Colors.NC}")
        if validate_bot_token(token):
            return token
        else:
            print_color(Colors.RED, "Nädogry token format! Format: 123456789:ABCDefgh1234_AbcDEF")

def get_admin_id():
    """Ulanyjydan Telegram ID al"""
    print_step("Admin ID alynýar...")
    print("1. Öz Telegram hasabyňyzda https://t.me/myidbot açyň")
    print("2. /getid buýrugy iberiň")
    print("3. Bot berýän ID belgiňizi göçürip alyň")
    
    while True:
        admin_id = input(f"{Colors.CYAN}Admin ID: {Colors.NC}")
        if validate_admin_id(admin_id):
            return admin_id
        else:
            print_color(Colors.RED, "Nädogry ID format! Diňe sanlardan ybarat bolmaly.")

def create_env_file(install_dir, bot_token, admin_id):
    """Bot üçin .env faýly döret"""
    env_path = os.path.join(install_dir, ".env")
    print_step(f".env faýly döredilýär: {env_path}")
    
    try:
        with open(env_path, 'w', encoding='utf-8') as f:
            f.write(f"BOT_TOKEN={bot_token}\n")
            f.write(f"ADMIN_ID={admin_id}\n")
            f.write(f"MONGODB_URI=mongodb://localhost:27017\n")
            f.write(f"DATABASE_NAME=chatbot_db\n")
        print_color(Colors.GREEN, ".env faýly döredildi ✓")
        return True
    except Exception as e:
        print_color(Colors.RED, f".env faýlyny döretmekde ýalňyşlyk: {e}")
        return False

def setup_directories():
    """Ulgama görä gurnalyş kataloglaryny taýýarla"""
    if platform.system() == "Windows":
        base_dir = os.path.join(os.environ.get("LOCALAPPDATA", "C:\\ProgramData"), "ChatBot")
    else:
        base_dir = "/opt/chatbot"
    
    try:
        os.makedirs(base_dir, exist_ok=True)
        print_color(Colors.GREEN, f"Gurnalyş katalogy taýýarlandy: {base_dir} ✓")
        return base_dir
    except Exception as e:
        print_color(Colors.RED, f"Katalog döretmekde ýalňyşlyk: {e}")
        alt_dir = os.path.join(os.path.expanduser("~"), "chatbot")
        try:
            os.makedirs(alt_dir, exist_ok=True)
            print_color(Colors.YELLOW, f"Alternatiw katalog ulanylýar: {alt_dir}")
            return alt_dir
        except Exception as e2:
            print_color(Colors.RED, f"Alternatiw katalogyň hem döredilip bilinmedi: {e2}")
            return None

def get_repo_files():
    """GitHub-dan bot faýllaryny al"""
    print_step("Bot faýllary GitHub-dan alynýar...")
    
    # Birnäçe usuly synap gör
    methods = [
        {"name": "git", "command": ["git", "clone", "https://github.com/hackedcdn/chatbot.git", "temp_repo"], "shell": False},
        {"name": "curl/wget", "command": "curl -L https://github.com/hackedcdn/chatbot/archive/main.zip -o repo.zip", "shell": True},
        {"name": "python requests", "url": "https://github.com/hackedcdn/chatbot/archive/main.zip", "requires": "requests"}
    ]
    
    temp_dir = tempfile.mkdtemp()
    os.chdir(temp_dir)
    
    # Git bilen synanyş
    print("Git bilen synanyşylýar...")
    result = run_command(methods[0]["command"], shell=methods[0]["shell"])
    if result and result.returncode == 0:
        print_color(Colors.GREEN, "Repozitoriýa Git bilen göçürildi ✓")
        return os.path.join(temp_dir, "temp_repo")
    
    # cURL/wget bilen synanyş
    print("cURL/wget bilen synanyşylýar...")
    if platform.system() == "Windows":
        result = run_command("powershell -Command \"Invoke-WebRequest -Uri https://github.com/hackedcdn/chatbot/archive/main.zip -OutFile repo.zip\"")
    else:
        result = run_command(methods[1]["command"])
    
    if result and result.returncode == 0 and os.path.exists("repo.zip"):
        print_color(Colors.GREEN, "ZIP faýl ýüklendi ✓")
        # ZIP faýly çözýäris
        try:
            import zipfile
            with zipfile.ZipFile("repo.zip", 'r') as zip_ref:
                zip_ref.extractall(".")
            print_color(Colors.GREEN, "ZIP faýl çözüldi ✓")
            return os.path.join(temp_dir, "chatbot-main")
        except Exception as e:
            print_color(Colors.RED, f"ZIP faýly çözmekde ýalňyşlyk: {e}")
    
    # Python requests bilen synanyş
    print("Python requests bilen synanyşylýar...")
    try:
        try:
            import requests
        except ImportError:
            print("requests kitaphanasyny gurnalyp başlanylýar...")
            install_pip_package("requests")
            import requests
        
        response = requests.get(methods[2]["url"], stream=True)
        if response.status_code == 200:
            with open("repo.zip", 'wb') as f:
                f.write(response.content)
            
            import zipfile
            with zipfile.ZipFile("repo.zip", 'r') as zip_ref:
                zip_ref.extractall(".")
            print_color(Colors.GREEN, "ZIP faýl requests bilen ýüklendi we çözüldi ✓")
            return os.path.join(temp_dir, "chatbot-main")
    except Exception as e:
        print_color(Colors.RED, f"Python requests bilen ýükleme synanyşygy şowsuz: {e}")
    
    print_color(Colors.RED, "Bot faýllaryny almak şowsuz!")
    return None

def install_requirements(venv_path):
    """Bot üçin gerekli Python paketlerini gur"""
    print_step("Python baglylyklaryny gurnalyar...")
    
    pip_path = os.path.join(venv_path, "bin", "pip") if platform.system() != "Windows" else os.path.join(venv_path, "Scripts", "pip")
    
    reqs = [
        "python-telegram-bot",
        "pymongo",
        "python-dotenv",
        "requests"
    ]
    
    success = True
    for req in reqs:
        print(f"{req} gurnalyar...")
        cmd = [pip_path, "install", req]
        result = run_command(cmd, shell=False)
        if not result or result.returncode != 0:
            print_color(Colors.RED, f"{req} gurnalyp bolunmady!")
            success = False
    
    if success:
        print_color(Colors.GREEN, "Ähli paketler gurnalyp bolundy ✓")
    return success

def copy_files(source_dir, target_dir):
    """Faýllary bir katalogdan başga kataloga göçür"""
    print_step(f"Faýllar göçürilýär: {source_dir} -> {target_dir}")
    
    try:
        # Rekursiw göçürme
        for item in os.listdir(source_dir):
            source_item = os.path.join(source_dir, item)
            target_item = os.path.join(target_dir, item)
            
            if os.path.isdir(source_item):
                # Katalogy göçür
                shutil.copytree(source_item, target_item, dirs_exist_ok=True)
            else:
                # Faýly göçür
                shutil.copy2(source_item, target_item)
        
        print_color(Colors.GREEN, "Faýllar üstünlikli göçürildi ✓")
        return True
    except Exception as e:
        print_color(Colors.RED, f"Faýllary göçürmekde ýalňyşlyk: {e}")
        try:
            # Aýry-aýry faýllary göçürip synanyşaly
            for item in os.listdir(source_dir):
                source_item = os.path.join(source_dir, item)
                target_item = os.path.join(target_dir, item)
                
                if not os.path.isdir(source_item) and item.endswith(".py"):
                    # Diňe Python faýllaryny göçür
                    shutil.copy2(source_item, target_item)
            print_color(Colors.YELLOW, "Diňe Python faýllary göçürildi")
            return True
        except Exception as e2:
            print_color(Colors.RED, f"Hiç hili faýl göçürilip bilinmedi: {e2}")
            return False

def setup_virtual_env(install_dir):
    """Python üçin wirtual gurşaw döret"""
    print_step("Python wirtual gurşawy döredilýär...")
    
    venv_path = os.path.join(install_dir, "venv")
    
    if os.path.exists(venv_path):
        print_color(Colors.YELLOW, "Bar bolan wirtual gurşaw tapyldy, täzelenmeli")
        try:
            shutil.rmtree(venv_path)
        except Exception as e:
            print_color(Colors.RED, f"Köne wirtual gurşawy aýryp bolmady: {e}")
            return None
    
    try:
        import venv
        venv.create(venv_path, with_pip=True)
        print_color(Colors.GREEN, "Wirtual gurşaw döredildi ✓")
        return venv_path
    except Exception as e:
        print_color(Colors.RED, f"Wirtual gurşaw döredip bolmady: {e}")
        
        # Alternatif usul - subprocess bilen
        try:
            result = run_command([sys.executable, "-m", "venv", venv_path], shell=False)
            if result and result.returncode == 0:
                print_color(Colors.GREEN, "Wirtual gurşaw alternatif usul bilen döredildi ✓")
                return venv_path
        except Exception as e2:
            print_color(Colors.RED, f"Alternatif usul hem şowsuz: {e2}")
        
        return None

def create_service_file(install_dir):
    """Ulgam hyzmaty faýlyny döret (Linux)"""
    if platform.system() != "Linux":
        print_color(Colors.YELLOW, "Hyzmat faýly diňe Linux üçin döredilýär")
        return False
    
    print_step("Systemd hyzmat faýly döredilýär...")
    
    service_path = "/etc/systemd/system/chatbot.service"
    python_path = os.path.join(install_dir, "venv", "bin", "python3")
    bot_script = os.path.join(install_dir, "bot.py")
    
    service_content = f"""[Unit]
Description=ChatBot Telegram Bot Service
After=network.target mongod.service

[Service]
Type=simple
User=root
WorkingDirectory={install_dir}
ExecStart={python_path} {bot_script}
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=chatbot

[Install]
WantedBy=multi-user.target
"""
    
    try:
        with open(service_path, 'w') as f:
            f.write(service_content)
        
        # Hyzmat faýlyny täzelemek
        run_command("systemctl daemon-reload")
        # Hyzmaty awtomatiki işe girizme
        run_command("systemctl enable chatbot.service")
        
        print_color(Colors.GREEN, "Systemd hyzmat faýly döredildi ✓")
        return True
    except Exception as e:
        print_color(Colors.RED, f"Hyzmat faýlyny döretmekde ýalňyşlyk: {e}")
        return False

def create_windows_shortcut(install_dir):
    """Windows üçin başlatmak üçin bat faýl döret"""
    if platform.system() != "Windows":
        return False
    
    print_step("Windows üçin başlatmak skripti döredilýär...")
    
    bat_path = os.path.join(os.environ.get("USERPROFILE", ""), "Desktop", "ChatBot.bat")
    python_path = os.path.join(install_dir, "venv", "Scripts", "python.exe")
    bot_script = os.path.join(install_dir, "bot.py")
    
    bat_content = f"""@echo off
title ChatBot Telegram
echo ChatBot Telegram başladylýar...
"{python_path}" "{bot_script}"
pause
"""
    
    try:
        with open(bat_path, 'w') as f:
            f.write(bat_content)
        print_color(Colors.GREEN, f"Başlatmak faýly döredildi: {bat_path} ✓")
        
        # Control Panel üçin hem bat faýl döret
        panel_path = os.path.join(os.environ.get("USERPROFILE", ""), "Desktop", "ChatBot_Panel.bat")
        panel_content = f"""@echo off
title ChatBot Dolandyryş Paneli
cd /d "{install_dir}"
"{python_path}" "{install_dir}\\panel.py"
pause
"""
        with open(panel_path, 'w') as f:
            f.write(panel_content)
        print_color(Colors.GREEN, f"Dolandyryş paneli faýly döredildi: {panel_path} ✓")
        
        return True
    except Exception as e:
        print_color(Colors.RED, f"Windows başlatmak faýlyny döretmekde ýalňyşlyk: {e}")
        return False

def check_mongodb():
    """MongoDB-niň gurnalandygyny we işleýändigini barla"""
    print_step("MongoDB barlanýar...")
    
    # MongoDB gurnalandygyny barla
    mongo_paths = [
        "mongod", 
        "/usr/bin/mongod",
        "C:\\Program Files\\MongoDB\\Server\\6.0\\bin\\mongod.exe",
        "C:\\Program Files\\MongoDB\\Server\\5.0\\bin\\mongod.exe",
        "C:\\Program Files\\MongoDB\\Server\\4.4\\bin\\mongod.exe"
    ]
    
    mongo_found = False
    for path in mongo_paths:
        try:
            result = run_command(f"{path} --version", timeout=5)
            if result and result.returncode == 0:
                print_color(Colors.GREEN, f"MongoDB tapyldy: {path} ✓")
                mongo_found = True
                break
        except:
            continue
    
    if not mongo_found:
        print_color(Colors.YELLOW, "MongoDB tapylmady, gurnalyşy maslahat berilýär")
        print("MongoDB gurmak üçin görkezmeleri alyň:")
        print("https://www.mongodb.com/docs/manual/administration/install-community/")
        
        # Windows üçin MongoDB gurnaýarmyk?
        if platform.system() == "Windows":
            install_mongo = input(f"{Colors.CYAN}MongoDB-ni awtomatik gurnamak isleýäňizmi? (y/n): {Colors.NC}")
            if install_mongo.lower() == 'y':
                # MongoDB-ni awtomatik gurna
                print_step("MongoDB ýüklenýär (bu biraz wagt alyp biler)...")
                try:
                    # Iň soňky MongoDB MSI faýlyny ýükle
                    import requests
                    response = requests.get("https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-6.0.0-signed.msi")
                    with open("mongodb.msi", 'wb') as f:
                        f.write(response.content)
                    
                    print_step("MongoDB gurnalyp başlanylýar...")
                    # MSI gurnalyşyny başlat
                    result = run_command("msiexec /i mongodb.msi /qn")
                    
                    if result and result.returncode == 0:
                        print_color(Colors.GREEN, "MongoDB guruldy! ✓")
                    else:
                        print_color(Colors.RED, "MongoDB gurnalyşy şowsuz. MongoDB.com-dan manual gurmagyňyz gerek bolar.")
                except Exception as e:
                    print_color(Colors.RED, f"MongoDB ýüklemekde ýalňyşlyk: {e}")
    
    # MongoDB-niň işleýşini barla
    if platform.system() == "Windows":
        # Windows-da service barlagy
        result = run_command("sc query MongoDB")
        if result and "RUNNING" in result.stdout:
            print_color(Colors.GREEN, "MongoDB serwisi işleýär ✓")
        else:
            print_color(Colors.YELLOW, "MongoDB serwisi işlemeýär. Manual başlatmagyňyz gerek bolar.")
    else:
        # Linux/Mac-da service barlagy
        result = run_command("systemctl status mongod")
        if result and "active (running)" in result.stdout:
            print_color(Colors.GREEN, "MongoDB serwisi işleýär ✓")
        else:
            print_color(Colors.YELLOW, "MongoDB serwisi işlemeýär. Ony başlatmak isleýärsiňizmi?")
            start_mongo = input(f"{Colors.CYAN}MongoDB-ni başlatmakmy? (y/n): {Colors.NC}")
            if start_mongo.lower() == 'y':
                run_command("systemctl start mongod")
                # İşledilenden soň täzeden barla
                result = run_command("systemctl status mongod")
                if result and "active (running)" in result.stdout:
                    print_color(Colors.GREEN, "MongoDB serwisi işledildi ✓")
                else:
                    print_color(Colors.RED, "MongoDB serwerini işledip bolmady")
    
def update_mode(install_dir):
    """Bot faýllaryny täzele"""
    print_title("ChatBot - Täzeleme tertibi")
    
    # Bot işleýärmi barla we durzdiryp bil
    if platform.system() != "Windows":
        result = run_command("systemctl status chatbot")
        if result and "active (running)" in result.stdout:
            print_color(Colors.YELLOW, "Bot häzir işleýär, täzelemek üçin wagtlaýyn durdurmak gerek")
            stop_bot = input(f"{Colors.CYAN}Boty durdurmakmy? (y/n): {Colors.NC}")
            if stop_bot.lower() == 'y':
                run_command("systemctl stop chatbot")
                print_color(Colors.GREEN, "Bot durdurlyldy ✓")
            else:
                print_color(Colors.RED, "Täzeleme işini goýbolsun etmek. Bot işläp durka faýllary täzeläp bolmaz!")
                return False
    
    # Repony al
    repo_dir = get_repo_files()
    if not repo_dir:
        print_color(Colors.RED, "Faýllary almak şowsuz, täzeläp bolunmady!")
        return False
    
    # Bar bolan konfigurasiýany sakla
    env_backup = {}
    env_path = os.path.join(install_dir, ".env")
    if os.path.exists(env_path):
        try:
            with open(env_path, 'r', encoding='utf-8') as f:
                for line in f:
                    if '=' in line and not line.startswith('#'):
                        key, value = line.strip().split('=', 1)
                        env_backup[key] = value
        except Exception as e:
            print_color(Colors.RED, f".env faýlyny okamakda ýalňyşlyk: {e}")
    
    # Faýllary täzele
    copy_files(repo_dir, install_dir)
    
    # Konfigurasiýany täzeden döret
    if env_backup:
        try:
            with open(env_path, 'w', encoding='utf-8') as f:
                for key, value in env_backup.items():
                    f.write(f"{key}={value}\n")
            print_color(Colors.GREEN, "Konfigurasiýa saklanyp galdy ✓")
        except Exception as e:
            print_color(Colors.RED, f"Konfigurasiýany täzeden döretmekde ýalňyşlyk: {e}")
    
    # Täze baglylyklaryny gur
    venv_path = os.path.join(install_dir, "venv")
    install_requirements(venv_path)
    
    # Boty täzeden başlat (Linux)
    if platform.system() != "Windows":
        run_command("systemctl start chatbot")
        time.sleep(2)
        result = run_command("systemctl status chatbot")
        if result and "active (running)" in result.stdout:
            print_color(Colors.GREEN, "Bot täzeden başladyldy ✓")
        else:
            print_color(Colors.RED, "Bot täzeden başladylyp bilinmedi!")
    
    print_color(Colors.GREEN, "ChatBot üstünlikli täzelendi!")
    return True

def start_bot(install_dir):
    """Boty başlat"""
    print_step("Bot başladylýar...")
    
    if platform.system() == "Windows":
        python_path = os.path.join(install_dir, "venv", "Scripts", "python.exe")
        bot_script = os.path.join(install_dir, "bot.py")
        
        print("Windows-da bot terminal penjiresi açylýar...")
        # process = subprocess.Popen(f'start cmd /k "{python_path}" "{bot_script}"', shell=True)
        print_color(Colors.GREEN, "ChatBot Desktop-da ýasalan bat faýl bilen başladylyp bilner")
        print_color(Colors.GREEN, "Desktopda 'ChatBot.bat' faýla iki gezek basyň")
    else:
        run_command("systemctl start chatbot")
        time.sleep(2)
        result = run_command("systemctl status chatbot")
        if result and "active (running)" in result.stdout:
            print_color(Colors.GREEN, "Bot üstünlikli başladyldy ✓")
        else:
            print_color(Colors.RED, "Bot başladylyp bilinmedi!")
            
            # Status meldirini görkezmek
            if result:
                print("\nStatus:\n" + result.stdout)

def main():
    """Ana funksiýa"""
    print_title("ChatBot - Gurnalyş we Täzeleme Ulgamy")
    
    # Zerur bolan Python wersiýasyny barla
    if not check_python_version():
        sys.exit(1)
    
    # Admin/root hukuklaryny barla
    if not is_admin():
        print_color(Colors.RED, "Bu skript admin/root hukuklary bilen işledilemeli")
        print("Windows: PowerShell/CMD terminal 'Run as administrator' bilen açyň")
        print("Linux/Mac: sudo bilen işlediň: sudo python install_update.py")
        print_color(Colors.YELLOW, "Dowam etmek isleýärsiňizmi? (käbir funksiýalar işlemezlik mümkin)")
        continue_anyway = input(f"{Colors.CYAN}Dowam etmek? (y/n): {Colors.NC}")
        if continue_anyway.lower() != 'y':
            sys.exit(1)
    
    # Gurnalyş ýa-da täzeleme tertibini saýlamak
    print_step("Tertip saýlaň:")
    print("1. Täzeden gurnamak")
    print("2. Täzelemek")
    choice = input(f"{Colors.CYAN}Saýlaw (1/2): {Colors.NC}")
    
    # Zerur global üýtgeýjileri taýýarla
    repo_dir = None
    install_dir = None
    
    # Täzelemek tertibimi?
    if choice == "2":
        # Baryp bolýan ýolda bar bolmagyny barla
        potential_dirs = [
            "/opt/chatbot",
            os.path.join(os.environ.get("LOCALAPPDATA", "C:\\ProgramData"), "ChatBot"),
            os.path.join(os.path.expanduser("~"), "chatbot")
        ]
        
        for dir_path in potential_dirs:
            if os.path.exists(dir_path) and os.path.exists(os.path.join(dir_path, "bot.py")):
                install_dir = dir_path
                break
        
        if install_dir:
            print_color(Colors.GREEN, f"Bar bolan gurnalyş tapyldy: {install_dir}")
            return update_mode(install_dir)
        else:
            print_color(Colors.RED, "Bar bolan gurnalyş tapylmady!")
            print_color(Colors.YELLOW, "Täze gurnalyş ediljek")
    
    # Täzeden gurnamak
    # 1. Gurnalyş katalogyny döret
    install_dir = setup_directories()
    if not install_dir:
        print_color(Colors.RED, "Gurnalyş katalogyny döredip bolmady!")
        sys.exit(1)
    
    # 2. Bot token we Admin ID al
    bot_token = get_bot_token()
    admin_id = get_admin_id()
    
    # 3. MongoDB gurnalyşyny barla
    check_mongodb()
    
    # 4. GitHub-dan faýllary al
    repo_dir = get_repo_files()
    if not repo_dir:
        print_color(Colors.RED, "Repony almak şowsuz!")
        sys.exit(1)
    
    # 5. Wirtual gurşaw döret
    venv_path = setup_virtual_env(install_dir)
    if not venv_path:
        print_color(Colors.RED, "Wirtual gurşaw döredip bolmady!")
        sys.exit(1)
    
    # 6. Baglylyklaryny gur
    install_requirements(venv_path)
    
    # 7. Faýllary gurnalyş katalogyna göçür
    if not copy_files(repo_dir, install_dir):
        print_color(Colors.RED, "Faýllary göçürip bolmady!")
        sys.exit(1)
    
    # 8. .env faýlyny döret
    create_env_file(install_dir, bot_token, admin_id)
    
    # 9. Platformaga görä awtomatiki başlatmak üçin sazlamalar
    if platform.system() == "Windows":
        create_windows_shortcut(install_dir)
    else:
        create_service_file(install_dir)
    
    # 10. Boty başlat
    start_bot(install_dir)
    
    # Üstünlikli
    print_title("ChatBot gurnalyşy tamamlandy!")
    if platform.system() == "Windows":
        print("Bot başlatmak üçin Desktopda 'ChatBot.bat' faýla basyň")
        print("Dolandyryş paneli üçin 'ChatBot_Panel.bat' faýla basyň")
    else:
        print("Bot dolandyrmak üçin buýruklar:")
        print("systemctl start chatbot  - Boty başlatmak")
        print("systemctl stop chatbot   - Boty durdurmak")
        print("systemctl restart chatbot - Boty täzeden başlatmak")
        print("systemctl status chatbot  - Botuň ýagdaýyny barlamak")
    
    print("\nGurnalyş üstünlikli tamamlandy!")
    return True

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_color(Colors.RED, "\nIşlem ulanyjy tarapyndan kesildi")
        sys.exit(1)
    except Exception as e:
        print_color(Colors.RED, f"\nÝalňyşlyk ýüze çykdy: {e}")
        sys.exit(1) 