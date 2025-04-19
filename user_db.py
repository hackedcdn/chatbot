import os
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables
load_dotenv()

# Connect to MongoDB
client = MongoClient(os.getenv('MONGODB_URI'))
db = client[os.getenv('DATABASE_NAME')]
users_collection = db['users']

def save_user(user_id, username, first_name, last_name, chat_id, language_code="tm"):
    """Save user to database"""
    user_data = {
        'user_id': user_id,
        'username': username,
        'first_name': first_name,
        'last_name': last_name,
        'chat_id': chat_id,
        'join_date': datetime.now(),
        'message_count': 0,
        'last_active': datetime.now(),
        'language_code': language_code
    }
    
    users_collection.update_one(
        {'user_id': user_id, 'chat_id': chat_id},
        {'$set': user_data},
        upsert=True
    )
    return user_data

def update_user_activity(user_id, chat_id):
    """Update user activity"""
    users_collection.update_one(
        {'user_id': user_id, 'chat_id': chat_id},
        {
            '$inc': {'message_count': 1},
            '$set': {'last_active': datetime.now()}
        }
    )

def set_user_language(user_id, chat_id, language_code):
    """Set user language preference"""
    users_collection.update_one(
        {'user_id': user_id, 'chat_id': chat_id},
        {'$set': {'language_code': language_code}}
    )

def get_user_language(user_id, chat_id, default="tm"):
    """Get user language preference"""
    user = users_collection.find_one({'user_id': user_id, 'chat_id': chat_id})
    if user:
        return user.get('language_code', default)
    return default

def get_user_stats(chat_id):
    """Get user statistics for a chat"""
    total_users = users_collection.count_documents({'chat_id': chat_id})
    active_today = users_collection.count_documents({
        'chat_id': chat_id, 
        'last_active': {'$gte': datetime.now().replace(hour=0, minute=0, second=0)}
    })
    
    top_users = list(users_collection.find(
        {'chat_id': chat_id},
        {'user_id': 1, 'username': 1, 'first_name': 1, 'message_count': 1}
    ).sort('message_count', -1).limit(5))
    
    return {
        'total_users': total_users,
        'active_today': active_today,
        'top_users': top_users
    }

def get_user(user_id, chat_id):
    """Get user data"""
    return users_collection.find_one({'user_id': user_id, 'chat_id': chat_id})
 