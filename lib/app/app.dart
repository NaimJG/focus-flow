import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_language_mapper.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_mode_mapper.dart';
import '../features/pomodoro/data/repositories/isar_pomodoro_session_repository.dart';
import '../features/pomodoro/domain/entities/pomodoro_task_option.dart';
import '../features/pomodoro/domain/repositories/pomodoro_session_repository.dart';
import '../features/pomodoro/domain/use_cases/get_task_pomodoro_stats_use_case.dart';
import '../features/pomodoro/domain/use_cases/save_pomodoro_session_use_case.dart';
import '../features/pomodoro/presentation/controllers/pomodoro_controller.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/todo/data/repositories/isar_category_repository.dart';
import '../features/todo/data/repositories/isar_task_repository.dart';
import '../features/todo/domain/entities/task_status.dart';
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
import '../l10n/app_localizations.dart';
import 'mappers/pomodoro_settings_mapper.dart';
import 'router.dart';

/// The root widget of the Focus Flow application.
class FocusFlowApp extends StatelessWidget {
  /// Creates a [FocusFlowApp] with the given [Isar] instance and
  /// [SettingsController].
  const FocusFlowApp({
    super.key,
    required this.isar,
    required this.settingsController,
  });

  /// The Isar database instance used throughout the application.
  final Isar isar;

  /// The application-scoped settings controller, initialized before
  /// runApp.
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final taskRepository = IsarTaskRepository(isar: isar);
    final categoryRepository = IsarCategoryRepository(isar: isar);
    final pomodoroRepository = IsarPomodoroSessionRepository(isar: isar);
    final saveSessionUseCase = SavePomodoroSessionUseCase(pomodoroRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        Provider<PomodoroSessionRepository>.value(value: pomodoroRepository),
        Provider<GetTaskPomodoroStatsUseCase>(
          create: (_) => GetTaskPomodoroStatsUseCase(pomodoroRepository),
        ),
        ChangeNotifierProvider<TodoController>(
          create: (_) => TodoController(
            getAllTasksUseCase: GetAllTasksUseCase(
              taskRepository: taskRepository,
            ),
            getAllCategoriesUseCase: GetAllCategoriesUseCase(
              categoryRepository: categoryRepository,
            ),
            createTaskUseCase: CreateTaskUseCase(
              taskRepository: taskRepository,
            ),
            editTaskUseCase: EditTaskUseCase(taskRepository: taskRepository),
            deleteTaskUseCase: DeleteTaskUseCase(
              taskRepository: taskRepository,
            ),
            completeTaskUseCase: CompleteTaskUseCase(
              taskRepository: taskRepository,
            ),
            reopenTaskUseCase: ReopenTaskUseCase(
              taskRepository: taskRepository,
            ),
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
        ),
        ChangeNotifierProxyProvider2<
          TodoController,
          SettingsController,
          PomodoroController
        >(
          create: (_) => PomodoroController(
            saveSessionUseCase: saveSessionUseCase,
            taskListProvider: () => [],
          )..init(),
          update: (_, todoController, settingsCtrl, pomodoroController) {
            final tasks = todoController.allTasks
                .map(
                  (task) => PomodoroTaskOption(
                    id: task.id,
                    title: task.title,
                    isCompleted: task.status == TaskStatus.completed,
                  ),
                )
                .toList();
            pomodoroController!.updateAvailableTasks(tasks);
            pomodoroController.updateConfig(
              mapSettingsToPomodoroConfig(settingsCtrl.settings),
            );
            return pomodoroController;
          },
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Focus Flow',
          debugShowCheckedModeBanner: false,
          locale: AppLanguageMapper.toLocale(settings.settings.language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: settings.settings.themeMode.toFlutterThemeMode(),
          theme: AppTheme.light(settings.settings.colorPalette),
          darkTheme: AppTheme.dark(settings.settings.colorPalette),
          initialRoute: Routes.home,
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
  }
}
