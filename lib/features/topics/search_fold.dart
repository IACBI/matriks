/// Folds text so search ignores case and diacritics: typing `ozdeger` finds
/// "Özdeğerler ve Özvektörler", and `ISIK` finds "ışık".
///
/// Case alone is not enough here. Dart's [String.toLowerCase] applies the
/// Unicode default mapping, which is not Turkish: "IŞIK" lowercases to "işik"
/// while "ışık" is already lowercase, so the same word typed in either case
/// would not match itself. Folding the dotted and dotless i onto one letter
/// removes that asymmetry along with the accents.
///
/// Apply this to the query and to the searched text, or the comparison is not
/// symmetric.
String foldForSearch(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    // Combining marks, in case the text arrives decomposed.
    if (rune >= 0x0300 && rune <= 0x036F) continue;
    final char = String.fromCharCode(rune);
    buffer.write(_folded[char] ?? char);
  }
  return buffer.toString();
}

/// Only letters that readers treat as the same letter typed without its mark.
/// Cyrillic и/й and Turkish ı/i are separate letters in their alphabets, but a
/// search box is not a dictionary; ё folds to е for the same reason.
const _folded = <String, String>{
  // Turkish
  'ı': 'i', 'ş': 's', 'ğ': 'g', 'ç': 'c', 'ö': 'o', 'ü': 'u',
  // Spanish and neighbouring Latin scripts
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u',
  'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
  'ß': 'ss', 'æ': 'ae', 'œ': 'oe', 'ø': 'o',
  // Russian
  'ё': 'е',
};
