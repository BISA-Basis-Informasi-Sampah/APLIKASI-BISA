import 'sub_kategori_model.dart';

class TipeSampahModel {
  final String id;
  final String subKategoriId;
  final String nama;
  final String? deskripsi;
  final int urutan;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final SubKategoriModel? subKategori;

  const TipeSampahModel({
    required this.id,
    required this.subKategoriId,
    required this.nama,
    this.deskripsi,
    this.urutan = 0,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.subKategori,
  });

  factory TipeSampahModel.fromJson(Map<String, dynamic> json) {
    return TipeSampahModel(
      id: json['id'] as String,
      subKategoriId: json['sub_kategori_id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      urutan: json['urutan'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subKategori: json['sub_kategori_sampah'] != null
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sub_kategori_id': subKategoriId,
        'nama': nama,
        'deskripsi': deskripsi,
        'urutan': urutan,
        'is_active': isActive,
      };
}