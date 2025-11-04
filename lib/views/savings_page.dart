import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:prayer/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../services/currency_service.dart';
import '../services/location_service.dart';
import '../services/hive_service.dart';
import '../controllers/user_controller.dart'; 

class SavingsPage extends StatefulWidget {
 const SavingsPage({super.key});

 @override
 State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
 final CurrencyService _currencyService = CurrencyService();
 final HiveService _hiveService = HiveService();
 static final LocationService _locationService = LocationService(); // Warning: Unused field

 final TextEditingController _amountController = TextEditingController();

 static const String _fromCurrency = 'IDR';

 final List<Map<String, String>> _timeZones = const [
  {'name': 'WIB (Jakarta)', 'zoneId': 'Asia/Jakarta'},
  {'name': 'WITA (Makassar)', 'zoneId': 'Asia/Makassar'},
  {'name': 'WIT (Jayapura)', 'zoneId': 'Asia/Jayapura'},
  {'name': 'London (GMT/BST)', 'zoneId': 'Europe/London'},
  {'name': 'Dubai (GST)', 'zoneId': 'Asia/Dubai'},
 ];

 String _selectedTimeZoneId = 'Asia/Jakarta';
 String _targetInputCurrency = '';
 String _targetTotalSavingsCurrency = '';

 double _totalSavingsIDR = 0.0;
 double _convertedTotalSavings = 0.0;
 double _convertedInputAmount = 0.0;

 String _statusMessage = 'Aplikasi siap konversi.';
 bool _isLoading = false;
 String _currentTime = 'N/A';

 late List<String> _conversionTargets;
 String? _currentUserId; // Simpan User ID yang sedang aktif

 @override
 void initState() {
  super.initState();
  tzdata.initializeTimeZones();

  _conversionTargets = CurrencyService.availableCurrencies
    .where((c) => c != _fromCurrency)
    .toList();

  _targetTotalSavingsCurrency =
    _conversionTargets.contains('SAR') ? 'SAR' : _conversionTargets.first;
  _targetInputCurrency =
    _conversionTargets.contains('SAR') ? 'SAR' : _conversionTargets.first;
 }
  
 @override
 void didChangeDependencies() {
  super.didChangeDependencies();
  final userController = context.read<UserController>();
  final newUserId = userController.currentUser?.uid;
    
  // Cek apakah user telah berganti atau ini adalah pemuatan pertama
  if (newUserId != _currentUserId) {
   _currentUserId = newUserId;
   
   // Reset dan muat ulang data untuk user baru
   _totalSavingsIDR = 0.0; 
   _convertedTotalSavings = 0.0;
   _loadInitialData();
  }
 }

 @override
 void dispose() {
  _amountController.dispose();
  super.dispose();
 }

 void _loadInitialData() async {
  // Jika user belum login, jangan lanjutkan
  if (_currentUserId == null || _currentUserId!.isEmpty) {
   setState(() {
    _totalSavingsIDR = 0.0;
   });
   return;
  }
    
  setState(() {
   // Menggunakan fungsi per user yang baru
   _totalSavingsIDR = _hiveService.getUserTotalSavings(_currentUserId!);
  });
  _fetchRates(); // Panggilan yang menyebabkan error, kini didefinisikan
  _updateTimeDisplay(_selectedTimeZoneId); // Panggilan yang menyebabkan error, kini didefinisikan
 }

 // 🛑 FUNGSI YANG HILANG DIKEMBALIKAN: _fetchRates
 Future<void> _fetchRates() async {
  setState(() {
   _isLoading = true;
   _statusMessage = 'Mengambil kurs terbaru...';
  });

  try {
   await _currencyService.fetchRates();
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

 // 🛑 FUNGSI YANG HILANG DIKEMBALIKAN: _updateTimeDisplay
 void _updateTimeDisplay(String zoneId) {
  try {
   final location = tz.getLocation(zoneId);
   final now = tz.TZDateTime.now(location);
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

 void _updateTotalSavingsConversion(String targetCurrency) {
  if (_currencyService.getRates().isEmpty || _currentUserId == null) return;

  // Menggunakan fungsi per user
  final totalIDR = _hiveService.getUserTotalSavings(_currentUserId!);

  if (targetCurrency == _fromCurrency) {
   setState(() {
    _convertedTotalSavings = totalIDR;
    _totalSavingsIDR = totalIDR;
   });
   return;
  }

  try {
   final converted =
     _currencyService.convert(_fromCurrency, targetCurrency, totalIDR);
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

 // 🛑 FUNGSI YANG HILANG DIKEMBALIKAN: _updateInputConversion
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
   inputAmount = double.parse(
     _amountController.text.isEmpty ? '0.0' : _amountController.text);
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
  if (_currentUserId == null || _currentUserId!.isEmpty) {
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Anda harus login untuk menyimpan tabungan.')),
    );
   }
   return;
  }

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

  // Menggunakan fungsi per user
  await _hiveService.addSavingsForUser(_currentUserId!, amount);

  _amountController.clear();
  _updateTotalSavingsConversion(_targetTotalSavingsCurrency);
  _updateInputConversion();

  // Tampilkan notifikasi saat menabung
  final formattedAmount = NumberFormat.currency(
   locale: 'id_ID',
   symbol: 'Rp',
   decimalDigits: 0,
  ).format(amount);

  NotificationService.showInstantNotification(
   id: DateTime.now().millisecondsSinceEpoch % 100000,
   title: '💵 Tabungan Berhasil Disimpan!',
   body:
     'Anda baru saja menabung sejumlah $formattedAmount. Semangat mencapai target!',
  );

  if (context.mounted) {
   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Tabungan $formattedAmount berhasil disimpan!')),
   );
  }
 }

 String _formatCurrencyResult(double amount, String currency) {
  final formatter = NumberFormat.currency(
   locale: 'id_ID',
   symbol: currency == 'IDR' ? 'Rp' : '$currency ',
   decimalDigits: currency == 'IDR' ? 0 : 2,
  );
  return formatter.format(amount);
 }

 @override
 Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Column(
   children: [
    AppBar(
     title: const Text('Tabungan Haji/Umroh'),
     backgroundColor: theme.primaryColor,
    ),
    Expanded(
     child: SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
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
              const Text(
               'Total Tabungan Dalam:',
               style:
                 TextStyle(fontSize: 16, color: Colors.white70),
              ),
              DropdownButton<String>(
               value: _targetTotalSavingsCurrency,
               dropdownColor: theme.primaryColor,
               style: const TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.bold),
               icon: const Icon(Icons.arrow_drop_down,
                 color: Colors.white),
               underline:
                 Container(height: 1, color: Colors.white),
               items:
                 _conversionTargets.map((String currency) {
                return DropdownMenuItem<String>(
                 value: currency,
                 child: Text(currency),
                );
               }).toList(),
               onChanged: (String? newValue) {
                if (newValue != null) {
                 setState(() {
                  _targetTotalSavingsCurrency = newValue;
                  _updateTotalSavingsConversion(newValue);
                 });
                }
               },
              ),
             ],
            ),
            const SizedBox(height: 5),
            Text(
             _formatCurrencyResult(_convertedTotalSavings,
               _targetTotalSavingsCurrency),
             style: const TextStyle(
               fontSize: 32,
               color: Colors.white,
               fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
             'Total dalam Rupiah: ${_formatCurrencyResult(_totalSavingsIDR, 'IDR')}',
             style: const TextStyle(
               fontSize: 12, color: Colors.white54),
            ),
           ],
          ),
         ),
        ),
        const SizedBox(height: 20),
        Card(
         elevation: 2,
         color: theme.colorScheme.surface,
         child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
              Text(
               'Zona Waktu Transaksi',
               style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: theme.primaryColor),
              ),
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
            Row(
             children: [
              Icon(Icons.schedule,
                size: 20, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
               _currentTime,
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.w600,
                 color: theme.primaryColor),
              ),
             ],
            ),
           ],
          ),
         ),
        ),
        const SizedBox(height: 20),
        TextField(
         controller: _amountController,
         keyboardType:
           const TextInputType.numberWithOptions(decimal: true),
         decoration: const InputDecoration(
          labelText: 'Nominal yang Ditabung',
          hintText: 'contoh: 100000',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.money),
          suffixText: 'IDR',
         ),
         onChanged: (value) {
          _updateInputConversion();
         },
        ),
        const SizedBox(height: 20),
        InputDecorator(
         decoration: const InputDecoration(
          labelText: 'Konversi Input Ke Mata Uang:',
          border: OutlineInputBorder(),
          contentPadding:
            EdgeInsets.symmetric(horizontal: 10.0),
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
              _updateInputConversion();
             });
            }
           },
          ),
         ),
        ),
        const SizedBox(height: 30),
        Card(
         elevation: 4,
         color: theme.colorScheme.secondary.withOpacity(0.8),
         child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
           children: [
            Text(
             'Nilai Input dalam $_targetInputCurrency:',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: theme.primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
             _formatCurrencyResult(
               _convertedInputAmount, _targetInputCurrency),
             style: TextStyle(
               fontSize: 32,
               color: theme.primaryColor,
               fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
             _statusMessage,
             textAlign: TextAlign.center,
             style: TextStyle(
               color: theme.primaryColor, fontSize: 12),
            ),
           ],
          ),
         ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
         onPressed: _isLoading ? null : _saveTransaction,
         icon: _isLoading
           ? const SizedBox(
             width: 20,
             height: 20,
             child: CircularProgressIndicator(
               color: Colors.white, strokeWidth: 2))
           : const Icon(Icons.save),
         label: Text(
           _isLoading ? 'Memuat Data...' : 'Simpan Transaksi'),
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