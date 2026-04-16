import 'package:flutter/material.dart';

/// 使用回数選択 UI。
class MaxUsesSelector extends StatelessWidget {
  final int? selectedMaxUses;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  const MaxUsesSelector({
    super.key,
    required this.selectedMaxUses,
    required this.onChanged,
    this.enabled = true,
  });

  static const _options = [
    (maxUses: 1, label: '1回'),
    (maxUses: 5, label: '5回'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '使用回数',
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
            children: [
              ..._options.map((option) {
                final isSelected = selectedMaxUses == option.maxUses;
                return ChoiceChip(
                  key: Key('inviteLinkShare_chip_maxUses${option.maxUses}'),
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: enabled
                      ? (_) => onChanged(option.maxUses)
                      : null,
                );
              }),
              ChoiceChip(
                key: const Key('inviteLinkShare_chip_maxUsesNull'),
                label: const Text('無制限'),
                selected: selectedMaxUses == null,
                onSelected: enabled
                    ? (_) => onChanged(null)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
