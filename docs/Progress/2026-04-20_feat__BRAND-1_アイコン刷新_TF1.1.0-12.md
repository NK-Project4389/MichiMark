---
date: 2026-04-20
task: BRAND-1 アイコン刷新・スプラッシュ背景色更新・TestFlight 1.1.0(12)
status: DONE
---

# BRAND-1: アイコン刷新・TF 1.1.0(12) アップロード

## 完了した作業

### T-620: HOTFIX-2 Share.sharePositionOrigin 修正
- `result_view.dart` の `_share()` に `sharePositionOrigin: rect` 追加
- Navigator.pop前後の問題はなし・sharePositionOrigin未指定が根本原因

### T-613: アイコン書き出し・flutter_launcher_icons適用
- `docs/Design/Logo_v2.png`（ユーザーFigma作成）を採用
- `flutter/assets/icon/app_icon.png` に配置
- `flutter_launcher_icons: ^0.14.3` 追加・`remove_alpha_ios: true` 設定
- iOS/Android 全サイズ生成完了

### T-614: スプラッシュ背景色更新
- `_kSplashBackgroundColor`: `#2B7A9E` → `#A8D4E6`（アイコンの薄青カラーに統一）

### TestFlight 1.1.0 (12) アップロード
- EXPORT SUCCEEDED・App Store Connect 処理待ち（10〜30分）

## アイコンデザイン経緯

- HTMLデザイン案（v1〜v3）を経てユーザーがFigmaで自作
- コンセプト: 薄青背景 × 濃Tealピン（穴あり）× 小→大ドット軌跡 × 斜め道路
- 「道を走った軌跡がピンに収束する」物語がシンボルとして表現されている

## 未完了

- T-611: BLOCKED（ユーザー自作完了・T-612 Figmaファイル化は今後不要）
- T-615: テスト実行（アイコン・スプラッシュの目視確認はTFで対応済み）

## 次回セッションで最初にやること

- TestFlight 1.1.0(12) の動作確認（アイコン・スプラッシュ目視確認）
- T-615 クローズ判断（目視確認OKなら DONE）
- 次の開発タスク着手（UI-15 イベントフィルター等）
