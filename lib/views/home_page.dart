// lib/views/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/user_controller.dart';
import 'detail_doa_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context); 
    final userController = Provider.of<UserController>(context);
    final userName = userController.currentUser?.name ?? 'Pengguna'; 
    final theme = Theme.of(context);
    
    // Menggunakan DefaultTabController untuk manajemen Tab Menu (Doa, Dzikir, Hadis)
    return DefaultTabController(
      length: 3, 
      child: Column( 
        children: [
          // 1. App Bar
          AppBar(
            title: const Text('Doa & Dzikir', style: TextStyle(color: Colors.white)),
            backgroundColor: theme.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false, 
          ),
          
          // 2. HERO HEADER (Judul & Search Bar)
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            color: theme.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                // Judul Dinamis (Assalamualaikum, [Nama])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      hintText: 'Cari doa, dzikir, atau hadis...',
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
          
          // 3. TAB BAR (Menu Kategori)
          TabBar(
            tabs: const [
              Tab(text: 'Doa'),
              Tab(text: 'Dzikir'),
              Tab(text: 'Hadis'),
            ],
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            overlayColor: MaterialStatePropertyAll(theme.scaffoldBackgroundColor),
          ),

          // 4. TAB BAR VIEW (Konten yang dapat di-scroll)
          Expanded(
            child: TabBarView(
              children: [
                // TAB 1: DOA
                _buildDoaList(homeController, theme, context),
                // TAB 2: DZIKIR
                _buildDzikirList(homeController, theme),
                // TAB 3: HADIS
                _buildHaditsList(homeController, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGET BUILDER UNTUK SETIAP TAB
  // =========================================================

  Widget _buildDoaList(HomeController controller, ThemeData theme, BuildContext context) {
    if (controller.isLoadingDoa) {
      return const Center(child: CircularProgressIndicator());
    }
    // FIX: Menampilkan error spesifik
    if (controller.errorDoa.isNotEmpty) {
      return Center(child: Text('Error: ${controller.errorDoa}'));
    }
    if (controller.filteredDoa.isEmpty) {
      return const Center(child: Text('Doa tidak ditemukan'));
    }

    return ListView.builder(
      // FIX: Menambahkan physics untuk memperbaiki scrolling di TabBarView
      physics: const ClampingScrollPhysics(), 
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: controller.filteredDoa.length,
      itemBuilder: (context, index) {
        final doa = controller.filteredDoa[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.5), 
              child: Text('${index + 1}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ),
            title: Text(doa.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(doa.idn, maxLines: 2, overflow: TextOverflow.ellipsis),
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
    );
  }

  Widget _buildDzikirList(HomeController controller, ThemeData theme) {
     if (controller.isLoadingDzikir) {
      return const Center(child: CircularProgressIndicator());
    }
    // FIX: Menampilkan error spesifik
    if (controller.errorDzikir.isNotEmpty) { 
      return Center(child: Text('Error: ${controller.errorDzikir}'));
    }
    if (controller.allDzikir.isEmpty) {
      return const Center(child: Text('Data Dzikir tidak ditemukan.'));
    }
    
    return ListView.builder(
      // FIX: Menambahkan physics
      physics: const ClampingScrollPhysics(), 
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: controller.allDzikir.length,
      itemBuilder: (context, index) {
        final dzikir = controller.allDzikir[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          child: ListTile(
            title: Text('${dzikir.type.toUpperCase()} (${dzikir.ulang})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(dzikir.arab, 
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Arial', fontSize: 20, color: theme.primaryColor),
                ),
                const SizedBox(height: 5),
                Text(dzikir.indo, style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  Widget _buildHaditsList(HomeController controller, ThemeData theme) {
     if (controller.isLoadingHadits) {
      return const Center(child: CircularProgressIndicator());
    }
    // FIX: Menampilkan error spesifik
    if (controller.errorHadits.isNotEmpty) { 
      return Center(child: Text('Error: ${controller.errorHadits}'));
    }
    if (controller.allHadits.isEmpty) {
      return const Center(child: Text('Data Hadis tidak ditemukan.'));
    }
    
    return ListView.builder(
      // FIX: Menambahkan physics
      physics: const ClampingScrollPhysics(), 
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: controller.allHadits.length,
      itemBuilder: (context, index) {
        final hadits = controller.allHadits[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          child: ExpansionTile(
            title: Text('${hadits.no}. ${hadits.judul}', style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hadits.arab, 
                      textAlign: TextAlign.right,
                      style: TextStyle(fontFamily: 'Arial', fontSize: 18, color: theme.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    const Text('Terjemahan:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(hadits.indo, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}