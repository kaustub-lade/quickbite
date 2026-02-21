class SavedAddress {
  final String id;
  final String userId;
  final String label; // 'Home', 'Work', 'Other'
  final String? customLabel; // For 'Other' type
  final String address;
  final String? landmark;
  final String city;
  final String pincode;
  final String phone;
  final bool isDefault;
  final DateTime? createdAt;

  SavedAddress({
    required this.id,
    required this.userId,
    required this.label,
    this.customLabel,
    required this.address,
    this.landmark,
    required this.city,
    required this.pincode,
    required this.phone,
    this.isDefault = false,
    this.createdAt,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      customLabel: json['customLabel'] as String?,
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      if (customLabel != null) 'customLabel': customLabel,
      'address': address,
      if (landmark != null) 'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  // Helper to get display label
  String get displayLabel {
    if (label == 'Other' && customLabel != null && customLabel!.isNotEmpty) {
      return customLabel!;
    }
    return label;
  }

  // Helper to get full address string
  String get fullAddress {
    final parts = <String>[
      address,
      if (landmark != null && landmark!.isNotEmpty) landmark!,
      city,
      pincode,
    ];
    return parts.join(', ');
  }

  // Helper to get icon for label
  String get iconForLabel {
    switch (label) {
      case 'Home':
        return '🏠';
      case 'Work':
        return '💼';
      case 'Other':
        return '📍';
      default:
        return '📍';
    }
  }

  // Copy with method for updates
  SavedAddress copyWith({
    String? id,
    String? userId,
    String? label,
    String? customLabel,
    String? address,
    String? landmark,
    String? city,
    String? pincode,
    String? phone,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
