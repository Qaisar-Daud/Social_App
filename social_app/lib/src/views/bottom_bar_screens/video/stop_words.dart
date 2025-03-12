final commonStopWords = {
  // Basic English Stop Words
  'a', 'about', 'above', 'after', 'again', 'against', 'all', 'am', 'an', 'and', 'any', 'are', 'aren\'t', 'as', 'at',
  'be', 'because', 'been', 'before', 'being', 'below', 'between', 'both', 'but', 'by',
  'can', 'can\'t', 'could', 'couldn\'t',
  'did', 'didn\'t', 'do', 'does', 'doesn\'t', 'doing', 'don\'t', 'down', 'during',
  'each', 'few', 'for', 'from', 'further',
  'had', 'hadn\'t', 'has', 'hasn\'t', 'have', 'haven\'t', 'having', 'he', 'he\'d', 'he\'ll', 'he\'s', 'her', 'here', 'here\'s', 'hers', 'herself', 'him', 'himself', 'his', 'how', 'how\'s',
  'i', 'i\'d', 'i\'ll', 'i\'m', 'i\'ve', 'if', 'in', 'into', 'is', 'isn\'t', 'it', 'it\'s', 'its', 'itself',
  'let\'s', 'me', 'more', 'most', 'mustn\'t', 'my', 'myself',
  'no', 'nor', 'not', 'of', 'off', 'on', 'once', 'only', 'or', 'other', 'ought', 'our', 'ours', 'ourselves', 'out', 'over', 'own',
  'same', 'shan\'t', 'she', 'she\'d', 'she\'ll', 'she\'s', 'should', 'shouldn\'t', 'so', 'some', 'such',
  'than', 'that', 'that\'s', 'the', 'their', 'theirs', 'them', 'themselves', 'then', 'there', 'there\'s', 'these', 'they', 'they\'d', 'they\'ll', 'they\'re', 'they\'ve', 'this', 'those', 'through', 'to', 'too',
  'under', 'until', 'up', 'very', 'was', 'wasn\'t', 'we', 'we\'d', 'we\'ll', 'we\'re', 'we\'ve', 'were', 'weren\'t',
  'what', 'what\'s', 'when', 'when\'s', 'where', 'where\'s', 'which', 'while', 'who', 'who\'s', 'whom', 'why', 'why\'s', 'with', 'won\'t', 'would', 'wouldn\'t',
  'you', 'you\'d', 'you\'ll', 'you\'re', 'you\'ve', 'your', 'yours', 'yourself', 'yourselves',

  // Common Slang & Contractions
  'gonna', 'wanna', 'gotta', 'dunno', 'lemme', 'gimme', 'aint', 'yall', 'yolo', 'omg', 'lol', 'idk', 'brb', 'btw',
  'tho', 'thx', 'rofl', 'lmao', 'tbh', 'imo', 'irl', 'smh', 'bcz', 'bc', 'fyi', 'fml', 'ikr', 'gg', 'af', 'tf', 'rn',

  // Internet & Social Media Terms
  'like', 'subscribe', 'share', 'comment', 'follow', 'unfollow', 'click', 'link', 'bio', 'hashtag', 'trending', 'view',
  'watch', 'live', 'stream', 'video', 'post', 'pic', 'photo', 'dm', 'reply', 'tweet', 'retweet',

  // Numbers (Commonly Removed in NLP)
  'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
  'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth',

  // Common Foreign Language Stop Words
  // - French
  'le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'dans', 'sur', 'avec', 'pour', 'par', 'pas', 'mais', 'ou', 'et',
  'donc', 'car', 'ce', 'cette', 'ces', 'mon', 'ton', 'son', 'notre', 'votre', 'leur',

  // - Spanish
  'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'de', 'del', 'en', 'con', 'para', 'por', 'que', 'yo', 'tú',
  'él', 'ella', 'nosotros', 'vosotros', 'ellos',

  // - German
  'der', 'die', 'das', 'ein', 'eine', 'einer', 'einem', 'einen', 'mit', 'auf', 'in', 'von', 'zu', 'nach', 'für', 'aber',
  'oder', 'und', 'so', 'doch', 'weil',

  // - Hindi / Urdu
  'और', 'के', 'का', 'को', 'में', 'से', 'पर', 'कि', 'है', 'था', 'हो', 'हूँ', 'जा', 'रहा', 'गया', 'कर', 'करना', 'थे',
  'کی', 'کے', 'کا', 'میں', 'تھا', 'ہوں', 'کر', 'جاتا', 'جاتے', 'کہ', 'یہ', 'وہ', 'پر', 'اور', 'لیکن', 'تاکہ',

  // - Arabic
  'و', 'في', 'على', 'من', 'مع', 'عن', 'إلى', 'ذلك', 'كما', 'إذا', 'ب', 'لكن', 'أو', 'إلا', 'حتى', 'بين', 'بعد',

  // - Turkish
  've', 'bu', 'bir', 'şu', 'o', 'bunu', 'şunu', 'için', 'ama', 'eğer', 'veya', 'çünkü', 'ne', 'nasıl', 'neden', 'kim',

  // - Russian
  'и', 'в', 'на', 'с', 'к', 'от', 'до', 'по', 'из', 'за', 'под', 'не', 'он', 'она', 'оно', 'они', 'мы', 'ты',

  // - Chinese (Pinyin Stop Words)
  'de', 'shi', 'le', 'zai', 'bu', 'ni', 'wo', 'ta', 'yige', 'me', 'hen', 'dou', 'hai', 'zenme', 'shui', 'shuo'
};
