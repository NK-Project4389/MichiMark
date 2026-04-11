# 要件書: カスタム数値キーパッド Phase 3（Push-up 方式 + 確定ボタンラベル変更）

作成日: 2026-04-11
作成ロール: product-manager
前フェーズ: docs/Requirements/REQ-custom_numeric_keypad_phase2.md

---

## 背景・目的

Phase 2 で四則演算機能を実装した。Phase 3 では以下 2 点を変更する。

1. **Push-up 方式への移行**: キーパッドを BottomSheet から「画面を押し上げる」方式に変更し、入力中のフィールドが見やすくなるようにする
2. **確定ボタンのラベル変更**: 初期ラベルを「確定」とし、四則演算が使用された場合のみ「＝」に変更する（Phase 2 とラベルのデフォルトを逆転させる）

---

## 機能要件

### 1. Push-up 方式への移行

- `CustomNumericKeypad` の表示方式を `showModalBottomSheet` から画面押し上げ方式に変更する
- キーパッドが表示されると、画面コンテンツ全体がキーパッドの高さ分だけ上に押し上げられる
- キーパッドが非表示になると、画面コンテンツが元の位置に戻る（アニメーションあり）
- **外部インタフェース（`onConfirmed`, `originalValue`, `unit`, `isDecimal`）は変更しない**

### 2. 確定ボタンのラベル変更（Phase 2 からの変更）

#### Phase 2 との違い

| | Phase 2 | Phase 3 |
|---|---|---|
| 初期ラベル | `=` | `確定` |
| 演算使用中ラベル | `確定`（`result_shown` 時のみ） | `＝`（演算子入力後〜計算前） |
| 計算結果表示中 | `確定` | `確定` |

#### 状態ごとのラベル

| 状態 | ボタンラベル | 意味 |
|---|---|---|
| `idle` | `確定` | 入力なし → 押しても何もしない（Phase 2 と同じ） |
| `entering_lhs` | `確定` | lhs のみ入力中 → 押すと lhs を確定してシート閉じる |
| `operator_entered` | `＝` | 演算子入力済み・rhs 待ち → 押すと lhs を確定してシート閉じる（演算子無視） |
| `entering_rhs` | `＝` | rhs 入力中 → 押すと計算実行し `result_shown` へ |
| `result_shown` | `確定` | 計算結果表示中 → 押すと結果を確定してシート閉じる |

#### ラベルの切り替え条件

- `_operator != null && !_resultShown` → ボタンラベルを `＝` に変更
- それ以外 → ボタンラベルを `確定` に変更

### 3. `label` パラメータ追加

- `CustomNumericKeypad` に `label` パラメータ（`String`, オプション, デフォルト `''`）を追加する
- Display エリアに「`{label}  {変更前値} {unit}`」を表示し、ユーザーが何のフィールドを編集しているか分かるようにする
- `NumericInputRow` は `label` を `CustomNumericKeypad` に渡す

---

## 非変更項目

- 外部インタフェース（`onConfirmed`, `originalValue`, `unit`, `isDecimal`）は変更しない
- Widget Key 一覧は変更しない（`Key('keypad_confirm')` は引き続き使用）
- Phase 2 の四則演算ロジック・状態機械は変更しない
- Phase 1 / Phase 2 のキー操作仕様は維持する

---

## 参照

- Phase 1 要件書: `docs/Requirements/REQ-custom_numeric_keypad.md`
- Phase 2 要件書: `docs/Requirements/REQ-custom_numeric_keypad_phase2.md`
- Phase 2 Spec: `docs/Spec/Features/FS-custom_numeric_keypad_phase2.md`
