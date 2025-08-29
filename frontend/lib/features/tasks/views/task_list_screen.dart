import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/theme/theme_extensions.dart';
import 'package:flutter_task_manager/features/tasks/models/task_model.dart';
import 'package:go_router/go_router.dart';
import '../controllers/task_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class TaskListScreen extends ConsumerWidget {
  static const String path = '/tasks';
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return Center(
                child: Text('No tasks yet', style: context.bodyMedium));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = list[i];
              return ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.description),
                  leading: Checkbox(
                    value: t.isDone,
                    onChanged: (_) =>
                        ref.read(taskListProvider.notifier).toggle(t),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.go('/tasks/${t.id}/edit', extra: t),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            ref.read(taskListProvider.notifier).remove(t.id),
                      ),
                    ],
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/tasks/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
