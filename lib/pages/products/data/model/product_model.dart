class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double? price;
  final String? category;
  final int? stock; // هذا للكمية (رقم)
  final String?
      stockStatus; // تم تغيير النوع هنا إلى String ليتوافق مع "In Stock"
  final double? rating;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    this.price,
    this.category,
    this.stock,
    this.stockStatus, // تحديث هنا
    this.rating,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category']?.toString(),
      // تحويل آمن جداً للمخزون: يحاول التحويل لرقم، وإذا فشل يضع null
      stock:
          json['stock'] != null ? int.tryParse(json['stock'].toString()) : null,
      // قراءة الحالة كنص (String) لمنع خطأ TypeError
      stockStatus: json['stock_status']?.toString(),
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
      'stock_status': stockStatus, // إرسال النص لقاعدة البيانات
      'rating': rating,
      'image_url': imageUrl,
    };
  }
}
