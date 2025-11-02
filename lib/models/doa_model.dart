class DoaModel {
  final int id;
  final String grup;
  final String nama; 
  final String ar;   
  final String tr;   
  final String idn;  
  final String tentang; 

  DoaModel({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      id: json['id'] ?? 0,
      grup: json['grup'] ?? 'Tanpa Grup',
      nama: json['nama'] ?? 'Doa Tanpa Judul',
      ar: json['ar'] ?? '',
      tr: json['tr'] ?? '',
      idn: json['idn'] ?? 'Terjemahan tidak tersedia',
      tentang: json['tentang'] ?? 'Keterangan tidak tersedia',
    );
  }
}