class AppUtils {
  static String cleanCharacterName(String name) {
    return name.contains('(')
        ? name.split('(')[0].trim()
        : name.trim();
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

