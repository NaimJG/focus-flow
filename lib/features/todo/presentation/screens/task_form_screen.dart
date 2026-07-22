import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../controllers/todo_controller.dart';

/// Screen for creating or editing a task.
///
/// When [initialTask] is `null`, the screen operates in create mode.
/// When [initialTask] is provided, the form pre-populates its editable fields
/// and submits the changes through [TodoController.editTask].
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

class _TaskFormScreenState extends State<TaskFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  Priority _selectedPriority = Priority.medium;
  int? _selectedCategoryId;

  bool _isSubmitting = false;
  String? _submissionError;

  bool get _isEditMode => widget.initialTask != null;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
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

      setState(() {
        _submissionError = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.select<TodoController, List<Category>>(
      (controller) => controller.categories.toList(),
    );

    final selectedCategoryExists =
        _selectedCategoryId == null ||
        categories.any((category) => category.id == _selectedCategoryId);

    if (!selectedCategoryExists) {
      _selectedCategoryId = null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Task' : 'New Task')),
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
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a task title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
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
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add an optional description',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: Priority.values
                      .map(
                        (priority) => DropdownMenuItem<Priority>(
                          value: priority,
                          child: Text(_priorityLabel(priority)),
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
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No category'),
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
                      : Text(_isEditMode ? 'Save Changes' : 'Create Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }
}
