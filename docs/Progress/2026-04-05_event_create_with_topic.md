# 2026-04-05 イベント新規作成時のトピック選択フロー実装完了

## 完了した作業

### 要件書作成（product-manager）
- `docs/Requirements/REQ-event_create_with_topic.md` 作成
  - REQ-ECT-001: 新規作成時にトピック選択UIを表示
  - REQ-ECT-002: 選択されたトピックをEventDetailに引き渡す
  - REQ-ECT-003: 新規イベントのBasicInfo初期化

### Spec作成（architect）
- `docs/Spec/Features/EventCreateWithTopic_Spec.md` 作成（v1.0）
  - BottomSheet表示タイミング: `showTopicSelection` フラグ方式
  - ルーター: `extra` 方式（`EventDetailArgs` 新設）
  - `OpenAddEventDelegate` 廃止 → `OpenAddEventWithTopicDelegate` に統合

### 実装（flutter-dev）

**新規作成ファイル**
- `flutter/lib/features/event_detail/event_detail_args.dart` — `EventDetailArgs(initialTopicType: TopicType?)`

**変更ファイル（EventList Feature）**
- `event_list/bloc/event_list_event.dart` — `EventListTopicSelectedForNewEvent` 追加
- `event_list/bloc/event_list_state.dart` — `showTopicSelection` フィールド追加、`OpenAddEventDelegate` 廃止・`OpenAddEventWithTopicDelegate` 追加
- `event_list/bloc/event_list_bloc.dart` — `_onAddButtonPressed` 変更（showTopicSelection:true emit）、`_onTopicSelectedForNewEvent` ハンドラ追加
- `event_list/view/event_list_page.dart` — `StatefulWidget` 化、`_TopicSelectionSheet` 追加、BlocListenerにshowTopicSelection処理追加

**変更ファイル（BasicInfo Feature）**
- `basic_info/bloc/basic_info_event.dart` — `BasicInfoStarted` に `initialTopicType: TopicType?` 追加
- `basic_info/bloc/basic_info_bloc.dart` — `TopicRepository` DI追加・新規イベント時の初期化ロジック追加

**変更ファイル（EventDetail + Router）**
- `event_detail/view/event_detail_page.dart` — `initialTopicType` パラメータ追加・`BasicInfoBloc` 生成時に渡す
- `app/router.dart` — `state.extra as EventDetailArgs?` 対応

**変更ファイル（Repository）**
- `repository/topic_repository.dart` — `fetchByType` シグネチャを `Future<TopicDomain?>` に変更
- `repository/impl/in_memory/in_memory_topic_repository.dart` — `fetchByType` 実装を `Future<TopicDomain?>` に変更

### レビュー（reviewer）
- T-021c: **PASS**（修正1件：fetchByType戻り値をFuture<TopicDomain?>に統一）

---

## 動作フロー

```
FABタップ
  → EventListAddButtonPressed
  → EventListLoaded(showTopicSelection: true) emit
  → BlocListenerがBottomSheet表示
  → TopicType.values をTopicConfig.forType()で表示
  → ユーザーがトピック選択
  → EventListTopicSelectedForNewEvent(topicType, newEventId)
  → OpenAddEventWithTopicDelegate(topicType, eventId) emit
  → context.push('/event/$eventId', extra: EventDetailArgs(initialTopicType: topicType))
  → BasicInfoBloc: DB未存在 → initialTopicTypeでDraft初期化
```

---

## 未完了

- T-020: EventList Feature 実装（現状スタブのみ）
- T-022: マスターデータ初期投入
- T-023: app_id / Bundle ID / アイコン設定
- REQ-009: TopicSetting（表示/非表示設定）

---

## 次回セッションで最初にやること

1. **実機 or シミュレータで動作確認**
   - 「+」ボタンタップでTopicSelectionBottomSheetが表示されるか
   - トピック選択後にEventDetailに遷移し、BasicInfoのトピックラベルが正しく表示されるか
   - BottomSheetをスワイプで閉じたとき（キャンセル）にEventDetailに遷移しないか

2. **T-022: マスターデータ初期投入**（Trans/Member/Tag/Action のデフォルトデータ）

3. **REQ-009: TopicSetting Spec・実装**
