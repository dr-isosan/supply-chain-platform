import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';
import '../core/services/file_upload_service.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/loading_widgets.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/snackbar_utils.dart';
import '../core/utils/validation_utils.dart';
import '../core/models/user_model.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final FileUploadService _fileUploadService = FileUploadService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUpdating = false;
  bool _isUploadingImage = false;
  String? _newImagePath;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final user = await _databaseService.getUser(widget.userId);
      if (user != null) {
        setState(() {
          _user = user;
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _phoneController.text = user.phoneNumber;
          _emailController.text = user.email;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context: context,
          message: 'Profil bilgileri yüklenemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Düzenle',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildProfileContent(),
              ),
            ),
    );
  }

  Widget _buildProfileContent() {
    if (_user == null) {
      return const Center(
        child: Text(
          'Kullanıcı bilgileri bulunamadı',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileForm(),
          const SizedBox(height: 24),
          if (_isEditing) _buildActionButtons(),
          if (!_isEditing) _buildStaticActions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildProfileImage(),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _showImagePicker,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_user!.firstName} ${_user!.lastName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          _buildEmailVerificationBadge(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isUploadingImage) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final imageUrl = _user?.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmailVerificationBadge() {
    final isVerified = _authService.isEmailVerified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'E-posta Doğrulandı' : 'E-posta Doğrulanmadı',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kişisel Bilgiler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: 'Ad',
                  prefixIcon: Icons.person_outline,
                  enabled: _isEditing,
                  validator: (value) => ValidationUtils.validateName(value, 'Ad'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: 'Soyad',
                  prefixIcon: Icons.person_outline,
                  enabled: _isEditing,
                  validator: (value) => ValidationUtils.validateName(value, 'Soyad'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Telefon',
            prefixIcon: Icons.phone_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            validator: ValidationUtils.validatePhone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'E-posta',
            prefixIcon: Icons.email_outlined,
            enabled: false, // Email cannot be edited directly
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_authService.isEmailVerified) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _sendEmailVerification,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Doğrulama E-postası Gönder'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'İptal',
                onPressed: _cancelEditing,
                variant: ButtonVariant.outlined,
                isLoading: _isUpdating,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Kaydet',
                onPressed: _saveProfile,
                isLoading: _isUpdating,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Şifre Değiştir',
          onPressed: _showChangePasswordDialog,
          variant: ButtonVariant.outlined,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStaticActions() {
    return Column(
      children: [
        CustomButton(
          text: 'Şifre Değiştir',
          onPressed: _showChangePasswordDialog,
          variant: ButtonVariant.outlined,
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Hesabı Sil',
          onPressed: _showDeleteAccountDialog,
          variant: ButtonVariant.outlined,
          fullWidth: true,
          backgroundColor: AppColors.error,
        ),
      ],
    );
  }

  // Actions
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profil Fotoğrafı Seç',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () => _pickImage(true),
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () => _pickImage(false),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(bool fromCamera) async {
    Navigator.pop(context);

    try {
      setState(() => _isUploadingImage = true);

      final result = await _fileUploadService.pickAndUploadImage(
        fromCamera: fromCamera,
        folder: 'profile_images',
        userId: widget.userId,
      );

      if (result != null) {
        await _databaseService.updateUser(widget.userId, {
          'profileImageUrl': result,
        });

        setState(() {
          _user = _user!.copyWith(profileImageUrl: result);
        });

        SnackBarUtils.showSuccess(
          context: context,
          message: 'Profil fotoğrafı güncellendi',
        );
      }
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Fotoğraf yüklenemedi: $e',
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset form fields
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
      _phoneController.text = _user!.phoneNumber;
    });
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    try {
      setState(() => _isUpdating = true);

      await _databaseService.updateUser(widget.userId, {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      });

      setState(() {
        _user = _user!.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
        _isEditing = false;
      });

      SnackBarUtils.showSuccess(
        context: context,
        message: 'Profil bilgileri güncellendi',
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Profil güncellenemedi: $e',
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  bool _validateForm() {
    final firstNameError = ValidationUtils.validateName(_firstNameController.text, 'Ad');
    final lastNameError = ValidationUtils.validateName(_lastNameController.text, 'Soyad');
    final phoneError = ValidationUtils.validatePhone(_phoneController.text);

    if (firstNameError != null) {
      SnackBarUtils.showValidationError(context: context, field: 'Ad');
      return false;
    }

    if (lastNameError != null) {
      SnackBarUtils.showValidationError(context: context, field: 'Soyad');
      return false;
    }

    if (phoneError != null) {
      SnackBarUtils.showValidationError(context: context, field: 'Telefon');
      return false;
    }

    return true;
  }

  Future<void> _sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      SnackBarUtils.showSuccess(
        context: context,
        message: 'Doğrulama e-postası gönderildi',
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Doğrulama e-postası gönderilemedi: $e',
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Şifre Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _currentPasswordController,
              label: 'Mevcut Şifre',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => ValidationUtils.validatePassword(value, 'Mevcut şifre'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _newPasswordController,
              label: 'Yeni Şifre',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => ValidationUtils.validatePassword(value, 'Yeni şifre'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Yeni Şifre Tekrar',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => ValidationUtils.validateConfirmPassword(
                _newPasswordController.text,
                value,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearPasswordFields();
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_validatePasswordChange()) return;

    try {
      // Re-authenticate first
      await _authService.reauthenticateWithPassword(_currentPasswordController.text);

      // Update password
      await _authService.updatePassword(_newPasswordController.text);

      Navigator.pop(context);
      _clearPasswordFields();

      SnackBarUtils.showSuccess(
        context: context,
        message: 'Şifre başarıyla değiştirildi',
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Şifre değiştirilemedi: $e',
      );
    }
  }

  bool _validatePasswordChange() {
    final currentPasswordError = ValidationUtils.validatePassword(
      _currentPasswordController.text,
      'Mevcut şifre',
    );
    final newPasswordError = ValidationUtils.validatePassword(
      _newPasswordController.text,
      'Yeni şifre',
    );
    final confirmPasswordError = ValidationUtils.validateConfirmPassword(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (currentPasswordError != null || newPasswordError != null || confirmPasswordError != null) {
      SnackBarUtils.showError(
        context: context,
        message: 'Lütfen tüm alanları doğru şekilde doldurun',
      );
      return false;
    }

    return true;
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumu kapatmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Çıkış yapılamadı: $e',
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _deleteAccount,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      Navigator.pop(context); // Close dialog

      SnackBarUtils.showLoading(
        context: context,
        message: 'Hesap siliniyor...',
      );

      await _authService.deleteAccount();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );

      SnackBarUtils.showSuccess(
        context: context,
        message: 'Hesap başarıyla silindi',
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Hesap silinemedi: $e',
      );
    }
  }
}
