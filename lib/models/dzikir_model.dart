class DzikirModel {
  final String id;
  final String arab;
  final String indo;
  final String type;
  final String ulang;

  DzikirModel({
    required this.id,
    required this.arab,
    required this.indo,
    required this.type,
    required this.ulang,
  });

  factory DzikirModel.fromJson(Map<String, dynamic> json) {
    return DzikirModel(
      id: json['_id'] ?? '',
      arab: json['arab'] ?? 'Teks Arab tidak tersedia',
      indo: json['indo'] ?? 'Terjemahan tidak tersedia',
      type: json['type'] ?? 'umum',
      ulang: json['ulang'] ?? '1x',
    );
  }
}