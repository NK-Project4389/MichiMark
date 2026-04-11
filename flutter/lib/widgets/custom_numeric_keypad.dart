import 'package:flutter/material.dart';

/// カスタム数値キーパッド（BottomSheet として表示）
///
/// - StatefulWidget で内部入力文字列を管理する
/// - BLoC・Cubit は持たない
/// - Phase 2: 演算子キー（+−×÷）のタップ有効化・四則演算対応
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
  // Phase 2 内部状態（Phase 1 の _inputString を廃止し4フィールドに分解）
  String _lhs = '';
  String? _operator;
  String _rhs = '';
  bool _resultShown = false;

  // エラー表示フラグ（ゼロ除算など）
  bool _isError = false;

  // ---- 状態導出 ----

  bool get _isIdle =>
      _lhs.isEmpty && _operator == null && _rhs.isEmpty && !_resultShown;

  bool get _isEnteringLhs => _lhs.isNotEmpty && _operator == null && !_resultShown;

  bool get _isOperatorEntered =>
      _operator != null && _rhs.isEmpty && !_resultShown;

  bool get _isEnteringRhs => _operator != null && _rhs.isNotEmpty;

  // ---- 入力ロジック ----

  void _onDigit(String digit) {
    setState(() {
      _isError = false;
      if (_resultShown) {
        // result_shown: 全リセットして新規入力
        _lhs = digit == '00' ? '' : (digit == '0' ? '0' : digit);
        _operator = null;
        _rhs = '';
        _resultShown = false;
        if (digit == '00') {
          // 00 は先頭には入力しない
        }
        return;
      }

      if (_operator == null) {
        // entering_lhs または idle
        if (digit == '00') {
          if (_lhs == '0') return;
          if (_lhs.length >= 15) return;
          if (_lhs.length + 2 > 15) return;
          _lhs += '00';
        } else {
          if (_lhs.length >= 15) return;
          if (_lhs == '0') {
            _lhs = digit;
          } else {
            _lhs += digit;
          }
        }
      } else {
        // operator_entered または entering_rhs
        if (digit == '00') {
          if (_rhs == '0') return;
          if (_rhs.length >= 15) return;
          if (_rhs.length + 2 > 15) return;
          _rhs += '00';
        } else {
          if (_rhs.length >= 15) return;
          if (_rhs == '0') {
            _rhs = digit;
          } else {
            _rhs += digit;
          }
        }
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      _isError = false;
      if (_isIdle) {
        // lhs なしで演算子は無効
        return;
      }
      if (_isEnteringLhs) {
        _operator = op;
      } else if (_isOperatorEntered) {
        _operator = op;
      } else if (_isEnteringRhs) {
        _operator = op;
        _rhs = '';
      } else if (_resultShown) {
        // 計算結果を lhs として引き継ぎ
        _operator = op;
        _rhs = '';
        _resultShown = false;
      }
    });
  }

  void _onEquals() {
    if (_isError) {
      // エラー状態では何もしない（表示はクリア操作まで維持）
      return;
    }
    if (_isIdle) {
      // idle 状態（未入力）でも = を押したらシートを閉じる（元の値を維持）
      widget.onConfirmed(widget.originalValue);
      Navigator.pop(context);
      return;
    }
    if (_isEnteringLhs) {
      final value = _lhs.isEmpty ? widget.originalValue : _lhs;
      widget.onConfirmed(value);
      Navigator.pop(context);
      return;
    }
    if (_isOperatorEntered) {
      final value = _lhs.isEmpty ? widget.originalValue : _lhs;
      widget.onConfirmed(value);
      Navigator.pop(context);
      return;
    }
    if (_isEnteringRhs) {
      _calculate();
      return;
    }
    if (_resultShown) {
      widget.onConfirmed(_lhs);
      Navigator.pop(context);
      return;
    }
  }

  void _calculate() {
    final op = _operator;
    if (op == null) return;

    final lhsVal = double.tryParse(_lhs);
    final rhsVal = double.tryParse(_rhs);
    if (lhsVal == null || rhsVal == null) return;

    // ゼロ除算チェック
    if (op == '÷' && rhsVal == 0) {
      setState(() {
        _isError = true;
      });
      return;
    }

    double result;
    switch (op) {
      case '+':
        result = lhsVal + rhsVal;
      case '−':
        result = lhsVal - rhsVal;
      case '×':
        result = lhsVal * rhsVal;
      case '÷':
        result = lhsVal / rhsVal;
      default:
        return;
    }

    setState(() {
      _lhs = _formatResult(result);
      _operator = null;
      _rhs = '';
      _resultShown = true;
      _isError = false;
    });
  }

  String _formatResult(double value) {
    // 整数値の場合は小数点なし
    if (value == value.truncateToDouble()) {
      final intStr = value.truncate().toString();
      if (intStr.length <= 15) return intStr;
      // 15文字超は丸めて対処
      return value.toStringAsFixed(0).substring(0, 15);
    }

    // 小数値: 末尾の余分な0を削除
    String str = value.toString();

    // 15文字超の場合は小数点以下を丸める
    if (str.length > 15) {
      // 小数点の位置を確認
      final dotIndex = str.indexOf('.');
      if (dotIndex >= 0) {
        final intPartLength = dotIndex;
        if (intPartLength >= 15) {
          return str.substring(0, 15);
        }
        final decimals = 15 - intPartLength - 1; // -1 for dot
        if (decimals <= 0) {
          return str.substring(0, 15);
        }
        str = value.toStringAsFixed(decimals);
      } else {
        return str.substring(0, 15);
      }
    }

    // 末尾の余分な0を削除
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }

    return str;
  }

  void _onDot() {
    if (!widget.isDecimal) return;
    setState(() {
      _isError = false;
      if (_resultShown) {
        // result_shown では何もしない
        return;
      }

      if (_operator == null) {
        // idle または entering_lhs: _lhs に小数点追加
        if (_lhs.contains('.')) return;
        if (_lhs.length >= 15) return;
        if (_lhs.isEmpty) {
          _lhs = '0.';
        } else {
          _lhs += '.';
        }
      } else {
        // operator_entered または entering_rhs: _rhs に小数点追加
        if (_rhs.contains('.')) return;
        if (_rhs.length >= 15) return;
        if (_rhs.isEmpty) {
          _rhs = '0.';
        } else {
          _rhs += '.';
        }
      }
    });
  }

  void _onClear() {
    setState(() {
      _lhs = '';
      _operator = null;
      _rhs = '';
      _resultShown = false;
      _isError = false;
    });
  }

  void _onBackspace() {
    setState(() {
      _isError = false;
      if (_isIdle) {
        return;
      }
      if (_resultShown) {
        // result_shown: 全消去 → idle
        _lhs = '';
        _operator = null;
        _rhs = '';
        _resultShown = false;
        return;
      }
      if (_isEnteringRhs) {
        _rhs = _rhs.substring(0, _rhs.length - 1);
        // rhs が空になったら operator_entered へ
        return;
      }
      if (_isOperatorEntered) {
        _operator = null;
        return;
      }
      if (_isEnteringLhs) {
        _lhs = _lhs.substring(0, _lhs.length - 1);
        return;
      }
    });
  }

  // ---- Display テキスト ----

  String _buildDisplayText() {
    if (_isError) return 'エラー';
    if (_resultShown) return _lhs;
    if (_isEnteringRhs) return '$_lhs $_operator $_rhs';
    if (_isOperatorEntered) return '$_lhs $_operator';
    if (_isEnteringLhs) return _lhs;
    // idle
    return widget.originalValue;
  }

  bool _isDisplayPlaceholder() {
    if (_isError) return false;
    return _isIdle;
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

  // Phase 2: 演算子活性スタイル
  Color _operatorActiveBackground(bool isDark) =>
      isDark ? const Color(0xFF1E3A3A) : const Color(0xFFD6EDEB);

  Color _operatorActiveForeground(bool isDark) =>
      isDark ? const Color(0xFF4ECDC4) : const Color(0xFF2D6A6A);

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
    final displayText = _buildDisplayText();
    final isPlaceholder = _isDisplayPlaceholder();

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
                        : _isError
                            ? Colors.red
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
            _buildOperatorKey('÷', keyId: 'keypad_op_divide', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
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
            _buildOperatorKey('×', keyId: 'keypad_op_multiply', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
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
            _buildOperatorKey('−', keyId: 'keypad_op_minus', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
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
            _buildOperatorKey('+', keyId: 'keypad_op_plus', isDark: isDark, keyHeight: keyHeight, radius: radius, sf: sf),
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
    required String keyId,
    required bool isDark,
    required double keyHeight,
    required double radius,
    required double sf,
  }) {
    return Expanded(
      child: GestureDetector(
        key: Key(keyId),
        onTap: () => _onOperator(symbol),
        child: Container(
          height: keyHeight,
          decoration: BoxDecoration(
            color: _operatorActiveBackground(isDark),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 20 * sf,
              fontWeight: FontWeight.w400,
              color: _operatorActiveForeground(isDark),
            ),
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
    final label = _resultShown ? '確定' : '=';
    return GestureDetector(
      key: const Key('keypad_confirm'),
      onTap: _onEquals,
      child: Container(
        width: double.infinity,
        height: keyHeight,
        decoration: BoxDecoration(
          color: _confirmBackground(isDark),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
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
