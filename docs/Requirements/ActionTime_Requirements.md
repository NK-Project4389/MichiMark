# ActionTime 要件書

## 背景・目的

現状のMichiMarkでは、Mark（地点）にActionを記録できるが「いつそのActionが発生したか」のタイムスタンプは記録できない。

ActionTimeは、Actionを **状態遷移のトリガー** として捉え、そのタイムスタンプをイベント単位でログとして蓄積する機能である。
これにより「移動時間」「作業時間」「滞留時間」「休憩時間」をActionTimeLogから算出できるようになる。

---

## 状態モデル

### 状態種別（ActionState）

| 状態 | 説明 |
|---|---|
| 滞留（waiting） | 移動前・終了後の待機状態 |
| 移動（moving） | 走行中 |
| 作業（working） | 訪問先での作業中 |
| 休憩（break） | 作業中の一時中断（トグル） |

### 状態遷移例

```
[滞留] --出発--> [移動] --到着--> [作業]
                               --休憩開始--> [休憩]
                               <--休憩終了--
              <--出発--         --出発--> [移動]
```

---

## ユーザーストーリー

- ユーザーとして、出発・到着などのActionを記録したとき、状態遷移とタイムスタンプを自動ログしたい
- ユーザーとして、休憩の開始・終了をトグルで記録して、休憩時間を把握したい
- ユーザーとして、イベント内のActionTimeLogを時系列で確認したい
- 管理者として、各ActionがどのState遷移を意味するかを設定画面で定義したい

---

## 機能要件

### ActionTimeLog（新規エンティティ）

Actionが発生したタイムスタンプをイベント単位でログとして記録する。

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 備考 |
|---|---|---|---|---|
| `id` | `String` | ❌ | - | PK（UUID文字列） |
| `eventId` | `String` | ❌ | - | FK → EventDomain |
| `actionId` | `String` | ❌ | - | FK → ActionDomain |
| `timestamp` | `DateTime` | ❌ | - | Actionが発生した日時 |
| `isDeleted` | `bool` | ❌ | `false` | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | - | |
| `updatedAt` | `DateTime` | ❌ | - | |

- ActionTimeLogはMarkLinkとは独立してEventに直接紐づく
- 同一Eventで複数の地点に到着・出発が発生しても、すべて同一Eventのログとして時系列に積み上げる

### ActionDomain 変更（状態遷移定義の追加）

既存ActionDomainに状態遷移情報を追加する。

| 追加フィールド名 | Dart型 | NULL許容 | デフォルト値 | 備考 |
|---|---|---|---|---|
| `fromState` | `ActionState?` | ✅ | `null` | 遷移前の状態（nullは任意状態から遷移可） |
| `toState` | `ActionState?` | ✅ | `null` | 遷移後の状態（nullは状態変化なしのAction） |
| `isToggle` | `bool` | ❌ | `false` | トグル型Action（休憩開始/終了など）かどうか |
| `togglePairId` | `String?` | ✅ | `null` | 対になるActionのid（休憩開始 ↔ 休憩終了） |

### ActionState enum（新規）

```dart
enum ActionState {
  waiting, // 滞留
  moving,  // 移動
  working, // 作業
  break_,  // 休憩（一時状態）
}
```

### デフォルトAction定義（マスタ初期データ）

| actionName | fromState | toState | isToggle | 備考 |
|---|---|---|---|---|
| 出発 | waiting / working | moving | false | 滞留・作業どちらからも出発可 |
| 到着 | moving | working | false | 移動→作業へ遷移 |
| 帰着 | moving | waiting | false | 最終地点への到着 |
| 休憩開始 | working | break_ | true | トグルON |
| 休憩終了 | break_ | working | true | トグルOFF（togglePairId: 休憩開始） |

---

## UI要件

### ActionTime記録UI

- EventDetailまたはMichiInfoView内に「ActionTime記録」ボタンを配置
- ボタンタップ時：現在日時をtimestampとして ActionTimeLog を記録
- 記録するActionは選択または直前の状態から自動サジェスト

### 現在状態表示

- イベント進行中に「現在の状態」（滞留/移動/作業/休憩）を表示
- 最後のActionTimeLogのtoStateから現在状態を導出

### 休憩トグル

- 「作業」状態中に休憩ボタンを表示
- タップで「休憩開始」ログを記録し、ボタンが「休憩終了」に切り替わる
- 「休憩終了」タップで終了ログを記録し、「作業」状態に戻る
- 任意のタイミングで記録可能（Markに紐づかない）

### ActionTimeログ表示

- イベント内のActionTimeLogを時系列で確認できる画面（またはセクション）
- 表示項目：timestamp・actionName・状態遷移（fromState → toState）

---

## 設定画面要件

- 設定画面（既存Action設定画面）でActionの状態遷移を定義できる
- 設定項目：actionName・fromState・toState・isToggle・togglePairId
- Phase 1はデフォルトAction（上記5種）を初期投入する
- 既存のActionDomain設定画面を拡張する形で実装する

---

## 非機能要件

- ActionTimeLogの記録・参照はEventRepositoryに集約する（独立Repositoryは作らない）
- 状態導出ロジック（ログ → 現在状態・各状態の所要時間）はAdapter/UseCase層で実装する
- ActionStateはDomainに定義し、UIは知らない

---

## スコープ外

- GPS位置情報との連携（自動到着検知など）
- 複数イベント横断での状態管理
- タイムラインのグラフ表示（Aggregation要件書を参照）

---

## 受け入れ条件

- [ ] ActionをタップするとActionTimeLogが記録される（eventId・actionId・timestamp）
- [ ] 休憩開始/終了トグルで2つのログ（開始・終了）が記録される
- [ ] 最後のActionTimeLogから現在状態が正しく導出される
- [ ] ActionTimeLogが時系列で表示される
- [ ] 設定画面でActionの状態遷移（fromState・toState）を確認・編集できる
- [ ] デフォルトAction 5種が初期データとして投入されている
