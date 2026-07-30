import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A reusable expandable floating action button that reveals multiple
/// actions when pressed.
///
/// Displays a main FAB with an add icon that, when tapped, expands upward
/// to reveal "Create task" and "Create category" actions with labels.
class ExpandableFab extends StatefulWidget {
  /// Creates an [ExpandableFab].
  const ExpandableFab({
    super.key,
    required this.onCreateTask,
    required this.onCreateCategory,
  });

  /// Called when the user selects "Create task".
  final VoidCallback onCreateTask;

  /// Called when the user selects "Create category".
  final VoidCallback onCreateCategory;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  void _onActionPressed(VoidCallback callback) {
    _close();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Child action: Create category (furthest from main FAB).
        _buildExpandingAction(
          icon: Icons.category,
          label: l10n.todoCreateCategoryFab,
          heroTag: 'fab_create_category',
          onPressed: () => _onActionPressed(widget.onCreateCategory),
        ),
        const SizedBox(height: 12),
        // Child action: Create task (closer to main FAB).
        _buildExpandingAction(
          icon: Icons.task_alt,
          label: l10n.todoCreateTaskFab,
          heroTag: 'fab_create_task',
          onPressed: () => _onActionPressed(widget.onCreateTask),
        ),
        const SizedBox(height: 12),
        // Main FAB.
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: _toggle,
          tooltip: _isOpen ? l10n.todoFabCloseMenu : l10n.todoFabCreate,
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _expandAnimation.value * 0.785398, // 45° in radians
                child: child,
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandingAction({
    required IconData icon,
    required String label,
    required String heroTag,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _expandAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_expandAnimation),
            child: child,
          ),
        );
      },
      child: Semantics(
        label: label,
        button: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: heroTag,
              onPressed: onPressed,
              tooltip: label,
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }
}
