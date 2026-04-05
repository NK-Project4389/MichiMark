# 進捗記録: EventCreateWithTopic 実装

日付: 2026-04-05
担当: flutter-dev

---

## 完了した作業

### EventCreateWithTopic Feature 実装（T-021b）

Spec: `docs/Spec/Features/EventCreateWithTopic_Spec.md`

#### 新規作成ファイル

- `flutter/lib/features/event_detail/event_detail_args.dart`
  - `EventDetailArgs(initialTopicType: TopicType?)` クラス

#### 変更ファイル

- `flutter/lib/features/event_list/bloc/event_list_event.dart`
  - `EventListTopicSelectedForNewEvent(topicType, eventId)` 追加
- `flutter/lib/features/event_list/bloc/event_list_state.dart`
  - `OpenAddEventDelegate` 廃止 → `OpenAddEventWithTopicDelegate(topicType, eventId)` 追加
  - `EventListLoaded.showTopicSelection: bool` フィールド追加
  - `copyWith` で `showTopicSelection` はデフォルト `false` にリセット
- `flutter/lib/features/event_list/bloc/event_list_bloc.dart`
  - `_onAddButtonPressed`: `showTopicSelection: true` をemit
  - `_onTopicSelectedForNewEvent`: `OpenAddEventWithTopicDelegate` をemit
- `flutter/lib/features/event_list/view/event_list_page.dart`
  - `StatefulWidget` 化
  - `_handleShowTopicSelection()` 追加（showModalBottomSheet→結果受け取り→Bloc発火）
  - `_TopicSelectionSheet` Widget追加（TopicType.values ループ・TopicConfig使用）
  - `_handleDelegate` に `OpenAddEventWithTopicDelegate` ケース追加
- `flutter/lib/features/basic_info/bloc/basic_info_event.dart`
  - `BasicInfoStarted` に `initialTopicType: TopicType?` 追加
- `flutter/lib/features/basic_info/bloc/basic_info_bloc.dart`
  - `TopicRepository` DI追加
  - `_onStarted`: `NotFoundError` catchで新規初期化ロジック追加（initialTopicTypeでDraft初期化）
- `flutter/lib/features/event_detail/view/event_detail_page.dart`
  - `EventDetailPage(initialTopicType: TopicType?)` コンストラクタ追加
  - `BasicInfoBloc` 生成時に `topicRepository` DI・`initialTopicType` を `BasicInfoStarted` に渡す
- `flutter/lib/app/router.dart`
  - `/event/:id` GoRoute で `state.extra as EventDetailArgs?` を受け取り `initialTopicType` を渡す

#### 確認事項

- `flutter analyze`: 本実装に関するエラーなし（既存の info 警告7件のみ）

---

## 未完了

- T-021c: イベント新規作成フロー レビュー（reviewer対応待ち）

---

## 次回セッションで最初にやること

- `reviewer` に T-021c（EventCreateWithTopic レビュー）を実施させる
