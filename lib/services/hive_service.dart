
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
 static const String userBoxName = 'userBox';
 static const String userSavingsBoxName = 'userSavingsBox'; //

 static Future<void> init() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
   Hive.registerAdapter(UserModelAdapter()); //
  }
  await Hive.openBox<UserModel>(userBoxName);
  await Hive.openBox<dynamic>(userSavingsBoxName); //
 }

 Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
 Box<dynamic> get userSavingsBox => Hive.box<dynamic>(userSavingsBoxName); 

 UserModel? getUserByEmail(String email) {
  try {
   return userBox.values.firstWhere(
    (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase(),
   ); //
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
  await userBox.put(user.uid, user); //
 }

 Future<void> updateUser(UserModel user) async {
  await userBox.put(user.uid, user); //
 }
  
 
 Future<void> addSavingsForUser(String userId, double amount) async {
  final currentData = userSavingsBox.get(userId);
  
  List<Map<String, dynamic>> transactions = currentData != null 
   ? List<Map<String, dynamic>>.from(currentData['transactions']) 
   : [];
  
  transactions.add({
    'amount': amount, 
    'date': DateTime.now(), 
  });
  
  await userSavingsBox.put(userId, {'transactions': transactions}); 
 }

 double getUserTotalSavings(String userId) {
  final data = userSavingsBox.get(userId);
  
  if (data == null) {
   return 0.0;
  }

  final List<Map<String, dynamic>> transactions = 
    List<Map<String, dynamic>>.from(data['transactions']);
  
  return transactions.fold(0.0, (sum, item) => sum + (item['amount'] as double));
 }

 List<Map<String, dynamic>> getUserSavingsHistory(String userId) {
  final data = userSavingsBox.get(userId);
  
  if (data == null) {
   return [];
  }
  
  final List<Map<String, dynamic>> transactions = 
    List<Map<String, dynamic>>.from(data['transactions']);
  
  transactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

  return transactions;
 }
}