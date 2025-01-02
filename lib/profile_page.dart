import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'update_supply_page.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(
              child: Text('Kullanıcı bilgileri yüklenemedi.', style: TextStyle(fontSize: 16)),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcı Bilgileri
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.account_circle, size: 48, color: Colors.blue),
                      title: Text(
                        userData['name'] ?? 'Ad bilgisi yok',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        userData['email'] ?? 'E-posta bilgisi yok',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kullanıcı Malzeme Listesi
                  const Text(
                    'Eklediğiniz Tedarikler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(thickness: 1),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('supplies')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text('Veriler yüklenemedi.', style: TextStyle(fontSize: 16)),
                        );
                      }

                      final supplies = snapshot.data!.docs;

                      if (supplies.isEmpty) {
                        return const Center(
                          child: Text(
                            'Hiçbir malzeme bulunamadı.',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: supplies.length,
                        itemBuilder: (context, index) {
                          final supply = supplies[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                supply['description'] ?? 'Tanım yok',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sektör: ${supply['sector'] ?? 'Sektör bilgisi yok'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Başlık: ${supply['title'] ?? 'Başlık yok'}',  // Show the title, if available
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Silme Onayı'),
                                          content: const Text('Bu tedarik kaydını silmek istediğinizden emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        FirebaseFirestore.instance.collection('supplies').doc(supply.id).delete().then((_) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Tedarik silindi.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Silme işlemi başarısız: $error'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateSupplyPage(
                                            supplyId: supply.id,
                                            initialData: supply.data() as Map<String, dynamic>,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Başvuru Yapılan Tedarikler
                  const Text(
                    'Başvuru Yaptığınız Tedarikler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(thickness: 1),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text('Veriler yüklenemedi.', style: TextStyle(fontSize: 16)),
                        );
                      }

                      final applications = snapshot.data!.docs;

                      if (applications.isEmpty) {
                        return const Center(
                          child: Text(
                            'Başvuru yaptığınız tedarik bulunamadı.',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final application = applications[index];
                          final supplyId = application['supplyId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('supplies').doc(supplyId).get(),
                            builder: (context, supplySnapshot) {
                              if (supplySnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (supplySnapshot.hasError || !supplySnapshot.hasData) {
                                return const ListTile(
                                  title: Text('Tedarik bilgisi yüklenemedi.'),
                                );
                              }

                              final supplyData = supplySnapshot.data!.data() as Map<String, dynamic>;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    supplyData['description'] ?? 'Tanım yok',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sektör: ${supplyData['sector'] ?? 'Sektör bilgisi yok'}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'Başlık: ${supplyData['title'] ?? 'Başlık yok'}',  // Show the title, if available
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Başvuru Geri Alma'),
                                          content: const Text('Bu başvuruyu geri almak istediğinizden emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // Delete the application
                                                await FirebaseFirestore.instance
                                                    .collection('applications')
                                                    .doc(application.id)
                                                    .delete();
                                                
                                                Navigator.of(context).pop(true);
                                                
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Başvuru geri alındı.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              },
                                              child: const Text('Geri Al'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
