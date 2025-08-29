import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/features/auth/views/login_screen.dart';
import 'package:flutter_task_manager/features/auth/views/register_screen.dart';
import 'package:flutter_task_manager/features/shared/splash_screen.dart';
import 'package:flutter_task_manager/features/tasks/models/task_model.dart';
import 'package:flutter_task_manager/features/tasks/views/task_edit_screen.dart';
import 'package:flutter_task_manager/features/tasks/views/task_form_screen.dart';
import 'package:flutter_task_manager/features/tasks/views/task_list_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controllers/auth_controller.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen<bool>(
      authControllerProvider.select((s) => s.isLoggedIn),
      (previous, next) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = GoRouterRefreshNotifier(ref);
  ref.onDispose(() => refreshListenable.dispose());

  return GoRouter(
    initialLocation: SplashScreen.path,
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = ref.read(authControllerProvider).isLoggedIn;
      final loggingIn = state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';

      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggedIn && loggingIn) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(
          path: SplashScreen.path,
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: LoginScreen.path,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: RegisterScreen.path,
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: TaskListScreen.path,
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
              path: TaskFormScreen.path,
              builder: (context, state) => const TaskFormScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (c, s) {
              final task = s.extra as Task;
              return TaskEditPage(task: task);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(TaskListScreen.path),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
