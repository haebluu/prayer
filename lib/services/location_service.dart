

import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _timezoneApiUrl = 'http://api.timezonedb.com/v2.1/get-time-zone';
  
  static const String _timezoneApiKey = 'YOUR_TIMEZONEDB_API_KEY'; 

  LocationService() {
    tzdata.initializeTimeZones();
  }

  Future<Position> getCurrentLocation() async {
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getTimeZoneFromCoordinates(double lat, double lon) async {

    try {
      final url = '$_timezoneApiUrl?key=$_timezoneApiKey&format=json&by=position&lat=$lat&lng=$lon';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['zoneName'] != null) {
          return data['zoneName']; 
        }
      }
      return 'Asia/Jakarta'; 
    } catch (e) {
      return 'Asia/Jakarta'; 
    }
  }

  String getLocalTime(String timeZoneId) {
    try {
      final location = tz.getLocation(timeZoneId);
      final now = tz.TZDateTime.now(location);
      return now.toString().split('.')[0]; 
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