import 'package:flutter/material.dart';
import '../core/services/database_service.dart';
import '../core/services/file_upload_service.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/loading_widgets.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/snackbar_utils.dart';
import '../core/utils/validation_utils.dart';
import '../core/models/supply_model.dart';

class UpdateSupplyPage extends StatefulWidget {
  final String supplyId;
  final SupplyModel initialSupply;

  const UpdateSupplyPage({
    Key? key,
    required this.supplyId,
    required this.initialSupply,
  }) : super(key: key);

  @override
  State<UpdateSupplyPage> createState() => _UpdateSupplyPageState();
}

class _UpdateSupplyPageState extends State<UpdateSupplyPage> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final FileUploadService _fileUploadService = FileUploadService();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactInfoController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isUploadingFile = false;
  String? _uploadedFileUrl;
  String? _uploadedFileName;
  late SupplyStatus _selectedStatus;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
  }

  void _initializeData() {
    final supply = widget.initialSupply;
    _titleController.text = supply.title;
    _descriptionController.text = supply.description;
    _categoryController.text = supply.category;
    _quantityController.text = supply.quantity?.toString() ?? '';
    _locationController.text = supply.location ?? '';
    _contactInfoController.text = supply.contactInfo ?? '';
    _uploadedFileUrl = supply.attachmentUrl;
    _selectedStatus = supply.status;

    // Extract filename from URL for display
    if (_uploadedFileUrl != null) {
      _uploadedFileName = _uploadedFileUrl!.split('/').last.split('?').first;
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
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

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tedarik Güncelle'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
            tooltip: 'Sil',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildFileUploadCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
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
            'Tedarik Bilgileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _titleController,
            label: 'Başlık *',
            prefixIcon: Icons.title,
            validator: (value) => ValidationUtils.validateRequired(value, 'Başlık'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            label: 'Açıklama *',
            prefixIcon: Icons.description,
            maxLines: 4,
            validator: (value) => ValidationUtils.validateRequired(value, 'Açıklama'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _categoryController,
            label: 'Kategori *',
            prefixIcon: Icons.category,
            validator: (value) => ValidationUtils.validateRequired(value, 'Kategori'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _quantityController,
                  label: 'Miktar',
                  prefixIcon: Icons.inventory_2,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final quantity = int.tryParse(value!);
                      if (quantity == null || quantity <= 0) {
                        return 'Geçerli bir miktar girin';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            label: 'Konum',
            prefixIcon: Icons.location_on,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _contactInfoController,
            label: 'İletişim Bilgisi',
            prefixIcon: Icons.contact_phone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<SupplyStatus>(
        value: _selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Durum',
          prefixIcon: Icon(Icons.flag),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: SupplyStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(_getStatusText(status)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedStatus = value);
          }
        },
      ),
    );
  }

  String _getStatusText(SupplyStatus status) {
    switch (status) {
      case SupplyStatus.available:
        return 'Mevcut';
      case SupplyStatus.pending:
        return 'Beklemede';
      case SupplyStatus.completed:
        return 'Tamamlandı';
    }
  }

  Widget _buildFileUploadCard() {
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
            'Dosya Ekleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (_uploadedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mevcut dosya: $_uploadedFileName',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _removeUploadedFile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          CustomButton(
            text: _isUploadingFile ? 'Yükleniyor...' : 'Yeni Dosya Seç',
            onPressed: _isUploadingFile ? null : _pickAndUploadFile,
            variant: ButtonVariant.outlined,
            fullWidth: true,
            icon: _isUploadingFile ? null : Icons.attach_file,
            isLoading: _isUploadingFile,
          ),
          const SizedBox(height: 8),
          Text(
            'PDF, Word, Excel dosyaları desteklenir. Maksimum 10MB.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'İptal',
            onPressed: () => Navigator.pop(context),
            variant: ButtonVariant.outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Güncelle',
            onPressed: _updateSupply,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  // Actions
  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploadingFile = true);

      final result = await _fileUploadService.pickAndUploadDocument(
        folder: 'supply_documents',
        userId: widget.initialSupply.userId,
      );

      if (result != null) {
        setState(() {
          _uploadedFileUrl = result['url'];
          _uploadedFileName = result['name'];
        });

        SnackBarUtils.showSuccess(
          context: context,
          message: 'Dosya başarıyla yüklendi',
        );
      }
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Dosya yükleme hatası: $e',
      );
    } finally {
      setState(() => _isUploadingFile = false);
    }
  }

  void _removeUploadedFile() {
    setState(() {
      _uploadedFileUrl = null;
      _uploadedFileName = null;
    });
  }

  Future<void> _updateSupply() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarUtils.showError(
        context: context,
        message: 'Lütfen tüm zorunlu alanları doldurun',
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final updatedSupply = widget.initialSupply.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        quantity: _quantityController.text.isNotEmpty
            ? int.parse(_quantityController.text)
            : null,
        location: _locationController.text.trim(),
        contactInfo: _contactInfoController.text.trim(),
        attachmentUrl: _uploadedFileUrl,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateSupply(widget.supplyId, updatedSupply.toMap());

      SnackBarUtils.showSuccess(
        context: context,
        message: 'Tedarik başarıyla güncellendi',
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Tedarik güncellenirken hata oluştu: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tedarik Sil'),
        content: const Text(
          'Bu tedariği kalıcı olarak silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _deleteSupply,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSupply() async {
    try {
      Navigator.pop(context); // Close dialog

      SnackBarUtils.showLoading(
        context: context,
        message: 'Tedarik siliniyor...',
      );

      await _databaseService.deleteSupply(widget.supplyId);

      Navigator.pop(context, 'deleted'); // Return 'deleted' to indicate deletion

      SnackBarUtils.showSuccess(
        context: context,
        message: 'Tedarik başarıyla silindi',
      );
    } catch (e) {
      SnackBarUtils.showError(
        context: context,
        message: 'Tedarik silinemedi: $e',
      );
    }
  }
}
