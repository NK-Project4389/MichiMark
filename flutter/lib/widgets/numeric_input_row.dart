import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_numeric_keypad.dart';

/// 数値入力行ウィジェット（ラベル + タップ表示エリア + 単位）
///
/// - フィールドタップで [CustomNumericKeypad] を BottomSheet として表示する
/// - システムキーボードは使用しない
/// - 単位テキストは値が空・0 でも常に表示する
/// - [isDecimal] = false（デフォルト）: 整数 → カンマ区切りを自動整形
/// - [isDecimal] = true: 小数点入力 → カンマ整形なし
/// - [value] は生の数値文字列（カンマなし）で渡す
/// - [onChanged] も生の数値文字列（カンマなし）を返す
class NumericInputRow extends StatelessWidget {
  final String label;
  final String unit;

  /// 生の数値文字列。カンマなしで渡す。
  final String value;

  /// true: 小数点入力可・カンマ整形なし / false: 整数・カンマ整形あり
  final bool isDecimal;

  /// 生の数値文字列（カンマなし）を返す
  final ValueChanged<String> onChanged;

  const NumericInputRow({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    this.isDecimal = false,
    required this.onChanged,
  });

  static final _numberFormat = NumberFormat('#,###');

  String _toDisplayText(String rawValue) {
    if (isDecimal) return rawValue;
    final raw = rawValue.replaceAll(',', '');
    final parsed = int.tryParse(raw);
    return parsed != null ? _numberFormat.format(parsed) : rawValue;
  }

  void _showKeypad(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomNumericKeypad(
        originalValue: value,
        unit: unit,
        isDecimal: isDecimal,
        onConfirmed: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = _toDisplayText(value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              key: Key('numeric_input_tap_$label'),
              onTap: () => _showKeypad(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  displayText.isEmpty ? '0' : displayText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: displayText.isEmpty
                        ? colorScheme.onSurface.withValues(alpha: 0.35)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          // 単位は常に表示（空・0でも消えない）
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              unit,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
