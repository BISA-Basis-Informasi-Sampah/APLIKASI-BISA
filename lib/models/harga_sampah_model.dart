import 'kategori_model.dart';
import 'sub_kategori_model.dart';
import 'jenis_sampah_model.dart';
import 'satuan_model.dart';
import 'tipe_sampah_model.dart';

class HargaSampahModel {
  final String id;
  final String bankSampahId;
  final String? kategoriId;
  final String? subKategoriId;
  final String? tipeId;
  final String? jenisSampahId;
  final double hargaPerSatuan;
  final String satuanId;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final TipeSampahModel? tipe;
  final JenisSampahModel? jenisSampah;
  final SatuanModel? satuan;

  const HargaSampahModel({
    required this.id,
    required this.bankSampahId,
    this.kategoriId,
    this.subKategoriId,
    this.tipeId,
    this.jenisSampahId,
    required this.hargaPerSatuan,
    required this.satuanId,
    required this.updatedAt,
    this.kategori,
    this.subKategori,
    this.tipe,
    this.jenisSampah,
    this.satuan,
  });

  // Label nama item berdasarkan level yang tersedia
  String get namaItem {
    if (jenisSampah != null) return jenisSampah!.nama;
    if (tipe != null) return tipe!.nama;
    if (subKategori != null) return subKategori!.nama;
    if (kategori != null) return kategori!.nama;
    return '-';
  }

  String get breadcrumb {
  final parts = <String>[];
  if (kategori != null) parts.add(kategori!.nama);
  if (subKategori != null) parts.add(subKategori!.nama);
  if (tipe != null) parts.add(tipe!.nama);
  if (jenisSampah != null) parts.add(jenisSampah!.nama);
  return parts.join(' > ');
}

  String get levelLabel {
    if (jenisSampahId != null) return 'Jenis';
    if (tipeId != null) return 'Tipe';
    if (subKategoriId != null) return 'Sub Kategori';
    return 'Kategori';
  }

  factory HargaSampahModel.fromJson(Map<String, dynamic> json) {
    return HargaSampahModel(
      id: json['id'] as String,
      bankSampahId: json['bank_sampah_id'] as String,
      kategoriId: json['kategori_id'] as String?,
      subKategoriId: json['sub_kategori_id'] as String?,
      tipeId: json['tipe_id'] as String?,
      jenisSampahId: json['jenis_sampah_id'] as String?,
      hargaPerSatuan: (json['harga_per_satuan'] as num).toDouble(),
      satuanId: json['satuan_id'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      kategori: json['kategori_sampah'] != null
          ? KategoriModel.fromJson(
              json['kategori_sampah'] as Map<String, dynamic>)
          : null,
      subKategori: json['sub_kategori_sampah'] != null
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
      tipe: json['tipe_sampah'] != null
          ? TipeSampahModel.fromJson(
              json['tipe_sampah'] as Map<String, dynamic>)
          : null,
      jenisSampah: json['jenis_sampah'] != null
          ? JenisSampahModel.fromJson(
              json['jenis_sampah'] as Map<String, dynamic>)
          : null,
      satuan: json['satuan'] != null
          ? SatuanModel.fromJson(json['satuan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_sampah_id': bankSampahId,
        'kategori_id': kategoriId,
        'sub_kategori_id': subKategoriId,
        'tipe_id': tipeId,
        'jenis_sampah_id': jenisSampahId,
        'harga_per_satuan': hargaPerSatuan,
        'satuan_id': satuanId,
      };
}