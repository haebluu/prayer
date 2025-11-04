import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final String hardcodeNama = 'Zahratun Nafiah'; 
  final String hardcodeNim = '124230083'; 
  final String hardcodeKelas = 'SI-A';
  final String hardcodeKesan = 'Mata kuliah ini sangat bermanfaat untuk memahami pengembangan aplikasi mobile menggunakan Flutter';
  final String hardcodeSaran = 'Deadline yang lebih longgar agar dapat mengerjakan projek dengan lebih optimal.';


  @override
  Widget build(BuildContext context) {
    final userController = context.read<UserController>();
    final theme = Theme.of(context);

    void _handleLogout() async {
      await userController.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return CustomScrollView( 
      slivers: [
        SliverAppBar(
          title: const Text('Profil Mahasiswa', style: TextStyle(color: Colors.white),),
          backgroundColor: theme.primaryColor,
          automaticallyImplyLeading: false,
          pinned: true,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage('assets/images/zahra.jpg'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 15),

                      Text(
                        hardcodeNama,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                      const SizedBox(height: 5),

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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

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