// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_model.dart'; 
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

// Host untuk Dzikir (muslim-api-three.vercel.app) - DIKEMBALIKAN KE API SEBELUMNYA
const String _muslimApiHost = 'https://muslim-api-three.vercel.app'; 
// Host untuk Doa (equran.id/api) - DIKEMBALIKAN KE API SEBELUMNYA
const String _doaApiHost = 'https://equran.id/api';

// HOST BARU UNTUK HADIS
const String _haditsApiHost = 'https://hadith-api-go.vercel.app/api/v1'; 

class DoaApiService {
  
  // FUNGSI DOA (TETAP SAMA SEPERTI SEBELUMNYA)
  Future<List<DoaModel>> getAllDoa() async {
    final response = await http.get(Uri.parse('$_doaApiHost/doa')); 
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body); 
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

  // lib/services/api_service.dart (REVISI FUNGSI getAllDzikir - SEMENTARA UNTUK DEBUG)

// ... (semua kode di atas tetap sama)

  // FUNGSI DZIKIR (TETAP SAMA SEPERTI SEBELUMNYA)
  Future<List<DzikirModel>> getAllDzikir({String? type}) async {
    // KITA HANYA MENGAMBIL SEMUA, DAN BERHARAP SERVER MENGIRIMKAN SEMUA TYPES
    String url = '$_muslimApiHost/v1/dzikir';
    
    // HAPUS QUERY TYPE SEMENTARA, AGAR TIDAK ADA MASALAH KETIDAKSESUAIAN
    // Jika Anda ingin mengambil Dzikir Sholat saja, gunakan: url += '?type=sholat'; 
    
    final response = await http.get(Uri.parse(url)); 

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => DzikirModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data dzikir. Status: ${response.statusCode}');
    }
  }

// ... (sisa kode)

 



  // FUNGSI HADITS (Mengambil Hadis No. 1 dari SETIAP Kitab)
  Future<List<HaditsModel>> getAllHadits() async {
    // Daftar lengkap SLUG (nama kitab) Hadis yang Anda sediakan
    const List<String> haditsSlugs = [
      'abu-dawud', 'ahmad', 'bukhari', 'darimi', 
      'ibnu-majah', 'malik', 'muslim', 'nasai', 'tirmidzi'
    ];
    
    // Kita ambil Hadis Nomor 1 dari setiap kitab sebagai sampel
    const int haditsNumber = 1; 

    List<Future<HaditsModel>> fetchTasks = [];

    for (String slug in haditsSlugs) {
      final url = '$_haditsApiHost/hadis/$slug/$haditsNumber';
      
      fetchTasks.add(
        http.get(Uri.parse(url)).then((response) {
          if (response.statusCode == 200) {
            // Jika sukses, parse data
            return HaditsModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>, slug);
          } else {
            // Jika gagal, log error dan return HaditsModel dummy agar Future.wait tidak terhenti
            print('Gagal memuat Hadis $slug/$haditsNumber. Status: ${response.statusCode}');
            // Return HaditsModel dummy dengan pesan error
            return HaditsModel(
              id: slug, 
              arab: 'Gagal memuat teks Hadis', 
              indo: 'Koneksi error atau hadis tidak ditemukan.', 
              judul: 'ERROR: Kitab ${slug.toUpperCase()}', 
              no: haditsNumber.toString(), 
              slug: slug,
            );
          }
        }),
      );
    }
    
    // Jalankan semua permintaan secara paralel
    return await Future.wait(fetchTasks);
  }
}