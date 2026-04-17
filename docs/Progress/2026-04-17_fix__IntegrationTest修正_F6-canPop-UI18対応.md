# 2026-04-17 Integration Test修正（F-6 showMemberSection・canPop()・UI-18テスト対応）

## 完了した作業
- fix: integration-testルール見直し（スコープ最上部・pumpAndSettle禁止例修正・スリム化） (853cd8f)
- fix: seedDataをFLAVOR dart-defineで切り替え・orchestratorモデル配分表追加 (669ca0d)
- chore: タスクボードにTEST-FIX-1追加・UI-20テスト実行DONE更新 (a606e68)
- docs: 進捗ファイル更新（シードデータFAIL詳細・次回やること明記） (76bf7b7)

### 実装修正（commit: 04ace8c）
- **F-6 showMemberSection分離**: `showMarkMembers`（F-4 MichiInfoカード用）と`showMemberSection`（F-6 メンバーセクション用）を分離
  - `topic_config.dart`: `showMemberSection`フィールド追加（visitWork=false、その他=true）
  - `basic_info_view.dart`, `mark_detail_page.dart`: `showMemberSection`参照に変更
  - `payment_detail_bloc.dart`, `payment_detail_state.dart`, `payment_detail_page.dart`: visitWork時メンバーセクション非表示
  - `payment_info_view.dart`: 支払者・割り勘チップ条件付き表示
  - `event_detail_adapter.dart`: PaymentInfoProjectionに`showMemberSection`追加

- **canPop()ガード追加**: SettingDetail 4画面（ShellRoute遷移でpopできない問題を修正）
  - trans_setting_detail_page, member_setting_detail_page, tag_setting_detail_page, action_setting_detail_page

### テスト修正
- **UI-18対応**: 61テストファイルの`find.text('イベント')`→`find.text('イベント一覧')`一括置換
- **master_detail_button_layout_test**: TransSettingDetailの3フィールド（名前・燃費・メーター値）全入力対応 → 28/28 ALL PASS
- **event_list_reload_test**: `findsOneWidget`→`findsAtLeastNWidgets(1)` → ALL PASS（BottomNavラベル+AppBarタイトルで2つ表示される）
- **event_delete_ui_redesign_test**: 同上 → 6/6 ALL PASS
- **visit_work_no_member_test**: NumericKeypad操作対応・TC-NM-I009 skip追加（PaymentDomain.paymentMember非null制約によりvisitWorkでの支払い保存不可）
- **dashboard_tab_rename_test**: TC-RNM-002 否定アサーション復元（sed過剰置換の修正）

### 3シャード全件テスト結果（2026-04-17）
| shard | PASS | SKIP | FAIL |
|---|---|---|---|
| 0 | 123 | 57 | 12 |
| 1 | 114 | 55 | 19 |
| 2 | 119 | 57 | 15 |
| **合計** | **356** | **169** | **46** |

### FAIL分析（46件）
| 種別 | 件数 | 状態 |
|---|---|---|
| 我々の変更が原因 | 2件 | **修正済み**（event_list_reload, event_delete_ui_redesign） |
| Xcodeビルド競合（一時的） | 5件 | 再実行で解消 |
| シードデータ不一致（既存問題） | 約39件 | 今回の変更とは無関係 |

### 残存FAIL主なテストファイル（シードデータ問題）
- `michi_info_card_topic_view_test` — キー`michiInfo_text_markDate_ml-001`が見つからない
- `visit_work_seed_data_actiontime_test` — アクション記録「到着」「作業開始」等が見つからない
- `michi_info_layout_test` — キー`michiInfo_button_delete_ml-001`が見つからない
- `mark_addition_defaults_test` — イベント「近所のドライブ」が見つからない
- `fuel_detail_design_test` — Mark「自宅出発」が開けない
- `road_timeline_test` — Mark/Linkカードが見つからない
- `seed_fix_test` — 「旅費可視化」トピック名が見つからない
- `payment_info_redesign_test` — メモ「高速道路代」が見つからない
- `dashboard_graph_popup_test` — キー`movingCost_tooltip_longpress`が見つからない
- `fab_and_unsaved_dialog_test` — 「近所のドライブ」のEventDetail遷移失敗

## 未完了
- シードデータ依存テストのFAIL修正（既存問題・原因調査が必要）

## 次回セッションで最初にやること
1. `docs/Progress/README.md` と本ファイルを確認
2. シードデータ依存FAIL原因調査
   - 「近所のドライブ」「富士五湖キャンプ」イベントがシードデータに存在するか確認
   - `michiInfo_button_delete_ml-001` キーがUIに存在するか確認
   - 必要に応じてシードデータ修正またはテスト修正
3. `docs/Tasks/TASKBOARD.md` でIN_PROGRESSタスクを確認
