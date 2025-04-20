#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Indentasiýa masalasyny düzetmek üçin skript

import os
import sys
import re

def fix_indentation(file_path):
    print(f"'{file_path}' faýlynyň indentasiýasyny düzedýärin...")
    
    try:
        # Faýly okaýarys
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        # Düzedilen faýl mazmuny
        fixed_lines = []
        block_stack = []
        in_comment_block = False
        in_string = False
        fixes_made = 0
        
        for i, line in enumerate(lines):
            fixed_line = line
            original_line = line
            line_stripped = line.strip()
            
            # Komment blokynda bolýandygymyzy barlaýarys
            if not in_string and (line_stripped.startswith('"""') or line_stripped.startswith("'''")):
                # Aýry setirde ýa-da şol bir setirde bitýän komentleri barla
                if line_stripped.endswith('"""') and line_stripped.count('"""') > 1:
                    # Bir setirlik komment, hiç zat ýapmaly däl
                    pass
                elif line_stripped.endswith("'''") and line_stripped.count("'''") > 1:
                    # Bir setirlik komment, hiç zat ýapmaly däl
                    pass
                else:
                    in_comment_block = not in_comment_block
            
            # Indentasiýa meseleleri diňe koda degişli, kommentlere däl
            if not in_comment_block and not line_stripped.startswith('#'):
                # Python sintaksis (çylşyrymly string) meselelerini barla
                # Bu ýönekeý barlag, has kämil barlaglar üçin Python parser ulanyp bolar
                for c in line:
                    if c == '\\':  # Escape bellik, onda indiniki bellik hasaplanmaýar
                        continue
                    if c == '"' or c == "'":
                        in_string = not in_string
                        
                if not in_string:
                    # Blok açýan setirler
                    if line_stripped.endswith(":"):
                        current_indent = len(line) - len(line.lstrip())
                        block_stack.append(current_indent)
                    
                    # Try/except/if/else/for/while/def/class bloklary
                    elif any(line_stripped == keyword or 
                            (line_stripped.startswith(keyword + " ") and line_stripped.endswith(":"))
                            for keyword in ["try:", "except:", "else:", "finally:", "if", "elif", "for", "while", "def", "class"]):
                        current_indent = len(line) - len(line.lstrip())
                        block_stack.append(current_indent)
                    
                    # Blok içindeki setirler
                    elif block_stack and line_stripped and not line.startswith(" ") and not line.startswith("\t"):
                        # İndentasýa ýapmaly setirleri düzet
                        expected_indent = block_stack[-1] + 4  # 4 boşluk standart Python indentasyonu
                        fixed_line = " " * expected_indent + line_stripped + '\n'
                        fixes_made += 1
                        print(f"Line {i+1} düzedildi: '{original_line.strip()}' -> '{fixed_line.strip()}'")
                    
                    # Block içindemi ýa-da däl?
                    elif line_stripped:
                        current_indent = len(line) - len(line.lstrip())
                        # Boş däl setir üçin indentasiýa azaldyk bolsa, blockdan çykdyk
                        while block_stack and current_indent < block_stack[-1]:
                            block_stack.pop()
            
            fixed_lines.append(fixed_line)
        
        # Düzedilen faýly ýazýarys
        with open(file_path, 'w', encoding='utf-8') as file:
            file.writelines(fixed_lines)
            
        if fixes_made > 0:
            print(f"'{file_path}' faýlynda {fixes_made} sany düzediş edildi!")
        else:
            print(f"'{file_path}' faýlynda düzediş talap edilýän zat ýok.")
        return True
        
    except Exception as e:
        print(f"Ýalňyşlyk ýüze çykdy: {str(e)}")
        return False

def check_bot_py_errors(file_path):
    """Bot.py faýlyndaky ýörite meseleleri barla we düzet"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Admin ID üçin düzedişleri barla
        if 'ADMIN_ID = int(os.getenv("ADMIN_ID", 0))' in content:
            content = content.replace(
                'ADMIN_ID = int(os.getenv("ADMIN_ID", 0))',
                'try:\n    admin_id_str = os.getenv("ADMIN_ID", "0")\n    # Diňe san bolsa, integer-e öwür\n    admin_id_str = admin_id_str.strip() if isinstance(admin_id_str, str) else "0"\n    admin_id_str = \'\'.join(c for c in admin_id_str if c.isdigit()) # diňe sanlar\n    ADMIN_ID = int(admin_id_str) if admin_id_str else 0\nexcept Exception as e:\n    print(f"Admin ID öwrülip bilmedi: {str(e)}")\n    ADMIN_ID = 0'
            )
            print("ADMIN_ID işlenişini düzetdim")
        
        # .env ýüklemesini barla we gerekli bolsa düzet
        if 'load_dotenv()' in content and 'try:\n    load_dotenv()' not in content:
            content = content.replace(
                'load_dotenv()',
                'try:\n    load_dotenv()\nexcept Exception:\n    try:\n        load_dotenv(".env.test")\n    except Exception as e:\n        print(f"Konfigurasiýa ýüklenip bilmedi: {str(e)}")'
            )
            print(".env ýüklenişini düzetdim")
        
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(content)
        
        return True
    except Exception as e:
        print(f"Bot.py faýlyny düzetmekde ýalňyşlyk: {str(e)}")
        return False

if __name__ == "__main__":
    bot_path = "/opt/chatbot/bot.py"
    
    # Eger komanda setirinden başga ýol berilen bolsa, şony ulanýarys
    if len(sys.argv) > 1:
        bot_path = sys.argv[1]
    
    if not os.path.exists(bot_path):
        print(f"Ýalňyşlyk: '{bot_path}' faýly tapylmady")
        sys.exit(1)
    
    # 1. Indentasiýa meseleleri düzet
    success1 = fix_indentation(bot_path)
    
    # 2. Bot.py-daky ýörite meseleleri düzet
    success2 = check_bot_py_errors(bot_path)
    
    sys.exit(0 if (success1 and success2) else 1) 