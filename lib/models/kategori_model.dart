class KategoriModel {
  final String id;
  final String nama;
  final String? deskripsi;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KategoriModel({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'deskripsi': deskripsi,
        'is_active': isActive,
      };
}