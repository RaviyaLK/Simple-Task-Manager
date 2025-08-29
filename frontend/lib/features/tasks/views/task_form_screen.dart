import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/features/shared/app_button.dart';
import 'package:flutter_task_manager/features/shared/app_text_field.dart';
import '../controllers/task_controller.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  static const String path = 'edit';
  const TaskFormScreen({super.key});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(taskListProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                  controller: _title,
                  label: 'Title',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null),
              const SizedBox(height: 12),
              AppTextField(
                  controller: _desc,
                  label: 'Description',
                  validator: (v) => v == null || v.isEmpty
                      ? 'Description is required'
                      : null),
              const SizedBox(height: 20),
              AppButton(
                label: 'Create',
                isLoading: loading,
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  await ref
                      .read(taskListProvider.notifier)
                      .add(_title.text.trim(), _desc.text.trim());
                  if (mounted) Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
