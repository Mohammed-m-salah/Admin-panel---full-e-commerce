// ═══════════════════════════════════════════════════════════════════════════════
// Offer Model with Target Support (Product / Category / All)
// ═══════════════════════════════════════════════════════════════════════════════

enum DiscountTarget {
  all,        // All products
  category,   // Specific category
  product,    // Specific product
}

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

  // Target fields
  final DiscountTarget target;
  final String? categoryId;
  final String? categoryName;
  final String? productId;
  final String? productName;

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
    this.target = DiscountTarget.all,
    this.categoryId,
    this.categoryName,
    this.productId,
    this.productName,
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
      target: _parseTarget(map['target']),
      categoryId: map['category_id'],
      categoryName: map['category_name'] ?? map['categories']?['name'],
      productId: map['product_id'],
      productName: map['product_name'] ?? map['products']?['name'],
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
      'target': target.name,
      'category_id': categoryId,
      'product_id': productId,
    };
  }

  static DiscountTarget _parseTarget(String? value) {
    switch (value?.toLowerCase()) {
      case 'category':
        return DiscountTarget.category;
      case 'product':
        return DiscountTarget.product;
      default:
        return DiscountTarget.all;
    }
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

  // Helper to get target display name
  String get targetDisplayName {
    switch (target) {
      case DiscountTarget.all:
        return 'All Products';
      case DiscountTarget.category:
        return categoryName ?? 'Category';
      case DiscountTarget.product:
        return productName ?? 'Product';
    }
  }

  // Helper to get target icon
  String get targetIcon {
    switch (target) {
      case DiscountTarget.all:
        return 'all';
      case DiscountTarget.category:
        return 'category';
      case DiscountTarget.product:
        return 'product';
    }
  }
}
