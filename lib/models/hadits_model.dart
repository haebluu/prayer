// lib/models/hadits_model.dart
class HaditsModel {
  final String id;
  final String arab;
  final String indo;
  final String judul;
  final String no;

  HaditsModel({
    required this.id,
    required this.arab,
    required this.indo,
    required this.judul,
    required this.no,
  });

  factory HaditsModel.fromJson(Map<String, dynamic> json) {
    return HaditsModel(
      id: json['_id'] ?? '',
      arab: json['arab'] ?? 'Teks Arab tidak tersedia',
      indo: json['indo'] ?? 'Terjemahan tidak tersedia',
      judul: json['judul'] ?? 'Tanpa Judul',
      no: json['no'] ?? 'N/A',
    );
  }
}