import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/theme/app_theme.dart';
import 'package:flutter_task_manager/core/theme/theme_extensions.dart';
import 'package:flutter_task_manager/features/auth/views/register_screen.dart';
import 'package:flutter_task_manager/features/shared/app_button.dart';
import 'package:flutter_task_manager/features/shared/app_text_field.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbar.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String path = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.status is AsyncError) {
        final msg = (next.status as AsyncError).error.toString();
        showSnack(context, msg);
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(context.space.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text('Welcome to Task Manager', style: context.headingLarge),
                const SizedBox(height: 8),
                Text('Sign in to continue', style: context.bodyMedium),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    AppTextField(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email),
                    const SizedBox(height: 12),
                    AppTextField(
                        controller: _password,
                        label: 'Password',
                        obscure: true,
                        validator: (v) =>
                            Validators.required(v, field: 'Password')),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Login',
                      isLoading: state.status is AsyncLoading,
                      onPressed: () async {
                        if (!(_formKey.currentState?.validate() ?? false))
                          return;
                        await ref
                            .read(authControllerProvider.notifier)
                            .login(_email.text.trim(), _password.text);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(RegisterScreen.path),
                      child: const Text('Create an account'),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
