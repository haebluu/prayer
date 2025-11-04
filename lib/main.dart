
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/services/notification_service.dart';

import 'controllers/user_controller.dart'; 
import 'controllers/home_controller.dart';
import 'services/hive_service.dart';
import 'services/session_service.dart';

import 'views/login_page.dart';
import 'views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
          primaryColor: const Color(0xFF43766C), 
          primarySwatch: Colors.grey, 
          scaffoldBackgroundColor: const Color(0xFFF8FAE5),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
          ).copyWith(
            primary: const Color(0xFF43766C),
            secondary: const Color(0xFFB19470), 
            tertiary: const Color(0xFF76453B), 
            surface: const Color(0xFFF8FAE5),
            onPrimary: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>(); 
    
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