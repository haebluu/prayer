import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_model.dart'; 
import '../models/dzikir_model.dart'; 
import '../models/hadits_model.dart'; 

const String _muslimApiHost = 'https://muslim-api-three.vercel.app'; 
const String _doaApiHost = 'https://equran.id/api';
const String _haditsApiHost = 'https://hadith-api-go.vercel.app/api/v1'; 

class DoaApiService {
  
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

  Future<List<DzikirModel>> getAllDzikir({String? type}) async {
    String url = '$_muslimApiHost/v1/dzikir';
    
    final response = await http.get(Uri.parse(url)); 

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> jsonList = responseBody['data'];
      return jsonList.map((json) => DzikirModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data dzikir. Status: ${response.statusCode}');
    }
  }

  Future<List<HaditsModel>> getAllHadits() async {
    const List<String> haditsSlugs = [
      'abu-dawud', 'ahmad', 'bukhari', 'darimi', 
      'ibnu-majah', 'malik', 'muslim', 'nasai', 'tirmidzi'
    ];
    
    const int haditsPerKitab = 99; 

    List<Future<HaditsModel>> fetchTasks = [];

    for (String slug in haditsSlugs) {
      for (int number = 1; number <= haditsPerKitab; number++) { 
        final url = '$_haditsApiHost/hadis/$slug/$number';
        
        fetchTasks.add(
          http.get(Uri.parse(url)).then((response) {
            if (response.statusCode == 200) {
              return HaditsModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>, slug);
            } else {
              return HaditsModel(
                id: '$slug-$number', 
                arab: 'Gagal memuat Hadis $number', 
                indo: 'Koneksi error atau hadis tidak ditemukan.', 
                judul: 'ERROR: ${slug.toUpperCase()} No. $number', 
                no: number.toString(), 
                slug: slug,
              );
            }
          }),
        );
      }
    }
    
    final results = await Future.wait(fetchTasks);
    return results.where((h) => !h.judul.startsWith('ERROR')).toList();
  }
}