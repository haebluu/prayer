import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Services dan Controllers
import 'controllers/user_controller.dart'; 
import 'controllers/home_controller.dart';
import 'services/hive_service.dart';
import 'services/session_service.dart';

// Import Views
import 'views/login_page.dart';
import 'views/main_view.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => HomeController()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doa & Dzikir App',
        theme: ThemeData(
          // --- REVISI TEMA WARNA MULAI DI SINI ---
          
          // Primary Color: Menggunakan rgb(98, 130, 93) -> #62825D
          primaryColor: const Color(0xFF62825D), 
          
          // PrimarySwatch (untuk kompatibilitas): Dibuat mendekati Primary Color baru
          primarySwatch: Colors.green, 
          
          // Color Scheme: Mengatur warna aksen/sekunder
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
            // BARIS primaryColorDark DIHAPUS DARI SINI (memperbaiki error)
          ).copyWith(
            // Secondary (Aksen): Menggunakan rgb(158, 223, 156) -> #9EDF9C
            secondary: const Color(0xFF9EDF9C), 
            // Tetapkan Primary color secara eksplisit di ColorScheme agar widget M3 menggunakannya.
            primary: const Color(0xFF62825D),
          ),
          
          // --- REVISI TEMA WARNA SELESAI ---
          useMaterial3: true,
        ),
        home: const RootPage(),
      ),
    );
  }
}

// ✅ Halaman yang menentukan apakah ke MainView (Home Flow) atau ke Login
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    if (userController.isLoading) {
      // Tampilkan splash screen atau loading saat sesi dicek
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userController.currentUser != null) {
      // NAVIGASI BARU: Ke MainView yang memiliki BottomNavBar
      return const MainView();
    } else {
      return const LoginPage();
    }
  }
}