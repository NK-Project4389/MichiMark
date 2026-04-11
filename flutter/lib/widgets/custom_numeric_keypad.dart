import 'package:flutter/material.dart';

/// カスタム数値キーパッド（BottomSheet として表示）
///
/// - StatefulWidget で内部入力文字列を管理する
/// - BLoC・Cubit は持たない
/// - Phase 1: 演算子キー（+−×÷）はタップ無効・非活性スタイル
class CustomNumericKeypad extends StatefulWidget {
  /// 確定時に呼ばれるコールバック（生の数値文字列、カンマなし）
  final ValueChanged<String> onConfirmed;

  /// 現在の値（BottomSheet 表示時点の値 = Display の変更前値）
  final String originalValue;

  /// 単位（Display エリアの変更前値行に表示）
  final String unit;

  /// true: 小数点キーを活性化 / false: 小数点キーを非活性グレー表示
  final bool isDecimal;

  const CustomNumericKeypad({
    super.key,
    required this.onConfirmed,
    required this.originalValue,
    required this.unit,
    this.isDecimal = false,
  });

  @override
  State<CustomNumericKeypad> createState() => _CustomNumericKeypadState();
}

class _CustomNumericKeypadState extends State<CustomNumericKeypad> {
  String _inputString = '';

  // ---- 入力ロジック ----

  void _onDigit(String digit) {
    if (_inputString.length >= 15) return;
    setState(() {
      if (digit == '00') {
        // 先頭が "0" だけの場合は "00" を入力しても "0" のまま
        if (_inputString == '0') return;
        _inputString += '00';
      } else {
        // 先頭が "0" の場合（小数点なし）は上書き
        if (_inputString == '0') {
          _inputString = digit;
        } else {
          _inputString += digit;
        }
      }
    });
  }

  void _onDot() {
    if (!widget.isDecimal) return;
    if (_inputString.contains('.')) return;
    if (_inputString.length >= 15) return;
    setState(() {
      if (_inputString.isEmpty) {
        _inputString = '0.';
      } else {
        _inputString += '.';
      }
    });
  }

  void _onClear() {
    setState(() {
      _inputString = '';
    });
  }

  void _onBackspace() {
    if (_inputString.isEmpty) return;
    setState(() {
      _inputString = _inputString.substring(0, _inputString.length - 1);
    });
  }

  void _onConfirm() {
    final value = _inputString.isEmpty ? widget.originalValue : _inputString;
    widget.onConfirmed(value);
    Navigator.pop(context);
  }

  // ---- カラー ----

  Color _keypadBackground(bool isDark) =>
      isDark ? const Color(0xFF1C2626) : const Color(0xFFF2F4F4);

  Color _digitBackground(bool isDark) =>
      isDark ? const Color(0xFF2C3C3C) : const Color(0xFFFFFFFF);

  Color _digitForeground(bool isDark) =>
      isDark ? const Color(0xFFE8F4F2) : const Color(0xFF1A1A2E);

  Color _operatorBackground(bool isDark) =>
      isDark ? const Color(0xFF1E2E2E) : const Color(0xFFE8F4F2);

  Color _operatorForeground(bool isDark) =>
      isDark ? const Color(0xFF4A6A68) : const Color(0xFFA0B8B6);

  Color _confirmBackground(bool isDark) =>
      isDark ? const Color(0xFF4ECDC4) : const Color(0xFF2D6A6A);

  Color _confirmForeground(bool isDark) =>
      isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);

  Color _deleteBackground(bool isDark) =>
      isDark ? const Color(0xFF243030) : const Color(0xFFE8EEF0);

  Color _deleteForeground(bool isDark) =>
      isDark ? const Color(0xFF9BB5B3) : const Color(0xFF4A6060);

  Color _clearBackground(bool isDark) =>
      isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFE5E5);

  Color _clearForeground(bool isDark) =>
      isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC0392B);

  // ---- ビルド ----

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final sf = screenWidth / 375;
    final colorScheme = Theme.of(context).colorScheme;

    final double keyHeight = 52 * sf;
    final double gap = 8 * sf;
    final double hPadding = 12 * sf;
    final double displayHeight = 90 * sf;
    final double radius = 8 * sf;

    return Container(
      key: const Key('custom_numeric_keypad'),
      decoration: BoxDecoration(
        color: _keypadBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        hPadding,
        0,
        hPadding,
        MediaQuery.of(context).padding.bottom + 8 * sf,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display エリア
          _buildDisplay(
            displayHeight: displayHeight,
            colorScheme: colorScheme,
            sf: sf,
          ),
          SizedBox(height: gap),
          // キーグリッド
          _buildKeyGrid(
            isDark: isDark,
            keyHeight: keyHeight,
            gap: gap,
            radius: radius,
            sf: sf,
          ),
          SizedBox(height: gap),
          // 確定ボタン（全幅）
          _buildConfirmButton(
            isDark: isDark,
            keyHeight: keyHeight,
            radius: radius,
            sf: sf,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay({
    required double displayHeight,
    required ColorScheme colorScheme,
    required double sf,
  }) {
    final showOriginal = widget.originalValue.isNotEmpty;
    final displayText =
        _inputString.isEmpty ? widget.originalValue : _inputString;
    final isPlaceholder = _inputString.isEmpty;

    return SizedBox(
      height: displayHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showOriginal)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                key: const Key('keypad_display_original'),
                '変更前: ${widget.originalValue}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}',
                style: TextStyle(
                  fontSize: 11 * sf,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  key: const Key('keypad_display_input'),
                  displayText.isEmpty ? '0' : displayText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 32 * sf,
                    fontWeight: FontWeight.w300,
                    color: isPlaceholder
                        ? colorScheme.onSurface.withValues(alpha: 0.3)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (widget.unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  widget.unit,
                  style: TextStyle(
                    fontSize: 12 * sf,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyGrid({
    required bool isDark,
    required double keyHeight,
    required double gap,
    required double radius,
    required double sf,
  }) {
    // 行1: [C]  [7] [8] [9] [÷]
    // 行2: [⌫] [4] [5] [6] [×]
    // 行3: [.]  [1] [2] [3] [−]
    // 行4: [00] [0] [　] [　] [+]
    return Column(
      children: [
        _buildRow(
          keys: [
            _buildClearKey(isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('7', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('8', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('9', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildOperatorKey('÷', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
          ],
          gap: gap,
        ),
        SizedBox(height: gap),
        _buildRow(
          keys: [
            _buildBackspaceKey(isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('4', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('5', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('6', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildOperatorKey('×', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
          ],
          gap: gap,
        ),
        SizedBox(height: gap),
        _buildRow(
          keys: [
            _buildDotKey(isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('1', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('2', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('3', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildOperatorKey('−', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
          ],
          gap: gap,
        ),
        SizedBox(height: gap),
        _buildRow(
          keys: [
            _buildDigitKey('00', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            _buildDigitKey('0', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
            // ダミーセル × 2
            SizedBox(height: keyHeight),
            SizedBox(height: keyHeight),
            _buildOperatorKey('+', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
          ],
          gap: gap,
        ),
      ],
    );
  }

  Widget _buildRow({required List<Widget> keys, required double gap}) {
    return Row(
      children: keys
          .expand((k) => [k, SizedBox(width: gap)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildDigitKey(
    String digit, {
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    final keyValue = digit == '00' ? '00' : digit;
    final keyId = digit == '00' ? 'keypad_digit_00' : 'keypad_digit_$digit';
    return Expanded(
      child: GestureDetector(
        key: Key(keyId),
        onTap: () => _onDigit(keyValue),
        child: Container(
          height: keyHeight,
          decoration: BoxDecoration(
            color: _digitBackground(isDark),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 18 * sf,
              fontWeight: FontWeight.w500,
              color: _digitForeground(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorKey(
    String symbol, {
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    return Expanded(
      child: Container(
        height: keyHeight,
        decoration: BoxDecoration(
          color: _operatorBackground(isDark),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 20 * sf,
            fontWeight: FontWeight.w400,
            color: _operatorForeground(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildClearKey({
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    return Expanded(
      child: GestureDetector(
        key: const Key('keypad_clear'),
        onTap: _onClear,
        child: Container(
          height: keyHeight,
          decoration: BoxDecoration(
            color: _clearBackground(isDark),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            'C',
            style: TextStyle(
              fontSize: 16 * sf,
              fontWeight: FontWeight.w600,
              color: _clearForeground(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey({
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    return Expanded(
      child: GestureDetector(
        key: const Key('keypad_backspace'),
        onTap: _onBackspace,
        child: Container(
          height: keyHeight,
          decoration: BoxDecoration(
            color: _deleteBackground(isDark),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            size: 20 * sf,
            color: _deleteForeground(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildDotKey({
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    final active = widget.isDecimal;
    return Expanded(
      child: GestureDetector(
        key: const Key('keypad_dot'),
        onTap: active ? _onDot : null,
        child: Container(
          height: keyHeight,
          decoration: BoxDecoration(
            color: active ? _digitBackground(isDark) : _operatorBackground(isDark),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            '.',
            style: TextStyle(
              fontSize: 18 * sf,
              fontWeight: FontWeight.w500,
              color: active ? _digitForeground(isDark) : _operatorForeground(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton({
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    return GestureDetector(
      key: const Key('keypad_confirm'),
      onTap: _onConfirm,
      child: Container(
        width: double.infinity,
        height: keyHeight,
        decoration: BoxDecoration(
          color: _confirmBackground(isDark),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          '=',
          style: TextStyle(
            fontSize: 16 * sf,
            fontWeight: FontWeight.w600,
            color: _confirmForeground(isDark),
          ),
        ),
      ),
    );
  }
}
