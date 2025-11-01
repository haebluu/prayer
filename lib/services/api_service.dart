// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_model.dart'; 
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

// Base URL untuk Dzikir dan Hadits (muslim-api-three.vercel.app)
const String _muslimApiHost = 'https://muslim-api-three.vercel.app'; 
// Base URL untuk Doa (dikembalikan ke equran.id/api)
const String _doaApiHost = 'https://equran.id/api';

class DoaApiService {
  
  // Fungsi-fungsi Doa (Host: equran.id/api)
  Future<List<DoaModel>> getAllDoa() async {
    final response = await http.get(Uri.parse('$_doaApiHost/doa')); 
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body); 
      // Asumsi: Doa API lama mengembalikan data di bawah key 'data'
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => DoaModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data doa. Status: ${response.statusCode}');
    }
  }
  
  Future<DoaModel> getDoaById(int id) async {
    final response = await http.get(Uri.parse('$_doaApiHost/doa/$id'));

    if (response.statusCode == 200) {
      return DoaModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Doa tidak ditemukan. Status: ${response.statusCode}');
    }
  }

  // FUNGSI DZIKIR (Host: muslim-api-three.vercel.app)
  Future<List<DzikirModel>> getAllDzikir({String? type}) async {
    String url = '$_muslimApiHost/v1/dzikir';
    if (type != null && type.isNotEmpty) {
      url += '?type=$type';
    }
    final response = await http.get(Uri.parse(url)); 

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => DzikirModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data dzikir. Status: ${response.statusCode}');
    }
  }

  // FUNGSI HADITS (Host: muslim-api-three.vercel.app)
  Future<List<HaditsModel>> getAllHadits() async {
    final response = await http.get(Uri.parse('$_muslimApiHost/v1/hadits')); 

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => HaditsModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data hadits. Status: ${response.statusCode}');
    }
  }
}