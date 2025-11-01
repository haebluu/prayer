// lib/models/hadits_model.dart

class HaditsModel {
  final String id;
  final String arab;
  final String indo;
  final String judul;
  final String no;
  final String slug; 

  HaditsModel({
    required this.id,
    required this.arab,
    required this.indo,
    required this.judul,
    required this.no,
    required this.slug,
  });

  factory HaditsModel.fromJson(Map<String, dynamic> json, String slug) {
    // API baru memiliki struktur respons {status, message, data: {number, arab, id}}
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw FormatException("API response data is missing or null.");
    }
    
    final number = data['number']?.toString() ?? 'N/A';
    
    return HaditsModel(
      id: number, 
      arab: data['arab'] ?? 'Teks Arab tidak tersedia',
      indo: data['id'] ?? 'Terjemahan tidak tersedia', // Map 'id' ke 'indo'
      judul: '${slug.toUpperCase()} No. $number', // Judul dibuat dari slug dan nomor
      no: number,
      slug: slug,
    );
  }
}