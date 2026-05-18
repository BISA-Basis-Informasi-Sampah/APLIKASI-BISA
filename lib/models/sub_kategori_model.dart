import 'kategori_model.dart';

class SubKategoriModel {
  final String id;
  final String kategoriId;
  final String nama;
  final String? deskripsi;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final KategoriModel? kategori;

  const SubKategoriModel({
    required this.id,
    required this.kategoriId,
    required this.nama,
    this.deskripsi,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.kategori,
  });

  factory SubKategoriModel.fromJson(Map<String, dynamic> json) {
    return SubKategoriModel(
      id: json['id'] as String,
      kategoriId: json['kategori_id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      kategori: json['kategori_sampah'] != null
          ? KategoriModel.fromJson(
              json['kategori_sampah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'kategori_id': kategoriId,
        'nama': nama,
        'deskripsi': deskripsi,
        'is_active': isActive,
      };
}
