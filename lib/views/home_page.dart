// lib/views/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../services/location_service.dart';
import 'detail_doa_page.dart';
import 'currency_converter_page.dart';
import 'time_converter-page.dart';

// HAPUS: Definisi kelas DoaCategory dan data dummyCategories

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context); 
    final LocationService locationService = LocationService();
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        // AppBar tetap dipertahankan untuk judul, dengan warna tema baru
        title: const Text('Doa Harian', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      
      // Menggunakan CustomScrollView untuk Header yang menarik
      body: CustomScrollView( 
        slivers: [
          // 1. HERO HEADER (Judul dan Search Bar)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              color: theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Agar children meregang
                children: [
                  // Judul dan Hero Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assalamualaikum!', 
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar (sekarang berada di dalam Hero Section)
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

          // 2. ACTION BUTTONS (Konversi Uang & Waktu) - Dipertahankan di bagian atas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionButtons(context, locationService),
            ),
          ),

          // 3. DAFTAR DOA LENGKAP (Menggantikan Daftar Kategori)
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
    );
  }

  // Metode untuk Tombol Aksi (Dipertahankan)
  Widget _buildActionButtons(BuildContext context, LocationService locationService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyConverterPage()),
              );
            },
            icon: const Icon(Icons.currency_exchange),
            label: const Text('Konversi Uang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary, 
              foregroundColor: Colors.black, 
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimeConverterPage()),
              );
            },
            icon: const Icon(Icons.access_time),
            label: const Text('Waktu Lokal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}