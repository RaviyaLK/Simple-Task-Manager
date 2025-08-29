import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../models/task_model.dart';

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(dioProvider)));

class TaskRepository {
  TaskRepository(this._dio);
  final Dio _dio;

  Future<List<Task>> fetchAll() async {
    final res = await _dio.get('/tasks');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  Future<Task> create(
      {required String title, required String description}) async {
    final res = await _dio.post('/tasks', data: {
      'title': title,
      'description': description,
    });
    return Task.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Task> update(Task t) async {
    final res = await _dio.put('/tasks/${t.id}', data: t.toJson());
    return Task.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/tasks/$id');
  }
}
