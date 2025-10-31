import 'package:flutter/material.dart';
import 'package:prayer/models/user_model.dart';
// Asumsi import service Anda sudah benar
import 'package:prayer/services/encryption_service.dart';
import 'package:prayer/services/hive_service.dart'; 
import 'package:prayer/services/session_service.dart';
import 'package:uuid/uuid.dart';

class UserController extends ChangeNotifier {
  // Deklarasikan dan inisialisasi instance HiveService di sini
  final HiveService _hiveService = HiveService(); // <--- PERBAIKAN: INISIALISASI SERVICE

  UserModel? _currentUser;
  bool _isLoading = true; 

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserController() {
    initController();
  }

  Future<void> initController() async {
    await checkSession();
  }

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();

    final userId = await SessionService.getSessionToken();
    if (userId != null) {
      // PERBAIKAN: Ganti HiveService.getCurrentUser menjadi _hiveService.getUser(userId) 
      // (Mengasumsikan nama metode di HiveService Anda adalah 'getUser')
      _currentUser = _hiveService.getUser(userId); 
      // Catatan: Jika HiveService.getCurrentUser adalah metode statis, gunakan user.uid
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Gunakan instance yang dideklarasikan
    final user = _hiveService.getUserByEmail(email); // <--- PERBAIKAN

    if (user == null || !EncryptionService.verifyPassword(password, user.passwordHash)) {
      _isLoading = false;
      notifyListeners();
      return 'Email atau password salah.';
    }

    await SessionService.createSession(user.uid);

    final updatedUser = UserModel(
      // ... (Field konstruktor tetap sama)
      uid: user.uid,
      email: user.email,
      name: user.name,
      passwordHash: user.passwordHash,
      lastLogin: DateTime.now(),
      doaOpened: user.doaOpened,
    );

    // Gunakan instance yang dideklarasikan
    await _hiveService.updateUser(updatedUser); // <--- PERBAIKAN

    _currentUser = updatedUser;
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Gunakan instance yang dideklarasikan
    final existing = _hiveService.getUserByEmail(email); // <--- PERBAIKAN
    if (existing != null) {
      _isLoading = false;
      notifyListeners();
      return 'Email sudah terdaftar!';
    }

    final passwordHash = EncryptionService.hashPassword(password);
    final newUser = UserModel(
      uid: const Uuid().v4(),
      email: email,
      name: name,
      lastLogin: DateTime.now(),
      passwordHash: passwordHash,
      doaOpened: 0,
    );

    // Gunakan instance yang dideklarasikan
    await _hiveService.saveUser(newUser); // <--- PERBAIKAN

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await SessionService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> incrementDoaOpened() async {
    if (_currentUser != null) {
      final user = _currentUser!;
      final updatedUser = UserModel(
        // ... (Field konstruktor tetap sama)
        uid: user.uid,
        email: user.email,
        name: user.name,
        doaOpened: user.doaOpened + 1,
        lastLogin: user.lastLogin,
        passwordHash: user.passwordHash,
      );
      _currentUser = updatedUser;
      // Gunakan instance yang dideklarasikan
      await _hiveService.updateUser(updatedUser); // <--- PERBAIKAN
      notifyListeners();
    }
  }
}