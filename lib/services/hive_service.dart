import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
// Asumsikan Anda memiliki import untuk DoaModel di sini juga

class HiveService {
  // Deklarasi nama Box sebagai static const (konstanta)
  static const String userBoxName = 'userBox';
  static const String bookmarkBoxName = 'bookmarkBox'; 

  // ======================================================
  // 1. INISIALISASI (Metode Statis, Dipanggil di main.dart)
  // ======================================================

  /// Melakukan inisialisasi Hive dan mendaftarkan Adapter.
  static Future<void> init() async { 
    // Inisialisasi Hive Flutter
    await Hive.initFlutter();

    // Registrasi adapter
    // PERHATIKAN: Anda harus memastikan semua adapter Model Hive sudah dibuat (flutter pub run build_runner)
    Hive.registerAdapter(UserModelAdapter());
    // Hive.registerAdapter(DoaModelAdapter()); // Tambahkan ini saat DoaModel final
    
    // Buka semua Box yang diperlukan
    await Hive.openBox<UserModel>(userBoxName);
    // await Hive.openBox<DoaModel>(bookmarkBoxName); // Tambahkan ini untuk Bookmark
  }
  
  // ======================================================
  // 2. GETTER (Akses ke Box)
  // ======================================================
  
  // Getter untuk mengakses User Box (aman karena diasumsikan sudah dibuka di init())
  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  
  // Getter untuk Bookmark Box (akan digunakan oleh BookmarkService)
  // Box<DoaModel> get bookmarkBox => Hive.box<DoaModel>(bookmarkBoxName); 

  // ======================================================
  // 3. METODE PENGGUNA (Digunakan oleh UserController)
  // ======================================================

  /// Menyimpan atau memperbarui pengguna.
  Future<void> saveUser(UserModel user) async {
    // put(key, value) menggunakan UID sebagai key unik
    await userBox.put(user.uid, user);
  }

  /// Mencari pengguna berdasarkan Email (untuk Login/Register).
  UserModel? getUserByEmail(String email) {
    try {
      // Menggunakan firstWhere untuk mencari kecocokan
      return userBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      // Jika firstWhere melempar StateError (tidak ditemukan), kembalikan null
      return null;
    }
  }

  /// Mengambil pengguna berdasarkan UID (untuk checkSession).
  UserModel? getUser(String uid) { 
    // Menggunakan get(key) adalah cara cepat mencari berdasarkan UID
    return userBox.get(uid); 
  }

  /// Memperbarui data pengguna yang ada.
  Future<void> updateUser(UserModel user) async {
    // put() berdasarkan UID untuk update
    await userBox.put(user.uid, user);
  }

  /// Menghapus semua data pengguna (Hanya digunakan untuk tujuan debugging atau clear data).
  Future<void> clearAllUsers() async { 
    await userBox.clear();
  }
}