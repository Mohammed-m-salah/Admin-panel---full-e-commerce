class OrderItemModel {
  final String? id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double total;

  OrderItemModel({
    this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      productImage: map['product_image'],
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class OrderModel {
  final String? id;
  final String orderNumber;
  final String? customerId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerAvatar;
  final List<OrderItemModel> items;
  final double subtotal;
  final double? discount;
  final double? shippingFee;
  final double? tax;
  final double total;
  final String status; // pending, processing, shipped, delivered, cancelled, refunded
  final String paymentStatus; // pending, paid, failed, refunded
  final String? paymentMethod; // cash, card, online
  final String? shippingAddress;
  final String? billingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    required this.orderNumber,
    this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerAvatar,
    required this.items,
    required this.subtotal,
    this.discount,
    this.shippingFee,
    this.tax,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.shippingAddress,
    this.billingAddress,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      orderNumber: map['order_number'] ?? '',
      customerId: map['customer_id'],
      customerName: map['customer_name'] ?? '',
      customerEmail: map['customer_email'],
      customerPhone: map['customer_phone'],
      customerAvatar: map['customer_avatar'],
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: map['discount']?.toDouble(),
      shippingFee: map['shipping_fee']?.toDouble(),
      tax: map['tax']?.toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['payment_status'] ?? 'pending',
      paymentMethod: map['payment_method'],
      shippingAddress: map['shipping_address'],
      billingAddress: map['billing_address'],
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'customer_avatar': customerAvatar,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shipping_fee': shippingFee,
      'tax': tax,
      'total': total,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  String get formattedTime =>
      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  bool get isPaid => paymentStatus == 'paid';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAvatar,
    List<OrderItemModel>? items,
    double? subtotal,
    double? discount,
    double? shippingFee,
    double? tax,
    double? total,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? shippingAddress,
    String? billingAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
