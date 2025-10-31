

import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  
  // URL untuk mendapatkan TimeZone dari koordinat (contoh menggunakan TimeZoneDB)
  // Catatan: Biasanya memerlukan API key, namun kita akan gunakan metode umum
  static const String _timezoneApiUrl = 'http://api.timezonedb.com/v2.1/get-time-zone';
  
  // API key TimeZoneDB (ganti dengan key Anda)
  static const String _timezoneApiKey = 'YOUR_TIMEZONEDB_API_KEY'; 

  LocationService() {
    tzdata.initializeTimeZones();
  }

  Future<Position> getCurrentLocation() async {
    // Cek dan minta izin lokasi
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan GPS dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen.');
    }

    // Ambil posisi dengan akurasi tinggi
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getTimeZoneFromCoordinates(double lat, double lon) async {
    // Karena mendapatkan TimeZone ID dari Lat/Long secara akurat memerlukan API Geocoding/Timezone,
    // kita akan menggunakan fallback atau API eksternal.

    // Untuk demo, kita asumsikan UTC, tetapi di produksi, gunakan TimeZone API:
    // Contoh: Mencoba API TimeZoneDB
    try {
      final url = '$_timezoneApiUrl?key=$_timezoneApiKey&format=json&by=position&lat=$lat&lng=$lon';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['zoneName'] != null) {
          // Mengembalikan TimeZone ID (misalnya 'Asia/Jakarta')
          return data['zoneName']; 
        }
      }
      // Fallback jika API gagal atau tidak ada key
      return 'Asia/Jakarta'; 
    } catch (e) {
      return 'Asia/Jakarta'; // Fallback umum untuk Indonesia
    }
  }

  String getLocalTime(String timeZoneId) {
    try {
      final location = tz.getLocation(timeZoneId);
      final now = tz.TZDateTime.now(location);
      return now.toString().split('.')[0]; // Format waktu yang lebih rapi
    } catch (e) {
      return 'Waktu Tidak Dikenal: $e';
    }
  }
}


class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}