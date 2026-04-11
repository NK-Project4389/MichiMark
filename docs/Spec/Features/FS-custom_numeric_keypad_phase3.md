# Feature Spec: CustomNumericKeypad Phase 3（確定ボタンラベル変更 + label 表示）

Version: 1.0
作成日: 2026-04-11
作成ロール: architect
参照要件書: docs/Requirements/REQ-custom_numeric_keypad_phase3.md
前フェーズ: docs/Spec/Features/FS-custom_numeric_keypad_phase2.md

---

## 1. Feature Overview

### Feature Name

`CustomNumericKeypad` Phase 3（確定ボタンラベル変更 + フィールド名表示）

### Purpose

- 確定ボタンのデフォルトラベルを「確定」に変更し、四則演算使用時のみ「＝」にする（UX 改善）
- `label` パラメータを追加して Display エリアにフィールド名を表示する

### Scope

**含むもの（Phase 3）**
- `_buildConfirmButton` のラベルロジック変更（`_resultShown` 基準 → `_operator != null && !_resultShown` 基準）
- `CustomNumericKeypad` への `label` パラメータ追加（省略可能）
- Display エリアの上部ヘッダー行に `label` を表示
- `NumericInputRow` から `label` を `CustomNumericKeypad` に渡す

**含まないもの（Phase 3 外）**
- 四則演算ロジック・状態機械の変更（Phase 2 から変更なし）
- 外部インタフェースの `onConfirmed`, `originalValue`, `unit`, `isDecimal` の変更
- BottomSheet 表示方式の変更（`showModalBottomSheet` を維持）

---

## 2. アーキテクチャ上の位置づけ

Phase 1・2 と変更なし。`CustomNumericKeypad` は `lib/widgets/` の共有ウィジェット。

---

## 3. 外部インタフェース変更

### 3.1 `CustomNumericKeypad` に `label` パラメータ追加

```dart
const CustomNumericKeypad({
  super.key,
  required this.onConfirmed,
  required this.originalValue,
  required this.unit,
  this.isDecimal = false,
  this.label = '',          // ← Phase 3 追加（省略可能）
});
```

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `label` | `String` | 任意（デフォルト `''`） | 編集中フィールド名。Display ヘッダーに表示する |

### 3.2 `NumericInputRow` の `_showKeypad` に `label` を追加

```dart
void _showKeypad(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CustomNumericKeypad(
      label: label,           // ← Phase 3 追加
      originalValue: value,
      unit: unit,
      isDecimal: isDecimal,
      onConfirmed: onChanged,
    ),
  );
}
```

---

## 4. 確定ボタンラベルロジック変更

### 4.1 変更前（Phase 2）

```dart
final label = _resultShown ? '確定' : '=';
```

### 4.2 変更後（Phase 3）

```dart
final confirmLabel = (_operator != null && !_resultShown) ? '＝' : '確定';
```

※ 変数名 `label` は `widget.label` と衝突するため `confirmLabel` に変更する。

### 4.3 状態ごとのラベル対応

| 状態 | `_operator` | `_resultShown` | ボタンラベル |
|---|---|---|---|
| `idle` | `null` | `false` | `確定` |
| `entering_lhs` | `null` | `false` | `確定` |
| `operator_entered` | `非null` | `false` | `＝` |
| `entering_rhs` | `非null` | `false` | `＝` |
| `result_shown` | `null` | `true` | `確定` |

---

## 5. Display エリア変更

### 5.1 `_buildDisplay` のヘッダー行変更

現状の「変更前: {originalValue} {unit}」行を、`label` が空でない場合はフィールド名も含めた形に更新する。

| 条件 | 表示内容 |
|---|---|
| `label` が空 | `変更前: {originalValue} {unit}` （現状と同じ） |
| `label` が非空 | `{label}  変更前: {originalValue} {unit}` |

実装例：
```dart
final headerText = widget.label.isNotEmpty
    ? '${widget.label}  変更前: ${widget.originalValue}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}'
    : '変更前: ${widget.originalValue}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}';
```

---

## 6. Widget Key（変更なし）

| ウィジェット | Key |
|---|---|
| `=` / `確定` ボタン | `Key('keypad_confirm')` |

Widget Key は Phase 2 から変更しない。ラベルテキストのみ変わる。

---

## 7. Test Scenarios（Phase 3）

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-CNK-020 | 初期状態でボタンラベルが「確定」であること | High |
| TC-CNK-021 | 演算子入力後にボタンラベルが「＝」に変わること | High |
| TC-CNK-022 | 計算結果表示後にボタンラベルが「確定」に戻ること | High |
| TC-CNK-023 | 「確定」ボタンで lhs を確定できること（演算子なし） | High |
| TC-CNK-024 | 「＝」→「確定」の2ステップで計算結果を確定できること | High |

---

### TC-CNK-020: 初期状態でボタンラベルが「確定」であること

**前提:**
- 「燃費」フィールドが表示されていること

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く

**期待結果:**
- `Key('keypad_confirm')` のラベルが `確定` である

---

### TC-CNK-021: 演算子入力後にボタンラベルが「＝」に変わること

**前提:**
- キーパッドが開いた直後（`idle` 状態）

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `0` → `0` を入力する（Display: `100`）
3. `Key('keypad_op_plus')` をタップする（Display: `100 +`）

**期待結果:**
- `Key('keypad_confirm')` のラベルが `＝` に変わる

---

### TC-CNK-022: 計算結果表示後にボタンラベルが「確定」に戻ること

**前提:**
- TC-CNK-021 に続いて操作する

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `0` → `0` を入力する
3. `Key('keypad_op_plus')` をタップする
4. `5` → `0` を入力する（Display: `100 + 50`）
5. `Key('keypad_confirm')` をタップする（ラベル `＝`）

**期待結果:**
- Display に `150` が表示される（`result_shown` 状態）
- `Key('keypad_confirm')` のラベルが `確定` に戻る

---

### TC-CNK-023: 「確定」ボタンで lhs を確定できること（演算子なし）

**前提:**
- キーパッドが開いた直後

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `2` → `0` を入力する（Display: `120`）
3. `Key('keypad_confirm')` をタップする（ラベル `確定`）

**期待結果:**
- キーパッドが閉じる
- 「燃費」フィールドに `120` が反映されている

---

### TC-CNK-024: 「＝」→「確定」の2ステップで計算結果を確定できること

**前提:**
- キーパッドが開いた直後

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `5` → `0` を入力する
3. `Key('keypad_op_plus')` をタップする
4. `5` → `0` を入力する
5. `Key('keypad_confirm')` をタップする（ラベル `＝`）
   - Display に `200` が表示され、ボタンラベルが `確定` に変わること（中間確認）
6. `Key('keypad_confirm')` をタップする（ラベル `確定`）

**期待結果:**
- キーパッドが閉じる
- 「燃費」フィールドに `200` が反映されている

---

## 8. Widget Key 一覧（変更なし）

Phase 2 から追加・変更なし。`Key('keypad_confirm')` は引き続き使用。
