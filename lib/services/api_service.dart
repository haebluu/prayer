import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_model.dart'; 

class DoaApiService {
  final String baseUrl = 'https://equran.id/api';

  Future<List<DoaModel>> getAllDoa() async {
    final response = await http.get(Uri.parse('$baseUrl/doa')); 

    if (response.statusCode == 200) {
      // 1. Decode JSON menjadi Map (karena responsnya adalah objek)
      final Map<String, dynamic> responseBody = jsonDecode(response.body); 
      
      // 2. Akses List<dynamic> di bawah key 'data' (atau key yang benar jika berbeda)
      // Jika key 'data' tidak ada, kode ini akan eror. Kita asumsikan ada.
      final List<dynamic> jsonList = responseBody['data'];
      
      // 3. Konversi List<dynamic> menjadi List<DoaModel>
      return jsonList.map((json) => DoaModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data doa. Status: ${response.statusCode}');
    }
  }
  // Fungsi getDoaById sudah benar untuk mengambil data spesifik, 
  // namun responnya adalah Map (bukan List), jadi sebaiknya dikembalikan sebagai DoaModel
  Future<DoaModel> getDoaById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/doa/$id'));

    if (response.statusCode == 200) {
      // Mengembalikan objek tunggal DoaModel
      return DoaModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Doa tidak ditemukan. Status: ${response.statusCode}');
    }
  }
}