import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/encryption_service.dart';
import '../services/hive_service.dart';
import '../services/session_service.dart';

class UserController extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserController() {
    checkSession();
  }

  // ✅ Cek session aktif saat app dibuka
  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();

    final userId = await SessionService.getSessionToken();
    if (userId != null && userId.isNotEmpty) {
      final user = _hiveService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
      } else {
        await SessionService.clearSession();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Login logic yang aman
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _hiveService.getUserByEmail(email);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return "Email tidak terdaftar.";
      }

      final isPasswordCorrect = EncryptionService.verifyPassword(password, user.passwordHash);
      if (!isPasswordCorrect) {
        _isLoading = false;
        notifyListeners();
        return "Password salah.";
      }

      await SessionService.createSession(user.uid);
      _currentUser = user;
      _hiveService.updateUser(user);

      _isLoading = false;
      notifyListeners();
      return null; // sukses
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Terjadi kesalahan saat login: $e";
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existing = _hiveService.getUserByEmail(email);
      if (existing != null) {
        _isLoading = false;
        notifyListeners();
        return "Email sudah terdaftar!";
      }

      final passwordHash = EncryptionService.hashPassword(password);
      final newUser = UserModel(
        uid: const Uuid().v4(),
        name: name,
        email: email,
        passwordHash: passwordHash,
        doaOpened: 0,
        lastLogin: DateTime.now(),
      );

      await _hiveService.saveUser(newUser);

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Terjadi kesalahan saat registrasi: $e";
    }
  }

  Future<void> logout() async {
    await SessionService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  // ✅ Tambahan supaya RootPage bisa panggil ini
  UserModel? getUserById(String uid) => _hiveService.getUserById(uid);

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}
