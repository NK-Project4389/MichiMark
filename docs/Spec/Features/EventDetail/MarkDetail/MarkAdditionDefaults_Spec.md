# MarkAdditionDefaults Feature Specification

Spec ID: MarkAdditionDefaults
Version: 1.0
作成日: 2026-04-08
ステータス: 確定
対応要件: REQ-mark_addition_defaults（REQ-MAD-001〜005）
関連タスク: T-073〜T-076

---

# 1. Purpose

MichiInfo タブで地点（Mark）を新規追加するとき、毎回メーター・メンバー・日付をゼロから入力する手間を省く。
直前の地点や設定済みの交通手段から情報を引き継ぎ、入力コストとデータ不整合を低減する。

また、地点のメンバー選択候補をイベントメンバー（BasicInfo で登録したメンバー）のみに絞り込むことで、
イベント未参加メンバーの混入を防ぐ。

さらに EventDetail 保存時に交通手段の最大メーター値を自動更新することで、
次回以降の地点追加における初期値精度を保つ。

---

# 2. 変更対象コンポーネント一覧

| コンポーネント | 変更種別 | 対応要件 |
|---|---|---|
| `MarkDetailArgs` | フィールド追加 | REQ-MAD-001〜004 |
| `MarkDetailBloc._onStarted` | 初期化ロジック変更 | REQ-MAD-001〜004 |
| `MarkDetailLoaded` | フィールド追加（`availableMembers`） | REQ-MAD-004 |
| `MichiInfoBloc._onAddMarkPressed` | Args構築ロジック変更（DB参照追加） | REQ-MAD-001〜004 |
| `MichiInfoBloc` | `EventRepository` 追加参照（既存） | REQ-MAD-001〜004 |
| `EventDetailBloc._onSaveRequested` | Trans最大メーター値更新処理追加 | REQ-MAD-005 |
| `EventDetailBloc` | `TransRepository` 依存追加 | REQ-MAD-005 |
| `router.dart` (`/event/mark/:markId`) | `MarkDetailArgs` からの `eventMembers` 取り出し追加 | REQ-MAD-004 |
| `di.dart` | `EventDetailBloc` への `TransRepository` 注入追加 | REQ-MAD-005 |

---

# 3. 各要件の詳細仕様

## REQ-MAD-001: 地点追加時のメーター初期値

### データフロー

1. `MichiInfoBloc._onAddMarkPressed` が発火する
2. `_eventId` をもとに `EventRepository.fetch` で現在の `EventDomain` を取得する
3. `EventDomain.markLinks` を `markLinkSeq` 昇順・`isDeleted == false` でフィルタリングする
4. フィルタ済みリストの中で `markLinkType == MarkOrLink.mark` の最後の要素を「前の地点（previousMark）」とする
5. 前の地点が存在する場合 → `previousMark.meterValue` を文字列変換して `MarkDetailArgs.initialMeterValueInput` に設定する
6. 前の地点が存在しない場合 → `EventDomain.trans?.meterValue` を文字列変換して設定する
7. どちらも null の場合 → 空文字列を設定する

### 境界条件

- `meterValue == 0` の場合も初期値として設定する（`"0"` を渡す）
- `meterValue` が `null` の場合は空文字列（`""`）を渡す
- 編集モード（既存地点の再オープン）には適用しない。`MarkDetailBloc._onStarted` で既存 `markLink` が見つかる場合は DB 値を使用する

---

## REQ-MAD-002: 地点追加時のメンバー初期値

### データフロー

1. REQ-MAD-001 と同じ `_onAddMarkPressed` の中で `previousMark` を特定する
2. 前の地点が存在する場合 → `previousMark.members` を `MarkDetailArgs.initialSelectedMembers` に設定する
3. 前の地点が存在しない場合 → 空リストを設定する

### 境界条件

- 前の地点の `members` が空リストの場合は空リストをそのまま引き継ぐ
- 前の地点のメンバーが `EventDomain.members` に含まれない場合でも引き継ぐ（後述の REQ-MAD-004 は選択候補に対する制限であり、初期値の引き継ぎには適用しない）

---

## REQ-MAD-003: 地点追加時の日付初期値

### データフロー

1. REQ-MAD-001 と同じ `_onAddMarkPressed` の中で `previousMark` を特定する
2. 前の地点が存在する場合 → `previousMark.markLinkDate` を `MarkDetailArgs.initialMarkLinkDate` に設定する
3. 前の地点が存在しない場合 → `DateTime.now()` の年月日部分（時刻はゼロ時）を設定する

### 境界条件

- 日付は年月日のみを初期値として使用する。時刻部分の扱いは実装者の判断に委ねる

---

## REQ-MAD-004: メンバー選択候補をイベントメンバーに限定

### データフロー

1. `_onAddMarkPressed` で `EventDomain.members` を `MarkDetailArgs.eventMembers` として渡す
2. `MarkDetailBloc._onStarted` は **新規作成モードのみ** `args.eventMembers` を `MarkDetailLoaded.availableMembers` に設定する
3. 既存編集モードでは `MarkDetailStarted` 経由で渡される `eventMembers` を `availableMembers` に設定する
4. `MarkDetailPage` はメンバー選択 UI に `availableMembers` を表示候補として使用する

### 境界条件

- `eventMembers` が空リストの場合、選択 UI は空リストを候補として表示する（クラッシュしないこと）
- `availableMembers` が空のときは「メンバーが設定されていません」等のメッセージを表示することを推奨する（実装詳細は flutter-dev に委ねる）

### MichiInfoView / MarkDetailPage 間の情報受け渡し

現状のルーティングでは `MarkDetailArgs` を `extra` として `context.push` に渡している。
`eventMembers` の追加により `MarkDetailArgs` のフィールドが増えるが、渡し方は変えない。
`router.dart` の `/event/mark/:markId` ビルダーが `args as MarkDetailArgs` から `eventMembers` を取り出し、
`MarkDetailStarted` イベントに追加する。

---

## REQ-MAD-005: EventDetail 保存時に Trans 最大メーター値を更新

### データフロー

1. `EventDetailBloc._onSaveRequested` が既存の保存フロー（`_eventRepository.save(updated)`）を完了する
2. 保存後に `updated.markLinks`（論理削除済みを含む全件 or 含まないか → **論理削除済みを除外した件のみ**）から `meterValue` の最大値を算出する
3. 最大値が null（= 有効な meterValue を持つ Mark が存在しない）の場合は何もしない
4. `updated.trans` が null の場合は何もしない
5. 算出した最大値が `updated.trans.meterValue` より大きい場合のみ `TransRepository.save(trans.copyWith(meterValue: newMax, updatedAt: DateTime.now()))` を呼ぶ
6. `TransRepository.save` の失敗は保存成功全体をロールバックしない。例外をキャッチしてログに残し、保存成功 Delegate を発火する

### meterValue の最大値算出ルール

- 対象: `updated.markLinks` のうち `isDeleted == false` かつ `markLinkType == MarkOrLink.mark` かつ `meterValue != null` のもの
- 対象リストが空の場合は null として扱い、処理をスキップする

### 境界条件

- `trans.meterValue == null` の場合、算出した最大値が 0 以上であれば更新する（`null < 正の整数` は更新対象とする）
- `trans.meterValue == 0` かつ `newMax == 0` の場合は更新しない（変化なし）
- TransRepository.save の失敗は上位の保存フローに影響を与えない

---

# 4. MarkDetailArgs の変更仕様

## 現在のフィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `eventId` | `String` | イベントID |
| `topicConfig` | `TopicConfig` | トピック設定 |

## 追加するフィールド

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `initialMeterValueInput` | `String` | `''` | メーター初期値（文字列。未設定時は空文字） |
| `initialSelectedMembers` | `List<MemberDomain>` | `const []` | 引き継ぎメンバー初期値 |
| `initialMarkLinkDate` | `DateTime?` | `null` | 日付初期値（null の場合は Bloc 側で DateTime.now() を使用） |
| `eventMembers` | `List<MemberDomain>` | `const []` | メンバー選択候補（イベントメンバー全件） |

**注意**: 新規追加フィールドはすべてオプション扱い（デフォルト値あり）。既存のルーター側コード（既存地点を開く `MichiInfoOpenMarkDelegate` 経由のフロー）への後方互換性を保つ。

---

# 5. MarkDetailBloc._onStarted の初期化ロジック変更仕様

## 新規作成モード（`markLink == null`）の Draft 初期化

現在の初期化:
- `markLinkDate: DateTime.now()`
- `meterValueInput: ''`（空）
- `selectedMembers: []`（空）

変更後の初期化:
- `markLinkDate`: `args.initialMarkLinkDate ?? DateTime.now()`
- `meterValueInput`: `args.initialMeterValueInput`（デフォルト `''`）
- `selectedMembers`: `args.initialSelectedMembers`（デフォルト `[]`）

## 新規作成モードの availableMembers 設定

`MarkDetailLoaded` に `availableMembers: List<MemberDomain>` フィールドを追加する。

- 新規作成モード: `args.eventMembers` を `availableMembers` に設定する
- 既存編集モード: `args.eventMembers` を `availableMembers` に設定する（編集時もイベントメンバーに限定）

## MarkDetailStarted イベントへのフィールド追加

`MarkDetailStarted` イベントに以下を追加する:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `initialMeterValueInput` | `String` | `''` | メーター初期値 |
| `initialSelectedMembers` | `List<MemberDomain>` | `const []` | メンバー初期値 |
| `initialMarkLinkDate` | `DateTime?` | `null` | 日付初期値 |
| `eventMembers` | `List<MemberDomain>` | `const []` | メンバー選択候補 |

## MarkDetailLoaded State のフィールド追加

| フィールド名 | 型 | 説明 |
|---|---|---|
| `availableMembers` | `List<MemberDomain>` | メンバー選択 UI に表示する候補一覧 |

---

# 6. MichiInfoBloc._onAddMarkPressed の変更仕様

## 現在の処理

`_onAddMarkPressed` は `MichiInfoAddMarkDelegate(eventId, topicConfig)` を emit するだけ。
`EventDomain` を参照していない。

## 変更後の処理フロー

1. `EventRepository.fetch(_eventId)` で最新の `EventDomain` を取得する
2. `domain.markLinks` を `markLinkSeq` 昇順・`isDeleted == false` でフィルタリングする
3. フィルタ済みリストから `markLinkType == MarkOrLink.mark` の最後の要素を `previousMark` とする
4. `previousMark` と `domain.trans`・`domain.members` を使って Args の初期値を決定する（詳細は REQ-MAD-001〜004 参照）
5. `MichiInfoAddMarkDelegate` に初期値情報を追加して emit する

## MichiInfoAddMarkDelegate の変更

現在のフィールド:
- `eventId: String`
- `topicConfig: TopicConfig`

追加するフィールド:
| フィールド名 | 型 | 説明 |
|---|---|---|
| `initialMeterValueInput` | `String` | REQ-MAD-001 で決定したメーター初期値 |
| `initialSelectedMembers` | `List<MemberDomain>` | REQ-MAD-002 で決定したメンバー初期値 |
| `initialMarkLinkDate` | `DateTime?` | REQ-MAD-003 で決定した日付初期値 |
| `eventMembers` | `List<MemberDomain>` | REQ-MAD-004 のイベントメンバー一覧 |

## MarkDetailArgs 構築（MichiInfoView の BlocListener）

`MichiInfoView` の BlocListener が `MichiInfoAddMarkDelegate` を受け取り、以下の `MarkDetailArgs` を構築して `context.push` に渡す:

- `eventId`: `delegate.eventId`
- `topicConfig`: `delegate.topicConfig`
- `initialMeterValueInput`: `delegate.initialMeterValueInput`
- `initialSelectedMembers`: `delegate.initialSelectedMembers`
- `initialMarkLinkDate`: `delegate.initialMarkLinkDate`
- `eventMembers`: `delegate.eventMembers`

---

# 7. EventDetailBloc._onSaveRequested の変更仕様

## 追加する依存

`EventDetailBloc` のコンストラクタに `TransRepository transRepository` を追加する。

## 変更後のフロー（追記箇所のみ）

既存の `await _eventRepository.save(updated)` 完了後に以下を追加する:

1. `updated.trans` が null の場合はスキップ
2. `updated.markLinks` から有効な Mark の `meterValue` 最大値を算出する
3. 最大値が null の場合はスキップ
4. 最大値 > `updated.trans.meterValue`（または `trans.meterValue == null`）の場合のみ `_transRepository.save(...)` を呼ぶ
5. `_transRepository.save` の失敗は `try-catch` で吸収し、保存成功のフローを継続する

## di.dart の変更

`router.dart` の `/event/:id` ビルダーおよび `di.dart` の `EventDetailBloc` 生成部分に `transRepository: getIt<TransRepository>()` を追加する。

---

# 8. テストシナリオ（Integration Test 用）

## 前提条件

- シミュレーターが起動済みであること
- テスト用イベントが存在し、BasicInfo タブにて以下が設定済みであること:
  - 交通手段（`meterValue` 付き）
  - メンバー2名以上

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MAD-001 | 地点が存在しない状態で地点追加すると交通手段のメーター値が初期値になる | High |
| TC-MAD-002 | 既存地点がある状態で地点追加すると前の地点のメーター値が初期値になる | High |
| TC-MAD-003 | 既存地点がある状態で地点追加すると前の地点のメンバーが引き継がれる | High |
| TC-MAD-004 | 既存地点がある状態で地点追加すると前の地点の日付が初期値になる | Medium |
| TC-MAD-005 | 地点が存在しない状態で地点追加すると本日の日付が初期値になる | Medium |
| TC-MAD-006 | MarkDetail のメンバー選択候補がイベントメンバーのみになっている | High |
| TC-MAD-007 | EventDetail 保存後に交通手段の最大メーター値が更新される | High |
| TC-MAD-008 | 既存地点の編集画面を開くと初期値は DB 値が表示される（引き継ぎ適用なし） | Medium |

## シナリオ詳細

### TC-MAD-001: 地点が存在しない状態で地点追加すると交通手段のメーター値が初期値になる

**前提:**
- 交通手段 meterValue = 10000 のイベントを開く
- MichiInfo タブに地点が存在しない

**操作手順:**
1. イベントを開き MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面が表示される

**期待結果:**
- メーター入力欄に `"10000"` が初期表示されている

---

### TC-MAD-002: 既存地点がある状態で地点追加すると前の地点のメーター値が初期値になる

**前提:**
- MichiInfo タブに meterValue = 15000 の地点が1件存在するイベントを開く

**操作手順:**
1. MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面が表示される

**期待結果:**
- メーター入力欄に `"15000"` が初期表示されている

---

### TC-MAD-003: 既存地点がある状態で地点追加すると前の地点のメンバーが引き継がれる

**前提:**
- MichiInfo タブにメンバー「田中・鈴木」が設定された地点が1件存在するイベントを開く

**操作手順:**
1. MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面が表示される

**期待結果:**
- メンバー欄に「田中・鈴木」が選択済み状態で表示されている

---

### TC-MAD-004: 既存地点がある状態で地点追加すると前の地点の日付が初期値になる

**前提:**
- MichiInfo タブに `markLinkDate = 2026-03-15` の地点が1件存在するイベントを開く

**操作手順:**
1. MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面が表示される

**期待結果:**
- 日付欄に `2026-03-15` が初期表示されている

---

### TC-MAD-005: 地点が存在しない状態で地点追加すると本日の日付が初期値になる

**前提:**
- MichiInfo タブに地点が存在しないイベントを開く（交通手段も未設定）

**操作手順:**
1. MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面が表示される

**期待結果:**
- 日付欄にテスト実行日の日付が初期表示されている

---

### TC-MAD-006: MarkDetail のメンバー選択候補がイベントメンバーのみになっている

**前提:**
- イベントの BasicInfo メンバーに「田中・鈴木」が設定済み
- マスターには「田中・鈴木・山田」が存在する

**操作手順:**
1. MichiInfo タブを表示する
2. 地点追加ボタンをタップする
3. MarkDetail 画面のメンバー選択ボタンをタップする

**期待結果:**
- 選択候補に「田中・鈴木」のみ表示される
- 「山田」は表示されない

---

### TC-MAD-007: EventDetail 保存後に交通手段の最大メーター値が更新される

**前提:**
- 交通手段 meterValue = 10000 のイベントを開く
- MichiInfo タブに meterValue = 15000 の地点が存在する
- BasicInfo タブで上記の交通手段が選択済み

**操作手順:**
1. EventDetail の保存ボタンをタップする
2. 保存完了後、設定 > 交通手段設定を開く
3. 対象交通手段の詳細を確認する

**期待結果:**
- 交通手段の meterValue が `15000` に更新されている

---

### TC-MAD-008: 既存地点の編集画面を開くと初期値は DB 値が表示される（引き継ぎ適用なし）

**前提:**
- MichiInfo タブに meterValue = 15000 の地点が1件存在するイベントを開く

**操作手順:**
1. MichiInfo タブを表示する
2. 既存地点のカードをタップして編集画面を開く

**期待結果:**
- メーター入力欄に `"15000"`（DB に保存された値）が表示されている
- 別の地点の値や交通手段の値は使用されていない

---

# 9. 非機能要件・スコープ外

## 非機能要件

- 既存地点の編集（`markLink != null` モード）には初期値ルールを適用しない
- 初期値はユーザーが変更可能である
- `availableMembers` が空のとき、メンバー選択 UI はクラッシュしないこと
- `TransRepository.save` の失敗は EventDetail 保存成功全体に影響を与えない
- `_onAddMarkPressed` の DB 参照（`EventRepository.fetch`）が失敗した場合はエラー State を emit する

## スコープ外

- Link（リンク）追加時の初期値引き継ぎ（別要件として後続定義）
- メーター自動補完・距離自動計算
- 前の地点ではなく任意の地点を選んで引き継ぐ機能

---

# 10. DI 変更サマリー

## EventDetailBloc への TransRepository 注入

`router.dart` の `/event/:id` ビルダーおよび `di.dart` の EventDetailBloc 生成箇所に以下を追加する:

- `transRepository: getIt<TransRepository>()`

`TransRepository` は既に `di.dart` で `Singleton` 登録済みのため、新規登録は不要。

---

# End of MarkAdditionDefaults Spec
