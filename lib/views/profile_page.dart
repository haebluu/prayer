// lib/views/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- DATA HARCODE MAHASISWA ---
  final String hardcodeNama = 'Nama Mahasiswa Anda'; 
  final String hardcodeNim = '20230040XXX'; 
  final String hardcodeKelas = 'SI-Pagi B';
  final String hardcodeKesan = 'Aplikasi ini sangat membantu saya dalam mempraktikkan manajemen state dan code generation.';
  final String hardcodeSaran = 'Perlu ditingkatkan fitur notifikasi dan manajemen database lokal menjadi lebih kompleks.';
  // -----------------------------


  @override
  Widget build(BuildContext context) {
    final userController = context.read<UserController>(); // Menggunakan read karena tidak perlu rebuild
    final theme = Theme.of(context);

    // Fungsi untuk Logout (termasuk navigasi)
    void _handleLogout() async {
      await userController.logout();
      
      // Navigasi ke halaman Login dan hapus semua rute
      if (context.mounted) {
        // Menggunakan Navigator.pushAndRemoveUntil untuk kembali ke LoginPage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            // ============== BAGIAN FOTO & DATA DIRI HARCODE ==============
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Placeholder Foto Profil
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.secondary,
                    child: Icon(
                      Icons.camera_alt, // Menggunakan ikon kamera sebagai placeholder foto
                      size: 50,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nama Pengguna (Hardcode)
                  Text(
                    hardcodeNama,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 5),

                  // Detail Profil: NIM dan Kelas
                  _buildProfileDetail(
                    icon: Icons.badge,
                    title: 'NIM',
                    subtitle: hardcodeNim,
                    context: context,
                  ),
                  _buildProfileDetail(
                    icon: Icons.school,
                    title: 'Kelas',
                    subtitle: hardcodeKelas,
                    context: context,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            // ============== KESAN & SARAN HARCODE ==============
            
            const Text(
              'Kesan & Saran Projek',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildKesanSaranCard(
              title: 'Kesan:',
              content: hardcodeKesan,
              context: context,
            ),
            const SizedBox(height: 15),
             _buildKesanSaranCard(
              title: 'Saran:',
              content: hardcodeSaran,
              context: context,
            ),
            
            const SizedBox(height: 30),

            // ============== MENU LOGOUT ==============
            Card(
              elevation: 2,
              color: Colors.white,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _handleLogout,
              ),
            ),
            // ============== AKHIR LOGOUT ==============

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk detail profil (Nama, NIM, Kelas)
  Widget _buildProfileDetail({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required BuildContext context
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor.withOpacity(0.8), size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                Text(subtitle, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  // Widget Pembantu untuk Kartu Kesan dan Saran
  Widget _buildKesanSaranCard({
    required String title,
    required String content,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: theme.primaryColor,
              ),
            ),
            const Divider(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}