#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import logging
import asyncio
from datetime import datetime, timedelta
from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    CallbackQueryHandler,
    ContextTypes,
    filters
)

# Yapılandırma
load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")
MONGODB_URI = os.getenv("MONGODB_URI")
DB_NAME = os.getenv("DATABASE_NAME", "turkmenbot_db")
ADMIN_ID = int(os.getenv("ADMIN_ID", 0))

# Loglama
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# MongoDB bağlantısı
try:
    client = MongoClient(MONGODB_URI)
    db = client[DB_NAME]
    users_collection = db["users"]
    groups_collection = db["groups"]
    mutes_collection = db["mutes"]
    logger.info("Connected to MongoDB successfully")
except ConnectionFailure as e:
    logger.error(f"Could not connect to MongoDB: {e}")
    exit(1)

# Dil desteği
LANGUAGES = {
    "tm": "Türkmençe"
}

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
    }
}

# Kullanıcı verilerini kaydetme
async def save_user_data(user_id, username, first_name, language=None):
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
    text = LANGUAGES[lang].get(key, LANGUAGES["tm"].get(key, f"Translation missing: {key}"))
    return text.format(**kwargs) if kwargs else text

# Komut işleyicileri
async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    await save_user_data(user.id, user.username, user.first_name)
    
    await update.message.reply_text(TRANSLATIONS["welcome"]["tm"])

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    await save_user_data(user.id, user.username, user.first_name)
    
    await update.message.reply_text(TRANSLATIONS["help"]["tm"])

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
    
    group = await asyncio.to_thread(groups_collection.find_one, {"chat_id": chat_id})
    
    if group:
        members = group.get("members_count", 0)
        messages = group.get("messages_count", 0)
    else:
        members = 0
        messages = 0
    
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
    
    if not context.args or not update.message.reply_to_message:
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
    
    until_date = datetime.now() + timedelta(minutes=duration)
    
    try:
        await context.bot.restrict_chat_member(
            chat_id, 
            target_id,
            permissions={"can_send_messages": False},
            until_date=until_date
        )
        
        # Mute bilgilerini veritabanına kaydet
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
        await asyncio.to_thread(
            mutes_collection.delete_one,
            {"user_id": target_id, "chat_id": chat_id}
        )
        
        await update.message.reply_text(
            TRANSLATIONS["user_unmuted"]["tm"].format(user=target_user.first_name)
        )
    except Exception as e:
        await update.message.reply_text(f"Ýalňyşlyk: {e}")

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    
    user_id = query.from_user.id
    data = query.data
    
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
    user = update.effective_user
    chat_type = update.effective_chat.type
    
    # Kullanıcının son etkinlik bilgisini güncelle
    await save_user_data(user.id, user.username, user.first_name)
    
    # Gruplar için istatistikleri güncelle
    if chat_type in ["group", "supergroup"]:
        chat_id = update.effective_chat.id
        
        await asyncio.to_thread(
            groups_collection.update_one,
            {"chat_id": chat_id},
            {
                "$inc": {"messages_count": 1},
                "$set": {"last_activity": datetime.now()}
            },
            upsert=True
        )

# Ana işlev
def main():
    # Uygulama oluştur
    application = Application.builder().token(BOT_TOKEN).build()
    
    # Komut işleyicileri ekle
    application.add_handler(CommandHandler("start", start_command))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("settings", settings_command))
    application.add_handler(CommandHandler("stats", stats_command))
    
    # Admin komutları
    application.add_handler(CommandHandler("ban", ban_command))
    application.add_handler(CommandHandler("unban", unban_command))
    application.add_handler(CommandHandler("mute", mute_command))
    application.add_handler(CommandHandler("unmute", unmute_command))
    
    # Callback sorguları işleyicisi
    application.add_handler(CallbackQueryHandler(button_callback))
    
    # Mesaj işleyicisi
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    # Uygulamayı başlat
    application.run_polling()

if __name__ == "__main__":
    main() 