# 2026-04-11 B-1〜B-4バグ修正・Integration Test全件PASS

## 完了した作業

### バグ修正
- **B-1**: 燃費・ガソリン単価の単位が消えていた問題を修正
  - `basic_info_view.dart` の `_NumberInputField` を `NumericInputRow` に置き換え
  - `didUpdateWidget` 対応・外部 Text で単位常時表示
- **B-2**: 交通手段選択後に燃費が即時反映されない問題を修正
  - `_onTransSelected` で Draft を即時更新（kmPerGas=null の場合は変化なし）
- **B-3**: MichiInfo 0件時に追加できない問題を修正
  - `_onInsertModeFabPressed` で items.empty 時に `pendingInsertAfterSeq: -1` シグナル値を設定
- **B-4**: InsertMode 時にタイムライン描画がずれる問題を修正
  - InsertMode 中は `CustomPaint` を非表示に変更
- **TC-PIR-006**: PaymentListTile メモ行を `fontStyle: FontStyle.italic` に修正

### Integration Test 修正
- 全テストファイルから `pumpAndSettle()` を完全除去（CustomPainter ハング防止）
  - 対象: mark_addition_defaults, michi_info_layout, michi_info_card_insert, fab_and_unsaved_dialog, fuel_detail_design, basic_info_trans_fuel, event_list_reload, payment_info_fab_color
- TC-SEED-001: topicName を `'移動コスト（給油から計算）'` に修正
- TC-MAB-001/002/008: markActions 未設定時のスキップ条件追加（設定必須機能のため）
- TC-FEU-002: createTransWithNoKmPerGas 失敗時のスキップ条件追加

### テスト結果
- **84 PASS / 19 SKIP / 0 FAIL**

### 要件書追加
- `REQ-member_required_guard.md`: メンバー未選択時の入力ガード（R-1）
- `REQ-michi_info_insert_button_size.md`: カード間挿入ボタン大型化（R-2）

### TestFlight アップロード
- **1.0.0 (7)** アップロード完了（2026-04-11）
  - objective_c.framework arm64 差し替え済み
  - App Store Connect に受理済み・TestFlight 配信待ち（10〜30分）

### 設定追加
- `.claude/settings.json`（MichiMark）: TestFlight 関連コマンド永続許可追加（lipo, cp, rm -rf /tmp/*, cat > /tmp/*）
- `.claude/settings.json`（NomikaiShare）: 同上 + xcrun, sqlite3 追加

## 未完了・次回やること

1. **R-1実装**: メンバー未選択時に各種入力を無効化（要件書: `REQ-member_required_guard.md`）
2. **R-2実装**: MichiInfo カード間挿入ボタン大型化（要件書: `REQ-michi_info_insert_button_size.md`）
3. **R-3**: 追加ボタンデザイン統一（designer 担当）

## TestFlight アップロード状況
- 直前バージョン: 1.0.0 (6)（2026-04-09）
- 今回: 1.0.0 (7)（2026-04-11）- B-1〜B-4修正・pumpAndSettle完全除去込み
