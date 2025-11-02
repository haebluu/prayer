import 'package:flutter/material.dart';
import 'package:prayer/models/user_model.dart';
import 'package:prayer/services/encryption_service.dart';
import 'package:prayer/services/hive_service.dart'; 
import 'package:prayer/services/session_service.dart';
import 'package:uuid/uuid.dart';

class UserController extends ChangeNotifier {
  final HiveService _hiveService = HiveService(); 

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
      _currentUser = _hiveService.getUser(userId); 
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = _hiveService.getUserByEmail(email); 

    if (user == null || !EncryptionService.verifyPassword(password, user.passwordHash)) {
      _isLoading = false;
      notifyListeners();
      return 'Email atau password salah.';
    }

    await SessionService.createSession(user.uid);

    final updatedUser = UserModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      passwordHash: user.passwordHash,
      lastLogin: DateTime.now(),
      doaOpened: user.doaOpened,
    );

    await _hiveService.updateUser(updatedUser); 

    _currentUser = updatedUser;
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final existing = _hiveService.getUserByEmail(email);
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

    await _hiveService.saveUser(newUser);

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
        uid: user.uid,
        email: user.email,
        name: user.name,
        doaOpened: user.doaOpened + 1,
        lastLogin: user.lastLogin,
        passwordHash: user.passwordHash,
      );
      _currentUser = updatedUser;
      await _hiveService.updateUser(updatedUser);
      notifyListeners();
    }
  }
}