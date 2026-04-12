# 要件書: カスタム数値キーパッド Phase 2（四則演算）

作成日: 2026-04-11
作成ロール: product-manager
前フェーズ: docs/Requirements/REQ-custom_numeric_keypad.md

---

## 背景・目的

Phase 1 で基本キーパッドを実装した。Phase 2 では演算子（+, −, ×, ÷）と `=`→`確定` トグルを追加し、簡易計算機能を提供する。

ドライブ記録でよくある計算（例: 給油金額 ÷ 給油量 = 単価、走行距離 × 燃費係数 など）をアプリ内で完結させる。

---

## 機能要件

### 1. 演算子キーの有効化

Phase 1 で配置済みの演算子キー（`+` `−` `×` `÷`）をタップ有効にする。

### 2. 入力の状態機械

| 状態 | 説明 |
|---|---|
| `idle` | 初期状態。`_inputString = ''` |
| `entering_lhs` | 左辺の数値を入力中 |
| `operator_entered` | 演算子を入力済み。右辺の入力待ち |
| `entering_rhs` | 右辺の数値を入力中 |
| `result_shown` | `=` を押して計算結果を表示中 |

### 3. 演算子入力の動作

- 左辺（lhs）を入力後に演算子をタップ → 演算子を記憶し状態を `operator_entered` へ
- 演算子入力後に別の演算子をタップ → 演算子を上書きする
- 演算子の連打（例: `5 + + 3`）は最後の演算子が有効

### 4. `=`→`確定` トグル動作

- **`=` ボタン（`result_shown` でない状態）をタップ:**
  - lhs のみ入力（演算子なし）→ そのまま `onConfirmed(lhs)` を呼び出し、シートを閉じる
  - lhs + 演算子 + rhs が揃っている → 計算を実行し結果を Display に表示する。ボタンラベルを `確定` に切り替える（`result_shown` 状態へ）
  - lhs + 演算子のみ（rhs なし）→ `onConfirmed(lhs)` を呼び出し、シートを閉じる（演算子無視）

- **`確定` ボタン（`result_shown` 状態）をタップ:**
  - 表示中の計算結果を `onConfirmed(result)` で返し、シートを閉じる

- **`result_shown` 状態でさらに数字を入力:**
  - 状態をリセットし新規入力（`entering_lhs`）として扱う

- **`result_shown` 状態で演算子をタップ:**
  - 計算結果を lhs として引き継ぎ、`operator_entered` 状態へ（連続計算）

### 5. Display エリアの更新

| 状態 | Display 表示内容 |
|---|---|
| `idle` | originalValue（薄く） |
| `entering_lhs` | lhs の入力値 |
| `operator_entered` | `{lhs} {演算子}` |
| `entering_rhs` | `{lhs} {演算子} {rhs}` |
| `result_shown` | 計算結果（大きく）|

### 6. エラー処理

- `÷ 0` の場合: Display に `エラー` と表示し `result_shown` 状態にならない（`=` ラベルのまま）
- 数値が大きすぎる場合（結果が 15桁超）: 小数点以下を丸めて表示する

### 7. C・⌫ キーの動作変更

| キー | `entering_lhs` | `operator_entered` | `entering_rhs` | `result_shown` |
|---|---|---|---|---|
| `C` | 全消去 → `idle` | 全消去 → `idle` | 全消去 → `idle` | 全消去 → `idle` |
| `⌫` | lhs の末尾1文字削除 | 演算子を削除 → `entering_lhs` | rhs の末尾1文字削除 | 全消去 → `idle` |

---

## 非変更項目

- `CustomNumericKeypad` の外部インタフェース（onConfirmed, originalValue, unit, isDecimal）は変更しない
- `NumericInputRow` は変更しない
- `=`→`確定` トグルは `CustomNumericKeypad` の内部実装のみで完結する
- Phase 1 で実装済みの基本キー（数字・00・.・C・⌫）の動作は維持する（演算子なし入力の場合）

---

## 参照

- Phase 1 要件書: `docs/Requirements/REQ-custom_numeric_keypad.md`
- Phase 1 Spec: `docs/Spec/Features/FS-custom_numeric_keypad.md`
