// lib/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settingsBox'; // Nama Box Baru
  static const String totalSavingsKey = 'totalSavings'; 
  static const String bookmarkBoxName = 'bookmarkBox'; 

  // ======================================================
  // 1. INISIALISASI (Box Baru Ditambahkan)
  // ======================================================

  static Future<void> init() async { 
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    
    await Hive.openBox<UserModel>(userBoxName);
    
    // Box BARU untuk pengaturan/nilai primitif (FIX: error saat menyimpan double)
    await Hive.openBox<dynamic>(settingsBoxName);
  }
  
  // ======================================================
  // 2. GETTER
  // ======================================================
  
  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName); 
  
  // ======================================================
  // 3. METODE TOTAL TABUNGAN (Menggunakan settingsBox)
  // ======================================================

  double getTotalSavings() {
    return settingsBox.get(totalSavingsKey) as double? ?? 0.0;
  }

  Future<void> addSavings(double amountInIDR) async {
    final currentTotal = getTotalSavings();
    final newTotal = currentTotal + amountInIDR;
    await settingsBox.put(totalSavingsKey, newTotal); // FIX: Menggunakan settingsBox
  }
  
  // ======================================================
  // 4. METODE PENGGUNA
  // ======================================================

  Future<void> saveUser(UserModel user) async {
    await userBox.put(user.uid, user);
  }

  UserModel? getUserByEmail(String email) {
    try {
      return userBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  UserModel? getUser(String uid) { 
    return userBox.get(uid); 
  }

  Future<void> updateUser(UserModel user) async {
    await userBox.put(user.uid, user);
  }

  Future<void> clearAllUsers() async { 
    await userBox.clear();
  }
}