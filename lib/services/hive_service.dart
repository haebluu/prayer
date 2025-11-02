import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settingsBox'; 
  static const String totalSavingsKey = 'totalSavings'; 
  static const String bookmarkBoxName = 'bookmarkBox'; 

  static Future<void> init() async { 
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<dynamic>(settingsBoxName);
  }
  
  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName); 
  
  double getTotalSavings() {
    return settingsBox.get(totalSavingsKey) as double? ?? 0.0;
  }

  Future<void> addSavings(double amountInIDR) async {
    final currentTotal = getTotalSavings();
    final newTotal = currentTotal + amountInIDR;
    await settingsBox.put(totalSavingsKey, newTotal); 
  }
  
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