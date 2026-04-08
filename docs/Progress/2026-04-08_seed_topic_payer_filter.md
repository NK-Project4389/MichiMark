# 2026-04-08 シードデータトピック追加・支払者参加者制限・イベント一覧トピック名表示

## 完了した作業

### 1. シードデータにトピック追加
- event-001（箱根日帰りドライブ）に「移動コスト可視化」トピック設定
- event-002（富士五湖キャンプ）に「旅費可視化」トピック設定
- event-003（近所のドライブ）はトピックなし（テストバリエーション維持）

### 2. 概要タブのガソリン支払者を参加者のみに制限
- `basic_info_view.dart`: SelectionArgsに`candidateMembers`を追加
- `selection_bloc.dart`: `gasPayMember`/`payMember`/`splitMembers`/`eventMembers`ケースで`_candidateMembers`を使用するよう修正
  - 以前は`markMembers`/`linkMembers`のみcandidateMembersを参照していたバグを修正
- 支払いタブは既にcandidateMembersで正しくフィルタリング済み

### 3. イベント一覧にトピック名表示
- `EventSummaryItemProjection`に`topicName`フィールド追加
- `EventListAdapter`でtopicNameをセット
- `_EventListItem`でイベント名の下にlabelSmallスタイル・テーマカラーでトピック名を表示

### 4. 運用ルールにtester必須ルール追加
- `.claude/rules/workflow.md`に「tester 必須ルール（全サイクル共通）」セクション追加
- reviewer承認後、push前に必ずtester実行（tester未実行でのpush禁止）

## Integration Test結果
- TC-SEED-001: イベント一覧で「移動コスト可視化」トピック名表示 → PASS
- TC-SEED-002: イベント一覧で「旅費可視化」トピック名表示 → PASS
- TC-SEED-003: 概要タブの支払者選択で参加者のみ表示 → PASS

## 修正ファイル
- `flutter/lib/repository/impl/in_memory/seed_data.dart`
- `flutter/lib/features/basic_info/view/basic_info_view.dart`
- `flutter/lib/features/selection/bloc/selection_bloc.dart`
- `flutter/lib/features/event_list/projection/event_list_projection.dart`
- `flutter/lib/adapter/event_list_adapter.dart`
- `flutter/lib/features/event_list/view/event_list_page.dart`
- `.claude/rules/workflow.md`
- `flutter/integration_test/seed_fix_test.dart`

## 次回セッションで最初にやること
- タスクボードT-080のステータス更新（シードデータ更新の残作業確認）
- T-070（日付セパレーターSpec作成）の着手検討
