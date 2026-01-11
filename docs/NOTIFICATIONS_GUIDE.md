# دليل إرسال الإشعارات - Notifications Guide

## نظرة عامة على النظام

نظام الإشعارات يتيح لك إرسال إشعارات للمستخدمين بطريقتين:
1. **إرسال لجميع المستخدمين** (All Users)
2. **إرسال لمستخدم محدد** (Specific User)

---

## الملفات المستخدمة

| الملف | الوظيفة |
|-------|---------|
| `notifications_page.dart` | واجهة المستخدم الرئيسية |
| `notification_model.dart` | نموذج البيانات |
| `notification_repository.dart` | التعامل مع Firebase |

---

## الخطوة 1: الوصول لصفحة الإشعارات

عند فتح صفحة الإشعارات، ستجد:

### 1.1 رأس الصفحة (Header)
- زر **"Send Notification"** الأحمر في أعلى اليمين
- يفتح نافذة إرسال إشعار لجميع المستخدمين

### 1.2 الإجراءات السريعة (Quick Actions)
ثلاث بطاقات للوصول السريع:

| البطاقة | الوظيفة |
|---------|---------|
| **Send to All Users** | إرسال إشعار لجميع المستخدمين |
| **Send to Specific User** | إرسال إشعار لمستخدم واحد |
| **Auto Notifications** | إعدادات الإشعارات التلقائية |

---

## الخطوة 2: إرسال إشعار لجميع المستخدمين

### 2.1 فتح نافذة الإرسال
```
اضغط على "Send to All Users" أو زر "Send Notification"
```

### 2.2 ملء النموذج

```dart
// في الكود، يتم استدعاء هذه الدالة:
_showSendNotificationDialog(target: NotificationTarget.allUsers);
```

#### الحقول المطلوبة:

| الحقل | الوصف | مثال |
|-------|-------|------|
| **Notification Title** | عنوان الإشعار | "عرض خاص!" |
| **Notification Body** | محتوى الإشعار | "خصم 50% على جميع المنتجات" |

### 2.3 معاينة الإشعار
- ستظهر معاينة للإشعار كما سيظهر على جهاز المستخدم

### 2.4 الإرسال
- اضغط زر **"Send"**
- سيتم حفظ الإشعار في Firebase

### 2.5 ما يحدث في الخلفية

```dart
// يتم استدعاء هذه الدالة في repository:
await _notificationRepository.sendToAllUsers(
  title: _titleController.text,
  body: _bodyController.text,
  type: NotificationType.custom,
);
```

#### البيانات المحفوظة في Firestore:

```json
{
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "type": "custom",
  "target": "allUsers",
  "data": null,
  "createdAt": "2024-01-15T10:30:00Z",
  "sentCount": 0,
  "readCount": 0,
  "isAutomatic": false
}
```

---

## الخطوة 3: إرسال إشعار لمستخدم محدد

### 3.1 فتح نافذة الإرسال
```
اضغط على "Send to Specific User"
```

### 3.2 اختيار المستخدم

```dart
// في الكود، يتم استدعاء:
_showSendNotificationDialog(target: NotificationTarget.specificUser);
```

#### خطوات اختيار المستخدم:
1. ستظهر قائمة بالمستخدمين
2. يمكنك البحث عن مستخدم معين
3. اضغط على اسم المستخدم لاختياره
4. سيظهر علامة ✓ بجانب المستخدم المختار

### 3.3 ملء النموذج

| الحقل | الوصف |
|-------|-------|
| **Select User** | اختيار المستخدم من القائمة |
| **Notification Title** | عنوان الإشعار |
| **Notification Body** | محتوى الإشعار |

### 3.4 الإرسال

```dart
// يتم استدعاء هذه الدالة:
await _notificationRepository.sendToUser(
  userId: _selectedUserId!,
  userName: _selectedUserName ?? 'User',
  title: _titleController.text,
  body: _bodyController.text,
  type: NotificationType.custom,
);
```

#### البيانات المحفوظة في Firestore:

```json
{
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "type": "custom",
  "target": "specificUser",
  "userId": "user123",
  "userName": "Ahmed Ali",
  "data": null,
  "createdAt": "2024-01-15T10:30:00Z",
  "sentCount": 1,
  "readCount": 0,
  "isAutomatic": false
}
```

---

## الخطوة 4: هيكل قاعدة البيانات (Firestore)

### 4.1 مجموعة الإشعارات (notifications collection)

```
firestore/
└── notifications/
    ├── notification_id_1
    │   ├── title: string
    │   ├── body: string
    │   ├── type: string (newOrder, orderStatusChange, newOffer, etc.)
    │   ├── target: string (allUsers, specificUser)
    │   ├── userId: string? (للمستخدم المحدد فقط)
    │   ├── userName: string? (للمستخدم المحدد فقط)
    │   ├── data: map? (بيانات إضافية)
    │   ├── createdAt: timestamp
    │   ├── sentCount: number
    │   ├── readCount: number
    │   └── isAutomatic: boolean
    └── notification_id_2
        └── ...
```

### 4.2 مجموعة رموز المستخدمين (user_tokens collection)

```
firestore/
└── user_tokens/
    ├── user_id_1
    │   ├── token: string (FCM token)
    │   └── platform: string (mobile, web)
    └── user_id_2
        └── ...
```

---

## الخطوة 5: أنواع الإشعارات

```dart
enum NotificationType {
  newOrder,           // طلب جديد
  orderStatusChange,  // تغيير حالة الطلب
  newOffer,           // عرض جديد
  productBackInStock, // منتج متوفر مجددًا
  newBanner,          // بانر جديد
  custom,             // إشعار مخصص
}
```

---

## الخطوة 6: الإشعارات التلقائية (Auto Notifications)

### 6.1 الإعدادات المتوفرة

| الإشعار | الوصف | الحالة الافتراضية |
|---------|-------|-------------------|
| New Order | عند استلام طلب جديد | مفعل ✓ |
| Order Status Change | عند تغيير حالة الطلب | مفعل ✓ |
| New Offer | عند إضافة عرض جديد | مفعل ✓ |
| Product Back in Stock | عند توفر منتج مجددًا | معطل ✗ |
| New Banner | عند نشر بانر جديد | مفعل ✓ |

### 6.2 تفعيل/تعطيل الإشعارات التلقائية
- انتقل إلى تبويب **"Auto Settings"**
- استخدم زر التبديل (Switch) لتفعيل أو تعطيل كل نوع

---

## الخطوة 7: تتبع الإشعارات

### 7.1 الإحصائيات المتوفرة

| الإحصائية | الوصف |
|-----------|-------|
| **Total Notifications** | إجمالي الإشعارات |
| **Sent Notifications** | عدد المرسلة |
| **Read Notifications** | عدد المقروءة |
| **Read Rate** | نسبة القراءة |

### 7.2 تاريخ الإشعارات
- تبويب **"Notification History"**: جميع الإشعارات
- تبويب **"Sent Notifications"**: الإشعارات المرسلة لجميع المستخدمين

### 7.3 خيارات كل إشعار
- **Resend**: إعادة إرسال الإشعار
- **View Details**: عرض التفاصيل
- **Delete**: حذف الإشعار

---

## الخطوة 8: إرسال Push Notification (اختياري)

لإرسال إشعارات Push فعلية، تحتاج إلى:

### 8.1 إعداد Firebase Cloud Messaging (FCM)

```dart
// في تطبيق الموبايل، يجب حفظ token المستخدم:
await _userTokensCollection.doc(userId).set({
  'token': fcmToken,
  'platform': 'mobile',
});
```

### 8.2 إرسال Push عبر Cloud Functions

```javascript
// Firebase Cloud Function
exports.sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();

    if (notification.target === 'allUsers') {
      // إرسال لجميع المستخدمين
      const tokens = await admin.firestore()
        .collection('user_tokens')
        .get();

      // إرسال FCM
    } else {
      // إرسال لمستخدم محدد
      const userToken = await admin.firestore()
        .collection('user_tokens')
        .doc(notification.userId)
        .get();

      // إرسال FCM
    }
  });
```

---

## ملخص سريع

### إرسال لجميع المستخدمين:
1. اضغط **"Send to All Users"**
2. اكتب العنوان والمحتوى
3. اضغط **"Send"**

### إرسال لمستخدم محدد:
1. اضغط **"Send to Specific User"**
2. اختر المستخدم من القائمة
3. اكتب العنوان والمحتوى
4. اضغط **"Send"**

---

## مسار الملفات

```
lib/
└── pages/
    └── notifications/
        ├── view/
        │   └── notifications_page.dart    // الواجهة الرئيسية
        └── data/
            ├── model/
            │   └── notification_model.dart // نموذج البيانات
            └── repositories/
                └── notification_repository.dart // التعامل مع Firebase
```

---

## نصائح

1. **اختبر الإشعارات** على مستخدم تجريبي أولًا
2. **استخدم عناوين واضحة** وموجزة
3. **لا تكثر من الإشعارات** لتجنب إزعاج المستخدمين
4. **تابع نسبة القراءة** لتحسين محتوى الإشعارات
