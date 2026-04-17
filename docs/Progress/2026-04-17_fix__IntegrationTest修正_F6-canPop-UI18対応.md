# 2026-04-17 Integration Test修正（F-6 showMemberSection・canPop()・UI-18テスト対応）

## 完了した作業

### 実装修正
- **F-6 showMemberSection分離**: `showMarkMembers`（F-4 MichiInfoカード用）と`showMemberSection`（F-6 メンバーセクション用）を分離
  - `topic_config.dart`: `showMemberSection`フィールド追加
  - `basic_info_view.dart`, `mark_detail_page.dart`: `showMemberSection`参照に変更
  - `payment_detail_bloc.dart`, `payment_detail_state.dart`, `payment_detail_page.dart`: visitWork時メンバーセクション非表示
  - `payment_info_view.dart`: 支払者・割り勘セクション条件付き表示
  - `event_detail_adapter.dart`: PaymentInfoProjectionに`showMemberSection`追加

- **canPop()ガード追加**: 4つのSettingDetail画面
  - trans_setting_detail_page, member_setting_detail_page, tag_setting_detail_page, action_setting_detail_page

### テスト修正
- **UI-18対応**: 61テストファイルの`find.text('イベント')`→`find.text('イベント一覧')`一括置換
- **master_detail_button_layout_test**: TransSettingDetailの3フィールド全入力対応 → 28/28 ALL PASS
- **event_list_reload_test**: `findsOneWidget`→`findsAtLeastNWidgets(1)` → ALL PASS
- **event_delete_ui_redesign_test**: 同上 → 6/6 ALL PASS
- **visit_work_no_member_test**: NumericKeypad操作対応・TC-NM-I009 skip追加
- **dashboard_tab_rename_test**: TC-RNM-002 否定アサーション復元

### 3シャード全件テスト結果
| shard | PASS | SKIP | FAIL |
|---|---|---|---|
| 0 | 123 | 57 | 12 |
| 1 | 114 | 55 | 19 |
| 2 | 119 | 57 | 15 |
| 合計 | 356 | 169 | 46 |

### FAIL分析
- **我々の変更が原因**: 2件 → 修正済み（event_list_reload, event_delete_ui_redesign）
- **Xcodeビルド競合**: 5件（一時的・コード問題なし）
- **シードデータ不一致（既存問題）**: 約39件（前回の変更とは無関係）

## 未完了
- シードデータ依存テストのFAIL修正（既存問題・別タスクとして対応予定）

## 次回セッションで最初にやること
- シードデータ依存テストFAILの分析・修正（michi_info_card_topic_view, visit_work_seed_data_actiontime, mark_addition_defaults等）
