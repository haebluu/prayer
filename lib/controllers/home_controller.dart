import 'package:flutter/material.dart';
import 'package:prayer/services/api_service.dart';
// Perhatian: Pastikan path import ini benar di proyek Anda
import '../models/doa_model.dart';

class HomeController extends ChangeNotifier {
  // Ganti 'ApiService' dengan 'DoaApiService' jika itu nama file service Anda
  final DoaApiService _doaApiService = DoaApiService(); 
  List<DoaModel> _allDoa = [];
  List<DoaModel> _filteredDoa = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<DoaModel> get filteredDoa => _filteredDoa;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  HomeController() {
    fetchDoaData();
  }

  Future<void> fetchDoaData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // PERBAIKAN SINTAKSIS DI SINI: Hapus tanda kurung yang tidak perlu
      // Ganti getAllDoa() menjadi fetchAllDoa() sesuai panduan sebelumnya.
      _allDoa = await _doaApiService.getAllDoa();
      _filteredDoa = _allDoa;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchDoa(String query) {
    if (query.isEmpty) {
      _filteredDoa = _allDoa;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredDoa = _allDoa.where((doa) {
        // Menggunakan field 'nama' dan 'idn' dari DoaModel yang diperbarui
        return doa.nama.toLowerCase().contains(lowerQuery) ||
               doa.idn.toLowerCase().contains(lowerQuery); 
      }).toList();
    }
    notifyListeners();
  }
}