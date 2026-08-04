import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pomodoro/domain/use_cases/get_task_pomodoro_stats_use_case.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_pomodoro_stats_controller.dart';
import '../controllers/todo_controller.dart';
import '../widgets/task_pomodoro_stats_section.dart';

/// Screen for creating or editing a task.
///
/// When [initialTask] is `null`, the screen operates in create mode.
/// When [initialTask] is provided, the form pre-populates its editable
/// fields and submits the changes through [TodoController.editTask].
class TaskFormScreen extends StatefulWidget {
  /// Creates a task form screen.
  const TaskFormScreen({super.key, this.initialTask});

  /// Initial task to edit.
  ///
  /// When `null`, the screen creates a new task.
  final Task? initialTask;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> with RouteAware {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  Priority _selectedPriority = Priority.medium;
  int? _selectedCategoryId;

  bool _isSubmitting = false;
  String? _submissionError;

  bool get _isEditMode => widget.initialTask != null;

  TaskPomodoroStatsController? _statsController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.initialTask?.description ?? '',
    );

    _selectedPriority = widget.initialTask?.priority ?? Priority.medium;

    _selectedCategoryId = widget.initialTask?.categoryId;

    if (_isEditMode) {
      // Defer controller creation to after the first frame so that
      // `context.read` is safe to call.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final useCase = context.read<GetTaskPomodoroStatsUseCase>();
        setState(() {
          _statsController = TaskPomodoroStatsController(
            getTaskPomodoroStatsUseCase: useCase,
            taskId: widget.initialTask!.id,
          );
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _titleController.dispose();
    _descriptionController.dispose();
    _statsController?.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when a route that was pushed on top is popped, returning
    // focus to this screen. Refresh stats to capture any new sessions.
    _statsController?.load();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _submissionError = null;
    });

    final formIsValid = _formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final controller = context.read<TodoController>();

    final title = _titleController.text.trim();

    final normalizedDescription = _descriptionController.text.trim();

    final description = normalizedDescription.isEmpty
        ? null
        : normalizedDescription;

    try {
      if (_isEditMode) {
        await controller.editTask(
          id: widget.initialTask!.id,
          title: title,
          priority: _selectedPriority,
          description: description,
          categoryId: _selectedCategoryId,
        );
      } else {
        await controller.createTask(
          title: title,
          priority: _selectedPriority,
          description: description,
          categoryId: _selectedCategoryId,
        );
      }

      if (!mounted) {
        return;
      }

      final errorMessage = controller.errorMessage;

      if (errorMessage == null) {
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        _submissionError = errorMessage;
        _isSubmitting = false;
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _submissionError = l10n.todoFormGenericError;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = context.select<TodoController, List<Category>>(
      (controller) => controller.categories.toList(),
    );

    final selectedCategoryExists =
        _selectedCategoryId == null ||
        categories.any((category) => category.id == _selectedCategoryId);

    if (!selectedCategoryExists) {
      _selectedCategoryId = null;
    }

    // Read cyclesBeforeLongBreak reactively from SettingsController.
    final cyclesBeforeLongBreak = context.select<SettingsController, int>(
      (c) => c.settings.cyclesBeforeLongBreak,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? l10n.todoFormEditTitle : l10n.todoFormNewTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditMode,
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.todoFormTitleLabel,
                    hintText: l10n.todoFormTitleHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.todoFormTitleRequired;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: l10n.todoFormDescriptionLabel,
                    hintText: l10n.todoFormDescriptionHint,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  initialValue: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: l10n.todoFormPriorityLabel,
                  ),
                  items: Priority.values
                      .map(
                        (priority) => DropdownMenuItem<Priority>(
                          value: priority,
                          child: Text(_priorityLabel(priority, l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.todoFormCategoryLabel,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.todoFormNoCategory),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                ),
                if (_isEditMode && _statsController != null) ...[
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: _statsController!,
                    builder: (context, _) => TaskPomodoroStatsSection(
                      status: _statsController!.status,
                      stats: _statsController!.stats,
                      cyclesBeforeLongBreak: cyclesBeforeLongBreak,
                      l10n: l10n,
                    ),
                  ),
                ],
                if (_submissionError != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _submissionError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditMode
                              ? l10n.todoFormSaveChanges
                              : l10n.todoCreateTask,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _priorityLabel(Priority priority, AppLocalizations l10n) {
    switch (priority) {
      case Priority.high:
        return l10n.todoPriorityHigh;
      case Priority.medium:
        return l10n.todoPriorityMedium;
      case Priority.low:
        return l10n.todoPriorityLow;
    }
  }
}
