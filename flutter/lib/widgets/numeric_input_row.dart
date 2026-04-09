import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 数値入力行ウィジェット（ラベル + 入力フィールド + 単位）
///
/// - 単位テキストは値が空・0 でも常に表示する
/// - [isDecimal] = false（デフォルト）: 整数 → カンマ区切りを自動整形
/// - [isDecimal] = true: 小数点入力 → カンマ整形なし
/// - [value] は生の数値文字列（カンマなし）で渡す
/// - [onChanged] も生の数値文字列（カンマなし）を返す
class NumericInputRow extends StatefulWidget {
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

  @override
  State<NumericInputRow> createState() => _NumericInputRowState();
}

class _NumericInputRowState extends State<NumericInputRow> {
  static final _numberFormat = NumberFormat('#,###');

  late final TextEditingController _controller;

  String _toDisplayText(String rawValue) {
    if (widget.isDecimal) return rawValue;
    final raw = rawValue.replaceAll(',', '');
    final parsed = int.tryParse(raw);
    return parsed != null ? _numberFormat.format(parsed) : rawValue;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _toDisplayText(widget.value));
  }

  @override
  void didUpdateWidget(NumericInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bloc側から外部更新（計算・クリア等）があった場合のみ同期する
    final newDisplay = _toDisplayText(widget.value);
    if (newDisplay != _controller.text) {
      _controller.text = newDisplay;
      _controller.selection =
          TextSelection.collapsed(offset: newDisplay.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              widget.label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: widget.isDecimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '0',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (input) {
                if (!widget.isDecimal) {
                  // 整数モード: カンマ整形してコントローラ更新
                  final raw = input.replaceAll(',', '');
                  final parsed = int.tryParse(raw);
                  if (parsed != null) {
                    final formatted = _numberFormat.format(parsed);
                    if (formatted != input) {
                      _controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                    widget.onChanged(raw);
                  } else {
                    // 数値でない場合はそのまま返す（空文字列など）
                    widget.onChanged(input.replaceAll(',', ''));
                  }
                } else {
                  widget.onChanged(input);
                }
              },
            ),
          ),
          // 単位は常に表示（空・0でも消えない）
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.unit,
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
