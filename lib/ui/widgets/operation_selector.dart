import 'package:flutter/material.dart';

/// Operations the SDK accepts for a user profile attribute.
enum ProfileOperation {
  set('Set'),
  unset('Unset'),
  add('Add'),
  remove('Remove');

  const ProfileOperation(this.label);
  final String label;
}

/// Single-choice segmented control; tapping the selected segment clears it.
class OperationSelector extends StatelessWidget {
  const OperationSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<ProfileOperation> options;
  final ProfileOperation? selected;
  final ValueChanged<ProfileOperation?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProfileOperation>(
      segments: [
        for (final option in options)
          ButtonSegment(value: option, label: Text(option.label)),
      ],
      selected: {?selected},
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      onSelectionChanged: (selection) =>
          onChanged(selection.isEmpty ? null : selection.first),
    );
  }
}
