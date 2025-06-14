class AppConstants {
  // App Information
  static const String appName = 'TedApp';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Supply Chain Management System';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String suppliesCollection = 'supplies';
  static const String applicationsCollection = 'applications';

  // Application Status
  static const String statusPending = 'Beklemede';
  static const String statusApproved = 'Kabul Edildi';
  static const String statusRejected = 'Reddedildi';

  // File Storage
  static const String suppliesStoragePath = 'supplies';
  static const String profileImagesPath = 'profile_images';

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Error Messages
  static const String networkError = 'Ağ bağlantısı hatası. Lütfen tekrar deneyin.';
  static const String unknownError = 'Bilinmeyen bir hata oluştu.';
  static const String authError = 'Kimlik doğrulama hatası.';
  static const String permissionError = 'İzin hatası.';
}
