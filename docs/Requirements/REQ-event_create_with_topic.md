# 要件書: イベント新規作成時のトピック選択フロー

要件書ID: REQ-event_create_with_topic
作成日: 2026-04-05
ステータス: 確定
関連タスク: T-021

---

## 背景・目的

REQ-001（トピックはイベント新規作成時にのみ選択可能）で定義した通り、Topicはイベント作成後に変更不可とする。
したがって、新規イベントを作成するタイミングで必ずTopicを選択させる必要がある。

現状、EventListの「+」ボタンはトピック選択なしにEventDetailへ直接遷移しており、Topicが未設定のままイベントが作成される問題がある。

---

## 要件一覧

### REQ-ECT-001: 新規作成時にトピック選択UIを表示する

**概要**
EventListの「+」ボタンを押したとき、EventDetailへ遷移する前にトピック選択UI（BottomSheet）を表示する。

**変更内容**
- 「+」ボタン押下 → トピック選択BottomSheetを表示する
- BottomSheetにはすべてのTopicTypeを選択肢として表示する
- 各選択肢はトピックのテーマカラー（TopicThemeColor）と表示名（displayName）を示す
- トピックを選択後 → BottomSheetを閉じてEventDetailへ遷移する
- キャンセル（BottomSheetを閉じる）→ EventListに戻る（EventDetailには遷移しない）

**UI仕様**
- BottomSheetのタイトル: 「トピックを選択」
- 各トピックの表示: テーマカラーの色付きアイコン（丸・正方形など）+ 表示名
- キャンセルボタンは不要（スワイプで閉じる標準動作で代替）

---

### REQ-ECT-002: 選択されたトピックをEventDetailに引き渡す

**概要**
トピック選択後のEventDetail初期化において、選択されたTopicTypeが事前設定された状態でBasicInfoが読み込まれる。

**変更内容**
- EventListからEventDetailへの遷移時にTopicTypeをルートパラメータで渡す
- BasicInfoBlocはルートパラメータのTopicTypeを受け取り、新規イベントの初期topicとして設定する
- 既存イベント（eventIdがDB上に存在する場合）はこのパラメータを無視する

**データフロー**
```
FAB押下
  → EventListAddButtonPressed（BLoC event）
  → EventListState: showTopicSelection フラグON（またはDelegateで通知）
  → BottomSheet表示（View側で制御）
  → トピック選択
  → EventListTopicSelectedForNewEvent(topicType, newEventId)（BLoC event）
  → OpenAddEventWithTopicDelegate(topicType, newEventId)（Delegate発行）
  → /event/:id?topic=:topicType へ遷移
  → BasicInfoBloc: topic パラメータを初期値として設定
```

---

### REQ-ECT-003: 新規イベントのBasicInfo初期化

**概要**
新規イベント（DBに存在しないeventId）のBasicInfo初期化時に、渡されたTopicTypeでDraftを初期化する。

**変更内容**
- BasicInfoBlocの`BasicInfoStarted`に`initialTopicType`パラメータを追加する
- DB未存在の場合（新規作成）は空のDraftを作成し、`initialTopicType`をselectedTopicに設定する
- DB存在の場合（既存イベント）は従来通りDB値を使用し、`initialTopicType`は無視する

---

## 実装スコープ

| 変更対象 | 内容 |
|---|---|
| `EventListEvent` | `EventListTopicSelectedForNewEvent` イベント追加 |
| `EventListState` | `showTopicSelection` フラグ or 新Delegate追加 |
| `EventListDelegate` | `OpenAddEventWithTopicDelegate(topicType, eventId)` 追加 |
| `EventListBloc` | `_onAddButtonPressed` → showTopicSelection、`_onTopicSelectedForNewEvent` 追加 |
| `EventListPage` | BottomSheet表示ロジック追加 |
| `EventListRouter` | `/event/:id?topic=:topicType` のクエリパラメータ対応 |
| `BasicInfoStarted` | `initialTopicType` パラメータ追加 |
| `BasicInfoBloc` | 新規イベント時の`initialTopicType`設定ロジック追加 |
| `EventDetailPage` | BasicInfoStartedへの`initialTopicType`引き渡し |

---

## 非機能要件

- トピック未選択でEventDetailに遷移できないこと（強制選択）
- BottomSheetはModalとして表示し、バックグラウンドタップで閉じられること
- トピック選択UIはTopicConfigのdisplayNameとThemeColorを使用すること（ハードコード禁止）

---

## 関連ドキュメント

- `docs/Requirements/REQ-topic_action_redesign.md` REQ-001（TopicはEventDetail BasicInfoで変更不可）
- `docs/Spec/Features/Topic_Spec.md` v2.1
- `docs/Spec/Features/ActionTime_Spec.md` v2.0
