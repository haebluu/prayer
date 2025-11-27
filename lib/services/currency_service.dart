// lib/services/currency_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyServiceException implements Exception {
  final String message;
  CurrencyServiceException(this.message);
  @override
  String toString() => 'CurrencyServiceException: $message';
}

class CurrencyService {
  static const String _apiKey = '222dabd382b071dcb3531a5e';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6/$_apiKey/latest/USD'; // Base USD

  Map<String, double> _rates = {};
  
  DateTime? get lastFetch => _lastFetch; 
  DateTime? _lastFetch;

  static const List<String> availableCurrencies = [
    'IDR', 
    'USD', 
    'EUR', 
    'JPY', 
    'KRW', 
    'CNY',  
    'SAR',  
  ];

  Future<void> fetchRates() async {
    if (_lastFetch != null && DateTime.now().difference(_lastFetch!).inHours < 1) {
      return; 
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        final Map<String, dynamic>? ratesJson = body['conversion_rates'] as Map<String, dynamic>?;

        if (ratesJson != null) {
          _rates = Map<String, double>.from(ratesJson.map((key, value) => MapEntry(key, value.toDouble())));
          _lastFetch = DateTime.now();
        } else {
          throw CurrencyServiceException('Format respons API salah: Tidak ditemukan conversion_rates.');
        }
      } else {
        throw CurrencyServiceException('Gagal mengambil kurs. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw CurrencyServiceException('Koneksi gagal: ${e.toString()}');
    }
  }

  double convert(String fromCurrency, String toCurrency, double amount) {
    if (_rates.isEmpty) {
      throw CurrencyServiceException('Kurs belum dimuat. Coba panggil fetchRates() terlebih dahulu.');
    }

    if (!_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
       throw CurrencyServiceException('Mata uang tidak didukung dalam data kurs.');
    }
    
    double amountInUsd = amount / _rates[fromCurrency]!;
    double convertedAmount = amountInUsd * _rates[toCurrency]!;
    
    return convertedAmount;
  }

  Map<String, double> getRates() => _rates;
}