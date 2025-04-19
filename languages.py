"""
Telegram bot için dil dosyası.
Desteklenen diller: Türkmence (tm), Türkçe (tr), Rusça (ru)
"""

LANGUAGES = {
    "tm": {
        "name": "Türkmençe",
        # Genel mesajlar
        "welcome_bot": "Salam! Men bu toparyň dolandyryş we işjeňlik botydyryn. Size nähili kömek edip bilerin?",
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
        "write_your_answer": "Jogabyňyzy söhbetdeşlige ýazyň we beýleki agzalar bilen gatnaşyga giriň!"
    },
    
    "tr": {
        "name": "Türkçe",
        # Genel mesajlar
        "welcome_bot": "Merhaba! Ben bu grubun yönetim ve aktivite botuyum. Size nasıl yardımcı olabilirim?",
        "choose_language": "Dil seçin:",
        "language_changed": "Dil değiştirildi: Türkçe",
        
        # Kullanıcı komutları
        "cmd_help": "Yardım",
        "cmd_rules": "Kurallar",
        "cmd_profile": "Profil",
        "cmd_events": "Etkinlikler",
        "cmd_suggest": "Öneri",
        "cmd_games": "Oyunlar",
        "cmd_language": "Dil",
        
        # Admin komutları
        "cmd_stats": "İstatistikler",
        "cmd_broadcast": "Duyuru",
        "cmd_poll": "Anket",
        "cmd_activity": "Aktivite",
        "cmd_ban": "Yasakla",
        "cmd_unban": "Yasak Kaldır",
        "cmd_promote": "Yönetici Yap",
        "cmd_demote": "Yöneticilik Al",
        
        # Komut listeleri
        "user_commands": """
*Kullanıcı Komutları:*
/help - Yardım menüsünü göster
/rules - Grup kurallarını göster
/profile - Profilinizi görüntüleyin
/events - Yaklaşan etkinlikleri göster
/suggest - Öneri veya geri bildirim gönderin
/games - Oyun menüsünü aç
/language - Dil değiştir
""",
        "admin_commands": """
*Admin Komutları:*
/stats - Grup istatistiklerini göster
/broadcast - Tüm kullanıcılara mesaj gönder
/poll - Anket oluştur
/activity - Aktivite mesajı gönder
/ban - Kullanıcıyı yasakla
/unban - Kullanıcının yasağını kaldır
/promote - Kullanıcıyı yönetici yap
/demote - Kullanıcının yönetici yetkisini al
""",
        
        # Grup kuralları
        "group_rules": """
*Grup Kuralları:*

1. Saygılı olun: Tüm üyelere saygılı davranın, hakaret ve kötü dil kullanmayın.

2. Spam yapmayın: Aynı mesajı tekrar tekrar göndermekten kaçının.

3. İlgili içerik paylaşın: Grup konusuyla ilgili içerikler paylaşın.

4. Reklam yapmayın: İzinsiz reklam ve tanıtım yapmak yasaktır.

5. Özel bilgileri paylaşmayın: Kendi veya başkalarının özel bilgilerini paylaşmayın.

6. Telif haklarına saygı gösterin: Telif hakkı ihlali olan içerikleri paylaşmayın.

7. Yönetici uyarılarına uyun: Yöneticilerin uyarılarını dikkate alın.

Kurallara uymayan üyeler uyarılabilir veya gruptan çıkarılabilir.
""",
        
        # Poll Topics
        "poll_topics": [
            ["Hangi etkinliği tercih edersiniz?", ["Sesli sohbet", "Video konferans", "Oyun gecesi", "Bilgi yarışması"]],
            ["En sevdiğiniz iletişim yöntemi hangisi?", ["Mesajlaşma", "Sesli arama", "Video görüşme", "Yüz yüze görüşme"]],
            ["Hangi tür içerikler görmek istersiniz?", ["Haberler", "Eğitim", "Eğlence", "Teknoloji", "Spor"]],
            ["Grupta en çok neyi seviyorsunuz?", ["Sohbetler", "Paylaşılan içerikler", "Yeni insanlar tanımak", "Bilgi edinmek"]],
            ["Hangi saatlerde daha aktifsiniz?", ["Sabah", "Öğlen", "Akşam", "Gece"]]
        ],
        
        # Karşılama mesajları
        "welcome_messages": [
            "Hoş geldiniz! Gruba katıldığınız için teşekkür ederiz! 🎉",
            "Aramıza hoş geldiniz! Sizinle tanışmak için sabırsızlanıyoruz! 👋",
            "Yeni bir üye daha! Gruba hoş geldiniz! 🚀",
            "Merhaba ve gruba hoş geldiniz! Keyifli sohbetler dileriz! 💬"
        ],
        
        # Aktivite promtları
        "activity_prompts": [
            "Bugün nasıl geçiyor? Paylaşmak istediğiniz bir şey var mı? 💭",
            "Bu haftanın en iyi anınız neydi? 🌟",
            "Hangi konular hakkında daha fazla konuşmak istersiniz? 🗣️",
            "Öneri veya geri bildirimleriniz var mı? Bize bildirin! 📝",
            "Herkese günaydın! Bugün için planlarınız neler? ☀️",
            "Sizce grubumuzu nasıl geliştirebiliriz? Fikirlerinizi paylaşın! 🚀",
            "Hafta sonu için önerileriniz var mı? 🏖️",
            "Bugün size ilham veren bir şey oldu mu? 💫",
            "Sevdiğiniz bir alıntı veya söz paylaşır mısınız? 📚",
            "En son izlediğiniz film ya da dizi neydi? 🎬"
        ],
        
        # Profil
        "name": "İsim",
        "username": "Kullanıcı Adı",
        "join_date": "Katılım Tarihi",
        "message_count": "Mesaj Sayısı",
        "language": "Dil",
        
        # İstatistikler
        "total_users": "Toplam Üye",
        "active_today": "Bugün Aktif",
        "top_users": "En Aktif Üyeler",
        
        # Oyun menüsü
        "games_menu": "🎮 *Oyun Menüsü*\n\nEğlenmek ve diğer üyelerle etkileşimde bulunmak için bir oyun seçin:",
        "game_chance": "Şans Oyunu",
        "game_trivia": "Soru-Cevap",
        "game_word": "Kelime Oyunu",
        
        # Diğer mesajlar
        "admin_only": "Bu komut sadece yöneticiler için kullanılabilir.",
        "suggestion_saved": "✅ Öneriniz kaydedildi. Teşekkür ederiz!",
        "poll_question": "Soru",
        "poll_answer": "Cevap",
        "show_answer": "Cevabı Göster",
        "your_chance": "Şansın bugün: {}/100\n\n{}",
        "very_lucky": "Çok şanslısın! 🍀",
        "todays_question": "💬 *Günün Sorusu*\n\n{}",
        "discussion_time": "💬 *Tartışma Zamanı*\n\n{}",
        "announcement": "📢 *Duyuru*\n\n{}",
        "write_your_answer": "Cevabınızı sohbete yazın ve diğer üyelerle etkileşime geçin!"
    },
    
    "ru": {
        "name": "Русский",
        # Genel mesajlar
        "welcome_bot": "Привет! Я бот для управления и активности этой группы. Чем я могу вам помочь?",
        "choose_language": "Выберите язык:",
        "language_changed": "Язык изменен: Русский",
        
        # Kullanıcı komutları
        "cmd_help": "Помощь",
        "cmd_rules": "Правила",
        "cmd_profile": "Профиль",
        "cmd_events": "События",
        "cmd_suggest": "Предложение",
        "cmd_games": "Игры",
        "cmd_language": "Язык",
        
        # Admin komutları
        "cmd_stats": "Статистика",
        "cmd_broadcast": "Объявление",
        "cmd_poll": "Опрос",
        "cmd_activity": "Активность",
        "cmd_ban": "Блокировать",
        "cmd_unban": "Разблокировать",
        "cmd_promote": "Повысить",
        "cmd_demote": "Понизить",
        
        # Komut listeleri
        "user_commands": """
*Команды пользователя:*
/help - Показать меню помощи
/rules - Показать правила группы
/profile - Просмотреть свой профиль
/events - Показать предстоящие события
/suggest - Отправить предложение или отзыв
/games - Открыть меню игр
/language - Изменить язык
""",
        "admin_commands": """
*Команды администратора:*
/stats - Показать статистику группы
/broadcast - Отправить сообщение всем пользователям
/poll - Создать опрос
/activity - Отправить сообщение активности
/ban - Заблокировать пользователя
/unban - Разблокировать пользователя
/promote - Сделать пользователя администратором
/demote - Удалить права администратора
""",
        
        # Poll Topics
        "poll_topics": [
            ["Какое мероприятие вы предпочитаете?", ["Голосовой чат", "Видеоконференция", "Игровой вечер", "Викторина"]],
            ["Какой способ общения вам нравится больше всего?", ["Сообщения", "Голосовые вызовы", "Видеозвонки", "Личные встречи"]],
            ["Какой контент вы хотели бы видеть?", ["Новости", "Образование", "Развлечения", "Технологии", "Спорт"]],
            ["Что вам больше всего нравится в группе?", ["Беседы", "Публикуемый контент", "Знакомство с новыми людьми", "Получение информации"]],
            ["В какое время вы наиболее активны?", ["Утро", "День", "Вечер", "Ночь"]]
        ],
        
        # Grup kuralları
        "group_rules": """
*Правила группы:*

1. Будьте вежливы: Относитесь ко всем участникам с уважением, не используйте оскорбления и грубые выражения.

2. Не спамьте: Избегайте повторной отправки одного и того же сообщения.

3. Публикуйте релевантный контент: Делитесь содержанием, связанным с темой группы.

4. Не рекламируйте: Несанкционированная реклама и продвижение запрещены.

5. Не делитесь личной информацией: Не раскрывайте свою или чужую личную информацию.

6. Уважайте авторские права: Не делитесь контентом, нарушающим авторские права.

7. Следуйте указаниям администраторов: Обращайте внимание на предупреждения администраторов.

Пользователи, не соблюдающие правила, могут быть предупреждены или удалены из группы.
""",
        
        # Karşılama mesajları
        "welcome_messages": [
            "Добро пожаловать! Спасибо за присоединение к группе! 🎉",
            "Добро пожаловать в наш круг! Мы с нетерпением ждем знакомства с вами! 👋",
            "Ещё один новый участник! Добро пожаловать в группу! 🚀",
            "Привет и добро пожаловать в группу! Желаем приятного общения! 💬"
        ],
        
        # Aktivite promtları
        "activity_prompts": [
            "Как проходит ваш день? Есть ли что-то, чем хотите поделиться? 💭",
            "Что было лучшим моментом этой недели? 🌟",
            "О каких темах вы хотели бы больше поговорить? 🗣️",
            "Есть ли у вас предложения или отзывы? Дайте нам знать! 📝",
            "Доброе утро всем! Какие у вас планы на сегодня? ☀️",
            "Как вы думаете, как мы можем улучшить нашу группу? Делитесь своими идеями! 🚀",
            "Есть ли у вас предложения на выходные? 🏖️",
            "Было ли сегодня что-то, что вас вдохновило? 💫",
            "Не могли бы вы поделиться любимой цитатой или высказыванием? 📚",
            "Какой фильм или сериал вы смотрели в последнее время? 🎬"
        ],
        
        # Profil
        "name": "Имя",
        "username": "Имя пользователя",
        "join_date": "Дата присоединения",
        "message_count": "Количество сообщений",
        "language": "Язык",
        
        # İstatistikler
        "total_users": "Всего участников",
        "active_today": "Активны сегодня",
        "top_users": "Самые активные пользователи",
        
        # Oyun menüsü
        "games_menu": "🎮 *Меню игр*\n\nВыберите игру, чтобы развлечься и взаимодействовать с другими участниками:",
        "game_chance": "Игра удачи",
        "game_trivia": "Вопрос-ответ",
        "game_word": "Словесная игра",
        
        # Diğer mesajlar
        "admin_only": "Эта команда доступна только для администраторов.",
        "suggestion_saved": "✅ Ваше предложение сохранено. Спасибо!",
        "poll_question": "Вопрос",
        "poll_answer": "Ответ",
        "show_answer": "Показать ответ",
        "your_chance": "Ваша удача сегодня: {}/100\n\n{}",
        "very_lucky": "Очень везучий! 🍀",
        "todays_question": "💬 *Вопрос дня*\n\n{}",
        "discussion_time": "💬 *Время обсуждения*\n\n{}",
        "announcement": "📢 *Объявление*\n\n{}",
        "write_your_answer": "Напишите свой ответ в чат и взаимодействуйте с другими участниками!"
    }
}

def get_text(lang_code, key):
    """Belirtilen dilin belirtilen anahtar kelimesini döndürür"""
    if lang_code not in LANGUAGES:
        lang_code = "tm"  # Varsayılan olarak Türkmence
    
    return LANGUAGES[lang_code].get(key, LANGUAGES["tm"].get(key, "")) 