class SatuanModel {
  final String id;
  final String nama;
  final String singkatan;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SatuanModel({
    required this.id,
    required this.nama,
    required this.singkatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SatuanModel.fromJson(Map<String, dynamic> json) {
    return SatuanModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      singkatan: json['singkatan'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'singkatan': singkatan,
      };

  @override
  String toString() => '$nama ($singkatan)';
}
