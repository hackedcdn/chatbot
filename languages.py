"""
ChatBot - Turkmenistan üçin chatbot
Dolandyryjy: hackedcdn (https://github.com/hackedcdn/chatbot)
"""

LANGUAGES = {
    "tm": {
        "name": "Türkmençe",
        # Genel mesajlar
        "welcome_bot": "Salam! Men ChatBot. Size nähili kömek edip bilerin?",
        "choose_language": "Dil saýlaň:",
        "language_changed": "Dil üýtgedildi: Türkmençe",
        
        # Kullanıcı komutları
        "cmd_help": "Kömek",
        "cmd_rules": "Düzgünler",
        "cmd_profile": "Profil",
        "cmd_events": "Çäreler",
        "cmd_suggest": "Teklip",
        "cmd_games": "Oýunlar",
        "cmd_language": "Dil",
        
        # Admin komutları
        "cmd_stats": "Statistika",
        "cmd_broadcast": "Habar",
        "cmd_poll": "Sorag",
        "cmd_activity": "Işjeňlik",
        "cmd_ban": "Gadagan",
        "cmd_unban": "Gadagany aýyr",
        "cmd_promote": "Ýokarlandyr",
        "cmd_demote": "Peseltmek",
        
        # Komut listeleri
        "user_commands": """
*Ulanyjy buýruklary:*
/help - Kömek menýusyny görkez
/rules - Toparyň düzgünlerini görkez
/profile - Profiliňizi görmek
/events - Geljek çäreleri görkez
/suggest - Teklip ýa-da seslenme iberip
/games - Oýun menýusyny aç
/language - Dili üýtget
""",
        "admin_commands": """
*Admin buýruklary:*
/stats - Topar statistikasyny görkez
/broadcast - Ähli ulanyjylara habar iber
/poll - Sorag döret
/activity - Işjeňlik habary iber
/ban - Ulanyjyny gadagan et
/unban - Ulanyjynyň gadaganlygyny aýyr
/promote - Ulanyjyny administrator et
/demote - Ulanyjynyň administrator ygtyýaryny aýyr
""",
        
        # Grup kuralları
        "group_rules": """
*Topar Düzgünleri:*

1. Hormatly boluň: Ähli agzalara hormat goýuň, sögünç we erbet dil ulanmaň.

2. Spam etmäň: Şol bir habary gaýtadan-gaýtada ibermekden saklanmak.

3. Degişli mazmuny paýlaşyň: Toparyň temasy bilen baglanyşykly mazmuny paýlaşyň.

4. Mahabat etmäň: Rugsatsyz mahabat we öňe sürmek gadagan.

5. Şahsy maglumatlary paýlaşmaň: Özüňiziň ýa-da beýlekileriň şahsy maglumatlaryny paýlaşmaň.

6. Awtorlyk hukuklaryna hormat goýuň: Awtorlyk hukugy bozan mazmuny paýlaşmaň.

7. Administrator duýduryşlaryna eýeriň: Administratorlaryň duýduryşlaryny hasaba alyň.

Düzgünlere boýun egmeýän agzalar duýdurylyp ýa-da topardan çykarylyp bilner.
""",
        
        # Karşılama mesajları
        "welcome_messages": [
            "Hoş geldiňiz! Topara goşulandygyňyz üçin sag boluň! 🎉",
            "Aramyza hoş geldiňiz! Siz bilen tanyşmak üçin sabyrsyzlanýarys! 👋",
            "Ýene bir täze agza! Topara hoş geldiňiz! 🚀",
            "Salam we topara hoş geldiňiz! Lezzet bilen söhbetdeşlik arzuw edýäris! 💬"
        ],
        
        # Aktivite promtları
        "activity_prompts": [
            "Şu gün nähili geçýär? Paýlaşmak isleýän zat barmy? 💭",
            "Bu hepdäniň iň gowy pursady näme boldy? 🌟",
            "Haýsy temalar barada has köp gürleşmek isleýärsiňiz? 🗣️",
            "Teklip ýa-da seslenme barmy? Bize habar beriň! 📝",
            "Hemmelere ertirlik haýyr! Şu gün üçin meýilnamalar näme? ☀️",
            "Siziň pikiriňizçe, toparymyzy nädip ösdürip bileris? Pikirlerňizi paýlaşyň! 🚀",
            "Dynç alyş günleri üçin teklipler barmy? 🏖️",
            "Şu gün size ruhlandyrýan zat boldymy? 💫",
            "Halaýan sitata ýa-da söz paýlaşjak bolsaňyz? 📚",
            "Iň soňky gören filmiňiz ýa-da serialyňyz näme boldy? 🎬"
        ],
        
        # Poll topics
        "poll_topics": [
            ["Haýsy çäräni gowy görýärsiňiz?", ["Sesli söhbet", "Wideo konferensiýa", "Oýun gijesini", "Bilim bäsleşigi"]],
            ["Iň gowy aragatnaşyk usuly haýsy?", ["Habarlary ibermek", "Ses jaň", "Wideo jaň", "Ýüz-be-ýüz duşuşyk"]],
            ["Haýsy görnüşli mazmuny görmek isleýärsiňiz?", ["Täzelikler", "Bilim", "Eglence", "Tehnologiýa", "Sport"]],
            ["Toparymyzda näme size has ýaraýar?", ["Söhbetler", "Paýlaşylan mazmun", "Täze adamlar bilen tanyşmak", "Maglumat almak"]],
            ["Haýsy sagatlarda has işjeň bolýarsyňyz?", ["Ertir", "Günortadan soň", "Agşam", "Gije"]]
        ],
        
        # Oyun menüsü
        "games_menu": "🎮 *Oýun Menýusy*\n\nEglenmek we beýleki agzalar bilen gatnaşyk saklamak üçin oýun saýlaň:",
        "game_chance": "Şans Oýny",
        "game_trivia": "Sorag-Jogap",
        "game_word": "Söz Oýny",
        
        # Profil
        "name": "At",
        "username": "Ulanyjy ady",
        "join_date": "Goşulan senesi",
        "message_count": "Habarlaryň sany",
        "language": "Dil",
        
        # İstatistikler
        "total_users": "Jemi Agzalar",
        "active_today": "Şu gün işjeň",
        "top_users": "Iň işjeň ulanyjylar",
        
        # Diğer mesajlar
        "admin_only": "Bu buýruk diňe administratorlar üçin ulanylýar.",
        "suggestion_saved": "✅ Teklibiňiz hasaba alyndy. Sag boluň!",
        "poll_question": "Sorag",
        "poll_answer": "Jogap",
        "show_answer": "Jogaby Görkez",
        "your_chance": "Şansyňyz şu gün: {}/100\n\n{}",
        "very_lucky": "Gaty şansly! 🍀",
        "todays_question": "💬 *Günüň Soragy*\n\n{}",
        "discussion_time": "💬 *Çekişme Wagty*\n\n{}",
        "announcement": "📢 *Bildiriş*\n\n{}",
        "write_your_answer": "Jogabyňyzy söhbetdeşlige ýazyň we beýleki agzalar bilen gatnaşyga giriň!",
        "owner_info": "Bu bot hackedcdn (https://github.com/hackedcdn/chatbot) tarapyndan döredildi."
    }
}

def get_text(lang_code, key):
    """
    Belirli bir anahtar için çeviriyi döndürür.
    Dil kodu yoksa varsayılan olarak Türkmence kullanılır.
    """
    if lang_code not in LANGUAGES:
        lang_code = "tm"
    
    return LANGUAGES[lang_code].get(key, f"Tercime tapylmady: {key}") 