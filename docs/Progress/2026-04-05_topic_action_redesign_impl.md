# Topic・Action再定義 実装（REQ-001〜006）

## 作業日: 2026-04-05

---

## 完了した作業
- docs: 進捗ファイルにバグ修正内容を追記 (d6a6a08)
- chore: iOS設定・進捗ドキュメント更新 (2d6116e)
- fix: 新規イベント作成時のトピック引き継ぎ不具合修正 (4443720)
- feat: T-021 イベント新規作成時のトピック選択フロー実装 (bfd7bfe)
- feat: EventCreateWithTopic実装 - Topic選択BottomSheet・BasicInfoBloc初期化・ルーター対応 (9a62b8d)
- docs: Phase 5完了 進捗記録・タスクボード更新 (52b9693)
- feat: REQ-007/008 トピックテーマカラー実装 (34c4212)
- feat: REQ-001〜006 Topic・Action再定義実装 (d80eed0)

### REQ-001: BasicInfoでTopicを読み取り専用表示に変更

- `BasicInfoDraft` から `availableTopics` フィールド削除
- `BasicInfoEvent` から `BasicInfoEditTopicPressed`・`BasicInfoTopicSelected`・`BasicInfoAvailableTopicsReceived` 削除
- `BasicInfoState` から `BasicInfoOpenTopicSelectionDelegate`・`BasicInfoTopicChangedDelegate` 削除
- `BasicInfoBloc` から Topic変更関連イベント処理削除
- `BasicInfoView` のTopic行を `_ReadOnlyRow`（読み取り専用ラベル）に変更
- `EventDetailEvent` から `EventDetailTopicChanged` 削除
- `EventDetailState` から `EventDetailAvailableTopicsDelegate` 削除
- `EventDetailBloc` から `TopicRepository` 依存削除・`EventDetailAvailableTopicsDelegate` 廃止
- `EventDetailPage` から BasicInfoTopicChangedDelegate リスナー削除
- router.dart の EventDetailBloc 初期化から `topicRepository` 引数削除

### REQ-002: ActionTimeAdapterをTopicConfigベースに変更

- `TopicConfig` に `markActions: List<String>` と `linkActions: List<String>` を追加
- `TopicConfig.fromTopicType()` で movingCost の markActions に `['action-seed-depart', 'action-seed-arrive']` を設定
- `ActionTimeAdapter` の `deriveAvailableActions` を TopicConfig参照に変更（fromState照合廃止）
- `ActionTimeAdapter` の `buildDraftAndProjection` に `topicConfig`・`markOrLink` 引数追加
- `ActionTimeDraft` に `topicConfig`・`markOrLink` フィールド追加
- `ActionTimeStarted` Event に `topicConfig`・`markOrLink` 引数追加
- `ActionTimeBloc` を更新

### REQ-003: Settings画面のActionSetting行を非表示

- `SettingsPage` から「行動」`_SettingsRow` を削除（UIのみ、コード・Router・BLocは維持）

### REQ-004: ActionDomainからfromStateを廃止

- `ActionDomain` から `fromState` フィールド削除
- `ActionSettingDetailDraft` から `fromState` フィールド削除
- `ActionSettingDetailProjection` から `fromStateLabel` フィールド削除
- `ActionSettingDetailEvent` から `ActionSettingDetailFromStateChanged` 削除
- `ActionSettingDetailBloc` から fromState処理削除
- `ActionSettingDetailPage` から fromState設定UI削除
- `MasterDao` の `_toActionDomain` で from_state カラム読み取り廃止（DBカラムは残す）
- `MasterDao` の `_toActionCompanion` で from_state の書き込みを削除（NULLABLEカラムとして残す）

### REQ-005: ActionDomainにneedsTransitionを追加

- `ActionDomain` に `needsTransition: bool`（デフォルト `true`）追加
- `ActionSettingDetailDraft` に `needsTransition: bool` 追加
- `ActionSettingDetailProjection` に `needsTransition: bool` 追加
- `ActionSettingDetailEvent` に `ActionSettingDetailNeedsTransitionChanged` 追加
- `ActionSettingDetailBloc` に needsTransition処理追加
- `ActionSettingDetailPage` に needsTransition SwitchListTile 追加
- Drift `Actions` テーブルに `needsTransition` カラム追加
- `database.dart` の schemaVersion を 2 → 3 に更新・マイグレーション追加（`needs_transition` カラム追加・`topics.color` カラム追加枠）
- `MasterDao` で needsTransition の読み書き追加
- SeedData に「出発」（toState: moving, needsTransition: true）・「到着」（toState: working, needsTransition: true）を追加（固定ID: `action-seed-depart`・`action-seed-arrive`）
- `ActionTimeAdapter.deriveCurrentState` を needsTransition=false のログを除外するよう更新

### REQ-006: Settings画面にイベント一覧へ戻るボタン追加

- `SettingsBloc`・`SettingsEvent`・`SettingsState`（`SettingsNavigateToEventsDelegate`）を新規作成
- `SettingsPage` に AppBar の leading に「戻る」ボタン追加・BlocListener で `/events` へ遷移
- router.dart の `/settings` ルートに `BlocProvider<SettingsBloc>` を追加

---

## 未完了・スコープ外

- REQ-007・008（TopicテーマカラーのEventList/EventDetailへの適用）: デザイン確定待ち
- T-052 レビューは別セッションで実施予定

---

## 次回セッションで最初にやること

1. **T-052: Topic・Action再定義 レビュー（reviewer）**
   - 今回の実装が設計憲章・Specに従っているかレビュー
2. 実機/シミュレータで動作確認（flutter run）
3. REQ-007/008 デザイン承認後に実装着手
