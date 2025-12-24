import 'package:core_dashboard/pages/authentication/logic/cubit/auth_state.dart';
import 'package:core_dashboard/pages/authentication/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<myAuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // الدخول
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final admin = await _repository.login(email, password);
      emit(Authenticated(admin));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // فحص الحالة عند فتح التطبيق
  Future<void> checkStatus() async {
    try {
      final admin = await _repository.getCurrentAdmin();
      if (admin != null) {
        emit(Authenticated(admin));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  // الخروج
  Future<void> logout() async {
    await _repository.logout();
    emit(Unauthenticated());
  }
}
