class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.permissions,
    required this.createdAt,
    this.lastLogin,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 'inactive',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastLogin: json['lastLogin'] != null ? DateTime.tryParse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

class StaffRole {
  final String value;
  final String label;

  const StaffRole({
    required this.value,
    required this.label,
  });
}

class StaffPermission {
  final String value;
  final String label;

  const StaffPermission({
    required this.value,
    required this.label,
  });
}

class StaffCreateRequest {
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> permissions;

  const StaffCreateRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'permissions': permissions,
      'hotelId': '', // Will be set by the service
    };
  }
}

class StaffData {
  final List<StaffMember> staff;
  final int totalCount;
  final int activeCount;
  final int inactiveCount;

  const StaffData({
    required this.staff,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
  });

  factory StaffData.fromJson(Map<String, dynamic> json) {
    final staffList = (json['data'] as List<dynamic>? ?? [])
        .map((item) => StaffMember.fromJson(item))
        .toList();

    return StaffData(
      staff: staffList,
      totalCount: staffList.length,
      activeCount: staffList.where((member) => member.status == 'active').length,
      inactiveCount: staffList.where((member) => member.status == 'inactive').length,
    );
  }
}

class StaffConstants {
  static const List<StaffRole> roleOptions = [
    StaffRole(value: 'front_desk', label: 'Front Desk'),
    StaffRole(value: 'housekeeper', label: 'Housekeeper'),
    StaffRole(value: 'restaurant_manager', label: 'Restaurant Manager'),
    StaffRole(value: 'spa_manager', label: 'Spa Manager'),
    StaffRole(value: 'hotel_owner', label: 'Hotel Owner'),
    StaffRole(value: 'admin', label: 'Admin'),
  ];

  static const List<StaffPermission> permissionOptions = [
    StaffPermission(value: 'clean_rooms', label: 'Clean Rooms'),
    StaffPermission(value: 'manage_bookings', label: 'Manage Bookings'),
    StaffPermission(value: 'view_reports', label: 'View Reports'),
    StaffPermission(value: 'manage_inventory', label: 'Manage Inventory'),
    StaffPermission(value: 'handle_payments', label: 'Handle Payments'),
    StaffPermission(value: 'customer_service', label: 'Customer Service'),
  ];

  static String getRoleLabel(String value) {
    final role = roleOptions.firstWhere(
      (role) => role.value == value,
      orElse: () => StaffRole(value: value, label: value),
    );
    return role.label;
  }

  static String getPermissionLabel(String value) {
    final permission = permissionOptions.firstWhere(
      (permission) => permission.value == value,
      orElse: () => StaffPermission(value: value, label: value),
    );
    return permission.label;
  }
}
