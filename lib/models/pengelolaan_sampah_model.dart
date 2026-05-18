import 'kategori_model.dart';
import 'sub_kategori_model.dart';
import 'jenis_sampah_model.dart';
import 'satuan_model.dart';
import 'profile_model.dart';
import 'bank_sampah_model.dart';

class PengelolaanSampahModel {
  final String id;
  final String bankSampahId;
  final String profileId;
  final String kategoriId;
  final String? subKategoriId;
  final String? jenisSampahId;
  final double jumlah;
  final String satuanId;
  final double? hargaPerSatuan;
  final double? totalHarga;
  final DateTime tanggalPengelolaan;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, ada bila di-join)
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final JenisSampahModel? jenisSampah;
  final SatuanModel? satuan;
  final ProfileModel? profile;
  final BankSampahModel? bankSampah;

  const PengelolaanSampahModel({
    required this.id,
    required this.bankSampahId,
    required this.profileId,
    required this.kategoriId,
    this.subKategoriId,
    this.jenisSampahId,
    required this.jumlah,
    required this.satuanId,
    this.hargaPerSatuan,
    this.totalHarga,
    required this.tanggalPengelolaan,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.kategori,
    this.subKategori,
    this.jenisSampah,
    this.satuan,
    this.profile,
    this.bankSampah,
  });

  // Label nama item berdasarkan level yang diisi
  String get namaItem {
    if (jenisSampah != null) return jenisSampah!.nama;
    if (subKategori != null) return subKategori!.nama;
    if (kategori != null) return kategori!.nama;
    return '-';
  }

  // Breadcrumb: Anorganik > Plastik > PP
  String get breadcrumb {
    final parts = <String>[];
    if (kategori != null) parts.add(kategori!.nama);
    if (subKategori != null) parts.add(subKategori!.nama);
    if (jenisSampah != null) parts.add(jenisSampah!.nama);
    return parts.join(' > ');
  }

  factory PengelolaanSampahModel.fromJson(Map<String, dynamic> json) {
    return PengelolaanSampahModel(
      id: json['id'] as String,
      bankSampahId: json['bank_sampah_id'] as String,
      profileId: json['profile_id'] as String,
      kategoriId: json['kategori_id'] as String,
      subKategoriId: json['sub_kategori_id'] as String?,
      jenisSampahId: json['jenis_sampah_id'] as String?,
      jumlah: (json['jumlah'] as num).toDouble(),
      satuanId: json['satuan_id'] as String,
      hargaPerSatuan: json['harga_per_satuan'] != null
          ? (json['harga_per_satuan'] as num).toDouble()
          : null,
      totalHarga: json['total_harga'] != null
          ? (json['total_harga'] as num).toDouble()
          : null,
      tanggalPengelolaan:
          DateTime.parse(json['tanggal_pengelolaan'] as String),
      catatan: json['catatan'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      kategori: json['kategori_sampah'] != null
          ? KategoriModel.fromJson(
              json['kategori_sampah'] as Map<String, dynamic>)
          : null,
      subKategori: json['sub_kategori_sampah'] != null
          ? SubKategoriModel.fromJson(
              json['sub_kategori_sampah'] as Map<String, dynamic>)
          : null,
      jenisSampah: json['jenis_sampah'] != null
          ? JenisSampahModel.fromJson(
              json['jenis_sampah'] as Map<String, dynamic>)
          : null,
      satuan: json['satuan'] != null
          ? SatuanModel.fromJson(json['satuan'] as Map<String, dynamic>)
          : null,
      profile: json['profiles'] != null
          ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      bankSampah: json['bank_sampah'] != null
          ? BankSampahModel.fromJson(
              json['bank_sampah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_sampah_id': bankSampahId,
        'profile_id': profileId,
        'kategori_id': kategoriId,
        'sub_kategori_id': subKategoriId,
        'jenis_sampah_id': jenisSampahId,
        'jumlah': jumlah,
        'satuan_id': satuanId,
        'harga_per_satuan': hargaPerSatuan,
        'tanggal_pengelolaan':
            tanggalPengelolaan.toIso8601String().split('T').first,
        'catatan': catatan,
      };
}
