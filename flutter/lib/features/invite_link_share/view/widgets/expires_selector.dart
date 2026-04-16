import 'package:flutter/material.dart';

/// 有効期限選択 UI。
class ExpiresSelector extends StatelessWidget {
  final int selectedHours;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const ExpiresSelector({
    super.key,
    required this.selectedHours,
    required this.onChanged,
    this.enabled = true,
  });

  static const _options = [
    (hours: 24, label: '24時間'),
    (hours: 72, label: '72時間'),
    (hours: 168, label: '7日間'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '有効期限',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: _options.map((option) {
              final isSelected = selectedHours == option.hours;
              return ChoiceChip(
                key: Key('inviteLinkShare_chip_expires${option.hours}'),
                label: Text(option.label),
                selected: isSelected,
                onSelected: enabled
                    ? (_) => onChanged(option.hours)
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
