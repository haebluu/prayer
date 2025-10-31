// lib/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:prayer/services/api_service.dart';
import '../models/doa_model.dart';
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

class HomeController extends ChangeNotifier {
  final DoaApiService _doaApiService = DoaApiService(); 
  
  // Data untuk Doa
  List<DoaModel> _allDoa = [];
  List<DoaModel> _filteredDoa = [];
  
  // Data untuk Dzikir
  List<DzikirModel> _allDzikir = [];
  
  // Data untuk Hadis
  List<HaditsModel> _allHadits = [];

  bool _isLoadingDoa = true;
  bool _isLoadingDzikir = true;
  bool _isLoadingHadits = true;
  
  // Variabel error sekarang menyimpan pesan spesifik per jenis konten
  String _errorDoa = '';
  String _errorDzikir = '';
  String _errorHadits = '';

  List<DoaModel> get filteredDoa => _filteredDoa;
  List<DzikirModel> get allDzikir => _allDzikir;
  List<HaditsModel> get allHadits => _allHadits;

  bool get isLoadingDoa => _isLoadingDoa;
  bool get isLoadingDzikir => _isLoadingDzikir;
  bool get isLoadingHadits => _isLoadingHadits;
  
  // Getter Error yang baru
  String get errorDoa => _errorDoa;
  String get errorDzikir => _errorDzikir;
  String get errorHadits => _errorHadits;

  HomeController() {
    fetchAllContent();
  }
  
  Future<void> fetchAllContent() async {
    // Reset semua error sebelum fetching baru
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
      _errorDoa = e.toString().replaceFirst('Exception: ', 'Error Koneksi: ');
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
      _errorDzikir = e.toString().replaceFirst('Exception: ', 'Error Koneksi: ');
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
      _errorHadits = e.toString().replaceFirst('Exception: ', 'Error Koneksi: ');
    } finally {
      _isLoadingHadits = false;
      notifyListeners();
    }
  }


  void searchDoa(String query) {
    if (query.isEmpty) {
      _filteredDoa = _allDoa;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredDoa = _allDoa.where((doa) {
        return doa.nama.toLowerCase().contains(lowerQuery) ||
               doa.idn.toLowerCase().contains(lowerQuery); 
      }).toList();
    }
    notifyListeners();
  }
}