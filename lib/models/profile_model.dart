class ProfileModel {
  final String id;
  final String authUserId;
  final String namaLengkap;
  final String? noHp;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.authUserId,
    required this.namaLengkap,
    this.noHp,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isKelurahan => role == 'kelurahan';
  bool get isPengelola => role == 'pengelola';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      authUserId: json['auth_user_id'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      noHp: json['no_hp'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'nama_lengkap': namaLengkap,
      'no_hp': noHp,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? namaLengkap,
    String? noHp,
  }) {
    return ProfileModel(
      id: id,
      authUserId: authUserId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noHp: noHp ?? this.noHp,
      role: role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
