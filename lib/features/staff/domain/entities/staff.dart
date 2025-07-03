class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String employeeStatus;
  final String? campaignId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.employeeStatus,
    this.campaignId,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear Staff desde JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      employeeStatus: json['employeeStatus']?.toString() ?? '',
      campaignId: json['campaignId']?.toString(),
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'].toString())
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null,
    );
  }

  /// Convertir Staff a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'employeeStatus': employeeStatus,
      if (campaignId != null) 'campaignId': campaignId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Crear copia con modificaciones
  Staff copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? employeeStatus,
    String? campaignId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      campaignId: campaignId ?? this.campaignId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si el staff está activo
  bool get isActive => employeeStatus.toLowerCase() == 'active';

  /// Verificar si el staff está inactivo
  bool get isInactive => employeeStatus.toLowerCase() == 'inactive';

  /// Obtener iniciales del nombre
  String get initials {
    if (name.isEmpty) return '';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Formatear nombre para mostrar
  String get displayName {
    if (name.isEmpty) return 'Sin nombre';
    final words = name.split(' ');
    return words.map((word) => word.isNotEmpty 
      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
      : word
    ).join(' ');
  }

  /// Formatear rol para mostrar
  String get displayRole {
    if (role.isEmpty) return 'Sin rol';
    return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
  }

  /// Formatear estado para mostrar
  String get displayStatus {
    switch (employeeStatus.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Inactivo';
      case 'suspended':
        return 'Suspendido';
      default:
        return employeeStatus;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Staff(id: $id, name: $name, email: $email, role: $role, status: $employeeStatus)';
  }
}
