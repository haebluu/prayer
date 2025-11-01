// lib/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:prayer/services/api_service.dart';
import 'package:prayer/services/notification_service.dart';
import '../models/doa_model.dart';
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

class HomeController extends ChangeNotifier {
  final DoaApiService _doaApiService = DoaApiService(); 
  
  // --- DATA LISTS ---
  List<DoaModel> _allDoa = [];
  List<DoaModel> _filteredDoa = [];
  List<DzikirModel> _allDzikir = [];
  List<HaditsModel> _allHadits = [];

  // --- STATE LISTS ---
final List<String> _dzikirTypes = ['pagi', 'sore'];
  // --- LOADING STATES ---
  bool _isLoadingDoa = true;
  bool _isLoadingDzikir = true;
  bool _isLoadingHadits = true;
  
  // --- ERROR STATES ---
  String _errorDoa = '';
  String _errorDzikir = '';
  String _errorHadits = '';

  // =======================================================
  // GETTERS
  // =======================================================
  List<DoaModel> get filteredDoa => _filteredDoa;
  List<DzikirModel> get allDzikir => _allDzikir;
  List<HaditsModel> get allHadits => _allHadits;

  List<String> get dzikirTypes => _dzikirTypes; 

  bool get isLoadingDoa => _isLoadingDoa;
  bool get isLoadingDzikir => _isLoadingDzikir;
  bool get isLoadingHadits => _isLoadingHadits;
  
  String get errorDoa => _errorDoa;
  String get errorDzikir => _errorDzikir;
  String get errorHadits => _errorHadits;

  // =======================================================
  // CONSTRUCTOR & INITIALIZATION
  // =======================================================
  HomeController() {
    fetchAllContent();
  }
  
  // =======================================================
  // DATA FETCHING LOGIC
  // =======================================================
  
  // Memuat semua data secara paralel saat controller dibuat
  Future<void> fetchAllContent() async {
    _errorDoa = _errorDzikir = _errorHadits = ''; 
    await Future.wait([
      fetchDoaData(),
      fetchDzikirData(),
      fetchHaditsData(),
    ]);
  }

  Future<void> fetchDoaData() async {
    _isLoadingDoa = true;
    notifyListeners();

    try {
      _allDoa = await _doaApiService.getAllDoa();
      _filteredDoa = _allDoa;
    } catch (e) {
      _errorDoa = e.toString().replaceFirst('Exception: ', 'Error Doa: ');
    } finally {
      _isLoadingDoa = false;
      notifyListeners();
    }
  }

  Future<void> fetchDzikirData() async {
    _isLoadingDzikir = true;
    notifyListeners();

    try {
      _allDzikir = await _doaApiService.getAllDzikir(); 
    } catch (e) {
      _errorDzikir = e.toString().replaceFirst('Exception: ', 'Error Dzikir: ');
    } finally {
      _isLoadingDzikir = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchHaditsData() async {
    _isLoadingHadits = true;
    notifyListeners();

    try {
      _allHadits = await _doaApiService.getAllHadits(); 
    } catch (e) {
      _errorHadits = e.toString().replaceFirst('Exception: ', 'Error Hadis: ');
    } finally {
      _isLoadingHadits = false;
      notifyListeners();
    }
  }

  void setupDzikirNotifications() async {
  await NotificationService.scheduleDailyNotification(
    hour: 5,  // Jam 5 pagi
    minute: 30,
    title: 'Waktunya Dzikir Pagi 🌅',
    body: 'Yuk mulai hari dengan dzikir pagi!',
  );

  await NotificationService.scheduleDailyNotification(
    hour: 17, // Jam 5 sore
    minute: 30,
    title: 'Waktunya Dzikir Sore 🌆',
    body: 'Luangkan waktu sebentar untuk dzikir sore.',
  );
}

  // =======================================================
  // FILTERING LOGIC
  // =======================================================

  // Fungsi: Filter Dzikir berdasarkan Type (Dipanggil oleh HomePage)
  List<DzikirModel> getDzikirByType(String type) {
    // Memastikan filtering case-insensitive
    return _allDzikir.where((d) => d.type.toLowerCase() == type.toLowerCase()).toList();
  }

  void searchDoa(String query) {
    if (query.isEmpty) {
      _filteredDoa = _allDoa;
    } else {
      final lowerQuery = query.toLowerCase();
      // Filter berdasarkan nama dan terjemahan (idn)
      _filteredDoa = _allDoa.where((doa) {
        return doa.nama.toLowerCase().contains(lowerQuery) ||
               doa.idn.toLowerCase().contains(lowerQuery); 
      }).toList();
    }
    notifyListeners();
  }
}