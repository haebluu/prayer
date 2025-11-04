import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String savingsBoxName = 'savingsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<double>(savingsBoxName);
  }

  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<double> get savingsBox => Hive.box<double>(savingsBoxName);

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

  Future<void> addSavings(double amount) async {
    await savingsBox.add(amount);
  }

  double getTotalSavings() {
    double total = 0;
    for (var amount in savingsBox.values) {
      total += amount;
    }
    return total;
  }
}
