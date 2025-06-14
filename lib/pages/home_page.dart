import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/loading_widgets.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/snackbar_utils.dart';
import '../core/models/supply_model.dart';
import 'add_supply_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tedarik Akışı'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateToAddSupply(),
            tooltip: 'Yeni Tedarik Ekle',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _navigateToProfile(),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
            tooltip: 'Ara',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildSuppliesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSupply(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldiniz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Güncel tedarik ilanlarını keşfedin',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tedarik ara...',
          prefixIcon: Icon(Icons.search, color: AppColors.onSurface.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildSuppliesList() {
    return StreamBuilder<QuerySnapshot>(
  Widget _buildSuppliesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getSuppliesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return ErrorWidget(
            message: 'Veriler yüklenirken bir hata oluştu!',
            onRetry: () => setState(() {}),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyWidget(
            message: searchQuery.isEmpty
                ? 'Henüz herhangi bir tedarik bulunmamaktadır.'
                : 'Aradığınız kriterlerde tedarik bulunamadı.',
            actionText: 'Yeni Tedarik Ekle',
            onAction: () => _navigateToAddSupply(),
          );
        }

        final supplies = snapshot.data!.docs;
        return _buildSuppliesGrid(supplies);
      },
    );
  }

  Stream<QuerySnapshot> _getSuppliesStream() {
    if (searchQuery.isEmpty) {
      return FirebaseFirestore.instance
          .collection(AppConstants.suppliesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(AppConstants.suppliesCollection)
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThan: searchQuery + 'z')
          .snapshots();
    }
  }

  Widget _buildSuppliesGrid(List<QueryDocumentSnapshot> supplies) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: supplies.length,
      itemBuilder: (context, index) {
        final supply = supplies[index];
        final supplyData = supply.data() as Map<String, dynamic>;

        return _buildSupplyCard(supply.id, supplyData);
      },
    );
  }

  Widget _buildSupplyCard(String supplyId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['sector'] ?? 'Genel',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(data['status'] ?? 'active'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['title'] ?? 'Başlık Yok',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['description'] ?? 'Açıklama bulunmuyor',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(data['createdAt']),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    if (data['fileName'] != null) ...[
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dosya var',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Detay Görüntüle',
                    onPressed: () => _showSupplyDetails(supplyId, data),
                    variant: ButtonVariant.outlined,
                    size: ButtonSize.small,
                  ),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  text: 'Başvur',
                  onPressed: () => _applyToSupply(supplyId),
                  size: ButtonSize.small,
                  icon: Icons.send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Aktif';
        break;
      case 'inactive':
        color = Colors.grey;
        text = 'Pasif';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Tamamlandı';
        break;
      default:
        color = Colors.orange;
        text = 'Beklemede';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tarih belirtilmemiş';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Geçersiz tarih';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _navigateToAddSupply() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplyPage(userId: widget.userId),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: SupplySearchDelegate(),
    );
  }

  Future<void> _applyToSupply(String supplyId) async {
    try {
      // Check if user already applied
      final existingApplication = await FirebaseFirestore.instance
          .collection(AppConstants.applicationsCollection)
          .where('userId', isEqualTo: widget.userId)
          .where('supplyId', isEqualTo: supplyId)
          .get();

      if (existingApplication.docs.isNotEmpty) {
        SnackBarUtils.showError(context, 'Bu tedariğe zaten başvurdunuz!');
        return;
      }

      // Create application
      await FirebaseFirestore.instance
          .collection(AppConstants.applicationsCollection)
          .add({
        'userId': widget.userId,
        'supplyId': supplyId,
        'status': 'Beklemede',
        'createdAt': FieldValue.serverTimestamp(),
      });

      SnackBarUtils.showSuccess(context, 'Başvurunuz başarıyla gönderildi!');
    } catch (e) {
      SnackBarUtils.showError(context, 'Başvuru sırasında hata oluştu: ${e.toString()}');
    }
  }

  void _showSupplyDetails(String supplyId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSupplyDetailsModal(data),
    );
  }

  Widget _buildSupplyDetailsModal(Map<String, dynamic> data) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'Başlık Yok',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(data['status'] ?? 'active'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Sektör', data['sector'] ?? 'Belirtilmemiş'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Açıklama', data['description'] ?? 'Açıklama bulunmuyor'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Oluşturulma Tarihi', _formatDate(data['createdAt'])),
                      if (data['fileName'] != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Dosya', data['fileName']),
                      ],
                      if (data['tags'] != null && (data['tags'] as List).isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Etiketler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (data['tags'] as List)
                              .map((tag) => Chip(
                                    label: Text(tag.toString()),
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SearchDelegateExample extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Tedarik ara...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('supplies')
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThan: query + 'z')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Veriler yüklenemedi.'));
        }

        final supplies = snapshot.data!.docs;

        if (supplies.isEmpty) {
          return const Center(child: Text('Aradığınız tedarik bulunamadı.'));
        }

        return ListView.builder(
          itemCount: supplies.length,
          itemBuilder: (context, index) {
            final supply = supplies[index];
            return ListTile(
              title: Text(supply['description']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sektör: ${supply['sector']}'),
                  Text('Başlık: ${supply['title'] ?? 'Başlık yok'}'),  // Show the title, if available
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
