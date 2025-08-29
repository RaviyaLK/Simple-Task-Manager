import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class AuthInterceptor extends Interceptor {
  final SecureStore store;
  final Ref ref;

  AuthInterceptor(this.store, this.ref);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await store.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Clear token and update auth state → triggers GoRouter redirect
      await store.clearToken();
      ref.read(authControllerProvider.notifier).forceLogout();
    }
    super.onError(err, handler);
  }
}
