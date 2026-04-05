# ActionTime Feature Specification

Platform: **Flutter / Dart**
Version: 2.0
Purpose: ActionをEvent単位の状態遷移トリガーとして捉え、タイムスタンプをActionTimeLogとして蓄積することで「移動時間」「作業時間」「滞留時間」「休憩時間」を算出可能にする。

## 改版履歴

| バージョン | 日付 | 変更概要 |
|---|---|---|
| 1.0 | 初版 | ActionTime Feature 初期設計 |
| 2.0 | 2026-04-05 | REQ-002・004・005対応。ActionDomain変更・fromState廃止・needsTransition追加・TopicConfig連携 |

---

# 1. Feature Overview

## Feature Name

ActionTime

## Purpose

Actionが発生した日時をイベント単位でログ（ActionTimeLog）として記録する。ActionTimeLogの時系列から現在の状態（ActionState）を導出し、各状態の経過時間を可視化できる基盤を構築する。

## Scope

含むもの
- ActionState enum の新規定義（Domain層）
- ActionDomain への状態遷移フィールド追加（toState / isToggle / togglePairId・needsTransition）
- ActionTimeLog Domain の新規定義（EventIDに直接紐づく）
- EventDomain への actionTimeLogs フィールド追加
- EventRepository への ActionTimeLog CRUD 操作追加（独立 Repository は作らない）
- ActionTimeLog 記録 BLoC 設計（action_time Feature）
- 状態導出ロジック（Adapter/UseCase層）
- ActionTime 記録UI（記録ボタン・現在状態表示・休憩トグル・タイムラインログ表示）
- 設定画面（action_setting Feature）への toState / isToggle / needsTransition 設定追加
- デフォルトマスタデータ（出発・到着の2種）の初期投入

含まないもの
- GPS位置情報との連携・自動到着検知
- 複数イベント横断での状態管理
- タイムラインのグラフ表示（Aggregation要件書参照）
- ActionTimeLog 専用の独立 Repository
- fromState照合によるAction候補提示（REQ-004により廃止。TopicConfig連携に移行）

---

# 2. Domain 変更・追加

## 2.1 ActionState enum（新規・Domain層）

Actionが表す状態遷移の「状態種別」を定義する。

| 値 | 説明 |
|---|---|
| `waiting` | 移動前・終了後の滞留状態 |
| `moving` | 走行中 |
| `working` | 訪問先での作業中 |
| `break_` | 一時中断（休憩）。作業中のトグル状態 |

設計方針:
- Domain層に定義する（UIは知らない）
- Projectionで表示文字列に変換する

---

## 2.2 ActionDomain 変更（フィールド追加・REQ-004・005対応）

### 変更前（v1.0）

既存 ActionDomain に以下4フィールドを追加していた。

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `fromState` | `ActionState?` | ✅ | `null` | 遷移前の状態。nullは任意状態から遷移可を意味する |
| `toState` | `ActionState?` | ✅ | `null` | 遷移後の状態。nullは状態変化なしのActionを意味する |
| `isToggle` | `bool` | ❌ | `false` | トグル型Action（休憩開始/終了など）かどうか |
| `togglePairId` | `String?` | ✅ | `null` | 対になるActionのid（例: 休憩開始 ↔ 休憩終了） |

### 変更後（v2.0 / REQ-004・005対応）

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 説明 | 変更 |
|---|---|---|---|---|---|
| `fromState` | `ActionState?` | ✅ | `null` | 遷移前の状態 | **廃止**（アプリロジックで使用しない。REQ-004） |
| `toState` | `ActionState?` | ✅ | `null` | 遷移後の状態。nullは状態変化なし | 変更なし |
| `isToggle` | `bool` | ❌ | `false` | トグル型Action | 変更なし |
| `togglePairId` | `String?` | ✅ | `null` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | ❌ | `true` | **新規追加**（REQ-005）。trueのとき`toState`への状態遷移を発生させる。falseのときログ記録のみで状態遷移しない |

### REQ-004 フィールド廃止の注意事項

- `ActionDomain.fromState` フィールドをDartクラスから削除する
- DBカラム `actions.from_state` は **NULLABLEのまま残す**（互換性維持のため削除しない）
- アプリロジックではDBの `from_state` カラムを読み書きしない

### 影響するクラス・ファイル（REQ-004・005）

| ファイル | 変更内容 |
|---|---|
| `domain/master/action/action_domain.dart` | `fromState` フィールド削除・`needsTransition` フィールド追加 |
| `features/settings/action_setting/draft/action_setting_detail_draft.dart` | `fromState` フィールド削除・`needsTransition` フィールド追加 |
| `features/settings/action_setting/projection/action_setting_detail_projection.dart` | `fromStateLabel` フィールド削除・`needsTransition` フィールド追加 |
| `features/settings/action_setting/bloc/action_setting_detail_event.dart` | `ActionSettingDetailFromStateChanged` Event削除・`ActionSettingDetailNeedsTransitionChanged` Event追加 |
| `features/settings/action_setting/bloc/action_setting_detail_bloc.dart` | fromState処理削除・needsTransition処理追加 |
| `adapter/action_time_adapter.dart` | fromState照合ロジック廃止・TopicConfig.markActions/linkActionsによる候補提示に変更・needsTransition=falseのログをtoState計算から除外 |
| DriftRepository（actions DAO） | `from_state` カラムの読み書き停止・`needs_transition` カラムの読み書き追加 |

既存フィールド（id / actionName / isVisible / isDeleted / createdAt / updatedAt）に変更なし。

---

## 2.3 ActionTimeLog Domain（新規）

ActionTimeLogはMarkLinkとは独立してEventIDに直接紐づく新規エンティティ。

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `id` | `String` | ❌ | - | PK（UUID文字列） |
| `eventId` | `String` | ❌ | - | FK → EventDomain.id |
| `actionId` | `String` | ❌ | - | FK → ActionDomain.id |
| `timestamp` | `DateTime` | ❌ | - | Actionが発生した日時 |
| `isDeleted` | `bool` | ❌ | `false` | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | - | 登録日時 |
| `updatedAt` | `DateTime` | ❌ | - | 更新日時 |

設計方針:
- Equatable を継承する
- const コンストラクタを使用する
- IDは String（UUID文字列）
- UIを知らない

---

## 2.4 EventDomain 変更（フィールド追加）

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `actionTimeLogs` | `List<ActionTimeLog>` | ❌ | `const []` | イベントに紐づくActionTimeLogの一覧（timestamp ASC順） |

既存フィールドに変更なし。

---

# 3. デフォルトマスタデータ（v2.0 / REQ-004・005対応）

アプリ初回起動時（または既存Actionが0件の場合）に以下の2種を初期投入する。

### 変更前（v1.0）: 5種

| actionName | fromState | toState | isToggle | 備考 |
|---|---|---|---|---|
| 出発 | `null` | `moving` | false | |
| 到着 | `moving` | `working` | false | |
| 帰着 | `moving` | `waiting` | false | |
| 休憩開始 | `working` | `break_` | true | |
| 休憩終了 | `break_` | `working` | true | |

### 変更後（v2.0）: 2種

| actionName | toState | isToggle | togglePairId | needsTransition | 備考 |
|---|---|---|---|---|---|
| 出発 | `moving` | false | null | `true` | 遷移あり。movingCost地点（Mark）用 |
| 到着 | `working` | false | null | `true` | 遷移あり。movingCost地点（Mark）用 |

### 変更理由

- `帰着` アクションは廃止（movingCost地点アクションを「出発」「到着」2種に限定）
- `休憩開始`・`休憩終了` はTopicConfigのmarkActionsに含まれないため現フェーズでは不要。将来再追加可能なようSeedDataからは除外するが、コード・Routeは残す
- `fromState` フィールドは全Actionで廃止（REQ-004）
- `needsTransition` フィールドを追加（REQ-005）

> **SeedDataのActionID** 実装時に固定UUIDを割り当てる。TopicConfig.markActionsはこのIDを参照するため、SeedDataのIDとTopicConfig定義を一致させること。

初期投入タイミング: アプリ起動時の DI 初期化フェーズ（ActionRepository.fetchAll() が空の場合）。

---

# 4. Repository 拡張

要件書の非機能要件に従い、ActionTimeLogのCRUD操作は **EventRepositoryに集約** する。独立したRepositoryは作らない。

## 4.1 EventRepository 追加メソッド

| メソッド | 説明 |
|---|---|
| `saveActionTimeLog(ActionTimeLog log)` | ActionTimeLog を保存（upsert） |
| `deleteActionTimeLog(String id)` | ActionTimeLog を論理削除 |
| `fetchActionTimeLogs(String eventId)` | 指定イベントの ActionTimeLog を timestamp ASC で取得 |

## 4.2 ActionRepository 変更

既存の ActionRepository インターフェースに変更なし。ActionDomain の新フィールド（fromState / toState / isToggle / togglePairId）は save(ActionDomain) の既存インターフェースで自動的にカバーされる。

---

# 5. 永続化テーブル追加（DriftRepository拡張）

DriftRepository_Spec.md に定義された既存テーブルに以下を追加する。

## 5.1 action_time_logs テーブル

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| event_id | TEXT | NOT NULL, FK → events(id) ON DELETE CASCADE | 所属イベントID |
| action_id | TEXT | NOT NULL, FK → actions(id) | アクションID |
| timestamp | INTEGER (DateTime) | NOT NULL | Actionが発生した日時（Unix milliseconds） |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日時 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日時 |

## 5.2 actions テーブル 変更（カラム追加・v2.0更新）

### v1.0 追加カラム（既存）

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| from_state | TEXT | NULLABLE | 遷移前状態。v2.0以降アプリロジックで未使用。DBカラムは残す（REQ-004） |
| to_state | TEXT | NULLABLE | 遷移後状態（enumの文字列値。nullは状態変化なし） |
| is_toggle | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | トグル型フラグ |
| toggle_pair_id | TEXT | NULLABLE, FK → actions(id) | 対ActionのID |

### v2.0 新規追加カラム（REQ-005）

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| needs_transition | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 状態遷移フラグ。1=遷移あり、0=ログ記録のみ（REQ-005） |

## 5.3 マイグレーション方針（v2.0更新）

- v1.0: schemaVersion 2 で actions テーブルへのカラム追加（from_state / to_state / is_toggle / toggle_pair_id）と action_time_logs テーブル新規作成
- **v2.0: schemaVersion を +1 して `needs_transition` カラムを actions テーブルに追加する**
  - `ALTER TABLE actions ADD COLUMN needs_transition INTEGER NOT NULL DEFAULT 1` を実行する
  - `from_state` カラムは削除しない（NULLABLEのまま残す）
  - 既存レコードの `needs_transition` はデフォルト値 1（true）が自動適用される

---

# 6. 状態導出ロジック（Adapter/UseCase層）

WidgetおよびBLoCに状態導出ロジックを書かない。Adapter/UseCase層に配置する。

## 6.1 現在状態の導出（v2.0 / REQ-005対応）

### 変更前（v1.0）
- 最後のログの `ActionDomain.toState` を現在の `ActionState` とみなす

### 変更後（v2.0）
- `ActionTimeLog` のリストを `timestamp` の昇順でソートする
- **`needsTransition == true` のActionTimeLogのみ** `toState` 計算の対象とする
- `needsTransition == false` のログはタイムラインに表示するがtoState計算から除外する
- 上記フィルタ後のログリストの末尾 `ActionDomain.toState` を現在の `ActionState` とみなす
- ログが空（またはフィルタ後が空）の場合は `ActionState.waiting` をデフォルト値とする

## 6.2 各状態の経過時間の算出（変更なし）

- ログを時系列に並べ、連続する2つのログの `timestamp` 差分から各状態の所要時間を計算する
- 現在進行中の状態は「最後のログのtimestamp〜現在時刻」を合算する
- `break_` 状態の時間は休憩時間として別集計する
- **`needsTransition == false` のログは状態遷移の区切りとして扱わない**（経過時間算出からも除外）

## 6.3 次に発火できるAction候補の導出（v2.0 / REQ-002・004対応）

### 変更前（v1.0）
- 現在の `ActionState` と各 ActionDomain の `fromState` を照合して候補を返す

### 変更後（v2.0）
- fromState照合ロジックを **廃止** する（REQ-004）
- Action候補は **TopicConfigのmarkActions / linkActionsリストのActionID** から取得する（REQ-002）
- 地点（Mark）タップ時: `TopicConfig.markActions` のIDに対応するActionDomainを候補として返す
- 区間（Link）タップ時: `TopicConfig.linkActions` のIDに対応するActionDomainを候補として返す
- `isDeleted == true` または `isVisible == false` のActionは候補から除外する

> **[設計判断]** ActionTimeBlocは `TopicConfig` を受け取り、markActions / linkActionsリストを使ってActionDomainをフィルタする。BlocはDraftに `markType`（Mark / Linkの種別）を保持し、Adapterに渡す。

上記ロジックはすべて `ActionTimeAdapter` に実装する。

---

# 7. BLoC設計（action_time Feature）

## 7.1 Feature責務

- ActionTimeLog の記録（Repository への保存）
- 現在の ActionState の導出（Adapter経由）
- 次に発火できるAction候補の提示（Adapter経由）
- 休憩トグルの制御

## 7.2 Draft Model（v2.0 / REQ-002対応）

`ActionTimeDraft` フィールド定義:

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `eventId` | `String` | 対象イベントID | 変更なし |
| `currentState` | `ActionState` | 現在の導出状態 | 変更なし |
| `availableActions` | `List<ActionDomain>` | TopicConfigのアクションリストから提示する候補（REQ-002） | 変更（fromState照合から変更） |
| `logs` | `List<ActionTimeLog>` | 読み込み済みのActionTimeLog（timestamp ASC） | 変更なし |
| `topicConfig` | `TopicConfig` | アクション候補提示に使用するTopicConfig（REQ-002） | **新規追加** |
| `markOrLink` | `MarkOrLink` | 現在操作対象がMarkかLinkか（REQ-002） | **新規追加** |

Draftは永続化しない。

## 7.3 Projection Model

`ActionTimeProjection` フィールド定義:

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `currentStateLabel` | `String` | 現在状態の表示文字列（例: 「作業中」） |
| `logItems` | `List<ActionTimeLogProjection>` | タイムライン表示用ログ一覧 |
| `isBreakActive` | `bool` | 現在休憩中かどうか |

`ActionTimeLogProjection` フィールド定義:

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | ログID |
| `actionName` | `String` | Action名 |
| `timestampLabel` | `String` | 表示用タイムスタンプ文字列 |
| `transitionLabel` | `String` | 状態遷移の表示文字列（例: 「移動 → 作業」） |

## 7.4 State

`ActionTimeState` フィールド定義:

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `draft` | `ActionTimeDraft` | 編集中状態 |
| `projection` | `ActionTimeProjection` | 表示用データ |
| `delegate` | `ActionTimeDelegate?` | 遷移意図の通知 |
| `isLoading` | `bool` | ローディング中フラグ |
| `errorMessage` | `String?` | エラーメッセージ |

## 7.5 Events（v2.0）

| Event名 | 発火タイミング | 説明 | 変更 |
|---|---|---|---|
| `ActionTimeStarted` | 画面表示時 | 指定EventのActionTimeLogをRepositoryから読み込む。TopicConfigとMarkOrLinkも受け取る | 引数追加（topicConfig・markOrLink） |
| `ActionTimeLogRecorded` | ActionボタンタップTime | 選択したActionのActionTimeLogを現在時刻で記録する | 変更なし |
| `ActionTimeBreakToggled` | 休憩トグルボタンタップ | 現在状態に応じて休憩開始または休憩終了のActionTimeLogを記録する | 変更なし |
| `ActionTimeLogDeleted` | ログ削除操作 | 指定ActionTimeLogを論理削除する | 変更なし |

## 7.6 Delegate Contract

| Delegate名 | 遷移先・通知先 | 説明 |
|---|---|---|
| `ActionTimeNavigateBackDelegate` | 前画面 | 記録完了後に前画面へ戻る意図を通知する |

---

# 8. action_setting Feature 拡張（v2.0 / REQ-004・005対応）

既存の `action_setting` Feature（ActionSettingReducerの移植）の変更。

## 8.1 ActionSettingDetailDraft 変更（v2.0）

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `actionName` | `String` | 行動名 | 変更なし |
| `isVisible` | `bool` | 表示設定 | 変更なし |
| `fromState` | `ActionState?` | 遷移前の状態 | **廃止**（REQ-004） |
| `toState` | `ActionState?` | 編集中の遷移後状態 | 変更なし |
| `isToggle` | `bool` | トグル型かどうか | 変更なし |
| `togglePairId` | `String?` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | 状態遷移フラグ | **新規追加**（REQ-005） |

## 8.2 ActionSettingDetailProjection 変更（v2.0）

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `actionName` | `String` | 行動名表示文字列 | 変更なし |
| `isVisible` | `bool` | 表示フラグ | 変更なし |
| `fromStateLabel` | `String?` | fromState の表示文字列 | **廃止**（REQ-004） |
| `toStateLabel` | `String?` | toState の表示文字列（未設定時は「変化なし」） | 変更なし |
| `isToggle` | `bool` | トグル表示用フラグ | 変更なし |
| `togglePairId` | `String?` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | 状態遷移フラグの表示用 | **新規追加**（REQ-005） |

## 8.3 Events 変更（v2.0）

| Event名 | 発火タイミング | 説明 | 変更 |
|---|---|---|---|
| `ActionSettingDetailFromStateChanged` | fromState選択時 | Draft の fromState を更新する | **廃止**（REQ-004） |
| `ActionSettingDetailToStateChanged` | toState選択時 | Draft の toState を更新する | 変更なし |
| `ActionSettingDetailIsToggleChanged` | トグルスイッチ変更時 | Draft の isToggle を更新する | 変更なし |
| `ActionSettingDetailNeedsTransitionChanged` | needsTransitionスイッチ変更時 | Draft の needsTransition を更新する | **新規追加**（REQ-005） |

---

# 9. UI設計方針

WidgetはProjectionのみを参照し、Domain・ActionStateを直接知らない。

## 9.1 ActionTime記録UI

- EventDetailまたはMichiInfoView内に「ActionTime記録」ボタン（またはセクション）を配置する
- ボタンタップで `ActionTimeLogRecorded` Event を発火する
- 記録するActionは `ActionTimeDraft.availableActions`（Adapter導出）から選択または自動サジェストする
- 現在状態を `ActionTimeProjection.currentStateLabel` で表示する

## 9.2 休憩トグル

- `ActionTimeProjection.isBreakActive` が false のとき「休憩開始」ボタンを表示する
- `ActionTimeProjection.isBreakActive` が true のとき「休憩終了」ボタンを表示する
- ボタンタップで `ActionTimeBreakToggled` Event を発火する

## 9.3 ActionTimeログ表示

- `ActionTimeProjection.logItems` を時系列リストで表示する
- 各ログに `actionName`・`timestampLabel`・`transitionLabel` を表示する

## 9.4 設定画面

- `action_setting` 画面の Action 編集フォームに fromState・toState・isToggle・togglePairId の設定項目を追加する
- fromState / toState は ActionState enum の選択UIとする（ピッカーまたはラジオボタン）
- isToggle は Switch（トグル）UIとする
- togglePairId は Action選択UIとする（SelectionFeatureを利用可）

---

# 10. Data Flow

## ActionTimeLog 記録フロー

1. ユーザーが ActionTime記録ボタンをタップする
2. `ActionTimeLogRecorded` Event が BLoC に送出される
3. BLoC が `ActionTimeAdapter` を呼び出し、現在時刻と選択 ActionId から `ActionTimeLog` を生成する
4. BLoC が `EventRepository.saveActionTimeLog()` を呼び出して永続化する
5. BLoC が `EventRepository.fetchActionTimeLogs()` で最新ログを取得する
6. BLoC が `ActionTimeAdapter` を呼び出して `ActionTimeDraft` と `ActionTimeProjection` を更新する
7. `ActionTimeState` を emit し、Widget が再描画される

## 現在状態導出フロー（v2.0）

1. `ActionTimeDraft.logs`（timestamp ASC）を `ActionTimeAdapter` に渡す
2. Adapter が `needsTransition == true` のログのみを抽出し、末尾の `toState` を現在状態として返す
3. Adapter が `TopicConfig.markActions` または `TopicConfig.linkActions`（`markOrLink` に応じて選択）からAction候補リストを生成して返す（fromState照合は行わない）
4. Draft と Projection を更新して State に反映する

---

# 11. Navigation

ActionTime Feature は BLoC の Delegate で遷移意図を通知する。BLoC内・Widget内で直接 `context.go()` / `context.push()` を呼び出すことは禁止。

| 遷移元 | Delegate | 遷移先 |
|---|---|---|
| ActionTime画面 | `ActionTimeNavigateBackDelegate` | 前画面（go_routerでpop） |

---

# 12. 受け入れ条件（v2.0）

## 既存条件

- [ ] ActionをタップするとActionTimeLogが記録される（eventId・actionId・timestamp）
- [ ] 最後の（needsTransition=trueの）ActionTimeLogのtoStateから現在状態が正しく導出される
- [ ] ActionTimeLogが時系列で表示される（timestamp ASC）
- [ ] 状態導出ロジックはAdapter層に実装されており、Widget/BLoCに書かれていない
- [ ] ActionStateはDomain層に定義されており、WidgetはProjectionの文字列のみを参照している

## REQ-002 対応条件

- [ ] 地点（Mark）のActionTime画面でのAction候補がTopicConfig.markActionsのIDに対応するActionのみであること
- [ ] 区間（Link）のActionTime画面でのAction候補がTopicConfig.linkActionsのIDに対応するActionのみであること
- [ ] movingCostの地点用アクション候補が「出発」「到着」の2種のみであること
- [ ] travelExpenseのアクション候補が0件であること
- [ ] fromState照合ロジックがActionTimeAdapterから削除されていること

## REQ-004 対応条件

- [ ] ActionDomainに `fromState` フィールドが存在しないこと
- [ ] ActionSettingDetailDraftに `fromState` フィールドが存在しないこと
- [ ] ActionSettingDetailProjectionに `fromStateLabel` フィールドが存在しないこと
- [ ] DBの `actions.from_state` カラムが残っていること（削除しない）

## REQ-005 対応条件

- [ ] ActionDomainに `needsTransition: bool` フィールドが存在すること
- [ ] needsTransition = false のActionをタップするとActionTimeLogは記録されるが状態遷移は起きないこと
- [ ] needsTransition = true のActionをタップするとtoStateへの状態遷移が起きること
- [ ] DBの `actions.needs_transition` カラムが存在すること

## SeedData条件

- [ ] デフォルトAction「出発」（toState: moving, needsTransition: true）が初期データとして投入されていること
- [ ] デフォルトAction「到着」（toState: working, needsTransition: true）が初期データとして投入されていること
- [ ] 帰着・休憩開始・休憩終了はSeedDataに含まれていないこと

---

# 13. SwiftUI版との対応

このFeatureはSwiftUI版には存在しない新規機能である。MichiMark Flutter版での新規追加となる。

---

# End of ActionTime Spec
