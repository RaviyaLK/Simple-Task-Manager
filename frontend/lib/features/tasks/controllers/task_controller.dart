import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repository/task_repository.dart';
import '../../../core/api/dio_client.dart';
import '../../auth/controllers/auth_controller.dart';

final taskListProvider =
    StateNotifierProvider.autoDispose<TaskController, AsyncValue<List<Task>>>(
  (ref) {
    final controller = TaskController(ref);

    final auth = ref.read(authControllerProvider);
    if (auth.isLoggedIn) {
      controller.load();
    }

    ref.listen(authControllerProvider, (prev, next) {
      if (next.isLoggedIn && !(prev?.isLoggedIn ?? false)) {
        controller.load();
      } else if (!next.isLoggedIn) {
        controller.clear();
      }
    });

    return controller;
  },
);

class TaskController extends StateNotifier<AsyncValue<List<Task>>> {
  TaskController(this.ref) : super(const AsyncLoading());
  final Ref ref;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final tasks = await ref.read(taskRepositoryProvider).fetchAll();
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(mapDioError(e), st).copyWithPrevious(state)
          as AsyncValue<List<Task>>;
    }
  }

  Future<void> update(Task t) async {
    try {
      final saved = await ref.read(taskRepositoryProvider).update(t);
      state = state.whenData((tasks) => [
            for (final x in tasks)
              if (x.id == saved.id) saved else x
          ]);
    } catch (e, st) {
      state = AsyncError(mapDioError(e), st).copyWithPrevious(state)
          as AsyncValue<List<Task>>;
    }
  }

  Future<void> toggle(Task t) async {
    try {
      final updated = t.copyWith(
          status: t.isDone ? TaskStatus.pending : TaskStatus.completed);
      final saved = await ref.read(taskRepositoryProvider).update(updated);
      state = state.whenData((tasks) => [
            for (final x in tasks)
              if (x.id == saved.id) saved else x
          ]);
    } catch (e, st) {
      state = AsyncError(mapDioError(e), st).copyWithPrevious(state)
          as AsyncValue<List<Task>>;
    }
  }

  Future<void> add(String title, String description) async {
    try {
      final created = await ref
          .read(taskRepositoryProvider)
          .create(title: title, description: description);
      state = state.whenData((tasks) => [created, ...tasks]);
    } catch (e, st) {
      state = AsyncError(mapDioError(e), st).copyWithPrevious(state)
          as AsyncValue<List<Task>>;
    }
  }

  Future<void> remove(String id) async {
    try {
      await ref.read(taskRepositoryProvider).delete(id);
      state =
          state.whenData((tasks) => tasks.where((e) => e.id != id).toList());
    } catch (e, st) {
      state = AsyncError(mapDioError(e), st).copyWithPrevious(state)
          as AsyncValue<List<Task>>;
    }
  }

  void clear() {
    state = const AsyncData([]);
  }
}
