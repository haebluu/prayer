import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Bagian Informasi Aplikasi
            const Center(
              child: Column(
                children: [
                  Icon(Icons.mosque, size: 80, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    'Doa & Dzikir Harian',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Versi 1.0.0', style: TextStyle(color: Colors.grey)),
                  Divider(height: 30),
                ],
              ),
            ),

            // Bagian Pengaturan
            const Text(
              'Pengaturan Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Opsi Pengaturan 1: Ukuran Font
            ListTile(
              leading: const Icon(Icons.format_size),
              title: const Text('Ukuran Teks Arab'),
              subtitle: const Text('Atur ukuran font untuk Teks Arab'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implementasi logika pengaturan ukuran font
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Pengaturan Font sedang dikembangkan!'))
                );
              },
            ),

            // Opsi Pengaturan 2: Notifikasi Harian
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Notifikasi Dzikir Pagi & Petang'),
              trailing: Switch(
                value: true, // Nilai dummy, harus diambil dari state/shared preferences
                onChanged: (bool value) {
                  // TODO: Implementasi logika notifikasi
                },
                activeColor: Colors.green,
              ),
            ),

            // Opsi Informasi Tambahan
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Kami'),
              onTap: () {
                // Menampilkan dialog atau navigasi ke halaman 'Tentang'
                showAboutDialog(
                  context: context,
                  applicationName: 'Doa & Dzikir Harian',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('Aplikasi ini dibuat sebagai sarana untuk memudahkan umat Islam dalam mengakses doa dan dzikir harian.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}