import 'sub_kategori_model.dart';
import 'satuan_model.dart';
import 'tipe_sampah_model.dart';
import 'kategori_model.dart';

class JenisSampahModel {
  final String id;
  final String? subKategoriId;   // nullable — Organik & Minyak Jelantah tidak punya
  final String? tipeId;          // nullable — Kertas/Logam/Kaca/Organik tidak pakai tipe
  final String? kategoriId;      // diisi langsung untuk Organik & Minyak Jelantah
  final String nama;
  final String? deskripsi;
  final String? satuanDefaultId;
  final int urutan;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final SubKategoriModel? subKategori;
  final TipeSampahModel? tipe;
  final KategoriModel? kategori;
  final SatuanModel? satuanDefault;

  const JenisSampahModel({
    required this.id,
    this.subKategoriId,
    this.tipeId,
    this.kategoriId,
    required this.nama,
    this.deskripsi,
    this.satuanDefaultId,
    this.urutan = 0,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.subKategori,
    this.tipe,
    this.kategori,
    this.satuanDefault,
  });

  factory JenisSampahModel.fromJson(Map<String, dynamic> json) {
    return JenisSampahModel(
      id: json['id'] as String,
      subKategoriId: json['sub_kategori_id'] as String?,
      tipeId: json['tipe_id'] as String?,
      kategoriId: json['kategori_id'] as String?,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String?,
      satuanDefaultId: json['satuan_default_id'] as String?,
      urutan: json['urutan'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subKategori: json['sub_kategori_sampah'] != null
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
      tipe: json['tipe_sampah'] != null
          ? TipeSampahModel.fromJson(
              json['tipe_sampah'] as Map<String, dynamic>)
          : null,
      kategori: json['kategori_sampah'] != null
          ? KategoriModel.fromJson(
              json['kategori_sampah'] as Map<String, dynamic>)
          : null,
      satuanDefault: json['satuan'] != null
          ? SatuanModel.fromJson(json['satuan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sub_kategori_id': subKategoriId,
        'tipe_id': tipeId,
        'kategori_id': kategoriId,
        'nama': nama,
        'deskripsi': deskripsi,
        'satuan_default_id': satuanDefaultId,
        'urutan': urutan,
        'is_active': isActive,
      };
}