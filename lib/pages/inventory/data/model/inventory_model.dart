import 'package:intl/intl.dart';

class InventoryModel {
  final String? id;
  final String productId;
  final String productName;
  final String? productImage;
  final String? sku;
  final String? category;
  final int quantity;
  final int minStockLevel;
  final double unitPrice;
  final DateTime? lastUpdated;

  InventoryModel({
    this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.sku,
    this.category,
    required this.quantity,
    this.minStockLevel = 10,
    this.unitPrice = 0.0,
    this.lastUpdated,
  });

  // Stock status
  String get stockStatus {
    if (quantity <= 0) return 'out_of_stock';
    if (quantity <= minStockLevel) return 'low_stock';
    return 'in_stock';
  }

  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= minStockLevel;
  bool get isInStock => quantity > minStockLevel;

  String get stockStatusLabel {
    switch (stockStatus) {
      case 'out_of_stock':
        return 'Out of Stock';
      case 'low_stock':
        return 'Low Stock';
      default:
        return 'In Stock';
    }
  }

  String get formattedPrice => '\$${unitPrice.toStringAsFixed(2)}';

  double get stockValue => quantity * unitPrice;
  String get formattedStockValue => '\$${stockValue.toStringAsFixed(2)}';

  String get formattedLastUpdated {
    if (lastUpdated == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(lastUpdated!);
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id']?.toString(),
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      sku: json['sku'],
      category: json['category'],
      quantity: json['quantity'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 10,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'sku': sku,
      'category': category,
      'quantity': quantity,
      'min_stock_level': minStockLevel,
      'unit_price': unitPrice,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  InventoryModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    String? sku,
    String? category,
    int? quantity,
    int? minStockLevel,
    double? unitPrice,
    DateTime? lastUpdated,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unitPrice: unitPrice ?? this.unitPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Stock Movement Model for tracking inventory changes
class StockMovementModel {
  final String? id;
  final String productId;
  final String productName;
  final String movementType; // 'in', 'out', 'adjustment'
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? reason;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  StockMovementModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reason,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });

  String get movementTypeLabel {
    switch (movementType) {
      case 'in':
        return 'Stock In';
      case 'out':
        return 'Stock Out';
      case 'adjustment':
        return 'Adjustment';
      default:
        return movementType;
    }
  }

  String get formattedDate =>
      DateFormat('MMM dd, yyyy HH:mm').format(createdAt);

  String get quantityChange {
    if (movementType == 'in') return '+$quantity';
    if (movementType == 'out') return '-$quantity';
    return quantity >= 0 ? '+$quantity' : '$quantity';
  }

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id']?.toString(),
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      movementType: json['movement_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      previousStock: json['previous_stock'] ?? 0,
      newStock: json['new_stock'] ?? 0,
      reason: json['reason'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'movement_type': movementType,
      'quantity': quantity,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'reason': reason,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
