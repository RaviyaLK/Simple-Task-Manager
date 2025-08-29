import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/theme/theme_extensions.dart';
import 'package:flutter_task_manager/features/auth/views/login_screen.dart';
import 'package:flutter_task_manager/features/shared/app_button.dart';
import 'package:flutter_task_manager/features/shared/app_text_field.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbar.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const String path = '/register';
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterScreen> {
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
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
            onPressed: () => context.go(LoginScreen.path),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(context.space.l),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Create your account', style: context.headingLarge),
                  const SizedBox(height: 24),
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
                    label: 'Register',
                    isLoading: state.status is AsyncLoading,
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      await ref
                          .read(authControllerProvider.notifier)
                          .register(_email.text.trim(), _password.text);
                      if (mounted) {
                        showSnack(
                            context, 'Registration successful. Please login.');
                        context.go(LoginScreen.path);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
