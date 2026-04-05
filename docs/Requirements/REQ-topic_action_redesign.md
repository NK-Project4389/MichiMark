# 要件書: Topic・Action 設計再定義

要件書ID: REQ-topic_action_redesign
作成日: 2026-04-05
ステータス: 確定

---

## 背景・目的

Topic/ActionTime 実装後の実際の操作感から、以下の課題が明確になった。

- トピックはイベントの性質を決定するものであり、作成後に変更すると表示制御が不整合になる
- アクションはユースケース（トピック）ごとに固定すべきであり、汎用マスタとして自由編集させる設計は過剰
- アクションの「遷移前状態（fromState）」はUIフローの観点から不要であり、簡素化したい
- 設定画面からイベント一覧へ戻る導線がない

---

## 要件一覧

### REQ-001: トピックはイベント新規作成時にのみ選択可能

**概要**
TopicはEventDetailの基本情報タブでの変更を廃止し、イベント新規作成フロー（将来実装のEventList新規作成）でのみ設定可能にする。

**変更内容**
- BasicInfo Feature からTopic選択UIを削除する
- 代わりに、新規イベント作成時のフローにTopic選択ステップを追加する（EventListの新規作成フロー、T-021で対応）
- 作成済みイベントのTopicは変更不可とする
- EventDetailのBasicInfoではTopicを「表示のみ（読み取り専用ラベル）」として表示する

**背景**
Topicはイベントの「用途カテゴリ」であり、作成後に変更するとMarkDetail/LinkDetailなどの表示制御が不整合になる。作成時に確定させることで整合性を保つ。

**注意: 現フェーズ（T-021未実装）の暫定対応**
T-021（EventList新規作成フロー）が未実装のため、新規作成時のTopic選択は現時点では別途検討する（例: EventDetail初回表示時にダイアログで選択、またはデフォルトでmovingCostを設定）。本要件の優先実装対象はBasicInfoからのTopic変更UIの廃止。

---

### REQ-002: アクションはトピックに紐づいて地点/区間ごとに固定表示

**概要**
ActionTimeBlocが提示するアクション候補を、全Actionマスタから動的に取得する代わりに、「現在のTopicと地点/区間の種別」によって固定のアクションセットを返す。

**変更内容**
- TopicConfig に `markActions: List<String>` と `linkActions: List<String>` を追加する（ActionIDのリスト）
- ActionTimeAdapterはAvailableActionsをfromState照合から **TopicConfigのアクションリスト** に切り替える
- 地点（Mark）タップ時 → `TopicConfig.markActions` のActionのみ表示
- 区間（Link）タップ時 → `TopicConfig.linkActions` のActionのみ表示
- アクション候補の提示方法の変更：fromState照合ロジックを廃止し、TopicConfig定義のリストで代替する

**各TopicのデフォルトAction割り当て（ハードコード）**

| TopicType | markActions（地点用） | linkActions（区間用） |
|---|---|---|
| movingCost | 出発, 到着, 帰着 | （なし） |
| travelExpense | チェックイン, チェックアウト | （なし） |

> 具体的なAction名・IDはSeedDataと一致させる。architectがSpec作成時に確定させること。

---

### REQ-003: ActionSettingマスタ画面を一時非表示化

**概要**
Settings画面からActionSettingへの導線を一時的に非表示にする。

**変更内容**
- SettingsPage の一覧から「アクション」の行を非表示にする（UIレベルの非表示。コード・Routeは残す）
- ActionDomainのSeedDataはアプリ起動時に自動投入する（ActionSetting画面経由での編集は不可）
- 非表示にするのはUI導線のみ。Router定義・BLoC・Repository は削除しない

**理由**
ActionマスタはTopicと連動して固定化するため、ユーザーによる自由編集は現フェーズでは不要。将来フェーズで再公開可能なよう、実装は残す。

---

### REQ-004: ActionDomainからfromStateを廃止

**概要**
ActionDomainの `fromState` フィールドを廃止する。遷移前状態による発火制約を撤廃し、アクション候補はTopicConfigで制御する（REQ-002）。

**変更内容**
- `ActionDomain.fromState` フィールドを削除する
- `ActionSettingDraft.fromState` フィールドを削除する
- `ActionSettingProjection.fromStateLabel` フィールドを削除する
- `ActionSettingDetailEvent.ActionFromStateUpdated` を削除する
- DBの `actions.from_state` カラムはNULLABLEのまま残す（マイグレーション不要。アプリ側では使用しない）
- ActionTimeAdapterのfromState照合ロジックを削除する

**注意**
DBカラムは互換性のためスキーマから除去しないが、アプリロジックでは参照しない。

---

### REQ-005: needsTransitionフラグを追加

**概要**
ActionDomainに `needsTransition: bool` フラグを追加する。

**定義**

| フラグ値 | 挙動 |
|---|---|
| `true` | ActionTimeLogを記録 **かつ** `toState` への状態遷移を行う |
| `false` | ActionTimeLogを記録するのみ。状態遷移は発生しない（toStateは無視） |

**変更内容**
- `ActionDomain` に `needsTransition: bool`（デフォルト `true`）を追加する
- `ActionTimeAdapter` の状態導出ロジックを修正：`needsTransition == false` のActionTimeLogは `toState` 計算から除外する
- DBの `actions` テーブルに `needs_transition` カラムを追加する（INTEGER BOOLEAN, NOT NULL, DEFAULT 1）
- SeedDataの各Actionに `needsTransition` を設定する
- ActionSettingDetailDraft / Projection / BLoC への `needsTransition` フィールド追加（将来の設定画面再公開時のため）

**デフォルトSeedData例**

| actionName | toState | needsTransition | 備考 |
|---|---|---|---|
| 出発 | moving | true | 遷移あり |
| 到着 | working | true | 遷移あり |
| 帰着 | waiting | true | 遷移あり |
| 休憩開始 | break_ | true | 遷移あり |
| 休憩終了 | working | true | 遷移あり |
| メモ | null | false | 時間ログのみ（例） |

> 具体的なSeedDataはarchitectがSpec確定時に定義すること。

---

### REQ-006: Settings画面にイベント一覧へ戻るボタンを実装

**概要**
Settings画面のAppBar（またはボトム）に「イベント一覧へ戻る」ボタンを追加し、イベント一覧画面（/events）へ遷移できるようにする。

**変更内容**
- `SettingsPage` のAppBarにボタンまたはリンクを追加する
- タップ時は `context.go('/events')`（または同等のルート）で遷移する
- BLoC経由Delegateパターンを使用する（BLoC内でのcontext直接操作禁止）

---

## スコープ外（本要件で対応しないもの）

- EventList新規作成フロー（Topic選択ステップの追加）→ T-021で対応
- ActionSettingマスタ画面の再公開
- カスタムTopicの作成
- isToggle / togglePairId の廃止（現状維持）

---

## 影響コンポーネント一覧

| コンポーネント | 変更概要 |
|---|---|
| `ActionDomain` | `fromState` 削除・`needsTransition` 追加 |
| `ActionSettingDraft/Projection/Bloc` | `fromState` 削除・`needsTransition` 追加 |
| `ActionTimeAdapter` | fromState照合ロジック廃止・needsTransition考慮 |
| `TopicConfig` | `markActions`・`linkActions` 追加 |
| `BasicInfoView/Bloc/Draft` | Topic選択UI削除・読み取り専用ラベル追加 |
| `SettingsPage` | ActionSetting行の非表示・イベント一覧戻るボタン追加 |
| `drift DBスキーマ` | `actions.needs_transition` カラム追加（schemaVersion +1） |
| `SeedData` | fromState削除・needsTransition設定 |

---

## 受け入れ条件

- [ ] 既存のEventDetailBasicInfoでTopicを変更できないこと（選択UIが表示されない）
- [ ] BasicInfoでTopicが読み取り専用ラベルとして表示されること
- [ ] ActionTime画面でのアクション候補がTopicConfig定義のリストから取得されること
- [ ] 地点（Mark）と区間（Link）でそれぞれ異なるアクションセットが表示されること
- [ ] Settings画面にActionの行が表示されないこと
- [ ] ActionDomainにfromStateが存在しないこと
- [ ] needsTransition = false のActionをタップするとActionTimeLogは記録されるが状態遷移は起きないこと
- [ ] needsTransition = true のActionをタップするとtoStateへの状態遷移が起きること
- [ ] Settings画面の「イベント一覧へ戻る」ボタンタップでイベント一覧に遷移すること
