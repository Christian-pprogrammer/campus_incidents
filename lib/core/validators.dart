class Validators {
  static const allowedDomains = ['alustudent.com', 'alueducation.com'];

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isAluEmail(String email) {
    final parts = email.trim().toLowerCase().split('@');
    return parts.length == 2 && parts.first.isNotEmpty && allowedDomains.contains(parts.last);
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(input)) return 'Enter a valid email address';
    if (!isAluEmail(input)) return 'Use your @alustudent.com or @alueducation.com email';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Enter a password';
    if (input.length < 8) return 'Use at least 8 characters';
    if (!input.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  static String? fullName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter your full name';
    if (input.split(RegExp(r'\s+')).length < 2) return 'Enter your first and last name';
    return null;
  }

  static String? title(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Add a short title';
    if (input.length < 5) return 'Title is too short';
    if (input.length > 80) return 'Keep the title under 80 characters';
    return null;
  }

  static String? description(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Describe the issue';
    if (input.length < 15) return 'Add a bit more detail (at least 15 characters)';
    if (input.length > 1000) return 'Keep the description under 1000 characters';
    return null;
  }
}
