import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';

/// Displays the "Pomodoro" settings section with numeric input controls
/// for focus duration, short break duration, long break duration, and
/// cycles before long break.
///
/// Each input validates against its allowed range and shows inline
/// error messages for out-of-range values.
class PomodoroSettingsSection extends StatelessWidget {
  /// Creates a [PomodoroSettingsSection].
  const PomodoroSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final enabled = !controller.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Pomodoro',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _DurationSettingTile(
          label: 'Focus duration',
          suffix: 'min',
          value: settings.focusDuration.inMinutes,
          min: 1,
          max: 120,
          enabled: enabled,
          onChanged: controller.updateFocusDuration,
        ),
        _DurationSettingTile(
          label: 'Short break',
          suffix: 'min',
          value: settings.shortBreakDuration.inMinutes,
          min: 1,
          max: 60,
          enabled: enabled,
          onChanged: controller.updateShortBreakDuration,
        ),
        _DurationSettingTile(
          label: 'Long break',
          suffix: 'min',
          value: settings.longBreakDuration.inMinutes,
          min: 1,
          max: 120,
          enabled: enabled,
          onChanged: controller.updateLongBreakDuration,
        ),
        _DurationSettingTile(
          label: 'Cycles before long break',
          suffix: 'cycles',
          value: settings.cyclesBeforeLongBreak,
          min: 1,
          max: 12,
          enabled: enabled,
          onChanged: controller.updateCyclesBeforeLongBreak,
        ),
      ],
    );
  }
}

/// A private stateful widget that renders a single numeric setting
/// input with label, text field, suffix, and inline validation error.
class _DurationSettingTile extends StatefulWidget {
  const _DurationSettingTile({
    required this.label,
    required this.suffix,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String suffix;
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final Future<bool> Function(int) onChanged;

  @override
  State<_DurationSettingTile> createState() => _DurationSettingTileState();
}

class _DurationSettingTileState extends State<_DurationSettingTile> {
  late final TextEditingController _textController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _DurationSettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textController.text = widget.value.toString();
      // Clear error when external value changes successfully.
      if (_errorText != null) {
        setState(() {
          _errorText = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      // Revert to current value on empty input.
      _textController.text = widget.value.toString();
      setState(() {
        _errorText = null;
      });
      return;
    }

    final parsed = int.tryParse(text);
    if (parsed == null || parsed < widget.min || parsed > widget.max) {
      setState(() {
        _errorText = 'Must be between ${widget.min} and ${widget.max}';
      });
      // Revert the text to the last valid value.
      _textController.text = widget.value.toString();
      return;
    }

    // Value is valid — clear any previous error.
    setState(() {
      _errorText = null;
    });

    final success = await widget.onChanged(parsed);
    if (!success) {
      // Save failed — revert text to current persisted value.
      _textController.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.label, style: theme.textTheme.bodyLarge),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _textController,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                    errorText: null,
                  ),
                  onSubmitted: (_) => _submit(),
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                    _submit();
                  },
                  onEditingComplete: _submit,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(widget.suffix, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
