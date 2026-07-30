import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../domain/entities/category.dart';
import '../controllers/todo_controller.dart';

/// Screen for managing categories: list, create, rename, and delete.
class CategoryManagerScreen extends StatefulWidget {
  /// Creates the category management screen.
  const CategoryManagerScreen({super.key, this.startCreating = false});

  /// When `true`, the screen opens with the new-category input visible.
  final bool startCreating;

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  final TextEditingController _newCategoryController = TextEditingController();

  String? _newCategoryError;

  bool _isAddingCategory = false;
  bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    if (widget.startCreating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isAddingCategory = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    if (_isCreatingCategory) {
      return;
    }

    FocusScope.of(context).unfocus();

    final name = _newCategoryController.text.trim();

    if (name.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _newCategoryError = l10n.todoCategoryNameRequired;
      });
      return;
    }

    setState(() {
      _newCategoryError = null;
      _isCreatingCategory = true;
    });

    final controller = context.read<TodoController>();

    await controller.createCategory(name);

    if (!mounted) {
      return;
    }

    final error = controller.errorMessage;

    setState(() {
      _isCreatingCategory = false;

      if (error == null) {
        _newCategoryController.clear();
        _newCategoryError = null;
        _isAddingCategory = false;
      } else {
        _newCategoryError = error;
      }
    });
  }

  void _cancelCategoryCreation() {
    if (_isCreatingCategory) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isAddingCategory = false;
      _newCategoryController.clear();
      _newCategoryError = null;
    });
  }

  Future<void> _showRenameDialog(Category category) async {
    final renameController = TextEditingController(text: category.name);

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          String? renameError;
          bool isSubmitting = false;

          return StatefulBuilder(
            builder: (builderContext, setDialogState) {
              final l10n = AppLocalizations.of(builderContext)!;

              Future<void> submitRename() async {
                if (isSubmitting) {
                  return;
                }

                final name = renameController.text.trim();

                if (name.isEmpty) {
                  setDialogState(() {
                    renameError = l10n.todoCategoryNameRequired;
                  });
                  return;
                }

                setDialogState(() {
                  renameError = null;
                  isSubmitting = true;
                });

                final controller = builderContext.read<TodoController>();

                await controller.renameCategory(id: category.id, name: name);

                if (!dialogContext.mounted) {
                  return;
                }

                final error = controller.errorMessage;

                if (error == null) {
                  Navigator.of(dialogContext).pop();
                  return;
                }

                setDialogState(() {
                  renameError = error;
                  isSubmitting = false;
                });
              }

              return PopScope(
                canPop: !isSubmitting,
                child: AlertDialog(
                  title: Text(l10n.todoCategoryRenameTitle),
                  content: TextField(
                    controller: renameController,
                    autofocus: true,
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.todoCategoryNameLabel,
                      errorText: renameError,
                    ),
                    onSubmitted: isSubmitting ? null : (_) => submitRename(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                            },
                      child: Text(l10n.sharedCancel),
                    ),
                    FilledButton(
                      onPressed: isSubmitting ? null : submitRename,
                      child: isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.todoCategoryRename),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      renameController.dispose();
    }
  }

  Future<void> _confirmDelete(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    await ConfirmationDialog.show(
      context,
      title: l10n.categoryDeleteTitle,
      message: l10n.categoryDeleteMessage(category.name),
      confirmLabel: l10n.sharedDelete,
      cancelLabel: l10n.sharedCancel,
      onConfirm: () async {
        final controller = context.read<TodoController>();

        await controller.deleteCategory(category.id);

        if (!mounted) {
          return;
        }

        final error = controller.errorMessage;

        if (error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        }
      },
    );
  }

  void _startCategoryCreation() {
    setState(() {
      _isAddingCategory = true;
      _newCategoryError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = context.select<TodoController, List<Category>>(
      (controller) => controller.categories.toList(),
    );

    final controllerIsLoading = context.select<TodoController, bool>(
      (controller) => controller.isLoading,
    );

    final mutationsDisabled = controllerIsLoading || _isCreatingCategory;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todoCategoriesTitle)),
      body: SafeArea(
        child: Column(
          children: [
            if (_isAddingCategory)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        autofocus: true,
                        enabled: !_isCreatingCategory,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.todoCategoryNewName,
                          errorText: _newCategoryError,
                        ),
                        onSubmitted: _isCreatingCategory
                            ? null
                            : (_) => _createCategory(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      label: l10n.todoCategorySaveSemantics,
                      button: true,
                      child: IconButton(
                        onPressed: _isCreatingCategory ? null : _createCategory,
                        tooltip: l10n.todoCategorySaveSemantics,
                        icon: _isCreatingCategory
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                      ),
                    ),
                    Semantics(
                      label: l10n.todoCategoryCancelSemantics,
                      button: true,
                      child: IconButton(
                        onPressed: _isCreatingCategory
                            ? null
                            : _cancelCategoryCreation,
                        tooltip: l10n.sharedCancel,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        l10n.todoCategoryEmptyState,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return _CategoryRow(
                          category: category,
                          actionsEnabled: !mutationsDisabled,
                          onRename: () {
                            _showRenameDialog(category);
                          },
                          onDelete: () {
                            _confirmDelete(category);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isAddingCategory
          ? null
          : FloatingActionButton(
              onPressed: controllerIsLoading ? null : _startCategoryCreation,
              tooltip: l10n.todoCategoryAdd,
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.actionsEnabled,
    required this.onRename,
    required this.onDelete,
  });

  final Category category;
  final bool actionsEnabled;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: l10n.todoCategoryRenameSemantics(category.name),
            button: true,
            child: IconButton(
              onPressed: actionsEnabled ? onRename : null,
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.todoCategoryRenameSemantics(category.name),
            ),
          ),
          Semantics(
            label: l10n.todoCategoryDeleteSemantics(category.name),
            button: true,
            child: IconButton(
              onPressed: actionsEnabled ? onDelete : null,
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.todoCategoryDeleteSemantics(category.name),
            ),
          ),
        ],
      ),
    );
  }
}
