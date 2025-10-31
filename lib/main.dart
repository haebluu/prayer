// lib/main.dart (REVISI FINAL WARNA)

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
          
          // Primary Color: rgb(28, 53, 45) -> #1C352D
          primaryColor: const Color(0xFF1C352D), 
          
          // PrimarySwatch (diatur ke abu-abu netral)
          primarySwatch: Colors.grey, 
          
          // Warna Background Utama: rgb(249, 246, 243) -> #F9F6F3
          scaffoldBackgroundColor: const Color(0xFFF9F6F3),

          // Color Scheme
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
          ).copyWith(
            // Primary: #1C352D
            primary: const Color(0xFF1C352D),
            
            // Secondary (Aksen): rgb(166, 178, 139) -> #A6B28B
            secondary: const Color(0xFFA6B28B), 
            
            // Tertiary (BottomNavBar BG): MENGGUNAKAN SECONDARY YANG BARU (#A6B28B)
            tertiary: const Color(0xFFA6B28B), // <-- REVISI UTAMA DI SINI
            
            // Surface (untuk Card, Sheet): rgb(245, 201, 176) -> #F5C9B0
            surface: const Color(0xFFF5C9B0),
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