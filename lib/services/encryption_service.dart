// lib/services/encryption_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Service stub untuk Hash Password
class EncryptionService {
  // Menggunakan SHA-256 untuk hashing sederhana (bukan enkripsi sejati)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash) {
    return hashPassword(password) == storedHash;
  }
}