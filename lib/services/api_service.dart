// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_model.dart';
import '../models/dzikir_model.dart';
import '../models/hadits_model.dart';

// =========================================================
// Base URL untuk masing-masing sumber API
// =========================================================
const String _muslimApiHost = 'https://muslim-api-three.vercel.app';
const String _doaApiHost = 'https://equran.id/api';

class DoaApiService {
  // =========================================================
  // ✅ 1. FUNGSI DOA (Host: equran.id/api)
  // =========================================================
  Future<List<DoaModel>> getAllDoa() async {
    final response = await http.get(Uri.parse('$_doaApiHost/doa'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Catatan: API equran.id/doa tidak pakai field "data"
      // langsung berupa list
      return data.map((json) => DoaModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data doa. Status: ${response.statusCode}');
    }
  }

  Future<DoaModel> getDoaById(int id) async {
    final response = await http.get(Uri.parse('$_doaApiHost/doa/$id'));

    if (response.statusCode == 200) {
      return DoaModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Doa tidak ditemukan. Status: ${response.statusCode}');
    }
  }

  // =========================================================
  // ✅ 2. FUNGSI DZIKIR (Host: muslim-api-three.vercel.app)
  // =========================================================
  Future<List<DzikirModel>> getAllDzikir({String? type}) async {
    String url = '$_muslimApiHost/v1/dzikir';
    if (type != null && type.isNotEmpty) {
      url += '?type=$type';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => DzikirModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data dzikir. Status: ${response.statusCode}');
    }
  }

  // =========================================================
  // ✅ 3. FUNGSI HADITS (Host: muslim-api-three.vercel.app)
  // =========================================================
  Future<List<HaditsModel>> getAllHadits() async {
    final response = await http.get(Uri.parse('$_muslimApiHost/v1/hadits'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => HaditsModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data hadits. Status: ${response.statusCode}');
    }
  }
}
