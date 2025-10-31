import 'package:flutter/material.dart';
import 'package:prayer/views/currency_converter_page.dart';
import 'package:prayer/views/time_converter-page.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../services/location_service.dart'; // Panggil service untuk button
import 'detail_doa_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final homeController = Provider.of<HomeController>(context); 
    final LocationService locationService = LocationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa & Dzikir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            tooltip: 'Profil',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tombol Fungsionalitas Konversi
          _buildActionButtons(context, locationService),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => homeController.searchDoa(value), // Hubungkan ke Controller
              decoration: const InputDecoration(
                labelText: 'Cari Doa (Judul atau Terjemahan)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // List Doa (Menggunakan data dari Controller)
          Expanded(
            child: homeController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : homeController.errorMessage.isNotEmpty
                    ? Center(child: Text('Error: ${homeController.errorMessage}'))
                    : homeController.filteredDoa.isEmpty
                        ? const Center(child: Text('Doa tidak ditemukan'))
                        : ListView.builder(
                            itemCount: homeController.filteredDoa.length,
                            // ...
                            // Di dalam ListView.builder pada home_page.dart

                            // ...
                            itemBuilder: (context, index) {
                              final doa = homeController.filteredDoa[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  // Ikon di awal list
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.secondary, 
                                    child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ),
                                  // Judul Doa
                                  title: Text(
                                    doa.nama, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008080)),
                                  ),
                                  // Snippet Terjemahan
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      doa.idn, 
                                      maxLines: 2, 
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DetailDoaPage(doa: doa)), 
                                    );
                                  },
                                ),
                              );
                            },
                            // ...
// ..
                          ),
          ),
        ],
      ),
    );
  }

  // Di dalam class HomePage

  Widget _buildActionButtons(BuildContext context, LocationService locationService) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Row(
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
                backgroundColor: Theme.of(context).colorScheme.secondary, // Warna Emas
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
                backgroundColor: Theme.of(context).primaryColor, // Warna Hijau Tema
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

