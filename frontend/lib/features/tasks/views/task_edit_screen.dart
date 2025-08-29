import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/features/shared/app_button.dart';
import 'package:flutter_task_manager/features/shared/app_text_field.dart';
import 'package:flutter_task_manager/features/tasks/models/task_model.dart';
import '../controllers/task_controller.dart';

class TaskEditPage extends ConsumerStatefulWidget {
  const TaskEditPage({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _desc = TextEditingController(text: widget.task.description);
  }

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
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
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
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _desc,
                label: 'Description',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save',
                isLoading: loading,
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final updated = widget.task.copyWith(
                    title: _title.text.trim(),
                    description: _desc.text.trim(),
                  );
                  await ref.read(taskListProvider.notifier).update(updated);
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
