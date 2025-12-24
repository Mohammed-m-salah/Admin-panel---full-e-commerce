class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String? category;
  final int? stock;
  final double? rating;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.category,
    this.stock,
    this.rating,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// تحويل البيانات القادمة من Supabase (Map) إلى كائن ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // السعر: تحويل آمن لـ double
      price: (json['price'] ?? 0).toDouble(),
      category: json['category']?.toString(),
      // المخزون: تحويل آمن لـ int
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : null,
      // التقييم: تحويل آمن لـ double
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'rating': rating,
      'image_url': imageUrl,
    };
  }
}
