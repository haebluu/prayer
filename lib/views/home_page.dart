// lib/views/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/user_controller.dart'; // Import UserController
import 'detail_doa_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context); 
    final theme = Theme.of(context);
    
    // 1. Ambil data pengguna dari UserController
    final userController = Provider.of<UserController>(context);
    // Ambil nama pengguna. Jika null (seharusnya tidak terjadi jika sudah login), gunakan default.
    final userName = userController.currentUser?.name ?? 'Pengguna'; 
    
    // Ganti Scaffold luar dengan Column
    return Column( 
      children: [
        // 1. App Bar
        AppBar(
          title: const Text('Doa Harian', style: TextStyle(color: Colors.white)),
          backgroundColor: theme.primaryColor,
          elevation: 0,
        ),
        
        // 2. Body (CustomScrollView dibungkus Expanded)
        Expanded(
          child: CustomScrollView( 
            slivers: [
              // 1. HERO HEADER (Judul dan Search Bar)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  color: theme.primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    children: [
                      // Judul dan Hero Text (REVISI: Menambahkan nama pengguna)
                      Padding( // Hapus 'const' pada Padding untuk menampung Text dinamis
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TEKS DINAMIS
                            Text('Assalamualaikum, $userName!', 
                              style: const TextStyle( 
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white
                              )
                            ),
                          ],
                        ),
                      ),
                      
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          onChanged: (value) => homeController.searchDoa(value),
                          decoration: InputDecoration(
                            hintText: 'Cari doa disini...',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. DAFTAR DOA LENGKAP
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: homeController.isLoading
                    ? const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: CircularProgressIndicator()
                      )))
                    : homeController.errorMessage.isNotEmpty
                        ? SliverToBoxAdapter(child: Center(child: Text('Error: ${homeController.errorMessage}')))
                        : homeController.filteredDoa.isEmpty
                            ? const SliverToBoxAdapter(child: Center(child: Text('Doa tidak ditemukan')))
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final doa = homeController.filteredDoa[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                        leading: CircleAvatar(
                                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.5), 
                                          child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        ),
                                        title: Text(
                                          doa.nama, 
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            doa.idn, 
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => DetailDoaPage(doa: doa)), 
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  childCount: homeController.filteredDoa.length,
                                ),
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}