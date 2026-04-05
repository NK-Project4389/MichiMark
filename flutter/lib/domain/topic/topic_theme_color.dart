import 'package:flutter/material.dart';

/// Topicのテーマカラーを定義するenum（REQ-007）。
/// 10色 × primaryColor / darkColor / tintColor の3値を持つ。
enum TopicThemeColor {
  coralRed,
  amberOrange,
  goldenYellow,
  freshGreen,
  emeraldGreen,
  tealGreen,
  brandTeal,
  indigoBlue,
  violetPurple,
  rosePink;

  /// メインカラー
  Color get primaryColor => switch (this) {
        TopicThemeColor.coralRed => const Color(0xFFD94F4F),
        TopicThemeColor.amberOrange => const Color(0xFFE07B39),
        TopicThemeColor.goldenYellow => const Color(0xFFC4A43A),
        TopicThemeColor.freshGreen => const Color(0xFF4DB36B),
        TopicThemeColor.emeraldGreen => const Color(0xFF2E9E6B),
        TopicThemeColor.tealGreen => const Color(0xFF1E8A8A),
        TopicThemeColor.brandTeal => const Color(0xFF2B7A9B),
        TopicThemeColor.indigoBlue => const Color(0xFF3D65C4),
        TopicThemeColor.violetPurple => const Color(0xFF7B5CC4),
        TopicThemeColor.rosePink => const Color(0xFFC4497A),
      };

  /// ダークバリアント（グラデーション開始色）。
  /// primaryColor の輝度を 0.75 倍にした色。
  Color get darkColor {
    final hsl = HSLColor.fromColor(primaryColor);
    final darkened = hsl.withLightness(
      (hsl.lightness * 0.75).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// 淡い背景色（カード背景への Tint 用）。
  /// primaryColor を不透明度 0.15 で重ねた色。
  Color get tintColor => primaryColor.withValues(alpha: 0.15);

  /// Topic 未設定時のデフォルトカラー（グレー）
  static TopicThemeColor get defaultThemeColor => TopicThemeColor.brandTeal;

  /// Topic 未設定時の左ボーダー用グレーカラー
  static Color get defaultBorderColor => const Color(0xFF9E9E9E);
}
