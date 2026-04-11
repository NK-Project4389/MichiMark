# Feature Spec: CustomNumericKeypad（カスタム数値キーパッド）

Version: 1.0
作成日: 2026-04-11
作成ロール: architect
参照要件書: docs/Requirements/REQ-custom_numeric_keypad.md

---

## 1. Feature Overview

### Feature Name

`CustomNumericKeypad`（共有ウィジェット）

### Purpose

デバイス標準キーボードを廃止し、数値入力専用のカスタムキーパッドを提供する。
`NumericInputRow` ウィジェットのフィールドタップ時に BottomSheet として表示する。

### Scope

**含むもの（Phase 1）**
- カスタムキーパッド BottomSheet 表示
- 数字キー（0〜9, 00）・小数点・C・⌫・`=`（確定）キー
- 演算子キー配置（UI表示のみ・タップ無効）
- Display エリア（変更前値・現在入力値）
- `isDecimal` 連動（小数点キーの活性/非活性）
- `MediaQuery` 比率によるレスポンシブサイズ
- ライトモード・ダークモード対応

**含まないもの（Phase 1 外）**
- 演算子ロジック（四則演算・中間式計算） → Phase 2
- `=`→`確定` トグル動作 → Phase 2
- Push-up 方式（画面押し上げ） → Phase 3

---

## 2. アーキテクチャ上の位置づけ

`CustomNumericKeypad` は Feature ではなく **共有ウィジェット**（`lib/widgets/`）として実装する。

- BLoC・Cubit は持たない
- `StatefulWidget` で内部状態（入力文字列）を管理する
- `NumericInputRow` がタップ時に `showModalBottomSheet` で表示する
- `onConfirmed` コールバックで確定値を呼び出し元に返す

---

## 3. Widget インタフェース

### CustomNumericKeypad

```dart
class CustomNumericKeypad extends StatefulWidget {
  /// 確定時に呼ばれるコールバック（生の数値文字列、カンマなし）
  final ValueChanged<String> onConfirmed;

  /// 現在の値（BottomSheet表示時点の値 = Draftの変更前値表示に使用）
  final String originalValue;

  /// 単位（Display エリアの変更前値行に表示）
  final String unit;

  /// true: 小数点キーを活性化 / false: 小数点キーを非活性グレー表示
  final bool isDecimal;

  const CustomNumericKeypad({
    super.key,
    required this.onConfirmed,
    required this.originalValue,
    required this.unit,
    this.isDecimal = false,
  });
}
```

### NumericInputRow の変更

`TextField` + システムキーボードを廃止し、以下に変更する：

```dart
// 変更後: タップで BottomSheet 表示
GestureDetector(
  onTap: () => _showKeypad(context),
  child: _DisplayText(value: widget.value),  // 読み取り専用テキスト表示
)
```

`_showKeypad` の実装：

```dart
void _showKeypad(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CustomNumericKeypad(
      originalValue: widget.value,
      unit: widget.unit,
      isDecimal: widget.isDecimal,
      onConfirmed: widget.onChanged,
    ),
  );
}
```

---

## 4. 内部状態（State）

```dart
class _CustomNumericKeypadState extends State<CustomNumericKeypad> {
  String _inputString = '';  // 現在の入力文字列（カンマなし）
}
```

- BottomSheet 表示直後: `_inputString = ''`（空文字からの新規入力）
- 表示エリアの「変更前値」: `widget.originalValue`（不変）
- 表示エリアの「現在の入力値」: `_inputString`（空の場合は `widget.originalValue` を薄く表示）

---

## 5. キー構成とレイアウト（C案）

### キーグリッド（5列 × 4行 + 確定行）

```
行1: [C]  [7] [8] [9] [÷]
行2: [⌫] [4] [5] [6] [×]
行3: [.]  [1] [2] [3] [−]
行4: [00] [0] [　] [　] [+]
行5: [           =（確定）           ]  ← 全幅
```

- 行4の `[　]` はダミーセル（空白埋め）
- 演算子キー（`+` `-` `×` `÷`）は Phase 1 では **タップ無効・非活性スタイル適用**

### `=`（確定）ボタンの Phase 1 動作

- 常にラベル `=` を表示
- タップ → `onConfirmed(_inputString)` を呼び出してから `Navigator.pop(context)` でシートを閉じる
- `_inputString` が空の場合は `onConfirmed(widget.originalValue)` を呼び出す（値を変更しない）

---

## 6. キー操作ロジック

| キー | 動作 |
|---|---|
| `0`〜`9` | `_inputString` の末尾に数字を追加 |
| `00` | `_inputString` の末尾に `00` を追加（ただし先頭の `00` は避ける） |
| `.` | `_inputString` に小数点を1つだけ追加（isDecimal=false なら無効）。すでに `.` を含む場合は無視 |
| `C` | `_inputString = ''` にリセット |
| `⌫` | `_inputString` の末尾1文字を削除 |
| `+` `-` `×` `÷` | Phase 1: 無視（タップ無効） |
| `=` | `onConfirmed` を呼び出し + シートを閉じる |

### 入力制限

- 先頭が `0` の場合、次に数字を入力しても `0N` にはならず `N` に上書きする（ただし `0.` は許容）
- 最大入力長: 15文字

---

## 7. Display エリア

キーパッド上部に配置する。

```
┌─────────────────────────────────┐
│ 変更前: 152.8 km/L               │  ← originalValue が空でない場合のみ表示
│ 152.8                           │  ← _inputString（空の場合は originalValue を薄く）
└─────────────────────────────────┘
```

- 「変更前」行: `widget.originalValue` が空でない場合のみ表示。フォント: 11sp / Regular / onSurfaceVariant
- 入力値行: フォント: 32sp / Light(300) / onSurface。右寄せ
- 単位ラベル: 入力値行の右端に `widget.unit` を小さく表示

---

## 8. カラー仕様

### ライトモード

| キー種別 | 背景色 | テキスト色 |
|---|---|---|
| 数字 (0-9, 00) | `#FFFFFF` | `#1A1A2E` |
| 演算子（非活性） | `#E8F4F2` | `#A0B8B6` |
| `=`（確定） | `#2D6A6A` | `#FFFFFF` |
| `⌫` Delete | `#E8EEF0` | `#4A6060` |
| `C` クリア | `#FFE5E5` | `#C0392B` |
| キーパッド背景 | `#F2F4F4` | — |

### ダークモード

| キー種別 | 背景色 | テキスト色 |
|---|---|---|
| 数字 | `#2C3C3C` | `#E8F4F2` |
| 演算子（非活性） | `#1E2E2E` | `#4A6A68` |
| `=`（確定） | `#4ECDC4` | `#1A1A2E` |
| `⌫` Delete | `#243030` | `#9BB5B3` |
| `C` クリア | `#3A1A1A` | `#FF6B6B` |
| キーパッド背景 | `#1C2626` | — |

---

## 9. レスポンシブサイズ仕様

スケール係数 `sf = MediaQuery.of(context).size.width / 375`

| 要素 | 基準値（375pt） | 実値 |
|---|---|---|
| キー高 | 52pt | `52 * sf` |
| キー横幅（1列） | (screenWidth - padding×2 - gap×4) / 5 | 自動 |
| キー間隔（gap） | 8pt | `8 * sf` |
| Display エリア高 | 90pt | `90 * sf` |
| 確定ボタン高 | 52pt | `52 * sf` |
| 全体 Padding (水平) | 12pt | `12 * sf` |
| 全体 Padding (下) | SafeArea + 8pt | SafeArea 加算 |
| 数字キー フォント | 18sp | `18 * sf` |
| 確定ボタン フォント | 16sp | `16 * sf` |
| C・⌫ フォント | 16sp | `16 * sf` |
| 演算子 フォント | 20sp | `20 * sf` |

キーの角丸: `BorderRadius.circular(8 * sf)`

---

## 10. BottomSheet 仕様

- `isScrollControlled: true`
- `backgroundColor: Colors.transparent`
- 上部角丸: `BorderRadius.vertical(top: Radius.circular(16))`
- シート背景色: カラー仕様の「キーパッド背景」
- バリア（背景）タップで閉じる（デフォルト動作）
- 閉じた際に `onChanged` が呼ばれない場合（バリアタップ）は入力値を変更しない

---

## 11. Widget ウィジェットキー一覧（Integration Test 用）

| ウィジェット | Key |
|---|---|
| キーパッド全体 | `Key('custom_numeric_keypad')` |
| 数字キー n | `Key('keypad_digit_$n')` （n: 0〜9） |
| 00 キー | `Key('keypad_digit_00')` |
| 小数点キー | `Key('keypad_dot')` |
| C クリアキー | `Key('keypad_clear')` |
| ⌫ バックスペース | `Key('keypad_backspace')` |
| `=`（確定）ボタン | `Key('keypad_confirm')` |
| Display 入力値テキスト | `Key('keypad_display_input')` |
| Display 変更前値テキスト | `Key('keypad_display_original')` |
| NumericInputRow タップ領域 | `Key('numeric_input_tap_$label')` ※label を kebab-case に変換 |

---

## 12. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- BasicInfo タブ（燃費・ガソリン単価）が表示されていること
- イベントのトピックが燃費表示を有効にしていること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-CNK-001 | 数値を入力して確定できる | High |
| TC-CNK-002 | ⌫（バックスペース）で1文字ずつ削除できる | High |
| TC-CNK-003 | C（クリア）で全消去できる | High |
| TC-CNK-004 | 変更前の値が Display に表示される | High |
| TC-CNK-005 | isDecimal=false の場合、小数点キーが非活性 | High |
| TC-CNK-006 | isDecimal=true の場合、小数点を含む値を入力できる | High |
| TC-CNK-007 | 00 キーで「00」を入力できる | Medium |
| TC-CNK-008 | バリア（背景）タップでキーパッドを閉じると値が変更されない | Medium |
| TC-CNK-009 | 空入力で確定すると元の値が維持される | Medium |

---

### TC-CNK-001: 数値を入力して確定できる

**操作手順:**
1. BasicInfo タブを表示する
2. 編集モードに入る
3. 「燃費」フィールドをタップする
4. キーパッド BottomSheet が開く
5. `1` → `5` → `0` の順にタップする
6. `=`（確定）ボタンをタップする

**期待結果:**
- キーパッドが閉じる
- 「燃費」フィールドに `150` が表示される

---

### TC-CNK-002: ⌫（バックスペース）で1文字ずつ削除できる

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `1` → `2` → `3` を入力する（Display に `123` 表示）
3. `⌫` を1回タップする

**期待結果:**
- Display の入力値が `12` になる

---

### TC-CNK-003: C（クリア）で全消去できる

**操作手順:**
1. 「燃費」フィールドをタップしてキーパッドを開く
2. `4` → `5` → `6` を入力する
3. `C` をタップする

**期待結果:**
- Display の入力値が空（プレースホルダー表示）になる

---

### TC-CNK-004: 変更前の値が Display に表示される

**操作手順:**
1. 燃費が `20.5` に保存された状態でイベントを開く
2. BasicInfo 編集モードに入る
3. 「燃費」フィールドをタップしてキーパッドを開く

**期待結果:**
- Display の「変更前」行に `20.5 km/L` が表示される

---

### TC-CNK-005: isDecimal=false の場合、小数点キーが非活性

**操作手順:**
1. 「ガソリン単価」フィールド（isDecimal=false）をタップしてキーパッドを開く
2. `.`（小数点）キーをタップする

**期待結果:**
- Display の入力値に `.` が追加されない
- 小数点キーが非活性（グレー）スタイルで表示されている

---

### TC-CNK-006: isDecimal=true の場合、小数点を含む値を入力できる

**操作手順:**
1. 「燃費」フィールド（isDecimal=true）をタップしてキーパッドを開く
2. `2` → `0` → `.` → `5` の順にタップする
3. `=`（確定）ボタンをタップする

**期待結果:**
- 「燃費」フィールドに `20.5` が表示される

---

### TC-CNK-007: 00 キーで「00」を入力できる

**操作手順:**
1. 「ガソリン単価」フィールドをタップしてキーパッドを開く
2. `1` → `00` の順にタップする
3. `=`（確定）ボタンをタップする

**期待結果:**
- 「ガソリン単価」フィールドに `100` が表示される（カンマ整形: `100`）

---

### TC-CNK-008: バリア（背景）タップでキーパッドを閉じると値が変更されない

**操作手順:**
1. 「燃費」フィールド（初期値 `20.5`）をタップしてキーパッドを開く
2. `3` → `0` と入力する
3. バリア（キーパッド外の暗い領域）をタップしてシートを閉じる

**期待結果:**
- 「燃費」フィールドが `20.5` のまま変わっていない

---

### TC-CNK-009: 空入力で確定すると元の値が維持される

**操作手順:**
1. 「燃費」フィールド（初期値 `15.0`）をタップしてキーパッドを開く
2. 何も入力せずに `=`（確定）ボタンをタップする

**期待結果:**
- 「燃費」フィールドが `15.0` のまま変わっていない

---

## 13. Phase 2 対応メモ（実装者向け）

Phase 2（四則演算）実装時の変更点：
- 演算子キーをタップ有効に変更
- `_inputString` を「式文字列」として拡張（例: `"150+48"`）
- `=` タップ時: 式を評価して結果を Display に表示 + ボタンラベルを `確定` に切り替え
- `確定` タップ時: `onConfirmed` を呼び出してシートを閉じる

この変更が `CustomNumericKeypad` の内部実装の変更のみで完結するよう、外部インタフェースは変更しない。
