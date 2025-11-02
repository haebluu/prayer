import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController(text: '1.0');
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';

  String _result = '0.00 IDR';
  String _statusMessage = 'Siap menghitung. Tekan Konversi.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAndConvertRates(); 
  }
  Future<void> _fetchAndConvertRates() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil kurs terbaru...';
    });

    try {
      await _currencyService.fetchRates();
      _convertCurrency();
    } on CurrencyServiceException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error tidak terduga: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _convertCurrency() {
    if (_isLoading) return;

    double amount;
    try {
      amount = double.parse(_amountController.text);
    } catch (e) {
      setState(() {
        _statusMessage = 'Input jumlah harus berupa angka.';
        _result = '0.00';
      });
      return;
    }

    try {
      final convertedAmount = _currencyService.convert(
        _fromCurrency, 
        _toCurrency, 
        amount,
      );
      
      final formatter = NumberFormat.currency(
        locale: 'id_ID', 
        symbol: _toCurrency == 'IDR' ? 'Rp' : '$_toCurrency ', 
        decimalDigits: 2
      );
      
      setState(() {
        _result = formatter.format(convertedAmount);
        final lastFetchTime = _currencyService.lastFetch?.toLocal().toString().split('.')[0] 
                              ?? 'Waktu Tidak Diketahui';
        _statusMessage = 'Konversi berhasil pada $lastFetchTime';     
        }
      ); 
    } on CurrencyServiceException catch (e) {
      setState(() {
        _statusMessage = 'Error konversi: ${e.message}';
        _result = 'N/A';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Mata Uang'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hasil Konversi
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Hasil Konversi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 32, color:  Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(_statusMessage, style: TextStyle(color: _statusMessage.contains('Error') ? Colors.red : Colors.grey)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // Input Jumlah
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Jumlah yang dikonversi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _amountController.clear(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Dropdown Mata Uang Asal (FROM)
            _buildCurrencyDropdown(
              label: 'Dari Mata Uang:',
              value: _fromCurrency,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _fromCurrency = newValue;
                  });
                }
              },
            ),

            const SizedBox(height: 10),

            // Tombol Tukar (Swap)
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert, size: 30, color:  Color(0xFFD4AF37)),
                onPressed: () {
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 10),

            // Dropdown Mata Uang Tujuan (TO)
            _buildCurrencyDropdown(
              label: 'Ke Mata Uang:',
              value: _toCurrency,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _toCurrency = newValue;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            // Tombol Konversi
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _convertCurrency,
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.calculate),
              label: Text(_isLoading ? 'Memuat Kurs...' : 'Konversi Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tombol Refresh Kurs
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _fetchAndConvertRates,
              icon: const Icon(Icons.refresh),
              label: const Text('Perbarui Kurs'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk Dropdown
  Widget _buildCurrencyDropdown({
    required String label, 
    required String value, 
    required ValueChanged<String?> onChanged
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: CurrencyService.availableCurrencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}