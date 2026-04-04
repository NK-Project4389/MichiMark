# ActionTime Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: ActionをEvent単位の状態遷移トリガーとして捉え、タイムスタンプをActionTimeLogとして蓄積することで「移動時間」「作業時間」「滞留時間」「休憩時間」を算出可能にする。

---

# 1. Feature Overview

## Feature Name

ActionTime

## Purpose

Actionが発生した日時をイベント単位でログ（ActionTimeLog）として記録する。ActionTimeLogの時系列から現在の状態（ActionState）を導出し、各状態の経過時間を可視化できる基盤を構築する。

## Scope

含むもの
- ActionState enum の新規定義（Domain層）
- ActionDomain への状態遷移フィールド追加（fromState / toState / isToggle / togglePairId）
- ActionTimeLog Domain の新規定義（EventIDに直接紐づく）
- EventDomain への actionTimeLogs フィールド追加
- EventRepository への ActionTimeLog CRUD 操作追加（独立 Repository は作らない）
- ActionTimeLog 記録 BLoC 設計（action_time Feature）
- 状態導出ロジック（Adapter/UseCase層）
- ActionTime 記録UI（記録ボタン・現在状態表示・休憩トグル・タイムラインログ表示）
- 設定画面（action_setting Feature）への fromState / toState / isToggle 設定追加
- デフォルトマスタデータ 5種の初期投入

含まないもの
- GPS位置情報との連携・自動到着検知
- 複数イベント横断での状態管理
- タイムラインのグラフ表示（Aggregation要件書参照）
- ActionTimeLog 専用の独立 Repository

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

## 2.2 ActionDomain 変更（フィールド追加）

既存 ActionDomain に以下4フィールドを追加する。

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `fromState` | `ActionState?` | ✅ | `null` | 遷移前の状態。nullは任意状態から遷移可を意味する |
| `toState` | `ActionState?` | ✅ | `null` | 遷移後の状態。nullは状態変化なしのActionを意味する |
| `isToggle` | `bool` | ❌ | `false` | トグル型Action（休憩開始/終了など）かどうか |
| `togglePairId` | `String?` | ✅ | `null` | 対になるActionのid（例: 休憩開始 ↔ 休憩終了） |

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

# 3. デフォルトマスタデータ

アプリ初回起動時（または既存Actionが0件の場合）に以下の5種を初期投入する。

| actionName | fromState | toState | isToggle | togglePairId | 備考 |
|---|---|---|---|---|---|
| 出発 | `null`（任意から） | `moving` | false | null | 滞留・作業どちらからも出発可。fromState=nullで表現 |
| 到着 | `moving` | `working` | false | null | 移動→作業へ遷移 |
| 帰着 | `moving` | `waiting` | false | null | 最終地点への到着 |
| 休憩開始 | `working` | `break_` | true | 「休憩終了」のid | トグルON |
| 休憩終了 | `break_` | `working` | true | 「休憩開始」のid | トグルOFF |

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

## 5.2 actions テーブル 変更（カラム追加）

| 追加カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| from_state | TEXT | NULLABLE | 遷移前状態（enumの文字列値。nullは任意状態） |
| to_state | TEXT | NULLABLE | 遷移後状態（enumの文字列値。nullは状態変化なし） |
| is_toggle | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | トグル型フラグ |
| toggle_pair_id | TEXT | NULLABLE, FK → actions(id) | 対ActionのID |

## 5.3 マイグレーション方針

- actions テーブルへのカラム追加と action_time_logs テーブル新規作成を schemaVersion 2 として定義する
- onUpgrade で `ALTER TABLE actions ADD COLUMN ...` と `CREATE TABLE action_time_logs ...` を実行する

---

# 6. 状態導出ロジック（Adapter/UseCase層）

WidgetおよびBLoCに状態導出ロジックを書かない。Adapter/UseCase層に配置する。

## 6.1 現在状態の導出

- `ActionTimeLog` のリストを `timestamp` の昇順でソートする
- 最後のログの `ActionDomain.toState` を現在の `ActionState` とみなす
- ログが空の場合は `ActionState.waiting` をデフォルト値とする

## 6.2 各状態の経過時間の算出

- ログを時系列に並べ、連続する2つのログの `timestamp` 差分から各状態の所要時間を計算する
- 現在進行中の状態は「最後のログのtimestamp〜現在時刻」を合算する
- `break_` 状態の時間は休憩時間として別集計する

## 6.3 次に発火できるAction候補の導出

- 現在の `ActionState` と各 ActionDomain の `fromState` を照合する
- `fromState == null`（任意状態から遷移可）のActionは常に候補に含める
- `fromState == 現在のActionState` のActionを候補として返す
- `isToggle == true` のActionは現在状態が `fromState` に一致する場合のみ表示する

上記ロジックはすべて `ActionTimeAdapter`（仮名）に実装する。

---

# 7. BLoC設計（action_time Feature）

## 7.1 Feature責務

- ActionTimeLog の記録（Repository への保存）
- 現在の ActionState の導出（Adapter経由）
- 次に発火できるAction候補の提示（Adapter経由）
- 休憩トグルの制御

## 7.2 Draft Model

`ActionTimeDraft` フィールド定義:

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `eventId` | `String` | 対象イベントID |
| `currentState` | `ActionState` | 現在の導出状態 |
| `availableActions` | `List<ActionDomain>` | 現在状態から発火可能なAction一覧 |
| `logs` | `List<ActionTimeLog>` | 読み込み済みのActionTimeLog（timestamp ASC） |

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

## 7.5 Events

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `ActionTimeStarted` | 画面表示時 | 指定EventのActionTimeLogをRepositoryから読み込む |
| `ActionTimeLogRecorded` | ActionボタンタップTime | 選択したActionのActionTimeLogを現在時刻で記録する |
| `ActionTimeBreakToggled` | 休憩トグルボタンタップ | 現在状態に応じて休憩開始または休憩終了のActionTimeLogを記録する |
| `ActionTimeLogDeleted` | ログ削除操作 | 指定ActionTimeLogを論理削除する |

## 7.6 Delegate Contract

| Delegate名 | 遷移先・通知先 | 説明 |
|---|---|---|
| `ActionTimeNavigateBackDelegate` | 前画面 | 記録完了後に前画面へ戻る意図を通知する |

---

# 8. action_setting Feature 拡張

既存の `action_setting` Feature（ActionSettingReducerの移植）に以下を追加する。

## 8.1 ActionSettingDraft 変更（フィールド追加）

既存フィールドに加えて以下を追加する:

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `fromState` | `ActionState?` | 編集中の遷移前状態 |
| `toState` | `ActionState?` | 編集中の遷移後状態 |
| `isToggle` | `bool` | トグル型かどうか |
| `togglePairId` | `String?` | 対ActionのID |

## 8.2 ActionSettingProjection 変更（フィールド追加）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `fromStateLabel` | `String` | fromState の表示文字列（未設定時は「任意」） |
| `toStateLabel` | `String` | toState の表示文字列（未設定時は「変化なし」） |
| `isToggle` | `bool` | トグル表示用フラグ |
| `togglePairName` | `String?` | 対Actionの名前（togglePairIdから導出） |

## 8.3 追加 Events

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `ActionFromStateUpdated` | fromState選択時 | Draft の fromState を更新する |
| `ActionToStateUpdated` | toState選択時 | Draft の toState を更新する |
| `ActionIsToggleUpdated` | トグルスイッチ変更時 | Draft の isToggle を更新する |
| `ActionTogglePairSelected` | 対Action選択時 | Draft の togglePairId を更新する |

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

## 現在状態導出フロー

1. `ActionTimeDraft.logs`（timestamp ASC）を `ActionTimeAdapter` に渡す
2. Adapter がログの末尾の `toState` を現在状態として返す
3. Adapter が現在状態と全 ActionDomain の `fromState` を照合し、発火可能 Action 候補リストを返す
4. Draft と Projection を更新して State に反映する

---

# 11. Navigation

ActionTime Feature は BLoC の Delegate で遷移意図を通知する。BLoC内・Widget内で直接 `context.go()` / `context.push()` を呼び出すことは禁止。

| 遷移元 | Delegate | 遷移先 |
|---|---|---|
| ActionTime画面 | `ActionTimeNavigateBackDelegate` | 前画面（go_routerでpop） |

---

# 12. 受け入れ条件

- [ ] ActionをタップするとActionTimeLogが記録される（eventId・actionId・timestamp）
- [ ] 休憩開始/終了トグルで2つのログ（開始・終了）が記録される
- [ ] 最後のActionTimeLogのtoStateから現在状態が正しく導出される
- [ ] ActionTimeLogが時系列で表示される（timestamp ASC）
- [ ] 設定画面でActionの状態遷移（fromState・toState）を確認・編集できる
- [ ] デフォルトAction 5種が初期データとして投入されている
- [ ] 状態導出ロジックはAdapter層に実装されており、Widget/BLoCに書かれていない
- [ ] ActionStateはDomain層に定義されており、WidgetはProjectionの文字列のみを参照している

---

# 13. SwiftUI版との対応

このFeatureはSwiftUI版には存在しない新規機能である。MichiMark Flutter版での新規追加となる。

---

# End of ActionTime Spec
