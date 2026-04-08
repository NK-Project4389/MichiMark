# 進捗記録 2026-04-09

## 完了した作業
- docs: 2026-04-09セッション進捗記録更新 (4b57744)

### タスクボード一括 DONE 更新（実機確認済み）
- T-020, T-022, T-023（EventList / マスタ初期投入 / Bundle ID設定）
- T-064〜067（タイムライン挿入UI FAB型）
- T-070〜072（MichiInfo 日付セパレーター Spec・実装・レビュー）
- T-075（地点追加初期値レビュー）
- T-080〜081（シードデータ更新・レビュー）

### アプリ設定
- アプリ表示名 `Michi Mark` → `MichiMark`（Info.plist CFBundleDisplayName）
- `.gitignore` に `.claude/worktrees/` を追加

### Phase 10 完全完了（T-094〜T-098）
- **要件書**: REQ-michi_info_action_button.md（B案: ⚡ ボタン + ボトムシート + 状態バッジ）
- **デザイン**: Violet（#7C3AED）採用。docs/Design/draft/ に HTML レポート
- **Spec**: ActionTimeButton_Spec.md
- **実装**: Mark カード右上に ⚡ ボタン / 状態バッジ / ボトムシートで ActionTimeView 展開
- **テスト**: 8 PASS / 1 SKIP / 0 FAIL

### バグ修正・改善（テスト過程で発覚）
- Drift DB `onCreate` でアクションマスタシード 7 件を自動投入
- `MichiInfoBloc._onStarted` で topicConfig 設定漏れを修正
- アクション記録後に `ActionTimeNavigateBackDelegate` emit してボトムシート自動クローズ

### Phase 11 タスク登録
- T-099〜T-103: MichiInfo タイムライン カード挿入機能（FAB 型）
- T-099 要件書作成完了（Pattern 3 FAB型・Amber #F59E0B）

---

## 未完了

- T-100: カード挿入機能 Spec 作成（architect）
- T-101〜103: カード挿入機能 実装・レビュー・テスト

---

## 次回セッションで最初にやること

1. **T-100**: MichiInfo カード挿入機能 Spec 作成（architect）
   - 要件書: `docs/Requirements/REQ-michi_info_card_insert.md`
   - sortOrder の中間値管理・挿入モード UI の詳細設計
2. **T-101〜103**: 実装 → レビュー → テスト

---

## バグ修正確認テスト（2026-04-09 追加セッション）

### 修正内容
`event_detail_page.dart` のグラデーション AppBar 戻るボタンを `EventDetailDismissPressed` 直接呼び出しから `_onBackPressed(context)` に変更。

### テスト結果

#### fab_and_unsaved_dialog_test.dart: 全件 PASS

| シナリオID | シナリオ名 | 結果 |
|---|---|---|
| TC-FAB-001 | MichiInfoView に FloatingActionButton.extended が表示される | PASS |
| TC-FAB-002 | PaymentInfoView に FloatingActionButton.extended が表示される | PASS |
| TC-FAB-003 | MarkDetailPage に保存 FloatingActionButton.extended が表示される | PASS |
| TC-FAB-004 | LinkDetailPage に保存 FloatingActionButton.extended が表示される | PASS |
| TC-FAB-005 | PaymentDetailPage に保存 FloatingActionButton.extended が表示される | PASS |
| TC-BACK-001 | Topic未設定イベントで編集中に戻るボタンタップで未保存確認ダイアログが表示される | PASS |
| TC-BACK-002 | Topic設定済みイベントで編集中にグラデーションAppBar戻るボタンタップで未保存確認ダイアログが表示される | PASS |
| TC-BACK-003 | Topic設定済みイベントで未編集時にグラデーションAppBar戻るボタンタップでイベント一覧に戻る | PASS |

#### event_detail_overview_redesign_test.dart: 12 PASS / 3 SKIP

TC-EOD-001〜009, TC-EOD-013〜015: PASS
TC-EOD-010〜012: SKIP（シードデータ依存）

### 既存テストで今回修正と無関係の FAIL（flutter-dev 要対応）

- **mark_addition_defaults_test.dart**:
  - TC-MAD-006: `IconButton.at(1)` でメンバー追加ボタン番号変更（入力画面刷新の影響）
  - TC-MAD-007: `Icons.check` AppBar 保存ボタン廃止（T-091 概要タブ再設計の影響）
- **michi_info_layout_test.dart**:
  - TS-03: `pumpAndSettle` タイムアウト（Mark タップ後の遷移確認）
  - TS-04: `find.text('反映')` / `find.text('区間詳細')` が見つからない（ボタン名変更の可能性）

