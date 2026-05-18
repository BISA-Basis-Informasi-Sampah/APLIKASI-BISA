class BankSampahModel {
  final String id;
  final String nama;
  final String? alamat;
  final String? rt;
  final String? rw;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankSampahModel({
    required this.id,
    required this.nama,
    this.alamat,
    this.rt,
    this.rw,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get namaLengkap {
    if (rt != null && rw != null) return '$nama (RT $rt/RW $rw)';
    if (rt != null) return '$nama (RT $rt)';
    return nama;
  }

  factory BankSampahModel.fromJson(Map<String, dynamic> json) {
    return BankSampahModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String?,
      rt: json['rt'] as String?,
      rw: json['rw'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'is_active': isActive,
    };
  }

  BankSampahModel copyWith({
    String? nama,
    String? alamat,
    String? rt,
    String? rw,
    bool? isActive,
  }) {
    return BankSampahModel(
      id: id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
