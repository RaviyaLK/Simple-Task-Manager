import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import '../storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final baseUrlProvider = Provider<String>((_) => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080'));

final dioProvider = Provider<Dio>((ref) {
  final base = ref.watch(baseUrlProvider);
  final dio = Dio(BaseOptions(
    baseUrl: base,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.addAll([
    LogInterceptor(requestBody: true, responseBody: true),
    AuthInterceptor(SecureStore(), ref),
  ]);
  return dio;
});

String mapDioError(Object e) {
  if (e is DioException) {
    return e.response?.data is Map && (e.response?.data['message'] != null)
        ? e.response?.data['message'] as String
        : e.message ?? 'Network error';
  }
  return 'Unexpected error';
}
