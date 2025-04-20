#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ChatBot - Turkmenistan üçin chatbot
# Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)

import os
import logging
import asyncio
import random
import string
import re
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Union, Any

# Daşky kitaphanalar
try:
    from dotenv import load_dotenv
except ImportError:
    os.system('pip install python-dotenv')
    from dotenv import load_dotenv

# Konfigurasiýa faýlyny ýükle
try:
    load_dotenv()
except Exception:
    try:
        load_dotenv(".env.test")
    except Exception as e:
        print(f"Konfigurasiýa ýüklenip bilmedi: {str(e)}")

# Çeşme üýtgeýjileri
BOT_TOKEN = os.getenv("BOT_TOKEN", "")
MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "chatbot_db")

# Admin ID howpsuz usulda göçür
try:
    admin_id_str = os.getenv("ADMIN_ID", "0")
    # Diňe san bolsa, integer-e öwür
    admin_id_str = admin_id_str.strip() if isinstance(admin_id_str, str) else "0"
    admin_id_str = ''.join(c for c in admin_id_str if c.isdigit()) # diňe sanlar
    ADMIN_ID = int(admin_id_str) if admin_id_str else 0
except Exception as e:
    print(f"Admin ID öwrülip bilmedi: {str(e)}")
    ADMIN_ID = 0

# Telegram kitaphanalaryny içe göçür
try:
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application,
        CommandHandler,
        MessageHandler,
        CallbackQueryHandler,
        ContextTypes,
        filters
    )
except ImportError:
    os.system('pip install python-telegram-bot')
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application,
        CommandHandler,
        MessageHandler,
        CallbackQueryHandler,
        ContextTypes,
        filters
    )

# Loglama
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Maglumat bazasy saýlamalary
USE_MONGODB = False
db = None
users_collection = None
groups_collection = None
mutes_collection = None
sqlite_conn = None

# MongoDB baglanyşykny synanyş
try:
    from pymongo import MongoClient
    from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
    
    print("MongoDB baglanyşygy synanyşylýar...")
    client = MongoClient(MONGODB_URI, serverSelectionTimeoutMS=5000)
    # Baglanyşygy barla
    client.admin.command('ping')
    db = client[DATABASE_NAME]
    users_collection = db["users"]
    groups_collection = db["groups"]
    mutes_collection = db["mutes"]
    logger.info("MongoDB bilen baglanyşyk üstünlikli boldy")
    USE_MONGODB = True
except (ImportError, ConnectionFailure, ServerSelectionTimeoutError) as e:
    logger.error(f"MongoDB bilen baglanyşyk edip bolmady: {e}")
    print(f"MongoDB bilen baglanyşyk bolmady: {str(e)}")
    print("SQLite ulanylyp başlanylýar...")
    
    # SQLite importlary
    try:
        import sqlite3
        from pathlib import Path
        
        # SQLite db faýly üçin katalog döret (ýok bolsa)
        data_dir = Path("./data")
        data_dir.mkdir(exist_ok=True)
        
        # SQLite baglanyşygyny döret
        db_path = data_dir / "chatbot.db"
        sqlite_conn = sqlite3.connect(str(db_path))
        sqlite_conn.row_factory = sqlite3.Row
        
        # Tablolary döret
        cursor = sqlite_conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY, 
                username TEXT, 
                first_name TEXT,
                language TEXT DEFAULT 'tm',
                last_activity TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS groups (
                chat_id INTEGER PRIMARY KEY, 
                members_count INTEGER DEFAULT 0, 
                messages_count INTEGER DEFAULT 0,
                last_activity TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS mutes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER, 
                chat_id INTEGER, 
                until_date TIMESTAMP,
                muted_by INTEGER
            )
        ''')
        
        sqlite_conn.commit()
        print(f"SQLite maglumatlary şu ýere ýazyljakdyr: {db_path}")
        logger.info(f"SQLite maglumatlary şu ýere ýazyljakdyr: {db_path}")
    except Exception as sqlite_error:
        logger.error(f"SQLite bilenem işläp bolmady: {sqlite_error}")
        print(f"SQLite bilenem işläp bolmady: {sqlite_error}")
        print("Bot diňe lokal maglumat baza ulanyp işleýär")

# Maglumat saklamak üçin funksiýalar
async def save_user_data(user_id, username, first_name, language=None):
    try:
        if USE_MONGODB:
            user_data = {
                "user_id": user_id,
                "username": username,
                "first_name": first_name,
                "last_activity": datetime.now()
            }

            if language:
                user_data["language"] = language

            await asyncio.to_thread(
                users_collection.update_one,
                {"user_id": user_id},
                {"$set": user_data},
                upsert=True
            )
        elif sqlite_conn:
            # SQLite üçin
            cursor = sqlite_conn.cursor()
            now = datetime.now().isoformat()
            
            # Ulanyşyjy bar bolsa, täzele, bolmasa döret
            cursor.execute(
                "INSERT OR REPLACE INTO users (user_id, username, first_name, language, last_activity) VALUES (?, ?, ?, ?, ?)",
                (user_id, username, first_name, language or "tm", now)
            )
            sqlite_conn.commit()
    except Exception as e:
        logger.error(f"Ulanyjy maglumatlaryny ýazdyryp bolmady: {e}")

# Dil desteği - sadece Türkmence
LANGUAGES = {
    "tm": "Türkmençe"
}

# Çeviriler
TRANSLATIONS = {
    "welcome": {
        "tm": "Salam! Men ChatBot. Haýyş edýärin buýruk saýlaň:"
    },
    "language_changed": {
        "tm": "Diliňiz üýtgedildi!"
    },
    "help": {
        "tm": "Men ChatBot! Aşakdaky buýruklary ulanyp bilersiňiz:\n\n/start - Botu täzeden başlatmak\n/help - Kömek\n/settings - Sazlamalar"
    },
    "settings": {
        "tm": "Sazlamalar:"
    },
    "stats": {
        "tm": "Statistikalar:\nAgzalar: {members}\nHabarlar: {messages}"
    },
    "admin_only": {
        "tm": "Bu buýruk diňe adminler üçin elýeterlidir."
    },
    "user_banned": {
        "tm": "{user} ban edildi."
    },
    "user_unbanned": {
        "tm": "{user} bannan çykaryldy."
    },
    "user_muted": {
        "tm": "{user} {duration} müddet seslendirilmedi."
    },
    "user_unmuted": {
        "tm": "{user} üçin sessize alynma ýatyryldy."
    },
    "group_only": {
        "tm": "Bu buýruk diňe gruppalarda elýeterlidir."
    },
    "owner_info": {
        "tm": "Bu bot hackedcdn (https://github.com/hackedcdn/chatbot) tarapyndan döredildi."
    }
}

# Admin kontrolü
async def is_admin(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    if user_id == ADMIN_ID:
        return True

    chat_id = update.effective_chat.id
    user = await context.bot.get_chat_member(chat_id, user_id)
    return user.status in ["creator", "administrator"]

# Kullanıcı ayarlarını alma
async def get_user_language(user_id):
    return "tm"

# Çeviri yardımcı işlevi
async def get_text(key, user_id, **kwargs):
    lang = await get_user_language(user_id)
    if lang not in LANGUAGES:
        lang = "tm"
    text = TRANSLATIONS.get(key, {}).get(lang, TRANSLATIONS.get(key, {}).get("tm", f"Translation missing: {key}"))       
    return text.format(**kwargs) if kwargs else text

# Komut işleyicileri
async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    await save_user_data(user.id, user.username, user.first_name)

    welcome_message = TRANSLATIONS["welcome"]["tm"]
    owner_info = TRANSLATIONS["owner_info"]["tm"]

    await update.message.reply_text(f"{welcome_message}\n\n{owner_info}")

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    await save_user_data(user.id, user.username, user.first_name)

    help_text = TRANSLATIONS["help"]["tm"]
    owner_info = TRANSLATIONS["owner_info"]["tm"]

    await update.message.reply_text(f"{help_text}\n\n{owner_info}")

async def settings_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id

    keyboard = [
        [InlineKeyboardButton("⚙️ " + TRANSLATIONS["settings"]["tm"], callback_data="settings_main")]
    ]

    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        TRANSLATIONS["settings"]["tm"],
        reply_markup=reply_markup
    )

async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await is_admin(update, context):
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["admin_only"]["tm"])
        return

    chat_id = update.effective_chat.id
    members = 0
    messages = 0

    try:
        if USE_MONGODB:
            group = await asyncio.to_thread(groups_collection.find_one, {"chat_id": chat_id})
            if group:
                members = group.get("members_count", 0)
                messages = group.get("messages_count", 0)
        elif sqlite_conn:
            cursor = sqlite_conn.cursor()
            cursor.execute("SELECT members_count, messages_count FROM groups WHERE chat_id = ?", (chat_id,))
            result = cursor.fetchone()
            if result:
                members = result["members_count"]
                messages = result["messages_count"]
    except Exception as e:
        logger.error(f"Statistikalary almakda ýalňyşlyk: {e}")

    await update.message.reply_text(
        TRANSLATIONS["stats"]["tm"].format(members=members, messages=messages)
    )

async def ban_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_chat.type == "private":
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["group_only"]["tm"])
        return

    if not await is_admin(update, context):
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["admin_only"]["tm"])
        return

    if not context.args or not update.message.reply_to_message:
        await update.message.reply_text("Ulanmak: /ban [sebäp]")
        return

    target_user = update.message.reply_to_message.from_user
    target_id = target_user.id
    reason = " ".join(context.args)

    try:
        await context.bot.ban_chat_member(update.effective_chat.id, target_id)
        await update.message.reply_text(
            TRANSLATIONS["user_banned"]["tm"].format(user=target_user.first_name)
        )
    except Exception as e:
        await update.message.reply_text(f"Ýalňyşlyk: {e}")

async def unban_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_chat.type == "private":
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["group_only"]["tm"])
        return

    if not await is_admin(update, context):
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["admin_only"]["tm"])
        return

    if not update.message.reply_to_message:
        await update.message.reply_text("Ulanmak: /unban")
        return

    target_user = update.message.reply_to_message.from_user
    target_id = target_user.id

    try:
        await context.bot.unban_chat_member(update.effective_chat.id, target_id)
        await update.message.reply_text(
            TRANSLATIONS["user_unbanned"]["tm"].format(user=target_user.first_name)
        )
    except Exception as e:
        await update.message.reply_text(f"Ýalňyşlyk: {e}")

async def mute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_chat.type == "private":
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["group_only"]["tm"])
        return

    if not await is_admin(update, context):
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["admin_only"]["tm"])
        return

    if not update.message.reply_to_message:
        await update.message.reply_text("Ulanmak: /mute [minutda wagt]")
        return

    duration = 60  # Default: 60 minutes
    if context.args and context.args[0].isdigit():
        duration = int(context.args[0])

    target_user = update.message.reply_to_message.from_user
    target_id = target_user.id
    chat_id = update.effective_chat.id
    user_id = update.effective_user.id

    until_date = datetime.now() + timedelta(minutes=duration)

    try:
        await context.bot.restrict_chat_member(
            chat_id,
            target_id,
            permissions={"can_send_messages": False},
            until_date=until_date
        )

        # Mute bilgilerini veritabanına kaydet
        if USE_MONGODB:
            await asyncio.to_thread(
                mutes_collection.update_one,
                {"user_id": target_id, "chat_id": chat_id},
                {"$set": {
                    "user_id": target_id,
                    "chat_id": chat_id,
                    "until_date": until_date,
                    "muted_by": user_id
                }},
                upsert=True
            )
        elif sqlite_conn:
            cursor = sqlite_conn.cursor()
            cursor.execute(
                "INSERT OR REPLACE INTO mutes (user_id, chat_id, until_date, muted_by) VALUES (?, ?, ?, ?)",
                (target_id, chat_id, until_date.isoformat(), user_id)
            )
            sqlite_conn.commit()

        await update.message.reply_text(
            TRANSLATIONS["user_muted"]["tm"].format(
                user=target_user.first_name,
                duration=f"{duration} min"
            )
        )
    except Exception as e:
        await update.message.reply_text(f"Ýalňyşlyk: {e}")

async def unmute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_chat.type == "private":
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["group_only"]["tm"])
        return

    if not await is_admin(update, context):
        user_id = update.effective_user.id
        await update.message.reply_text(TRANSLATIONS["admin_only"]["tm"])
        return

    if not update.message.reply_to_message:
        await update.message.reply_text("Ulanmak: /unmute")
        return

    target_user = update.message.reply_to_message.from_user
    target_id = target_user.id
    chat_id = update.effective_chat.id

    try:
        await context.bot.restrict_chat_member(
            chat_id,
            target_id,
            permissions={
                "can_send_messages": True,
                "can_send_audios": True,
                "can_send_documents": True,
                "can_send_photos": True,
                "can_send_videos": True,
                "can_send_video_notes": True,
                "can_send_voice_notes": True,
                "can_send_polls": True,
                "can_send_other_messages": True,
                "can_add_web_page_previews": True,
            }
        )

        # Mute'i veritabanından kaldır
        if USE_MONGODB:
            await asyncio.to_thread(
                mutes_collection.delete_one,
                {"user_id": target_id, "chat_id": chat_id}
            )
        elif sqlite_conn:
            cursor = sqlite_conn.cursor()
            cursor.execute(
                "DELETE FROM mutes WHERE user_id = ? AND chat_id = ?",
                (target_id, chat_id)
            )
            sqlite_conn.commit()

        await update.message.reply_text(
            TRANSLATIONS["user_unmuted"]["tm"].format(user=target_user.first_name)
        )
    except Exception as e:
        await update.message.reply_text(f"Ýalňyşlyk: {e}")

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    data = query.data
    user_id = query.from_user.id

    await query.answer()

    if data == "settings_main":
        keyboard = []

        # Burada istediğiniz ayarları ekleyebilirsiniz
        keyboard.append([InlineKeyboardButton("⬅️ Yza", callback_data="back_to_main")])

        reply_markup = InlineKeyboardMarkup(keyboard)

        await query.edit_message_text(
            text=TRANSLATIONS["settings"]["tm"],
            reply_markup=reply_markup
        )
    elif data == "back_to_main":
        await query.edit_message_text(text=TRANSLATIONS["settings"]["tm"])

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.effective_user or not update.message:
        return

    user = update.effective_user
    message = update.message
    chat_id = update.effective_chat.id
    chat_type = update.effective_chat.type

    # Kullanıcı kaydı
    await save_user_data(user.id, user.username, user.first_name)

    # Gruplar için istatistikleri güncelle
    if chat_type in ["group", "supergroup"]:
        try:
            if USE_MONGODB:
                await asyncio.to_thread(
                    groups_collection.update_one,
                    {"chat_id": chat_id},
                    {
                        "$inc": {"messages_count": 1},
                        "$set": {"last_activity": datetime.now()}
                    },
                    upsert=True
                )
            elif sqlite_conn:
                cursor = sqlite_conn.cursor()
                now = datetime.now().isoformat()
                cursor.execute(
                    "INSERT INTO groups (chat_id, messages_count, last_activity) VALUES (?, 1, ?) ON CONFLICT(chat_id) DO UPDATE SET messages_count = messages_count + 1, last_activity = ?",
                    (chat_id, now, now)
                )
                sqlite_conn.commit()
        except Exception as e:
            logger.error(f"Grup aktivitelerini güncellerken hata: {e}")

def main():
    # Uygulama oluştur
    application = Application.builder().token(BOT_TOKEN).build()

    # Komut işleyicileri
    application.add_handler(CommandHandler("start", start_command))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("settings", settings_command))
    application.add_handler(CommandHandler("stats", stats_command))
    application.add_handler(CommandHandler("ban", ban_command))
    application.add_handler(CommandHandler("unban", unban_command))
    application.add_handler(CommandHandler("mute", mute_command))
    application.add_handler(CommandHandler("unmute", unmute_command))

    # Callback ve mesaj işleyicileri
    application.add_handler(CallbackQueryHandler(button_callback))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    # Uygulamayı başlat
    logger.info("ChatBot - Turkmenistan üçin chatbot başladylýar (Eýesi: hackedcdn)")
    print("ChatBot - Turkmenistan üçin chatbot başladylýar (Eýesi: hackedcdn)")
    print("GitHub: https://github.com/hackedcdn/chatbot")
    
    # Veritabanı bilgisi
    if USE_MONGODB:
        print("MongoDB kullanılıyor")
    elif sqlite_conn:
        print("SQLite kullanılıyor")
    else:
        print("Veritabanı kullanılmıyor - sadece bellek modunda")
        
    application.run_polling()

if __name__ == "__main__":
    main() 