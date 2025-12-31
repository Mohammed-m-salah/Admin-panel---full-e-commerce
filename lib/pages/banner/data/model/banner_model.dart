class BannerModel {
  final String? id;
  final String title;
  final String? description;
  final String imageUrl;
  final String linkType; // product, category, offer, external
  final String? linkId;
  final int position;
  final String status; // active, inactive, scheduled
  final DateTime? startDate;
  final DateTime? endDate;
  final int views;
  final int clicks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkType = 'external',
    this.linkId,
    this.position = 0,
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.views = 0,
    this.clicks = 0,
    this.createdAt,
    this.updatedAt,
  });

  // هل البانر نشط حالياً؟
  bool get isActive {
    if (status != 'active') return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // نسبة النقر CTR
  double get ctr => views > 0 ? (clicks / views) * 100 : 0;

  // تحويل من Supabase Map إلى Model
  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['image_url'] ?? '',
      linkType: map['link_type'] ?? 'external',
      linkId: map['link_id'],
      position: map['position'] ?? 0,
      status: map['status'] ?? 'active',
      startDate:
          map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // تحويل من Model إلى Map للإرسال لـ Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link_type': linkType,
      'link_id': linkId,
      'position': position,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  // نسخ مع تعديل
  BannerModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? linkType,
    String? linkId,
    String? externalUrl,
    int? position,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? views,
    int? clicks,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
      position: position ?? this.position,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
