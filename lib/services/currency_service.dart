import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyServiceException implements Exception {
  final String message;
  CurrencyServiceException(this.message);
  @override
  String toString() => 'CurrencyServiceException: $message';
}

class CurrencyService {
  // API key tidak diperlukan untuk API ini, tetapi kita menggunakan USD sebagai basis
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/USD';

  // Menyimpan semua kurs mata uang yang didapat dari API
  late Map<String, double> _rates; 
  DateTime? get lastFetch => _lastFetch; 
  DateTime? _lastFetch;

  // Mata uang yang akan ditampilkan
  static const List<String> availableCurrencies = ['IDR', 'USD', 'EUR', 'JPY', 'SGD', 'GBP'];

  // Fungsi untuk mengambil kurs dari API
  Future<void> fetchRates() async {
    // Hindari fetch berlebihan, batasi 1 jam per fetch
    if (_lastFetch != null && DateTime.now().difference(_lastFetch!).inHours < 1) {
      return; 
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['rates'] is Map) {
          _rates = Map<String, double>.from(body['rates'].map((key, value) => MapEntry(key, value.toDouble())));
          _lastFetch = DateTime.now();
        } else {
          throw CurrencyServiceException('Format respons API salah atau tidak ada kurs.');
        }
      } else {
        throw CurrencyServiceException('Gagal mengambil kurs. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Menangkap error koneksi internet, timeout, dll.
      throw CurrencyServiceException('Koneksi gagal: ${e.toString()}');
    }
  }

  // Fungsi konversi utama
  double convert(String fromCurrency, String toCurrency, double amount) {
    if (_rates.isEmpty) {
      throw CurrencyServiceException('Kurs belum dimuat. Coba panggil fetchRates() terlebih dahulu.');
    }

    if (!_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
       throw CurrencyServiceException('Mata uang tidak didukung dalam data kurs.');
    }
    
    // Semua rate berdasarkan USD (base USD)
    // 1. Ubah mata uang 'from' ke USD
    double amountInUsd = amount / _rates[fromCurrency]!;
    
    // 2. Ubah USD ke mata uang 'to'
    double convertedAmount = amountInUsd * _rates[toCurrency]!;
    
    return convertedAmount;
  }

  // Fungsi untuk mendapatkan daftar rate yang sudah di-fetch
  Map<String, double> getRates() => _rates;
}