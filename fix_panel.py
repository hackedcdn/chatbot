#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot paneldäki awtomatiki refresh meselesini düzediji

import os
import sys
import time
import shutil
import subprocess

def check_panel_file():
    """
    Panel faýlyny barla we düzetmek gerek bolsa düzet
    """
    # Mümkin bolan panel faýl ýerlerini barla
    panel_paths = [
        "/opt/chatbot/panel.py",
        "/opt/chatbot/panel.sh",
        "/usr/local/bin/chatbot",
        "/usr/bin/chatbot",
        os.path.join(os.getcwd(), "panel.py"),
        os.path.join(os.getcwd(), "panel.sh")
    ]
    
    fixed_panel = False
    
    for panel_path in panel_paths:
        if os.path.exists(panel_path):
            print(f"Panel faýly tapyldy: {panel_path}")
            
            # Faýl görnüşine görä barlap we düzet
            if panel_path.endswith(".py"):
                fixed_panel = fix_python_panel(panel_path)
            elif panel_path.endswith(".sh") or "/bin/chatbot" in panel_path:
                fixed_panel = fix_bash_panel(panel_path)
            
            if fixed_panel:
                print(f"Panel faýly üstünlikli düzedildi: {panel_path}")
                return True
    
    return False

def fix_python_panel(panel_path):
    """
    Python panel faýlyny düzet
    """
    # Backup faýlyny döret
    backup_path = panel_path + ".backup"
    shutil.copy2(panel_path, backup_path)
    print(f"Panel faýlynyň ätiýaçlyk nusgasy döredildi: {backup_path}")
    
    try:
        with open(panel_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Mesele döredip biljek kodlary gözle we düzet
        if "while True:" in content:
            # Awtomatiki täzelenmäni durzdurmak üçin kod goş
            content = content.replace("while True:", 
                """
# Öňki awtomatiki täzelenme düzedildi
auto_refresh = False
while True:
    if not auto_refresh:
""")
            # Indentation goş
            content = content.replace("\n    option = input(", 
                "\n        option = input(")
            
        # Menýu çykyşynda ýalňyşlyk bolup biljek kodlary gözle we düzet
        if "Ýalňyş saýlaw. Täzeden synanyşyň." in content:
            content = content.replace("Ýalňyş saýlaw. Täzeden synanyşyň.",
                "Ýalňyş saýlaw. Täzeden synanyşyň.\n        time.sleep(2)")
        
        # Düzedilen mazmun bilen faýly täzeden ýaz
        with open(panel_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"Panel faýlyny düzetmekde ýalňyşlyk: {e}")
        
        # Eger ýalňyşlyk bolsa, ätiýaçlyk nusgasyny dikelt
        try:
            shutil.copy2(backup_path, panel_path)
            print("Ätiýaçlyk nusgasy dikeldildi")
        except:
            pass
        
        return False

def fix_bash_panel(panel_path):
    """
    Bash panel faýlyny düzet
    """
    # Backup faýlyny döret
    backup_path = panel_path + ".backup"
    shutil.copy2(panel_path, backup_path)
    print(f"Panel faýlynyň ätiýaçlyk nusgasy döredildi: {backup_path}")
    
    try:
        with open(panel_path, 'r', encoding='utf-8') as f:
            content = f.readlines()
        
        new_content = []
        for line in content:
            # Awtomatiki täzelenme kodlaryny gözle we düzet
            if "while true" in line.lower() or "while :" in line:
                new_content.append("# Öňki awtomatiki täzelenme düzedildi\n")
                new_content.append("AUTO_REFRESH=false\n")
                new_content.append(line)
            elif "clear" in line and "clear_screen" not in line:
                # clear ekrandan öň sleep goş - bu awtomatiki täzelenme meselesini çözmäge kömek eder
                new_content.append("sleep 0.5\n")
                new_content.append(line)
            elif "read -p" in line or "read -r" in line:
                # Okamak buýrugy üçin timeout goş
                new_content.append(line.replace("read -p", "read -t 600 -p").replace("read -r", "read -t 600 -r"))
            else:
                new_content.append(line)
        
        # Düzedilen mazmun bilen faýly täzeden ýaz
        with open(panel_path, 'w', encoding='utf-8') as f:
            f.writelines(new_content)
        
        # Eger bash skript bolsa, rugsat beriji et
        if panel_path.endswith(".sh"):
            os.chmod(panel_path, 0o755)
        
        return True
    except Exception as e:
        print(f"Panel faýlyny düzetmekde ýalňyşlyk: {e}")
        
        # Eger ýalňyşlyk bolsa, ätiýaçlyk nusgasyny dikelt
        try:
            shutil.copy2(backup_path, panel_path)
            print("Ätiýaçlyk nusgasy dikeldildi")
        except:
            pass
        
        return False

def fix_env_file():
    """
    .env faýlyny barla we düzet
    """
    # chatbot esasy katalogyny anykla
    chatbot_dirs = [
        "/opt/chatbot",
        os.getcwd()
    ]
    
    for chatbot_dir in chatbot_dirs:
        env_path = os.path.join(chatbot_dir, ".env")
        if os.path.exists(env_path):
            print(f".env faýly tapyldy: {env_path}")
            
            try:
                # Faýl mazmunyny oka
                with open(env_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # TOKEN we ADMIN_ID barla
                has_token = "BOT_TOKEN=" in content and not "BOT_TOKEN=TOKEN_PLACEHOLDER" in content
                has_admin = "ADMIN_ID=" in content and not "ADMIN_ID=123456789" in content
                
                if not has_token or not has_admin:
                    print("TOKEN ýa-da ADMIN_ID nädogry. fix_env.py skripti işledilýär...")
                    
                    # fix_env.py ýerini anykla
                    fix_env_paths = [
                        os.path.join(os.getcwd(), "fix_env.py"),
                        os.path.join(chatbot_dir, "fix_env.py"),
                        os.path.join(chatbot_dir, "tools", "fix_env.py")
                    ]
                    
                    for fix_path in fix_env_paths:
                        if os.path.exists(fix_path):
                            print(f"fix_env.py faýly tapyldy: {fix_path}")
                            
                            # fix_env.py skriptini işlet
                            try:
                                subprocess.run([sys.executable, fix_path], check=True)
                                return True
                            except Exception as e:
                                print(f"fix_env.py işlemekde ýalňyşlyk: {e}")
                    
                    print("fix_env.py tapylmady. Biz bu faýly döretdik, ýöne ony aýratyn işletmegiňiz gerek.")
                    return False
                else:
                    print(".env faýly dogry bolup görünýär.")
                    return True
            except Exception as e:
                print(f".env faýlyny barlamakda ýalňyşlyk: {e}")
    
    print(".env faýly tapylmady.")
    return False

def main():
    print("=" * 60)
    print("CHATBOT PANEL DÜZEDIJI SKRIPT".center(60))
    print("=" * 60)
    print("\nBu skript ChatBot paneldäki awtomatiki täzelenme meselesini düzetmäge kömek eder.")
    print("Panel faýly we .env konfigurasiýa faýly düzediler.\n")
    
    # Panel faýlyny barla we düzet
    panel_fixed = check_panel_file()
    
    # .env faýlyny barla we düzet
    env_fixed = fix_env_file()
    
    if panel_fixed and env_fixed:
        print("\nÄHLI MESELELER ÜSTÜNLIKLI DÜZEDILDI!")
        print("Indi paneli täzeden işlediň. Ol awtomatiki täzelenmeli däl.")
        
        # Eger dolandyryş paneli /usr/bin/chatbot-da bolsa, dikelt
        if os.path.exists("/usr/bin/chatbot"):
            print("\nPaneli täzeden işledip görmek isleýärsiňizmi? (y/n)")
            choice = input("> ")
            if choice.lower() == 'y':
                # Şu skripti gutaryp, paneli aýratyn prosses hökmünde başlat
                subprocess.Popen(["/usr/bin/chatbot"], start_new_session=True)
                print("Panel täzeden işledilýär...")
                time.sleep(1)
                sys.exit(0)
    else:
        print("\nKÄBIR MESELELER DOLY DÜZEDILIP BILINMEDI.")
        print("fix_env.py skriptini aýratyn işlediň.")
    
    input("\nDowam etmek üçin ENTER düwmä basyň...")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nUlanyjy tarapyndan bes edildi.")
    except Exception as e:
        print(f"\n\nÝALŇYŞLYK: {e}")
        print("Bu ýalňyşlygy hackedcdn@gmail.com adresine iberiň.") 