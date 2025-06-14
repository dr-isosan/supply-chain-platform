import '../constants/app_constants.dart';

class ValidationUtils {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gereklidir';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Şifre en az ${AppConstants.minPasswordLength} karakter olmalıdır';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Şifre en az bir büyük harf içermelidir';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Şifre en az bir küçük harf içermelidir';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Şifre en az bir rakam içermelidir';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gereklidir';
    }

    if (value.trim().length < 2) {
      return 'Ad soyad en az 2 karakter olmalıdır';
    }

    if (value.trim().length > 50) {
      return 'Ad soyad en fazla 50 karakter olabilir';
    }

    // Check for valid characters (letters, spaces, and some special characters)
    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\-\.]+$').hasMatch(value.trim())) {
      return 'Ad soyad sadece harf ve boşluk içerebilir';
    }

    return null;
  }

  /// Validate supply title
  static String? validateSupplyTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık gereklidir';
    }

    if (value.trim().length < 5) {
      return 'Başlık en az 5 karakter olmalıdır';
    }

    if (value.trim().length > AppConstants.maxTitleLength) {
      return 'Başlık en fazla ${AppConstants.maxTitleLength} karakter olabilir';
    }

    return null;
  }

  /// Validate supply description
  static String? validateSupplyDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama gereklidir';
    }

    if (value.trim().length < 10) {
      return 'Açıklama en az 10 karakter olmalıdır';
    }

    if (value.trim().length > AppConstants.maxDescriptionLength) {
      return 'Açıklama en fazla ${AppConstants.maxDescriptionLength} karakter olabilir';
    }

    return null;
  }

  /// Validate sector
  static String? validateSector(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sektör gereklidir';
    }

    if (value.trim().length < 2) {
      return 'Sektör en az 2 karakter olmalıdır';
    }

    if (value.trim().length > 30) {
      return 'Sektör en fazla 30 karakter olabilir';
    }

    return null;
  }

  /// Validate phone number (Turkish format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }

    // Remove spaces and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]+'), '');

    // Turkish phone number pattern
    final phoneRegex = RegExp(r'^(\+90|90|0)?5[0-9]{9}$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası girin (5XXXXXXXXX)';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Geçerli bir URL girin (https://example.com)';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }

    if (value.trim().length < minLength) {
      return '$fieldName en az $minLength karakter olmalıdır';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olabilir';
    }
    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName sayısal bir değer olmalıdır';
    }

    return null;
  }

  /// Validate integer value
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }

    if (int.tryParse(value) == null) {
      return '$fieldName tam sayı olmalıdır';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName pozitif bir değer olmalıdır';
    }

    return null;
  }

  /// Validate date
  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Geçerli bir $fieldName girin (YYYY-MM-DD)';
    }
  }

  /// Validate future date
  static String? validateFutureDate(String? value, String fieldName) {
    final dateError = validateDate(value, fieldName);
    if (dateError != null) return dateError;

    final date = DateTime.parse(value!);
    if (date.isBefore(DateTime.now())) {
      return '$fieldName gelecek bir tarih olmalıdır';
    }

    return null;
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }

  /// Check if string contains only letters
  static bool isAlpha(String value) {
    return RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ]+$').hasMatch(value);
  }

  /// Check if string is a valid username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gereklidir';
    }

    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }

    if (value.length > 20) {
      return 'Kullanıcı adı en fazla 20 karakter olabilir';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
    }

    if (value.startsWith('_') || value.endsWith('_')) {
      return 'Kullanıcı adı alt çizgi ile başlayamaz veya bitemez';
    }

    return null;
  }

  /// Sanitize input string
  static String sanitizeInput(String input) {
    return input.trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[<>\"\'%;()&+]'), ''); // Remove potentially dangerous characters
  }

  /// Check password strength
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength { empty, weak, medium, strong }
