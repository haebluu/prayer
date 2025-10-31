import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Services dan Controllers
import 'controllers/user_controller.dart'; 
import 'controllers/home_controller.dart'; // <--- ASUMSI: Controller Doa
import 'services/hive_service.dart';
import 'services/session_service.dart';

// Import Views
import 'views/home_page.dart';
import 'views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Service Global (Hive dan Session)
  await HiveService.init(); 
  await SessionService.init(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PENTING: Gunakan MultiProvider untuk mendaftarkan semua Controller
    return MultiProvider(
      providers: [
        // 1. Controller Otentikasi/Pengguna
        ChangeNotifierProvider(create: (_) => UserController()),
        // 2. Controller Logika Utama (Daftar Doa, Search)
        ChangeNotifierProvider(create: (_) => HomeController()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doa & Dzikir App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: const Color(0xFF008080), 
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
            secondary: const Color(0xFFD4AF37), // Emas
          ),
          useMaterial3: true,
        ),
        home: const RootPage(),
      ),
    );
  }
}

// ✅ Halaman yang menentukan apakah ke Home (MainScreen) atau ke Login
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil userController untuk memeriksa status login
    final userController = Provider.of<UserController>(context);

    if (userController.isLoading) {
      // Tampilkan splash screen atau loading saat sesi dicek
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika pengguna sudah login
    if (userController.currentUser != null) {
      // Langsung navigasi ke MainScreen (yang berisi Bottom Navbar)
      return const HomePage(); 
    } else {
      // Jika belum login
      return const LoginPage();
    }
  }
}