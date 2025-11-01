// lib/views/savings_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../services/currency_service.dart';
import '../services/location_service.dart';
import '../services/hive_service.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  // Service instances
  final CurrencyService _currencyService = CurrencyService();
  final HiveService _hiveService = HiveService();
  
  // FIX: Mengubah LocationService menjadi static final (seperti yang didiskusikan sebelumnya)
  static final LocationService _locationService = LocationService(); 
  
  // Input Controller
  final TextEditingController _amountController = TextEditingController(); 
  
  static const String _fromCurrency = 'IDR'; 

  // --- DATA HARDCODE ZONA WAKTU ---
  final List<Map<String, String>> _timeZones = const [
    {'name': 'WIB (Jakarta)', 'zoneId': 'Asia/Jakarta'},
    {'name': 'WITA (Makassar)', 'zoneId': 'Asia/Makassar'},
    {'name': 'WIT (Jayapura)', 'zoneId': 'Asia/Jayapura'},
    {'name': 'London (GMT/BST)', 'zoneId': 'Europe/London'},
    {'name': 'Dubai (GST)', 'zoneId': 'Asia/Dubai'}, 
  ];
  String _selectedTimeZoneId = 'Asia/Jakarta'; // Default: WIB
  // ---------------------------------

  // State Variables
  String _targetInputCurrency = ''; 
  String _targetTotalSavingsCurrency = ''; 
  
  double _totalSavingsIDR = 0.0; 
  double _convertedTotalSavings = 0.0; 
  double _convertedInputAmount = 0.0; 
  
  String _statusMessage = 'Aplikasi siap konversi.';
  bool _isLoading = false;
  String _currentTime = 'N/A';
  
  late List<String> _conversionTargets; 

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    
    // Inisialisasi daftar mata uang target
    _conversionTargets = CurrencyService.availableCurrencies
        .where((c) => c != _fromCurrency)
        .toList();
        
    // Set nilai default yang valid
    _targetTotalSavingsCurrency = _conversionTargets.contains('DINAR') ? 'DINAR' : 'USD'; 
    _targetInputCurrency = _conversionTargets.contains('DINAR') ? 'DINAR' : 'USD'; 

    _loadInitialData();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() {
      _totalSavingsIDR = _hiveService.getTotalSavings();
    });
    // Memuat kurs dan memperbarui waktu default
    _fetchRates();
    _updateTimeDisplay(_selectedTimeZoneId); // Tampilkan waktu WIB (default)
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil kurs terbaru...';
    });

    try {
      await _currencyService.fetchRates();
      
      // Setelah kurs dimuat, hitung konversi awal
      _updateTotalSavingsConversion(_targetTotalSavingsCurrency);
      _updateInputConversion();
      
      setState(() {
         _statusMessage = 'Kurs berhasil dimuat.';
      });
      
    } on CurrencyServiceException catch (e) {
      setState(() {
        _statusMessage = 'Error Kurs: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error Umum: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // FUNGSI BARU: Memperbarui tampilan waktu berdasarkan zona waktu yang dipilih
  void _updateTimeDisplay(String zoneId) {
    try {
      final location = tz.getLocation(zoneId);
      final now = tz.TZDateTime.now(location);
      // Format waktu
      final formatter = DateFormat('dd MMM yyyy, HH:mm:ss').format(now);

      setState(() {
        _currentTime = formatter;
      });
    } catch (e) {
      setState(() {
        _currentTime = 'Zona Waktu tidak valid';
      });
    }
  }

  // FUNGSI KONVERSI TOTAL TABUNGAN
  void _updateTotalSavingsConversion(String targetCurrency) {
     if (_currencyService.getRates().isEmpty) return;

     final totalIDR = _hiveService.getTotalSavings();
     
     if (targetCurrency == _fromCurrency) {
       setState(() {
         _convertedTotalSavings = totalIDR;
         _totalSavingsIDR = totalIDR;
       });
       return;
     }

     try {
       final converted = _currencyService.convert(_fromCurrency, targetCurrency, totalIDR);
       setState(() {
         _convertedTotalSavings = converted;
         _totalSavingsIDR = totalIDR;
       });
     } on CurrencyServiceException catch (e) {
       setState(() {
         _statusMessage = 'Error konversi total: ${e.message}';
         _convertedTotalSavings = totalIDR; 
       });
     }
  }

  // FUNGSI KONVERSI INPUT AMOUNT
  void _updateInputConversion() {
    if (_currencyService.getRates().isEmpty) {
      setState(() {
        _convertedInputAmount = 0.0;
        _statusMessage = 'Data kurs belum siap.';
      });
      return;
    }
    
    double inputAmount;
    try {
      inputAmount = double.parse(_amountController.text.isEmpty ? '0.0' : _amountController.text);
    } catch (e) {
      setState(() {
        _convertedInputAmount = 0.0;
        _statusMessage = 'Input jumlah harus berupa angka.';
      });
      return;
    }
    
    if (inputAmount == 0.0) {
      setState(() {
        _convertedInputAmount = 0.0;
        _statusMessage = 'Masukkan jumlah tabungan.';
      });
      return;
    }

    if (_targetInputCurrency == _fromCurrency) {
      setState(() {
        _convertedInputAmount = inputAmount;
        _statusMessage = 'Konversi berhasil. Target: $_targetInputCurrency';
      });
      return;
    }
    
    try {
      final convertedInput = _currencyService.convert(
        _fromCurrency, 
        _targetInputCurrency, 
        inputAmount,
      );
      
      setState(() {
        _convertedInputAmount = convertedInput;
        _statusMessage = 'Konversi berhasil. Target: $_targetInputCurrency';
      });
    } on CurrencyServiceException catch (e) {
      setState(() {
        _statusMessage = 'Error konversi input: ${e.message}';
        _convertedInputAmount = 0.0;
      });
    }
  }

  Future<void> _saveTransaction() async {
    double amount;
    try {
      amount = double.parse(_amountController.text);
    } catch (e) {
      setState(() {
        _statusMessage = 'Input jumlah tidak valid.';
      });
      return;
    }
    
    if (amount <= 0) {
      setState(() {
        _statusMessage = 'Jumlah tabungan harus lebih dari 0.';
      });
      return;
    }
    
    // Simpan ke Hive (selalu dalam IDR)
    await _hiveService.addSavings(amount); 
    
    _amountController.clear(); // Bersihkan input
    _updateTotalSavingsConversion(_targetTotalSavingsCurrency); // Perbarui Total Tabungan
    _updateInputConversion(); // Perbarui konversi input (sekarang 0.0)
    
    if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tabungan Rp${NumberFormat.decimalPattern().format(amount)} berhasil disimpan!')),
       );
    }
  }
  
  String _formatCurrencyResult(double amount, String currency) {
    final formatter = NumberFormat.currency(
      locale: 'en_US', 
      symbol: currency == 'IDR' ? 'Rp' : '$currency ', 
      decimalDigits: currency == 'IDR' ? 0 : 4,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 1. App Bar
        AppBar(
          title: const Text('Tabungan Haji/Umroh', style: TextStyle(color: Colors.white),),
          backgroundColor: theme.primaryColor,
        ),
        
        // 2. Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // --- KARTU TOTAL TABUNGAN (Dikonversi) ---
                Card(
                  elevation: 4,
                  color: theme.primaryColor.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Tabungan Dalam:', 
                              style: TextStyle(fontSize: 16, color: Colors.white70)),
                            
                            // DROPDOWN MATA UANG TOTAL TABUNGAN
                            DropdownButton<String>(
                              value: _targetTotalSavingsCurrency,
                              dropdownColor: theme.primaryColor,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              underline: Container(height: 1, color: Colors.white),
                              items: _conversionTargets.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _targetTotalSavingsCurrency = newValue;
                                    _updateTotalSavingsConversion(newValue); // Konversi Total
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          // Menampilkan Total Tabungan yang Dikonversi
                          _formatCurrencyResult(_convertedTotalSavings, _targetTotalSavingsCurrency),
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total dalam Rupiah: ${_formatCurrencyResult(_totalSavingsIDR, 'IDR')}',
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 1. KARTU PEMILIH WAKTU
                Card(
                  elevation: 2,
                  color: theme.colorScheme.surface, // Menggunakan Surface Color yang lebih terang untuk background kartu
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Zona Waktu Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                            
                            // DROPDOWN PEMILIH ZONA WAKTU
                            DropdownButton<String>(
                              value: _selectedTimeZoneId,
                              items: _timeZones.map((zone) {
                                return DropdownMenuItem<String>(
                                  value: zone['zoneId'],
                                  child: Text(zone['name']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedTimeZoneId = newValue;
                                    _updateTimeDisplay(newValue);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // HASIL WAKTU YANG DIBUAT JELAS
                        Text(
                          _currentTime, 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600, 
                            color: theme.colorScheme.tertiary // Warna utama agar kontras
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // 2. INPUT JUMLAH (IDR)
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Nominal yang Ditabung',
                    hintText: 'ex. 100000', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                    suffixText: 'IDR',
                  ),
                  onChanged: (value) {
                    _updateInputConversion();
                  },
                ),

                const SizedBox(height: 20),

                // 3. DROPDOWN PILIH MATA UANG TARGET (UNTUK INPUT)
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Konversi Input Ke Mata Uang:',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _targetInputCurrency,
                      isExpanded: true,
                      items: _conversionTargets.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _targetInputCurrency = newValue;
                            _updateInputConversion(); // Konversi Input
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 4. HASIL KONVERSI INPUT AMOUNT (Khusus Hasil Input)
                Card(
                  elevation: 4,
                  // Menggunakan warna aksen sekunder untuk kontras
                  color: theme.colorScheme.tertiary.withOpacity(0.8), 
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text('Nilai Input dalam $_targetInputCurrency:', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(
                          _formatCurrencyResult(_convertedInputAmount, _targetInputCurrency),
                          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _statusMessage, 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // 5. TOMBOL SIMPAN TRANSAKSI
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveTransaction,
                  icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Memuat Data...' : 'Simpan Transaksi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}