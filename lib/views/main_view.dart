// lib/views/main_view.dart

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'savings_page.dart'; 

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  // Daftar View yang sinkron dengan urutan BottomNavigationBar items
  final List<Widget> _pages = const [
    // Index 0: Home
    HomePage(),
    // Index 1: Tabungan
    SavingsPage(),
    // Index 2: Profile (Sudah termasuk Kesan/Saran dan Logout)
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body tanpa Scaffold untuk menghindari masalah bersarang
      body: _pages[_selectedIndex], 
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Index 0: Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Index 1: Tabungan
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tabungan',
          ),
          // Index 2: Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}