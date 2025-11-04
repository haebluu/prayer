import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
 static const String userBoxName = 'userBox';
 // ✅ PERBAIKAN: Ubah nama box tabungan untuk mencerminkan bahwa ia menyimpan data per user
 // Nama box sebelumnya: 'savingsBox' (List<double>)
 // Nama box baru (atau yang sama, tapi isinya Map<String, List<double>>):
 static const String userSavingsBoxName = 'userSavingsBox'; 

 static Future<void> init() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
   Hive.registerAdapter(UserModelAdapter());
  }
  await Hive.openBox<UserModel>(userBoxName);
  // ✅ PERBAIKAN: Buka box baru untuk penyimpanan per user. 
  // Box ini akan menyimpan Map (userId -> List of savings)
  await Hive.openBox<dynamic>(userSavingsBoxName); 
 }

 Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
 // Box lama (savingsBox) dihapus atau diabaikan, kita gunakan userSavingsBox
 Box<dynamic> get userSavingsBox => Hive.box<dynamic>(userSavingsBoxName); 

 // ... (Fungsi user tetap sama)
 UserModel? getUserByEmail(String email) {
  try {
   return userBox.values.firstWhere(
    (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase(),
   );
  } catch (e) {
   return null;
  }
 }

 UserModel? getUserById(String uid) {
  try {
   return userBox.get(uid);
  } catch (e) {
   return null;
  }
 }

 Future<void> saveUser(UserModel user) async {
  await userBox.put(user.uid, user);
 }

 Future<void> updateUser(UserModel user) async {
  await userBox.put(user.uid, user);
 }
  
 // ✅ PERBAIKAN: Hapus fungsi addSavings lama (yang menyimpan global)
 // Future<void> addSavings(double amount) async { ... }

 // ✅ PERBAIKAN: Hapus fungsi getTotalSavings lama (yang menghitung global)
 // double getTotalSavings() { ... }
  
 // 🆕 FUNGSI BARU: Tambah Tabungan untuk User Tertentu
 Future<void> addSavingsForUser(String userId, double amount) async {
  // Ambil data tabungan saat ini untuk user ini.
  final currentAmounts = userSavingsBox.get(userId);
  
  List<double> amounts = currentAmounts != null 
   ? List<double>.from(currentAmounts['amounts']) 
   : [];
  
  amounts.add(amount);
  
  // Simpan kembali dengan key userId
  await userSavingsBox.put(userId, {'amounts': amounts}); 
 }

 // 🆕 FUNGSI BARU: Hitung Total Tabungan untuk User Tertentu
 double getUserTotalSavings(String userId) {
  // Ambil data tabungan spesifik user.
  final data = userSavingsBox.get(userId);
  
  if (data == null) {
   return 0.0;
  }

  final List<double> amounts = List<double>.from(data['amounts']);
  
  // Hitung totalnya
  return amounts.fold(0.0, (sum, item) => sum + item);
 }
}