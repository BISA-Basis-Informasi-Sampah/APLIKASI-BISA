import 'sub_kategori_model.dart';
import 'satuan_model.dart';

class JenisSampahModel {
  final String id;
  final String subKategoriId;
  final String nama;
  final String? deskripsi;
  final String? satuanDefaultId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final SubKategoriModel? subKategori;
  final SatuanModel? satuanDefault;

  const JenisSampahModel({
    required this.id,
    required this.subKategoriId,
    required this.nama,
    this.deskripsi,
    this.satuanDefaultId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.subKategori,
    this.satuanDefault,
  });

  factory JenisSampahModel.fromJson(Map<String, dynamic> json) {
    return JenisSampahModel(
      id: json['id'] as String,
      subKategoriId: json['sub_kategori_id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      satuanDefaultId: json['satuan_default_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subKategori: json['sub_kategori_sampah'] != null
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
      satuanDefault: json['satuan'] != null
          ? SatuanModel.fromJson(json['satuan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sub_kategori_id': subKategoriId,
        'nama': nama,
        'deskripsi': deskripsi,
        'satuan_default_id': satuanDefaultId,
        'is_active': isActive,
      };
}