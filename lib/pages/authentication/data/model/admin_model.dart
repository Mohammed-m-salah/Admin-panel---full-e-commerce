class AdminModel {
  final String id;
  final String email;
  final String name;
  final String? avatar_url;
  final bool role; // سنبقيها bool ولكن سنغير طريقة القراءة في الـ factory

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar_url,
    required this.role,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'Admin',
      avatar_url: map['avatar_url'],

      // التعديل هنا حل مشكلة النوع (Type Error)
      // نتحقق: إذا كان النص القادم هو 'admin' نجعل القيمة true
      role: map['role'] is bool ? map['role'] : (map['role'] == 'admin'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatar_url,
      'role':
          role ? 'admin' : 'user', // تحويلها لنص عند الإرسال لقاعدة البيانات
    };
  }
}
