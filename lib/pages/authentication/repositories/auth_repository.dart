import 'package:core_dashboard/pages/authentication/data/model/admin_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// تسجيل الدخول مع التحقق من جدول الـ Admins
  Future<AdminModel> login(String email, String password) async {
    try {
      // 1. محاولة تسجيل الدخول في نظام الـ Auth
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("فشل العثور على بيانات المستخدم.");
      }

      // 2. جلب البيانات من جدول admins
      // ملاحظة: إذا ظهر لك خطأ recursion هنا، فالمشكلة من الـ RLS في سوبابيز
      final data = await _client
          .from('admins')
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      // 3. التحقق هل المستخدم مسجل كأدمن؟
      if (data == null) {
        await _client.auth.signOut(); // تسجيل خروج فوري للأمان
        throw Exception("عذراً، هذا الحساب لا يملك صلاحيات لوحة التحكم.");
      }

      // 4. تحويل البيانات للموديل (تأكد من استخدام الموديل المصحح)
      return AdminModel.fromMap(data);
    } on AuthException catch (e) {
      // التعامل مع أخطاء سوبابيز مثل "Invalid login credentials"
      if (e.message.contains("Invalid login credentials")) {
        throw Exception("البريد الإلكتروني أو كلمة المرور غير صحيحة.");
      } else if (e.message.contains("Email not confirmed")) {
        throw Exception("يرجى تأكيد بريدك الإلكتروني أولاً.");
      }
      throw Exception(e.message);
    } catch (e) {
      // التعامل مع أخطاء الـ Model (TypeError) أو الـ Policy
      throw Exception("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  /// فحص الحالة الحالية (عند فتح التطبيق)
  Future<AdminModel?> getCurrentAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data =
          await _client.from('admins').select().eq('id', user.id).maybeSingle();

      return data != null ? AdminModel.fromMap(data) : null;
    } catch (e) {
      print("Error checking status: $e");
      return null;
    }
  }
}
