import os
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables
load_dotenv()

# Connect to MongoDB
client = MongoClient(os.getenv('MONGODB_URI'))
db = client[os.getenv('DATABASE_NAME')]
chats_collection = db['chats']

def register_chat(chat_id, chat_title, chat_type):
    """Register a chat in the database"""
    chat_data = {
        'chat_id': chat_id,
        'title': chat_title,
        'type': chat_type,
        'registered_at': datetime.now(),
        'active': True,
        'settings': {
            'welcome_enabled': True,
            'activity_prompts_enabled': True,
            'stats_tracking_enabled': True,
            'games_enabled': True
        }
    }
    
    chats_collection.update_one(
        {'chat_id': chat_id},
        {'$set': chat_data},
        upsert=True
    )
    return chat_data

def get_active_chats():
    """Get all active chats"""
    return list(chats_collection.find({'active': True}))

def update_chat_setting(chat_id, setting, value):
    """Update a chat setting"""
    chats_collection.update_one(
        {'chat_id': chat_id},
        {'$set': {f'settings.{setting}': value}}
    )

def deactivate_chat(chat_id):
    """Mark a chat as inactive"""
    chats_collection.update_one(
        {'chat_id': chat_id},
        {'$set': {'active': False}}
    )

def reactivate_chat(chat_id):
    """Mark a chat as active"""
    chats_collection.update_one(
        {'chat_id': chat_id},
        {'$set': {'active': True}}
    )

def get_chat_settings(chat_id):
    """Get chat settings"""
    chat = chats_collection.find_one({'chat_id': chat_id})
    if chat:
        return chat.get('settings', {})
    return {} 