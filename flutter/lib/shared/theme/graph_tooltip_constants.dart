import 'package:flutter/material.dart';

/// グラフ ツールチップ（ポップアップ）の配色・スタイル定数
abstract final class GraphTooltipConstants {
  /// ポップアップ背景色（暗色半透明）
  static const Color graphTooltipBackgroundColor = Colors.black87;

  /// ポップアップ文字色
  static const Color graphTooltipTextColor = Colors.white;

  /// ポップアップの角丸半径
  static final BorderRadius graphTooltipBorderRadius = BorderRadius.circular(8);
}
