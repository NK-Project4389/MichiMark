# 進捗: MichiInfo タイムライン UI 再設計 (v3.0)

日付: 2026-04-07

---

## 完了した作業

### 要件定義
- `docs/Requirements/REQ-michi_info_timeline_redesign.md` 作成
- 3つの変更要件を定義:
  1. Mark カードとドットの接続を三角ポインター → 水平罫線に変更
  2. タイムライン縦線をカード高さ範囲内に短縮
  3. 距離表示をマーク間スパン矢印形式に変更（4パターン対応）

### アーキテクチャ設計
- `docs/Spec/Features/MichiInfo_Layout_Spec.md` を v3.0 に更新
- B案（CustomScrollView + SliverList）を採用
  - 理由: `michi_info_view.dart` 内に閉じる（他 Widget への影響ゼロ）、単一描画コンテキストで座標管理がシンプル、将来の UI 拡張性が高い
- 主な設計変更:
  - `_MichiTimelineCanvas`（新設）: スパン矢印を背景レイヤー CustomPainter で描画
  - 距離表示2段構造: `_linkDistanceColumnWidth = 64.0` + `_spanArrowColumnWidth = 72.0`
  - `_SpanArrowOverlay`（C案）は採用せず廃止

### 実装
- `flutter/lib/features/michi_info/view/michi_info_view.dart` 全面刷新
  - 三角ポインター廃止・水平罫線接続
  - `ListView.builder` → `CustomScrollView + SliverList`
  - `_MichiTimelineCanvas` 新設（スパン矢印描画）
  - `_LinkDistanceCell` 新設（Link 個別距離表示）
  - `_DistanceColumn` 廃止
- バグ修正: `_TimelineItemOverlay` に `Positioned.fill` 追加（Link タップ領域修正）

### テスト
- `flutter/integration_test/michi_info_layout_test.dart` に TS-08〜TS-16 追加
- 全16件中 15 PASS / 1 SKIP（TS-09: シードデータにパターン1が存在しない）

---

## 未完了・次回やること

- [ ] **罫線接続の見た目調整**: 手動確認で罫線の見た目が微妙と判断。タスクボードのレイアウト修正タスクで対応予定
- [ ] **スパン矢印の座標精度確認**: スクロール後・アクションボタンあり Mark での目視確認
- [ ] **TS-09 パターン1の検証**: Link なし（Mark-Mark 直接）のシードデータを作って手動確認
- [ ] TS-09 用のシードデータが準備できれば Integration Test として追加可能

## 次回セッションで最初にやること

タスクボードの「MichiInfo レイアウト修正」タスクを確認し、罫線接続の見た目改善に着手する。

---

## 備考
- テスト実行時に tester エージェントの報告と実際の出力が食い違うケースがあった
  - 実際のテスト出力ファイルを直接確認することで問題を発見・修正
- `Positioned.fill` 漏れにより Link タップが機能しなかった（TS-04 が18分タイムアウト）
  - `CustomScrollView` 移行後はタップ領域のカバー範囲に注意が必要
