import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

import '../features/todo/data/repositories/isar_category_repository.dart';
import '../features/todo/data/repositories/isar_task_repository.dart';
import '../features/todo/domain/use_cases/complete_task_use_case.dart';
import '../features/todo/domain/use_cases/create_category_use_case.dart';
import '../features/todo/domain/use_cases/create_task_use_case.dart';
import '../features/todo/domain/use_cases/delete_category_use_case.dart';
import '../features/todo/domain/use_cases/delete_task_use_case.dart';
import '../features/todo/domain/use_cases/edit_task_use_case.dart';
import '../features/todo/domain/use_cases/get_all_categories_use_case.dart';
import '../features/todo/domain/use_cases/get_all_tasks_use_case.dart';
import '../features/todo/domain/use_cases/rename_category_use_case.dart';
import '../features/todo/domain/use_cases/reopen_task_use_case.dart';
import '../features/todo/presentation/controllers/todo_controller.dart';
import 'router.dart';

/// The root widget of the Focus Flow application.
class FocusFlowApp extends StatelessWidget {
  /// Creates a [FocusFlowApp] with the given [Isar] instance.
  const FocusFlowApp({super.key, required this.isar});

  /// The Isar database instance used throughout the application.
  final Isar isar;

  @override
  Widget build(BuildContext context) {
    final taskRepository = IsarTaskRepository(isar: isar);
    final categoryRepository = IsarCategoryRepository(isar: isar);

    return ChangeNotifierProvider<TodoController>(
      create: (_) => TodoController(
        getAllTasksUseCase: GetAllTasksUseCase(taskRepository: taskRepository),
        getAllCategoriesUseCase: GetAllCategoriesUseCase(
          categoryRepository: categoryRepository,
        ),
        createTaskUseCase: CreateTaskUseCase(taskRepository: taskRepository),
        editTaskUseCase: EditTaskUseCase(taskRepository: taskRepository),
        deleteTaskUseCase: DeleteTaskUseCase(taskRepository: taskRepository),
        completeTaskUseCase: CompleteTaskUseCase(
          taskRepository: taskRepository,
        ),
        reopenTaskUseCase: ReopenTaskUseCase(taskRepository: taskRepository),
        createCategoryUseCase: CreateCategoryUseCase(
          categoryRepository: categoryRepository,
        ),
        renameCategoryUseCase: RenameCategoryUseCase(
          categoryRepository: categoryRepository,
        ),
        deleteCategoryUseCase: DeleteCategoryUseCase(
          categoryRepository: categoryRepository,
        ),
      )..init(),
      child: MaterialApp(
        title: 'Focus Flow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        initialRoute: Routes.todo,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
