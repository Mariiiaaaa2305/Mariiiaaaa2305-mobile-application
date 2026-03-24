class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введіть email';
    if (!value.contains('@')) return 'Email має містити @';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 8) return 'Мінімум 8 символів';
    if (!RegExp(r'[A-Z]').hasMatch(value))
      return 'Треба хоча б одну велику літеру';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Додайте хоча б одну цифру';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Введіть імʼя';
    if (RegExp(r'[0-9]').hasMatch(value)) return 'Імʼя не може мати цифр';
    return null;
  }
}
