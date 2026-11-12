class EmailValidator {
  static final RegExp _pattern = RegExp(
    r'^[A-Z0-9]+(?:[._%+-][A-Z0-9]+)*@(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,}$',
    caseSensitive: false,
  );

  static bool isValid(String email) => _pattern.hasMatch(email.trim());
}
