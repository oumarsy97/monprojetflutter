// lib/app/core/utils/crypto_utils.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CryptoUtils {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convertit en bytes
    final digest = sha256.convert(bytes); // Utilise SHA-256
    return digest.toString();
  }

  static bool verifyPassword(String password, String hashedPassword) {
    final hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }
}