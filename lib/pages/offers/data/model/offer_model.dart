class OfferModel {
  final String? id;
  final String title;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? minimumPurchase;
  final double? maximumDiscount;
  final String? code;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int? usedCount;
  final String? status; // 'active', 'inactive', 'expired', 'scheduled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OfferModel({
    this.id,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minimumPurchase,
    this.maximumDiscount,
    this.code,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usedCount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      discountType: map['discount_type'] ?? 'percentage',
      discountValue: (map['discount_value'] ?? 0).toDouble(),
      minimumPurchase: map['minimum_purchase']?.toDouble(),
      maximumDiscount: map['maximum_discount']?.toDouble(),
      code: map['code'],
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : DateTime.now().add(const Duration(days: 30)),
      usageLimit: map['usage_limit'],
      usedCount: map['used_count'],
      status: map['status'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'minimum_purchase': minimumPurchase,
      'maximum_discount': maximumDiscount,
      'code': code,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'status': status,
    };
  }

  // Helper to check if offer is currently active
  bool get isActive {
    final now = DateTime.now();
    return status?.toLowerCase() == 'active' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  // Helper to get formatted discount
  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return '\$${discountValue.toStringAsFixed(2)}';
    }
  }
}
