# EventCreateWithTopic Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
作成日: 2026-04-05
要件書: REQ-event_create_with_topic
関連Spec: Topic_Spec.md v2.1

---

# 1. Feature Overview

## Feature Name

EventCreateWithTopic（EventList新規作成フロー）

## Purpose

EventListの「+」ボタンタップ時にTopicType選択BottomSheetを表示し、選択されたTopicTypeをEventDetailのBasicInfo初期化に引き渡す。Topicはイベント作成後に変更不可であるため（REQ-001）、新規作成の入口でTopicを強制選択させる。

## Scope

含むもの
- EventList FABタップ時のTopicType選択BottomSheet表示制御
- BottomSheetでのTopicType選択 → EventDetail（新規）遷移
- `EventListAddButtonPressed` の挙動変更（直接遷移 → BottomSheet表示への切り替え）
- `EventListTopicSelectedForNewEvent` イベント追加
- `OpenAddEventWithTopicDelegate` Delegate追加
- `OpenAddEventDelegate` の廃止（`OpenAddEventWithTopicDelegate` に統合）
- `BasicInfoStarted` への `initialTopicType` パラメータ追加
- BasicInfoBloc の新規イベント初期化ロジック変更
- EventDetailPage での `BasicInfoStarted` 発火時の `initialTopicType` 引き渡し
- ルーター `/event/:id` の `extra` 対応（`EventDetailArgs` 新設）

含まないもの
- 既存イベント（既存eventId）のTopic変更UI
- TopicType選択BottomSheetの外部Feature化
- TopicType追加・カスタム作成（Phase 3）

---

# 2. Feature Responsibility

## EventList Feature（変更対象）

- BottomSheet表示意図の通知（`showTopicSelection` 状態を経由してView側でBottomSheetを表示）
- TopicType選択後に新規eventIdを生成し、Delegateで遷移意図を通知

## BasicInfo Feature（変更対象）

- `BasicInfoStarted` に `initialTopicType: TopicType?` を受け取る
- 新規イベント（DB未存在）の場合のみ `initialTopicType` でDraftを初期化
- 既存イベント（DB存在）の場合は `initialTopicType` を無視

---

# 3. BottomSheet表示タイミングの設計方針

## 方針: `showTopicSelection` フラグをStateに持ち、BlocListenerがBottomSheetを表示する

`EventListAddButtonPressed` 発火時、BlocはDraftに `showTopicSelection = true` をセットした状態を emit する。
EventListPageのBlocListenerが `showTopicSelection == true` を検知してBottomSheetを `showModalBottomSheet` で表示する。

この設計を採用する理由:
- Blocが直接Navigatorを呼ばない（設計憲章§9遵守）
- TopicType選択はBottomSheet内の結果をPage側で取得し、`EventListTopicSelectedForNewEvent` としてBlocに通知する
- Delegateパターンを用いるよりもBottomSheet特有の「表示→結果取得」というモーダル性との相性が良い

`showTopicSelection` は `EventListLoaded` の追加フィールドとして持たせる。BottomSheetを表示した後はPageがフラグをリセットするEventを発火するのではなく、BottomSheetのクローズを契機に次のEventが発火されるまで `showTopicSelection = true` を維持する（表示のトリガーとして使用するためidempotent性は要求しない）。

---

# 4. Draft Model

## EventListDraft（変更なし）

EventListはイベント一覧の表示のみを担うため、Draftは空のままとする。

| フィールド名 | 型 | 説明 |
|---|---|---|
| （なし）| - | - |

---

# 5. Domain Model

変更なし。TopicDomain・TopicType は既存定義を使用する。

---

# 6. Projection Model

## EventListProjection（変更なし）

既存定義を維持。

---

# 7. ルーター変更方針

## `extra` 方式を採用する（クエリパラメータ方式は不採用）

### 採用根拠

既存のルーターは `/event/mark/:markId`・`/event/link/:linkId`・`/event/payment` すべてで `state.extra` による型安全な引数受け渡しパターンを採用している（`MarkDetailArgs`・`LinkDetailArgs`・`PaymentDetailArgs`）。`TopicType` enum を URL文字列にシリアライズ/デシリアライズするクエリパラメータ方式はこの一貫したパターンに反し、型安全性の破壊（憲章§14.1違反）リスクがある。

### 変更内容

`EventDetailArgs` を新設する。

#### EventDetailArgs フィールド定義

| フィールド名 | 型 | NULL許容 | 説明 |
|---|---|---|---|
| `initialTopicType` | `TopicType?` | ✅ | 新規作成時にTopicを指定する。既存イベントでは `null` を渡す |

ルーターの `/event/:id` GoRoute の builder で `state.extra` を `EventDetailArgs?` にキャストし、`initialTopicType` を `EventDetailScaffold` → `BasicInfoBloc` 初期化時の `BasicInfoStarted` に引き渡す。

`extra` が `null` の場合（既存の `OpenEventDetailDelegate` 経由の遷移）は `initialTopicType = null` として扱う。

---

# 8. BLocEvent 定義

## EventList Feature 追加Event

### `EventListTopicSelectedForNewEvent`

| 項目 | 内容 |
|---|---|
| 発火タイミング | BottomSheetでTopicTypeが選択されたとき（PageがBottomSheet内の選択結果を受け取り発火） |
| フィールド | `topicType: TopicType`（選択されたTopic種別）、`eventId: String`（Page側で生成した新規UUID） |
| BlocのAction | `OpenAddEventWithTopicDelegate(topicType, eventId)` を emit する |

#### 設計Note: eventId生成の責務

新規 eventId は `const Uuid().v4()` で生成する。生成責務はEventListPage側（BottomSheet表示前またはDelegate処理時）とする。BlocはIDを受け取るのみで生成しない（Blocは副作用の少ないロジックのみ担当）。

## BasicInfo Feature 変更Event

### `BasicInfoStarted`（変更）

| 項目 | 内容 |
|---|---|
| 変更内容 | `initialTopicType: TopicType?` パラメータを追加 |
| デフォルト値 | `null` |
| 既存呼び出し箇所への影響 | `EventDetailPage` の1箇所のみ。名前付き引数で追加するため既存呼び出しコードは省略可能（null省略） |

---

# 9. BLocState 定義

## EventList Feature 変更State

### `EventListLoaded`（変更）

追加フィールド:

| フィールド名 | 型 | NULL許容 | 説明 |
|---|---|---|---|
| `showTopicSelection` | `bool` | ❌ | BottomSheet表示トリガー。trueになったらPageがBottomSheetを表示する |

`showTopicSelection` のデフォルト値は `false`。

`copyWith` では `showTopicSelection` をオプション引数として受け取り、省略時は `false` にリセットする（Delegateと同様の扱い）。BlocListenerがBottomSheet表示後に重複表示しないよう、`EventListTopicSelectedForNewEvent` 発火後に別Stateが emit されることでフラグが自然にリセットされる。

---

# 10. Delegate Contract

## EventList Feature 変更Delegate

### `OpenAddEventWithTopicDelegate`（追加）

| 項目 | 内容 |
|---|---|
| 遷移先 | `/event/:id`（`extra: EventDetailArgs(initialTopicType: topicType)`） |
| フィールド | `topicType: TopicType`、`eventId: String` |
| PageのAction | `context.push('/event/$eventId', extra: EventDetailArgs(initialTopicType: topicType))` |

### `OpenAddEventDelegate`（廃止）

`OpenAddEventWithTopicDelegate` に統合するため廃止する。削除対象ファイル: `event_list_state.dart` 内の `OpenAddEventDelegate` クラス定義。

---

# 11. Data Flow

## 新規イベント作成フロー（FABタップ → EventDetail初期化）

1. ユーザーがEventListのFABをタップする
2. EventListPageが `EventListAddButtonPressed` をBlocに発火する
3. EventListBlocが `EventListLoaded(showTopicSelection: true)` を emit する
4. EventListPageのBlocListenerが `showTopicSelection == true` を検知する
5. EventListPageが `showModalBottomSheet` でTopicType選択BottomSheetを表示する
6. BottomSheet内にすべての `TopicType.values` を `TopicConfig.forType(type).displayName` と `TopicConfig.forType(type).themeColor` で表示する（ハードコード禁止）
7. ユーザーがTopicTypeを選択する
8. EventListPageがBottomSheetを閉じ、新規 `eventId = Uuid().v4()` を生成し、`EventListTopicSelectedForNewEvent(topicType, eventId)` をBlocに発火する
9. EventListBlocが `OpenAddEventWithTopicDelegate(topicType, eventId)` を emit する
10. EventListPageのBlocListenerがDelegateを受け取り、`context.push('/event/$eventId', extra: EventDetailArgs(initialTopicType: topicType))` で遷移する
11. ルーターが `EventDetailArgs` を受け取り、`EventDetailScaffold` の `BasicInfoBloc` 初期化時に `BasicInfoStarted(eventId, initialTopicType: topicType)` を発火する
12. BasicInfoBlocがDB上に `eventId` が存在しないことを確認し、空のDraftに `selectedTopic` を `initialTopicType` に対応する `TopicDomain` で初期化する

## 既存イベント遷移フロー（変更なし）

1. ユーザーがイベント行をタップする
2. `EventListItemTapped(eventId)` → `OpenEventDetailDelegate(eventId)` → `context.push('/event/$eventId')` （extraなし）
3. ルーターが `state.extra` を `null` として扱い、`BasicInfoStarted(eventId, initialTopicType: null)` を発火する
4. BasicInfoBlocがDB上に `eventId` が存在することを確認し、DB値でDraftを初期化する（`initialTopicType` は無視）

---

# 12. BasicInfoBloc 変更仕様

## `_onStarted` の変更ロジック

1. DB から `eventId` で EventDomain を取得しようとする
2. EventDomain が存在した場合（既存イベント）: DB値からDraftを初期化する。`initialTopicType` は無視する（既存実装と変わらず）
3. EventDomain が存在しない場合（新規イベント、DBに未存在）:
   - 空のDraftを作成する
   - `initialTopicType` が非nullの場合、`TopicRepository` から対応する `TopicDomain` を取得し `selectedTopic` にセットする
   - `initialTopicType` が `null` の場合、`selectedTopic` は `null` のまま

### TopicDomain取得方針

`initialTopicType` を受け取った場合、`TopicRepository.fetchByType(TopicType)` で `TopicDomain` を取得する。このメソッドが既存の `TopicRepository` に存在しない場合は追加が必要。

---

# 13. TopicRepository 追加メソッド（BasicInfoBloc依存）

BasicInfoBlocが `initialTopicType: TopicType` から `TopicDomain` を取得するために必要。

## 追加メソッド

| メソッド名 | シグネチャ | 説明 |
|---|---|---|
| `fetchByType` | `Future<TopicDomain?> fetchByType(TopicType type)` | TopicTypeに一致するTopicDomainを返す。存在しない場合はnull |

---

# 14. BottomSheet Widget 設計方針

BottomSheetはEventListPage内のプライベートメソッド（`_showTopicSelectionSheet`）として実装する。独立したFeatureとしての切り出しはPhase 3まで不要。

## 表示内容

- タイトル: 「トピックを選択」
- 各選択肢: `TopicType.values` をループし、`TopicConfig.forType(type).themeColor.primaryColor` で色付きアイコン + `TopicConfig.forType(type).displayName` を表示する
- キャンセルボタン不要（スワイプでBottomSheetを閉じる標準動作で代替）

## Widgetが `StatefulWidget` であることの必要性

BottomSheetは `showModalBottomSheet` を `await` する必要はない。Pageは `showTopicSelection` フラグをBlocListenerで検知してBottomSheetを表示し、BottomSheet内でユーザーがTopicTypeをタップした時点で `context.pop(selectedTopicType)` で結果を返す。この結果をPageが受け取り、BlocにEventを発火する。

設計憲章§9「`context.push` を `await` する Widget は `StatefulWidget` とする」ルールに従い、EventListPageは `StatefulWidget` に変更する。

---

# 15. 変更ファイル一覧

| ファイル | 変更種別 | 変更内容 |
|---|---|---|
| `event_list/bloc/event_list_event.dart` | 変更 | `EventListTopicSelectedForNewEvent` 追加 |
| `event_list/bloc/event_list_state.dart` | 変更 | `EventListLoaded.showTopicSelection` フィールド追加、`OpenAddEventDelegate` 廃止・`OpenAddEventWithTopicDelegate` 追加 |
| `event_list/bloc/event_list_bloc.dart` | 変更 | `_onAddButtonPressed` 変更、`_onTopicSelectedForNewEvent` ハンドラ追加 |
| `event_list/view/event_list_page.dart` | 変更 | `StatefulWidget` 化、`_showTopicSelectionSheet` 追加、BlocListenerに `showTopicSelection` 処理追加、`_handleDelegate` に `OpenAddEventWithTopicDelegate` 追加 |
| `basic_info/bloc/basic_info_event.dart` | 変更 | `BasicInfoStarted` に `initialTopicType: TopicType?` 追加 |
| `basic_info/bloc/basic_info_bloc.dart` | 変更 | `_onStarted` の新規イベント初期化ロジック変更、`TopicRepository` DI追加 |
| `event_detail/view/event_detail_page.dart` | 変更 | `BasicInfoStarted` 発火時に `initialTopicType` を渡す処理追加 |
| `app/router.dart` | 変更 | `/event/:id` GoRoute の builder で `state.extra as EventDetailArgs?` を受け取り `initialTopicType` を渡す |
| `features/event_detail/event_detail_args.dart` | 新規作成 | `EventDetailArgs` クラス定義（`initialTopicType: TopicType?`） |
| `repository/topic_repository.dart` | 変更 | `fetchByType(TopicType)` メソッド追加（abstract + drift実装） |

---

# 16. 非機能要件

- BottomSheetがスワイプで閉じられた場合（キャンセル）、EventDetailに遷移しないこと
- Topicを選択せずにEventDetailに遷移する経路が存在しないこと（強制選択）
- TopicType表示はすべて `TopicType.values` と `TopicConfig` を使用し、ハードコードしないこと

---

# End of Feature Spec
