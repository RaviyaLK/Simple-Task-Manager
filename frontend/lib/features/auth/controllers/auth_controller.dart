import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/api/dio_client.dart';
import '../models/auth_models.dart';
import '../repository/auth_repository.dart';

class AuthState {
  final AsyncValue<void> status;
  final bool isLoggedIn;
  const AuthState(
      {this.status = const AsyncData(null), this.isLoggedIn = false});

  AuthState copyWith({AsyncValue<void>? status, bool? isLoggedIn}) => AuthState(
        status: status ?? this.status,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      );
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
    (ref) => AuthController(ref));

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(const AuthState()) {
    _bootstrap();
  }

  final Ref ref;

  Future<void> _bootstrap() async {
    final repo = ref.read(authRepositoryProvider);
    final has = await repo.hasToken();
    state = state.copyWith(isLoggedIn: has);
  }

  Future<void> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(status: const AsyncLoading());
    try {
      await repo.login(LoginRequest(email: email, password: password));
      state = state.copyWith(status: const AsyncData(null), isLoggedIn: true);
    } catch (e) {
      state = state.copyWith(
          status: AsyncError(mapDioError(e), StackTrace.current));
    }
  }

  Future<void> register(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    state = state.copyWith(status: const AsyncLoading());
    try {
      await repo.register(RegisterRequest(email: email, password: password));
      state = state.copyWith(status: const AsyncData(null));
    } catch (e) {
      state = state.copyWith(
          status: AsyncError(mapDioError(e), StackTrace.current));
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState(isLoggedIn: false);
  }

  Future<void> forceLogout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState(isLoggedIn: false);
  }
}
