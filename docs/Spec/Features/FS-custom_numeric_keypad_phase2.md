# Feature Spec: CustomNumericKeypad Phase 2（四則演算）

Version: 1.0
作成日: 2026-04-11
作成ロール: architect
参照要件書: docs/Requirements/REQ-custom_numeric_keypad_phase2.md
前フェーズ: docs/Spec/Features/FS-custom_numeric_keypad.md

---

## 1. Feature Overview

### Feature Name

`CustomNumericKeypad` Phase 2（四則演算拡張）

### Purpose

Phase 1 の基本数値入力に四則演算機能（+, −, ×, ÷）を追加する。
演算子キーをタップ有効にし、`=` → `確定` トグルによって中間計算結果を確定できるようにする。
アプリ内でドライブ記録の計算（例: 給油金額 ÷ 給油量 = 単価）を完結させる。

### Scope

**含むもの（Phase 2）**
- 演算子キー（`+`, `−`, `×`, `÷`）のタップ有効化
- 四則演算ロジック（中間式の評価）
- `=` → `確定` トグル（`result_shown` 状態の追加）
- 状態機械（5状態）による入力フロー管理
- ゼロ除算エラー表示
- 連続計算（結果を lhs として引き継ぎ）

**含まないもの（Phase 2 外）**
- Push-up 方式（画面押し上げ） → Phase 3
- 複数演算子の連鎖（`1 + 2 + 3` 形式） → Phase 2 は直前の演算子上書きのみ
- 外部インタフェース変更（onConfirmed, originalValue, unit, isDecimal）

---

## 2. アーキテクチャ上の位置づけ

Phase 1 と変更なし。`CustomNumericKeypad` は引き続き共有ウィジェット（`lib/widgets/`）として実装する。

- BLoC・Cubit は持たない
- `StatefulWidget` で内部状態を管理する
- 外部インタフェースへの変更はなし

---

## 3. 外部インタフェース（変更なし）

Phase 1 の `CustomNumericKeypad` コンストラクタ（onConfirmed, originalValue, unit, isDecimal）は変更しない。

---

## 4. 内部状態（Phase 2 追加分）

### 4.1 Phase 1 からの変更

Phase 1 では単一フィールド `_inputString` で入力文字列を管理していた。
Phase 2 では `_inputString` を**廃止**し、以下の4フィールドに分解する。

`_inputString` は Phase 1 実装内でのみ使用されていた内部フィールドであり、外部インタフェースではないため変更可。

### 4.2 追加する内部状態フィールド

| フィールド | 型 | 説明 |
|---|---|---|
| `_lhs` | `String` | 左辺の数値文字列（カンマなし）。Phase 1 の `_inputString` に相当 |
| `_operator` | `String?` | 現在の演算子（`'+'`, `'−'`, `'×'`, `'÷'`）または `null` |
| `_rhs` | `String` | 右辺の数値文字列（カンマなし）。`_operator` が null の場合は常に空 |
| `_resultShown` | `bool` | `=` を押して計算結果を表示中かどうか。`true` のときボタンラベルを `確定` に変える |

### 4.3 状態機械（5状態）

| 状態名 | 条件 | 説明 |
|---|---|---|
| `idle` | `_lhs == '' && _operator == null && _rhs == '' && !_resultShown` | 初期状態 |
| `entering_lhs` | `_lhs != '' && _operator == null` | 左辺入力中 |
| `operator_entered` | `_operator != null && _rhs == '' && !_resultShown` | 演算子入力済み・右辺待ち |
| `entering_rhs` | `_operator != null && _rhs != ''` | 右辺入力中 |
| `result_shown` | `_resultShown == true` | `=` 押下後・計算結果表示中 |

状態は明示的なenumフィールドではなく、上記4フィールドの組み合わせで導出する（実装判断に委ねる）。

---

## 5. キー操作仕様

### 5.1 `_onDigit(String digit)` の状態ごとの動作

| 状態 | 動作 |
|---|---|
| `idle` | `_lhs` に追加（Phase 1 と同じ先頭0・最大15文字ルール適用）→ `entering_lhs` へ |
| `entering_lhs` | `_lhs` の末尾に追加（Phase 1 の `_inputString` 操作と同一） |
| `operator_entered` | `_rhs` に追加→ `entering_rhs` へ |
| `entering_rhs` | `_rhs` の末尾に追加 |
| `result_shown` | 全状態リセット（`_lhs = digit`, `_operator = null`, `_rhs = ''`, `_resultShown = false`）→ `entering_lhs` へ |

`00` キーの動作は Phase 1 と同一ルールを lhs / rhs それぞれに適用する（先頭が `'0'` の場合は `00` を無視）。

### 5.2 `_onOperator(String op)` （新規メソッド）

| 状態 | 動作 |
|---|---|
| `idle` | 何もしない（lhs なしで演算子は無効） |
| `entering_lhs` | `_operator = op`→ `operator_entered` へ |
| `operator_entered` | `_operator = op`（演算子上書き）→ 状態変化なし |
| `entering_rhs` | `_operator = op`（演算子上書き）、`_rhs = ''`→ `operator_entered` へ |
| `result_shown` | 計算結果を `_lhs` として引き継ぎ、`_operator = op`, `_rhs = ''`, `_resultShown = false`→ `operator_entered` へ |

### 5.3 `_onEquals()` の状態ごとの動作

| 状態 | 動作 |
|---|---|
| `idle` | 何もしない |
| `entering_lhs` | `onConfirmed(_lhs)` を呼び出し → `Navigator.pop(context)` でシートを閉じる |
| `operator_entered` | `onConfirmed(_lhs)` を呼び出し → シートを閉じる（rhs なし・演算子無視） |
| `entering_rhs` | `_calculate()` を実行。成功時: 結果を Display に表示・`_resultShown = true`（`result_shown` へ）。ゼロ除算時: Display に `エラー` 表示・状態変化なし |
| `result_shown` | `onConfirmed(_lhs)` を呼び出し → シートを閉じる（`_lhs` には計算結果が格納済み） |

`result_shown` 状態での `onConfirmed` の引数は `_lhs`（計算結果文字列）。

### 5.4 `_calculate()` の計算ロジック

- `_lhs` と `_rhs` を `double.parse()` で変換して四則演算を実行する
- `÷ 0`（rhs が 0）の場合: 計算を中止し Display に `エラー` を表示する。`_resultShown` は `false` のまま
- 計算成功時: 結果を文字列化して `_lhs` に格納し、`_operator = null`, `_rhs = ''`, `_resultShown = true` に更新する
- 結果の文字列化ルール:
  - 整数値（小数部が 0）の場合: 小数点なし整数文字列で返す（例: `150.0` → `'150'`）
  - 小数値の場合: 末尾の余分な `0` を削除して返す（例: `1.50` → `'1.5'`）
  - 結果が 15桁超の場合: 小数点以下を適切に丸めて 15文字以内に収める

### 5.5 `_onClear()` の動作変更

全状態共通: `_lhs = ''`, `_operator = null`, `_rhs = ''`, `_resultShown = false`→ `idle` へ（Phase 1 と結果は同じ、実装内部が変わる）

### 5.6 `_onBackspace()` の状態ごとの動作変更

| 状態 | 動作 |
|---|---|
| `idle` | 何もしない |
| `entering_lhs` | `_lhs` の末尾1文字削除。`_lhs` が空になった場合は `idle` へ |
| `operator_entered` | `_operator = null`→ `entering_lhs` へ（演算子削除） |
| `entering_rhs` | `_rhs` の末尾1文字削除。`_rhs` が空になった場合は `operator_entered` へ |
| `result_shown` | 全消去→ `idle` へ（Phase 1 のバックスペース動作と同等） |

### 5.7 `_onDot()` の動作変更

| 状態 | 動作 |
|---|---|
| `idle` / `entering_lhs` | Phase 1 と同様に `_lhs` に小数点を追加（`isDecimal` チェック・重複チェック含む） |
| `operator_entered` / `entering_rhs` | `_rhs` に小数点を追加（`isDecimal` チェック・`_rhs` 内での重複チェック含む）。`_rhs` が空の場合は `'0.'` を設定 |
| `result_shown` | 何もしない |

---

## 6. Display エリアの更新仕様

`Key('keypad_display_input')` に表示する内容を状態ごとに定義する。

| 状態 | `keypad_display_input` の表示内容 | 備考 |
|---|---|---|
| `idle` | `widget.originalValue`（薄くグレー表示） | `_inputString` が空の場合の Phase 1 動作と同じ |
| `entering_lhs` | `_lhs` | 通常テキスト色 |
| `operator_entered` | `${_lhs} ${_operator}` | 例: `"150 +"` |
| `entering_rhs` | `${_lhs} ${_operator} ${_rhs}` | 例: `"150 + 48"` |
| `result_shown` | 計算結果文字列（`_lhs` の値） | 通常テキスト色・大きく |
| エラー時 | `エラー` | `result_shown` にはならず `=` ラベルのまま |

### 確定ボタンラベルの切り替え

| `_resultShown` | ボタンラベル | Widget Key |
|---|---|---|
| `false` | `=` | `Key('keypad_confirm')` |
| `true` | `確定` | `Key('keypad_confirm')` |

Widget Key は変更しない。ラベルテキストのみ変わる。

---

## 7. Widget Key 追加（演算子キー）

Phase 2 で演算子キーに `GestureDetector` を追加し、以下のキーを付与する。

| キー記号 | Widget Key |
|---|---|
| `+` | `Key('keypad_op_plus')` |
| `−` | `Key('keypad_op_minus')` |
| `×` | `Key('keypad_op_multiply')` |
| `÷` | `Key('keypad_op_divide')` |

Phase 1 で演算子キーは `GestureDetector` なし・非活性スタイルだった。Phase 2 では `GestureDetector` で `_onOperator()` を呼び出す形に変更する。演算子キーのカラーは「活性時」スタイルに変更する（設計憲章の演算子カラー仕様に従う）。

---

## 8. カラー仕様（演算子キー活性時）

Phase 1 の非活性スタイルから活性スタイルに変更する。

### ライトモード

| キー種別 | 背景色 | テキスト色 |
|---|---|---|
| 演算子（活性） | `#D6EDEB` | `#2D6A6A` |

### ダークモード

| キー種別 | 背景色 | テキスト色 |
|---|---|---|
| 演算子（活性） | `#1E3A3A` | `#4ECDC4` |

非活性スタイル（`_operatorBackground`, `_operatorForeground`）は引き続き `.` キーの非活性時（`isDecimal = false`）に使用する。

---

## 9. Data Flow（Phase 2 追加分）

```
ユーザーが演算子キーをタップ
  ↓
_onOperator(op) が呼ばれる
  ↓
_operator, _lhs, _rhs, _resultShown を更新
  ↓
setState() で Display 再描画

ユーザーが = をタップ（rhs あり）
  ↓
_onEquals() が呼ばれる
  ↓
_calculate() を実行（÷0 チェック含む）
  ↓
成功: _lhs に結果格納・_resultShown = true → Display に結果表示・ボタンラベル「確定」
失敗: Display に「エラー」表示・_resultShown = false のまま

ユーザーが 確定 をタップ（_resultShown = true）
  ↓
_onEquals() が呼ばれる（result_shown 分岐）
  ↓
onConfirmed(_lhs) を呼び出す
  ↓
Navigator.pop(context) でシートを閉じる
```

---

## 10. Test Scenarios（Phase 2 追加分）

### 前提条件

- iOSシミュレーターが起動済みであること
- BasicInfo タブ（燃費・ガソリン単価）が表示されていること
- イベントのトピックが燃費表示を有効にしていること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-CNK-010 | 加算：lhs + rhs を計算して確定できる | High |
| TC-CNK-011 | 減算：lhs − rhs を計算して確定できる | High |
| TC-CNK-012 | 乗算：lhs × rhs を計算して確定できる | High |
| TC-CNK-013 | 除算：lhs ÷ rhs を計算して確定できる | High |
| TC-CNK-014 | `=` → `確定` の2ステップで確定できる | High |
| TC-CNK-015 | lhs + 演算子のみで `=` を押した場合は lhs を確定する | High |
| TC-CNK-016 | ゼロ除算でエラーを表示する | High |
| TC-CNK-017 | `result_shown` 状態で演算子を押して連続計算できる | Medium |
| TC-CNK-018 | `result_shown` 状態で数字を押すと新規入力としてリセットされる | Medium |
| TC-CNK-019 | `⌫` で演算子を削除できる（`operator_entered` → `entering_lhs`） | Medium |

---

### TC-CNK-010: 加算 — lhs + rhs を計算して確定できる

**前提:**
- 「燃費」フィールドが表示されていること
- `isDecimal = true`

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `0` → `0` を入力する（Display: `100`）
3. `Key('keypad_op_plus')` をタップする（Display: `100 +`）
4. `5` → `0` を入力する（Display: `100 + 50`）
5. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- Display に `150` が表示される（`result_shown` 状態）
- `Key('keypad_confirm')` のラベルが `確定` に変わる

**実装ノート（ウィジェットキー）:**
- `Key('keypad_display_input')`: Display 入力値テキスト
- `Key('keypad_op_plus')`: `+` 演算子キー
- `Key('keypad_confirm')`: `=` / `確定` ボタン

---

### TC-CNK-011: 減算 — lhs − rhs を計算して確定できる

**前提:**
- 「燃費」フィールドが表示されていること

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `2` → `0` → `0` を入力する（Display: `200`）
3. `Key('keypad_op_minus')` をタップする（Display: `200 −`）
4. `5` → `0` を入力する（Display: `200 − 50`）
5. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- Display に `150` が表示される
- `Key('keypad_confirm')` のラベルが `確定` に変わる

**実装ノート（ウィジェットキー）:**
- `Key('keypad_op_minus')`: `−` 演算子キー
- `Key('keypad_display_input')`: Display 入力値テキスト
- `Key('keypad_confirm')`: `=` / `確定` ボタン

---

### TC-CNK-012: 乗算 — lhs × rhs を計算して確定できる

**前提:**
- 「燃費」フィールドが表示されていること

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `3` → `0` を入力する（Display: `30`）
3. `Key('keypad_op_multiply')` をタップする（Display: `30 ×`）
4. `5` を入力する（Display: `30 × 5`）
5. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- Display に `150` が表示される
- `Key('keypad_confirm')` のラベルが `確定` に変わる

**実装ノート（ウィジェットキー）:**
- `Key('keypad_op_multiply')`: `×` 演算子キー

---

### TC-CNK-013: 除算 — lhs ÷ rhs を計算して確定できる

**前提:**
- 「燃費」フィールドが表示されていること（`isDecimal = true`）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `3` → `0` → `0` を入力する（Display: `300`）
3. `Key('keypad_op_divide')` をタップする（Display: `300 ÷`）
4. `2` を入力する（Display: `300 ÷ 2`）
5. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- Display に `150` が表示される
- `Key('keypad_confirm')` のラベルが `確定` に変わる

**実装ノート（ウィジェットキー）:**
- `Key('keypad_op_divide')`: `÷` 演算子キー

---

### TC-CNK-014: `=` → `確定` の2ステップで確定できる

**前提:**
- TC-CNK-010 の続き（`result_shown` 状態・Display に `150` 表示）、またはこのシナリオ内で同様の状態を作る

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `5` → `0` を入力する
3. `Key('keypad_op_plus')` をタップする
4. `5` → `0` を入力する
5. `Key('keypad_confirm')` をタップする（ラベル `=`）
   - Display に `200` が表示され、ボタンラベルが `確定` に変わること（中間確認）
6. `Key('keypad_confirm')` をタップする（ラベル `確定`）

**期待結果:**
- キーパッドが閉じる
- 「燃費」フィールドに `200` が反映されている

**実装ノート（ウィジェットキー）:**
- `Key('keypad_confirm')`: `=` / `確定` ボタン（同一キー・ラベルのみ変化）

---

### TC-CNK-015: lhs + 演算子のみで `=` を押した場合は lhs を確定する

**前提:**
- キーパッドを開いた直後（`idle` 状態）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `2` → `0` を入力する（Display: `120`）
3. `Key('keypad_op_plus')` をタップする（Display: `120 +`）
4. rhs を入力せず `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- キーパッドが閉じる
- 「燃費」フィールドに `120` が反映されている（演算子は無視される）

**実装ノート（ウィジェットキー）:**
- `Key('keypad_op_plus')`, `Key('keypad_confirm')`

---

### TC-CNK-016: ゼロ除算でエラーを表示する

**前提:**
- キーパッドを開いた直後（`idle` 状態）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `5` → `0` を入力する（Display: `150`）
3. `Key('keypad_op_divide')` をタップする（Display: `150 ÷`）
4. `0` を入力する（Display: `150 ÷ 0`）
5. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- `Key('keypad_display_input')` に `エラー` が表示される
- `Key('keypad_confirm')` のラベルは `=` のまま変わらない（`result_shown` にならない）
- キーパッドは閉じない

**実装ノート（ウィジェットキー）:**
- `Key('keypad_display_input')`: エラー文字列の確認に使用
- `Key('keypad_confirm')`: ラベルが `=` のままであることを確認

---

### TC-CNK-017: `result_shown` 状態で演算子を押して連続計算できる

**前提:**
- `result_shown` 状態（計算結果が表示されている状態）を作る

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `0` → `0` を入力する
3. `Key('keypad_op_plus')` をタップする
4. `5` → `0` を入力する
5. `Key('keypad_confirm')` をタップする（ラベル `=`）→ Display に `150`
6. `Key('keypad_op_multiply')` をタップする（Display: `150 ×`）
7. `2` を入力する（Display: `150 × 2`）
8. `Key('keypad_confirm')` をタップする（ラベル `=`）

**期待結果:**
- Display に `300` が表示される
- `Key('keypad_confirm')` のラベルが `確定` に変わる

**実装ノート（ウィジェットキー）:**
- `Key('keypad_op_multiply')`, `Key('keypad_display_input')`, `Key('keypad_confirm')`

---

### TC-CNK-018: `result_shown` 状態で数字を押すと新規入力としてリセットされる

**前提:**
- `result_shown` 状態を作る（TC-CNK-010 の手順 1〜5 を実施）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `0` → `0` を入力する
3. `Key('keypad_op_plus')` をタップする
4. `5` → `0` を入力する
5. `Key('keypad_confirm')` をタップする（ラベル `=`）→ Display に `150`（`result_shown`）
6. `Key('keypad_digit_5')` をタップする

**期待結果:**
- `Key('keypad_display_input')` に `5` が表示される（`150` がリセットされる）
- `Key('keypad_confirm')` のラベルが `=` に戻っている（`result_shown = false`）

**実装ノート（ウィジェットキー）:**
- `Key('keypad_digit_5')`: 数字キー
- `Key('keypad_display_input')`, `Key('keypad_confirm')`

---

### TC-CNK-019: `⌫` で演算子を削除できる（`operator_entered` → `entering_lhs` に戻る）

**前提:**
- キーパッドを開いた直後（`idle` 状態）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `2` → `0` を入力する（Display: `120`）
3. `Key('keypad_op_plus')` をタップする（Display: `120 +`）
4. `Key('keypad_backspace')` をタップする

**期待結果:**
- `Key('keypad_display_input')` に `120` が表示される（演算子が削除される）
- 演算子キーの `+` は押せる状態のまま（ウィジェット存在確認）

**実装ノート（ウィジェットキー）:**
- `Key('keypad_backspace')`: バックスペースキー
- `Key('keypad_display_input')`: Display 入力値テキスト

---

## 11. Widget Key 一覧（Phase 2 追加分）

Phase 1 からの追加キー。

| ウィジェット | Key |
|---|---|
| `+` 演算子キー | `Key('keypad_op_plus')` |
| `−` 演算子キー | `Key('keypad_op_minus')` |
| `×` 演算子キー | `Key('keypad_op_multiply')` |
| `÷` 演算子キー | `Key('keypad_op_divide')` |

Phase 1 からの継続キー（変更なし）。

| ウィジェット | Key |
|---|---|
| キーパッド全体 | `Key('custom_numeric_keypad')` |
| 数字キー n | `Key('keypad_digit_$n')` （n: 0〜9） |
| 00 キー | `Key('keypad_digit_00')` |
| 小数点キー | `Key('keypad_dot')` |
| C クリアキー | `Key('keypad_clear')` |
| ⌫ バックスペース | `Key('keypad_backspace')` |
| `=` / `確定` ボタン | `Key('keypad_confirm')` |
| Display 入力値テキスト | `Key('keypad_display_input')` |
| Display 変更前値テキスト | `Key('keypad_display_original')` |

---

## 12. Phase 3 対応メモ（実装者向け）

Phase 3（Push-up 方式）実装時の変更点：
- `CustomNumericKeypad` の表示方式を BottomSheet から画面押し上げに変更する
- 外部インタフェース・内部状態は Phase 2 から変更しない予定
