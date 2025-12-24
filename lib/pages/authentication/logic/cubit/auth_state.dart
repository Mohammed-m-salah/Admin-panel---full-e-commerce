import 'package:core_dashboard/pages/authentication/data/model/admin_model.dart';

abstract class myAuthState {}

class AuthInitial extends myAuthState {}

class AuthLoading extends myAuthState {}

class Authenticated extends myAuthState {
  final AdminModel admin; // نمرر الـ Model كاملاً هنا
  Authenticated(this.admin);
}

class Unauthenticated extends myAuthState {}

class AuthError extends myAuthState {
  final String message;
  AuthError(this.message);
}
