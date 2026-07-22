import 'package:flutter/material.dart';

/// Reusable modal dialog for destructive-action confirmation.
///
/// Displays a Material 3 [AlertDialog] with cancel and confirm actions.
/// Use [ConfirmationDialog.show] for a convenient static invocation.
class ConfirmationDialog extends StatelessWidget {
  /// Creates a confirmation dialog.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
  });

  /// The dialog title.
  final String title;

  /// The dialog body message.
  final String message;

  /// Label for the confirm action button.
  final String confirmLabel;

  /// Label for the cancel action button.
  final String cancelLabel;

  /// Called when the user presses the confirm button.
  final VoidCallback onConfirm;

  /// Shows a [ConfirmationDialog] as a modal dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
