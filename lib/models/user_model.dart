import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String uid; 
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String passwordHash; 
  @HiveField(4)
  final DateTime lastLogin; 
  @HiveField(5)
  final int doaOpened; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.lastLogin,
    this.doaOpened = 0, 
  });
}