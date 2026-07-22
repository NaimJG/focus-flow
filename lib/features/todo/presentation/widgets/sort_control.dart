import 'package:flutter/material.dart';

import '../../domain/entities/sort_criterion.dart';
import '../../domain/entities/sort_direction.dart';

/// A compact row with a sort criterion dropdown and a direction toggle button.
///
/// The direction toggle uses a `Semantics` label to remain accessible for
/// screen readers.
class SortControl extends StatelessWidget {
  /// Creates a sort control widget.
  const SortControl({
    super.key,
    required this.activeCriterion,
    required this.activeDirection,
    required this.onCriterionChanged,
    required this.onDirectionChanged,
  });

  /// The currently active sort criterion.
  final SortCriterion activeCriterion;

  /// The currently active sort direction.
  final SortDirection activeDirection;

  /// Called when the user selects a different sort criterion.
  final ValueChanged<SortCriterion> onCriterionChanged;

  /// Called when the user toggles the sort direction.
  final ValueChanged<SortDirection> onDirectionChanged;

  String _criterionLabel(SortCriterion criterion) {
    switch (criterion) {
      case SortCriterion.creationDate:
        return 'Date';
      case SortCriterion.priority:
        return 'Priority';
      case SortCriterion.alphabetical:
        return 'A–Z';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<SortCriterion>(
          value: activeCriterion,
          underline: const SizedBox.shrink(),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
          items: SortCriterion.values.map((criterion) {
            return DropdownMenuItem<SortCriterion>(
              value: criterion,
              child: Text(_criterionLabel(criterion)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCriterionChanged(value);
            }
          },
        ),
        Semantics(
          label: activeDirection == SortDirection.ascending
              ? 'Sort ascending, tap to sort descending'
              : 'Sort descending, tap to sort ascending',
          button: true,
          child: IconButton(
            tooltip: activeDirection == SortDirection.ascending
                ? 'Sort descending'
                : 'Sort ascending',
            icon: Icon(
              activeDirection == SortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              final newDirection = activeDirection == SortDirection.ascending
                  ? SortDirection.descending
                  : SortDirection.ascending;
              onDirectionChanged(newDirection);
            },
          ),
        ),
      ],
    );
  }
}
