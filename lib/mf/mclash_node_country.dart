
library;

const int _kRegionalIndicatorA = 0x1F1E6;

const Map<String, String> _kNameAliases = <String, String>{

  '香港': 'HK', 'hongkong': 'HK', 'hong kong': 'HK', 'hk': 'HK', 'hkg': 'HK',
  '台湾': 'TW', 'taiwan': 'TW', 'tw': 'TW', 'taipei': 'TW', '台北': 'TW',
  '澳门': 'MO', 'macao': 'MO', 'macau': 'MO', 'mo': 'MO',
  '中国': 'CN', 'china': 'CN', 'cn': 'CN', '上海': 'CN', '北京': 'CN',
  '深圳': 'CN', '广州': 'CN', '杭州': 'CN',

  '日本': 'JP', 'japan': 'JP', 'jp': 'JP', 'tokyo': 'JP', '东京': 'JP',
  '大阪': 'JP', 'osaka': 'JP',
  '韩国': 'KR', 'korea': 'KR', 'kr': 'KR', 'seoul': 'KR', '首尔': 'KR',

  '新加坡': 'SG', '狮城': 'SG', 'singapore': 'SG', 'sg': 'SG', 'sgp': 'SG',
  '马来西亚': 'MY', 'malaysia': 'MY', 'my': 'MY', '吉隆坡': 'MY',
  '泰国': 'TH', 'thailand': 'TH', 'th': 'TH', '曼谷': 'TH',
  '越南': 'VN', 'vietnam': 'VN', 'vn': 'VN',
  '菲律宾': 'PH', 'philippines': 'PH', 'ph': 'PH',
  '印尼': 'ID', '印度尼西亚': 'ID', 'indonesia': 'ID', 'id': 'ID',
  '柬埔寨': 'KH', 'cambodia': 'KH', 'kh': 'KH',

  '美国': 'US', 'united states': 'US', 'usa': 'US', 'us': 'US',
  '洛杉矶': 'US', '圣何塞': 'US', '西雅图': 'US', '纽约': 'US', '达拉斯': 'US',
  '加拿大': 'CA', 'canada': 'CA', 'ca': 'CA', '多伦多': 'CA', '温哥华': 'CA',
  '墨西哥': 'MX', 'mexico': 'MX', 'mx': 'MX',

  '英国': 'GB', 'united kingdom': 'GB', 'uk': 'GB', 'gb': 'GB',
  '伦敦': 'GB', 'england': 'GB',
  '德国': 'DE', 'germany': 'DE', 'de': 'DE', '法兰克福': 'DE',
  '法国': 'FR', 'france': 'FR', 'fr': 'FR', '巴黎': 'FR',
  '荷兰': 'NL', 'netherlands': 'NL', 'nl': 'NL', '阿姆斯特丹': 'NL',
  '俄罗斯': 'RU', 'russia': 'RU', 'ru': 'RU', '莫斯科': 'RU',
  '意大利': 'IT', 'italy': 'IT', 'it': 'IT', '米兰': 'IT',
  '西班牙': 'ES', 'spain': 'ES', 'es': 'ES',
  '瑞士': 'CH', 'switzerland': 'CH', 'ch': 'CH', '苏黎世': 'CH',
  '瑞典': 'SE', 'sweden': 'SE', 'se': 'SE',
  '挪威': 'NO', 'norway': 'NO', 'no': 'NO',
  '芬兰': 'FI', 'finland': 'FI', 'fi': 'FI',
  '丹麦': 'DK', 'denmark': 'DK', 'dk': 'DK',
  '波兰': 'PL', 'poland': 'PL', 'pl': 'PL',
  '奥地利': 'AT', 'austria': 'AT', 'at': 'AT',
  '爱尔兰': 'IE', 'ireland': 'IE', 'ie': 'IE',
  '乌克兰': 'UA', 'ukraine': 'UA', 'ua': 'UA',
  '土耳其': 'TR', 'turkey': 'TR', 'tr': 'TR', 'türkiye': 'TR',
  '葡萄牙': 'PT', 'portugal': 'PT', 'pt': 'PT',
  '捷克': 'CZ', 'czech': 'CZ', 'cz': 'CZ',
  '罗马尼亚': 'RO', 'romania': 'RO', 'ro': 'RO',
  '比利时': 'BE', 'belgium': 'BE', 'be': 'BE',
  '希腊': 'GR', 'greece': 'GR', 'gr': 'GR',
  '匈牙利': 'HU', 'hungary': 'HU', 'hu': 'HU',

  '以色列': 'IL', 'israel': 'IL', 'il': 'IL',
  '阿联酋': 'AE', '迪拜': 'AE', 'dubai': 'AE', 'emirates': 'AE', 'ae': 'AE',
  '沙特': 'SA', 'saudi': 'SA', 'sa': 'SA',
  '埃及': 'EG', 'egypt': 'EG', 'eg': 'EG',
  '南非': 'ZA', 'south africa': 'ZA', 'za': 'ZA',
  '尼日利亚': 'NG', 'nigeria': 'NG', 'ng': 'NG',

  '澳大利亚': 'AU', '澳洲': 'AU', 'australia': 'AU', 'au': 'AU', '悉尼': 'AU',
  '新西兰': 'NZ', 'new zealand': 'NZ', 'nz': 'NZ',
  '巴西': 'BR', 'brazil': 'BR', 'br': 'BR',
  '阿根廷': 'AR', 'argentina': 'AR', 'ar': 'AR',
  '智利': 'CL', 'chile': 'CL', 'cl': 'CL',
  '哥伦比亚': 'CO', 'colombia': 'CO', 'co': 'CO',

  '印度': 'IN', 'india': 'IN', 'in': 'IN', '孟买': 'IN',
  '巴基斯坦': 'PK', 'pakistan': 'PK', 'pk': 'PK',
};

const Set<String> _kAsciiTokens = <String>{
  'hk', 'hkg', 'tw', 'mo', 'cn', 'jp', 'kr', 'sg', 'sgp', 'my', 'th', 'vn',
  'ph', 'id', 'kh', 'us', 'usa', 'ca', 'mx', 'uk', 'gb', 'de', 'fr', 'nl',
  'ru', 'it', 'es', 'ch', 'se', 'no', 'fi', 'dk', 'pl', 'at', 'ie', 'ua',
  'tr', 'pt', 'cz', 'ro', 'be', 'gr', 'hu', 'il', 'ae', 'sa', 'eg', 'za',
  'ng', 'au', 'nz', 'br', 'ar', 'cl', 'co', 'in', 'pk',
};

class MclashNodeCountry {
  MclashNodeCountry._();

  static String? codeOf(String nodeName) {
    final name = nodeName.trim();
    if (name.isEmpty) {
      return null;
    }

    final byFlag = _codeFromFlag(name);
    if (byFlag != null) {
      return byFlag;
    }

    final lower = name.toLowerCase();
    for (final token in _tokenize(lower)) {
      if (_kAsciiTokens.contains(token)) {
        final code = _kNameAliases[token];
        if (code != null) {
          return code;
        }
      }
    }

    return _matchSubstringAlias(lower);
  }

  static String flagFor(String code) {
    final c = code.trim().toUpperCase();
    if (c.length != 2) {
      return c;
    }
    for (final unit in c.codeUnits) {
      if (unit < 0x41 || unit > 0x5A) {
        return c;
      }
    }
    return String.fromCharCodes(<int>[
      _kRegionalIndicatorA + (c.codeUnitAt(0) - 0x41),
      _kRegionalIndicatorA + (c.codeUnitAt(1) - 0x41),
    ]);
  }

  static String displayName(String code) {
    final c = code.trim().toUpperCase();
    return _kDisplayNames[c] ?? c;
  }

  static int sortWeight(String code) {
    final i = _kDisplayOrder.indexOf(code.trim().toUpperCase());
    return i < 0 ? _kDisplayOrder.length : i;
  }

  static String? _codeFromFlag(String name) {
    final units = name.runes.toList();
    for (var i = 0; i + 1 < units.length; i++) {
      final a = units[i];
      final b = units[i + 1];
      if (a >= _kRegionalIndicatorA && a <= _kRegionalIndicatorA + 25 &&
          b >= _kRegionalIndicatorA && b <= _kRegionalIndicatorA + 25) {
        return String.fromCharCodes(<int>[
          0x41 + (a - _kRegionalIndicatorA),
          0x41 + (b - _kRegionalIndicatorA),
        ]);
      }
    }
    return null;
  }

  static List<String> _tokenize(String lower) {
    return lower
        .split(RegExp(r'[^a-z0-9]+'))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String? _matchSubstringAlias(String lower) {
    final aliases = _kNameAliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final alias in aliases) {
      if (alias.length < 3 && _isAscii(alias)) {
        continue;
      }
      if (lower.contains(alias)) {
        return _kNameAliases[alias];
      }
    }
    return null;
  }

  static bool _isAscii(String s) {
    for (final unit in s.codeUnits) {
      if (unit > 0x7F) {
        return false;
      }
    }
    return true;
  }

  static const Map<String, String> _kDisplayNames = <String, String>{
    'HK': '香港', 'TW': '台湾', 'MO': '澳门', 'CN': '中国',
    'JP': '日本', 'KR': '韩国',
    'SG': '新加坡', 'MY': '马来西亚', 'TH': '泰国', 'VN': '越南',
    'PH': '菲律宾', 'ID': '印尼', 'KH': '柬埔寨',
    'US': '美国', 'CA': '加拿大', 'MX': '墨西哥',
    'GB': '英国', 'DE': '德国', 'FR': '法国', 'NL': '荷兰', 'RU': '俄罗斯',
    'IT': '意大利', 'ES': '西班牙', 'CH': '瑞士', 'SE': '瑞典', 'NO': '挪威',
    'FI': '芬兰', 'DK': '丹麦', 'PL': '波兰', 'AT': '奥地利', 'IE': '爱尔兰',
    'UA': '乌克兰', 'TR': '土耳其', 'PT': '葡萄牙', 'CZ': '捷克',
    'RO': '罗马尼亚', 'BE': '比利时', 'GR': '希腊', 'HU': '匈牙利',
    'IL': '以色列', 'AE': '阿联酋', 'SA': '沙特', 'EG': '埃及',
    'ZA': '南非', 'NG': '尼日利亚',
    'AU': '澳大利亚', 'NZ': '新西兰', 'BR': '巴西', 'AR': '阿根廷',
    'CL': '智利', 'CO': '哥伦比亚',
    'IN': '印度', 'PK': '巴基斯坦',
  };

  static const List<String> _kDisplayOrder = <String>[
    'HK', 'TW', 'JP', 'SG', 'US', 'KR', 'MO', 'CN',
    'MY', 'TH', 'VN', 'PH', 'ID', 'KH',
    'GB', 'DE', 'FR', 'NL', 'CA', 'AU', 'RU', 'TR', 'IN',
  ];
}
