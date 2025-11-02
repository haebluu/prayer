import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../services/location_service.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  final LocationService _locationService = LocationService();
  
  String _locationStatus = 'Tekan tombol untuk mendapatkan lokasi...';
  String _currentTime = 'N/A';
  String _latLong = '';
  
  final List<Map<String, String>> _timeZones = [
    {'name': 'WIB (Jakarta)', 'zoneId': 'Asia/Jakarta'},
    {'name': 'WITA (Makassar)', 'zoneId': 'Asia/Makassar'},
    {'name': 'WIT (Jayapura)', 'zoneId': 'Asia/Jayapura'},
    {'name': 'London (GMT/BST)', 'zoneId': 'Europe/London'},
  ];

  Map<String, String> _convertedTimes = {};

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones(); 
  }
  
  Map<String, String> _convertAllTimes(DateTime utcTime) {
    final Map<String, String> results = {};
    for (var zone in _timeZones) {
      try {
        final location = tz.getLocation(zone['zoneId']!);
        final convertedTime = tz.TZDateTime.from(utcTime, location); 
        results[zone['name']!] = convertedTime.toString().split('.')[0]; 
      } catch (e) {
        results[zone['name']!] = 'Error: Zona tidak dikenal';
      }
    }
    return results;
  }

  Future<void> _fetchTimeAndLocation() async {
    setState(() {
      _locationStatus = 'Mencari lokasi (Pastikan GPS aktif)...';
      _convertedTimes = {};
      _currentTime = 'N/A';
    });

    try {
      final position = await _locationService.getCurrentLocation();
      
      final timeZoneId = await _locationService.getTimeZoneFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      final localTime = _locationService.getLocalTime(timeZoneId);
      
      final utcNow = DateTime.now().toUtc();
      
      final converted = _convertAllTimes(utcNow); 

      setState(() {
        _latLong = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
        _locationStatus = 'Lokasi ditemukan di Zona Waktu: $timeZoneId';
        _currentTime = localTime;
        _convertedTimes = converted; 
      });

    } on LocationServiceException catch (e) {
      setState(() {
        _locationStatus = 'Error Lokasi: ${e.message}';
        _currentTime = 'Gagal';
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error Umum: $e';
        _currentTime = 'Gagal';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waktu Lokal & Konversi Zona'),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Waktu Lokal Terdeteksi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _currentTime,
                      style: const TextStyle(fontSize: 30, color:  Color(0xFF008080), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Geolokasi:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(_locationStatus),
                    const SizedBox(height: 5),
                    Text('Koordinat: $_latLong'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: _fetchTimeAndLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Dapatkan Waktu Berdasarkan Lokasi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF008080),
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),

            const Text('Konversi Zona Waktu Spesifik:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            
            if (_convertedTimes.isEmpty && _latLong.isNotEmpty)
              const Center(child: Text('Gagal melakukan konversi waktu')),

            if (_convertedTimes.isNotEmpty)
              ..._convertedTimes.entries.map((entry) => ListTile(
                    leading: const Icon(Icons.schedule, color:  Color(0xFF008080)),
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(entry.value, style: const TextStyle(fontSize: 16)),
                    dense: true,
                  )).toList(),
          ],
        ),
      ),
    );
  }
}