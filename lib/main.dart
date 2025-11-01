// lib/main.dart (REVISI FINAL WARNA)

import 'package:flutter/material.dart';
import 'package:prayer/services/notification_service.dart';
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
  await NotificationService.init();
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
         /// Primary Color: rgb(67, 118, 108) -> #43766C
          primaryColor: const Color(0xFF43766C), 
          
          // PrimarySwatch (diatur ke abu-abu netral)
          primarySwatch: Colors.grey, 
          
          // Warna Background Utama: rgb(248, 250, 229) -> #F8FAE5
          scaffoldBackgroundColor: const Color(0xFFF8FAE5),

          // Color Scheme
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
          ).copyWith(
            // Primary: #43766C
            primary: const Color(0xFF43766C),
            // Secondary (Aksen): rgb(177, 148, 112) -> #B19470
            secondary: const Color(0xFFB19470), 
            // Tertiary (BottomNavBar BG): rgb(118, 69, 59) -> #76453B
            tertiary: const Color(0xFF76453B), 
            // Surface (untuk Card, Sheet): Menggunakan warna Background untuk tampilan bersih
            surface: const Color(0xFFF8FAE5),
            // Warna untuk Error/Kontras Teks
            onPrimary: Colors.white,
          ),
          
          // --- REVISI TEMA WARNA SELESAI ---
          useMaterial3: true,
        ),
        home: const RootPage(),
      ),
    );
  }
}

// Halaman yang menentukan apakah ke MainView (Home Flow) atau ke Login (Tetap Sama)
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    if (userController.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userController.currentUser != null) {
      return const MainView();
    } else {
      return const LoginPage();
    }
  }
}