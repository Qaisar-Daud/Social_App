const videoKeywords = [
  // 🎬 Media & Entertainment
  'film', 'song', 'naat', 'drama', 'movie', 'movies 2025', 'best movies', 'new songs',
  'Bollywood movies', 'Hollywood movies', 'Lollywood', 'music album', 'latest songs',
  'Netflix series', 'Amazon Prime', 'Disney Plus', 'trailer', 'cinema', 'top rated movies',
  'series', 'web series', 'concert', 'dance', 'dj', 'remix', 'radio', 'podcast', 'celebrity',
  'biopic', 'awards', 'OST', 'soundtrack', 'comedy', 'documentary',

  // 🎮 Gaming & Esports
  'game', 'gameplay', 'gaming', 'gaming news', 'best PC games', 'best mobile games',
  'PUBG tricks', 'Fortnite tips', 'Call of Duty updates', 'Minecraft servers',
  'GTA', 'GTA 6 leaks', 'Assassin’s Creed', 'FIFA', 'NBA', 'stream', 'Twitch', 'livestream',
  'console', 'Xbox', 'PlayStation', 'Nintendo', 'VR gaming', 'metaverse', 'gaming tournaments',
  'eSports teams', 'gaming influencers', 'walkthrough',

  // 🤖 AI & Technology
  'AI', 'AI tools', 'best AI apps', 'AI-generated content', 'artificial intelligence',
  'machine learning', 'deep learning', 'neural networks', 'chatbot', 'GPT',
  'automation', 'robotics', 'blockchain', 'crypto', 'crypto trading', 'NFTs',
  'Metaverse', 'quantum computing', 'hologram', 'cybersecurity', 'cybersecurity tips',
  'cloud computing', 'tech gadgets 2025', 'Flutter', 'Flutter tutorial', 'React',
  'JavaScript', 'Python', 'Python for beginners', 'programming', 'data science',
  'data science course', 'big data', '5G technology', 'best coding languages', 'metaverse trends',

  // 📱 Social Media & Trends
  'trending', 'viral', 'viral videos', 'meme', 'TikTok', 'Instagram', 'Facebook', 'Twitter',
  'YouTube', 'Shorts', 'Reels', 'Hashtag', 'Snapchat', 'social influencer',
  'live', 'stories', 'content creator', 'blog', 'vlog', 'subscriber', 'engagement',
  'like', 'share', 'comment', 'social media marketing', 'Instagram trends',
  'TikTok viral songs', 'Facebook ads strategy', 'how to grow YouTube channel',
  'best hashtags for Instagram', 'how to get more followers', 'TikTok algorithm hack',
  'content creation tips',

  // 📚 Education & Knowledge
  'learning', 'study', 'university', 'college', 'school', 'exam', 'lecture', 'course',
  'online courses', 'best e-learning platforms', 'online class', 'teacher', 'student',
  'assignment', 'notes', 'research', 'eBook', 'science', 'math', 'math tricks',
  'history', 'history knowledge', 'economics', 'geography', 'philosophy', 'literature',
  'best programming languages', 'Flutter vs React', 'how to start freelancing',

  // 🛍️ E-commerce & Business
  'shop', 'ecommerce', 'best online shopping sites', 'sale', 'discount', 'Amazon',
  'Amazon deals', 'AliExpress', 'AliExpress discounts', 'Daraz', 'store',
  'shopping', 'product', 'brand', 'marketing', 'digital marketing tips', 'startup',
  'entrepreneur', 'investment', 'dropshipping', 'start a dropshipping business',
  'advertising', 'influencer marketing', 'business growth', 'business ideas 2025',
  'how to increase sales online',

  // ⚽ Sports & Fitness
  'sports', 'cricket', 'football', 'NBA', 'UFC', 'boxing', 'tennis', 'Olympics',
  'FIFA', 'FIFA World Cup', 'FIFA World Cup 2026', 'Champions League', 'workout',
  'gym', 'bodybuilding', 'best workout plans', 'gym exercises', 'healthy diet tips',
  'diet', 'yoga', 'health', 'nutrition', 'athlete', 'training', 'sports news',
  'match highlights', 'sports betting tips', 'best running shoes',

  // 🌍 News & Current Affairs
  'breaking news', 'breaking news today', 'headlines', 'politics', 'elections',
  'US elections 2024', 'world news', 'business news', 'science news', 'technology news',
  'weather', 'climate change', 'economic crisis 2025', 'market trends', 'economy',
  'stock market updates', 'inflation', 'recession', 'global events', 'war', 'peace talks',
  'crypto market crash', 'AI replacing jobs', 'future of space exploration',

  // 🎭 Art & Culture
  'painting', 'art gallery', 'fashion', 'design', 'creative', 'photography', 'portrait',
  'digital art', 'sketching', 'crafts', 'poetry', 'literature', 'books', 'writing',
  'storytelling', 'animation', 'cartoon', 'graphic design', 'illustration',

  // 🚀 Future Tech & Innovations
  'space', 'NASA', 'Elon Musk', 'SpaceX', 'Mars mission', 'AI future', 'flying cars',
  'flying cars 2050', 'drones', 'self-driving cars', 'hyperloop', 'biotechnology',
  'genetics', 'future inventions', 'nanotechnology', 'holographic technology',
  '3D printing', 'space travel 2030', 'Tesla new model', 'EV cars 2025',

  // 🌿 Religion & Spirituality
  'Islam', 'Christianity', 'Judaism', 'Hinduism', 'Buddhism', 'Quran', 'Bible',
  'Bhagavad Gita', 'prayers', 'daily prayers', 'dua', 'dua for success', 'spirituality',
  'faith', 'hadith', 'Islamic lectures', 'Islamic teachings', 'Islamic history',
  'mosque', 'church', 'Ramadan', 'Ramadan fasting tips', 'Hajj', 'Zakat', 'charity',
  'peace', 'soul', 'spiritual meditation', 'powerful mantras', 'Buddhist meditation techniques',

  // 🌍 Travel & Adventure
  'travel', 'best places to visit in 2025', 'tourism', 'trip', 'vacation', 'explore',
  'hotels', 'flights', 'cheap travel destinations', 'road trip', 'solo travel tips',
  'backpacking', 'beach', 'mountains', 'nature', 'adventure', 'camping', 'airbnb',
  'visa', 'visa-free countries 2025', 'passport', 'cruise', 'travel essentials',

  // 💰 Finance & Money
  'money', 'finance', 'investment', 'stocks', 'stocks to buy in 2025', 'trading',
  'crypto for beginners', 'Bitcoin', 'Ethereum', 'personal finance', 'saving tips',
  'budgeting', 'passive income', 'side hustle', 'side hustles that pay well',
  'freelancing', 'best freelancing websites', 'real estate investing tips',
  'loans', 'credit cards', 'how to save money fast',

  // 🌟 Miscellaneous & Trending Topics
  'mystery', 'mystery facts', 'conspiracy', 'best conspiracy theories', 'aliens',
  'UFO', 'UFO sightings 2025', 'paranormal', 'horror', 'ghost', 'secret societies',
  'ancient history', 'hidden knowledge', 'lost civilizations', 'philosophy',
  'unexplained phenomena', 'life-changing books', 'top 10 mysteries of the world',
  'unexplained events'
];
