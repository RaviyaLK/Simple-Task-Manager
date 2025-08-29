import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.watch(dioProvider), SecureStore()));

class AuthRepository {
  AuthRepository(this._dio, this._store);
  final Dio _dio;
  final SecureStore _store;

  Future<String> login(LoginRequest req) async {
    final res = await _dio.post('/auth/login', data: req.toJson());
    final payload = AuthPayload.fromJson(res.data as Map<String, dynamic>);
    await _store.saveToken(payload.token);
    return payload.token;
  }

  Future<void> register(RegisterRequest req) async {
    await _dio.post('/auth/register', data: req.toJson());
  }

  Future<void> logout() async {
    await _store.clearToken();
  }

  Future<bool> hasToken() async => (await _store.readToken()) != null;
}
