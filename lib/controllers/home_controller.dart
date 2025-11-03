import 'package:flutter/material.dart';
import 'package:prayer/services/api_service.dart';
import '../models/doa_model.dart';
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

class HomeController extends ChangeNotifier {
  final DoaApiService _doaApiService = DoaApiService(); 
  
  List<DoaModel> _allDoa = [];
  List<DoaModel> _filteredDoa = [];
  List<DzikirModel> _allDzikir = [];
  List<HaditsModel> _allHadits = [];
  List<HaditsModel> _filteredHadits = [];

  final List<String> _dzikirTypes = ['pagi', 'sore'];
  bool _isLoadingDoa = true;
  bool _isLoadingDzikir = true;
  bool _isLoadingHadits = true;
  
  String _errorDoa = '';
  String _errorDzikir = '';
  String _errorHadits = '';
  List<DoaModel> get filteredDoa => _filteredDoa;
  List<DzikirModel> get allDzikir => _allDzikir;
  List<HaditsModel> get allHadits => _allHadits;
  List<HaditsModel> get filteredHadits => _filteredHadits;
  List<String> get dzikirTypes => _dzikirTypes; 

  bool get isLoadingDoa => _isLoadingDoa;
  bool get isLoadingDzikir => _isLoadingDzikir;
  bool get isLoadingHadits => _isLoadingHadits;
  
  String get errorDoa => _errorDoa;
  String get errorDzikir => _errorDzikir;
  String get errorHadits => _errorHadits;

  HomeController() {
    fetchAllContent();
  }
  
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
      final fetchedHadits = await _doaApiService.getAllHadits(); 
      _allHadits = fetchedHadits;
      _filteredHadits = fetchedHadits;
    } catch (e) {
      _errorHadits = e.toString().replaceFirst('Exception: ', 'Error Hadis: ');
    } finally {
      _isLoadingHadits = false;
      notifyListeners();
    }
  }

  List<DzikirModel> getDzikirByType(String type) {
    return _allDzikir.where((d) => d.type.toLowerCase() == type.toLowerCase()).toList();
  }

  void searchContent(String query) {
    final lowerQuery = query.toLowerCase();

    _filteredDoa = _allDoa.where((doa) {
      return doa.nama.toLowerCase().contains(lowerQuery) ||
             doa.idn.toLowerCase().contains(lowerQuery);
    }).toList();

    _filteredHadits = _allHadits.where((hadits) {
      final judul = hadits.judul.toLowerCase();
      final indo = hadits.indo.toLowerCase();
      final arab = hadits.arab.toLowerCase();
      final slug = hadits.slug.toLowerCase();
      final no = hadits.no.toString();

      return judul.contains(lowerQuery) ||
             indo.contains(lowerQuery) ||
             arab.contains(lowerQuery) ||
             slug.contains(lowerQuery) ||
             no.contains(lowerQuery);
    }).toList();

    notifyListeners();
  }
}