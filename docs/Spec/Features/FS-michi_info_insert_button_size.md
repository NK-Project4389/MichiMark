# Feature Spec: MichiInfo 挿入インジケーター改善

FS-michi_info_insert_button_size
Version: 2.0
対応要件: REQ-MIB-001（REQ-MIB-003と統合）, REQ-MIB-002

---

# 1. Feature Overview

## Feature Name

MichiInfo InsertIndicator Improvement

## Purpose

MichiInfo タイムラインの挿入モード時に表示される `_InsertIndicator` について、
視認性・操作性を向上させるため以下の改善を行う。

- REQ-MIB-001 + REQ-MIB-003（統合）: インジケーターのサイズ拡大 ＋ デザイン改善（C案：塗りつぶし円 + Amberグロー）
  - 負のmarginによるカードへの重なり表現は不採用。グロー効果で視認性を担保する
- REQ-MIB-002: InsertMode 時、先頭カードの前にもインジケーターを表示する

## Scope

含むもの
- `_InsertIndicator` Widgetのサイズ変更（height・iconSize）
- `_InsertIndicator` アイコンデザイン変更（C案：`add_circle` + Amberグロー、REQ-MIB-003統合）
- InsertMode 時の SliverList 先頭 index 0 を `_InsertIndicator` に変更（先頭挿入表示）

含まないもの
- 負のmarginによるカードへの重なり表現（採用しない）
- Bloc・State・Event・Domain の構造変更
- 非 InsertMode 時の表示

---

# 2. Feature Responsibility

本Specで変更対象となる責務は Widget（View）層のみ。

- `_InsertIndicator` Widgetのレイアウト変更
- `michi_info_view.dart` 内の SliverList インデックス構造の変更

BLoC・State・Adapter・Domain・Repository は変更不要。

---

# 3. _InsertIndicator Widget 変更仕様

## REQ-MIB-001 + REQ-MIB-003（統合）: サイズ拡大 ＋ デザイン改善（C案）

### 変更前

| プロパティ | 現在値 |
|---|---|
| SizedBox height | 24dp |
| アイコン | `Icons.add_circle_outline` |
| アイコンサイズ | 16dp |
| グロー | なし |

### 変更後

| プロパティ | 変更後の仕様 |
|---|---|
| SizedBox height | 36dp |
| アイコン | `Icons.add_circle`（塗りつぶし） |
| アイコンサイズ | 28dp |
| グロー | `DecoratedBox` + `BoxShadow`（color: Amber 25%不透明、blurRadius: 8、spreadRadius: 4） |

### 実装方針（C案）

```dart
DecoratedBox(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: const Color(0x40F59E0B), // Amber 25%
        blurRadius: 8,
        spreadRadius: 4,
      ),
    ],
  ),
  child: const Icon(
    Icons.add_circle,
    color: Color(0xFFF59E0B),
    size: 28,
  ),
)
```

- 負のmarginは使用しない（グロー効果で視認性を担保）
- 左右の Divider・カラースキームは変更しない

---

# 4. SliverList 構造変更仕様（REQ-MIB-002）

## 現在の構造

InsertMode 時の SliverList インデックスマッピング：

| index | 内容 | 備考 |
|---|---|---|
| 0 | `SizedBox.shrink()` | 先頭インジケーター非表示（スペース確保のみ） |
| 1 | `_TimelineItem`（items[0]） | 先頭カード |
| 2 | `_InsertIndicator`（items[0].markLinkSeq） | 先頭カード直後 |
| 3 | `_TimelineItem`（items[1]） | 2枚目のカード |
| ... | ... | |
| 2n | `_InsertIndicator`（items[n-1].markLinkSeq） | |
| 2n+1 | `_TimelineItem`（items[n]） | |

childCount: `items.length * 2 + 1`

## 変更後の構造

| index | 内容 | 備考 |
|---|---|---|
| 0 | `_InsertIndicator`（insertAfterSeq: -1） | 先頭挿入インジケーター（変更点） |
| 1 | `_TimelineItem`（items[0]） | 先頭カード |
| 2 | `_InsertIndicator`（items[0].markLinkSeq） | 先頭カード直後 |
| 3 | `_TimelineItem`（items[1]） | 2枚目のカード |
| ... | ... | |

childCount: `items.length * 2 + 1`（変更なし）

## insertAfterSeq = -1 の扱い

- 先頭挿入インジケーター（index 0）は `insertAfterSeq: -1` を使用する
- 0件時の「追加ボタン」も同じ `-1` を使用しているが、InsertMode 中は items が 1件以上あることが前提のため競合しない
- Bloc側の `MichiInfoInsertPointSelected` の既存ハンドラは `-1` を先頭挿入として処理する仕様がすでに実装済みのため、変更不要

---

# 5. Data Flow（変更なし）

本変更は Widget 層の表示調整のみ。データフローは既存の挿入モードフローと同一。

```
ユーザーが挿入モードをON（FABタップ）
  ↓
MichiInfoInsertModeFabPressed → Bloc → isInsertMode: true
  ↓
SliverList が _InsertIndicator を index 0 から表示（変更点）
  ↓
ユーザーが先頭インジケーターをタップ
  ↓
MichiInfoInsertPointSelected(insertAfterSeq: -1) → Bloc → pendingInsertAfterSeq: -1
  ↓
BottomSheet 表示 → Mark/Link 選択
  ↓
MichiInfoInsertMarkPressed / MichiInfoInsertLinkPressed → MichiInfoAddMarkDelegate / MichiInfoAddLinkDelegate（insertAfterSeq: -1）
```

---

# 6. Widget Key 定義

テストから参照可能とするため、以下の Widget Key を付与する。

| Widget | Key名 | 用途 |
|---|---|---|
| 先頭の `_InsertIndicator`（insertAfterSeq: -1） | `Key('insert_indicator_top')` | TC-MIB-002 で先頭インジケーターの存在確認に使用 |
| カード間の `_InsertIndicator`（seq付き） | `Key('insert_indicator_<seq>')` | 各インジケーターの識別 |

---

# 7. SwiftUI版との対応

本改善はFlutter固有のUI改善であり、SwiftUI版に直接対応するReducerは存在しない。
michi_info Feature（MichiInfoReducer 対応）のUI変更として位置付ける。

---

# 8. Test Scenarios

## 前提条件

- iOS シミュレーターが起動済みであること
- テスト対象イベントに MichiInfo（マーク/リンク）が 2件以上存在すること
- InsertMode が OFF の状態から開始すること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MIB-001 | InsertMode OFF 時にインジケーターが表示されないこと | High |
| TC-MIB-002 | InsertMode ON 時に先頭カードの前にインジケーターが表示されること | High |
| TC-MIB-003 | InsertMode ON 時にカード間にインジケーターが表示されること | High |
| TC-MIB-004 | 先頭インジケーターをタップすると先頭挿入フローが起動すること | High |
| TC-MIB-005 | カード間インジケーターをタップすると挿入フローが起動すること | Medium |

---

## シナリオ詳細

### TC-MIB-001: InsertMode OFF 時にインジケーターが表示されないこと

**操作手順:**
1. MichiInfo 画面を表示する（InsertMode は OFF）
2. タイムラインを確認する

**期待結果:**
- `Key('insert_indicator_top')` を持つウィジェットが画面上に存在しない
- カード間にインジケーター行が表示されていない

---

### TC-MIB-002: InsertMode ON 時に先頭カードの前にインジケーターが表示されること

**操作手順:**
1. MichiInfo 画面を表示する
2. 挿入モード FAB をタップして InsertMode を ON にする
3. タイムライン先頭を確認する

**期待結果:**
- `Key('insert_indicator_top')` を持つウィジェットが先頭カードの上に表示されている
- インジケーターが上下のカード（または画面上端）に少し被るサイズで表示されている（目視確認）

---

### TC-MIB-003: InsertMode ON 時にカード間にインジケーターが表示されること

**操作手順:**
1. MichiInfo 画面を表示する（マーク/リンク 2件以上）
2. 挿入モード FAB をタップして InsertMode を ON にする
3. タイムラインのカード間を確認する

**期待結果:**
- 各カードの間に `_InsertIndicator` が表示されている
- 末尾カードの後にも `_InsertIndicator` が表示されている

---

### TC-MIB-004: 先頭インジケーターをタップすると先頭挿入フローが起動すること

**操作手順:**
1. MichiInfo 画面を表示する
2. 挿入モード FAB をタップして InsertMode を ON にする
3. `Key('insert_indicator_top')` のインジケーターをタップする
4. 表示されたボトムシートで「マーク」を選択する

**期待結果:**
- ボトムシート（Mark/Link 選択）が表示される
- マーク追加画面（MarkDetail）へ遷移する
- 保存後、新しいマークがタイムラインの先頭に追加されている

---

### TC-MIB-005: カード間インジケーターをタップすると挿入フローが起動すること

**操作手順:**
1. MichiInfo 画面を表示する（マーク/リンク 2件以上）
2. 挿入モード FAB をタップして InsertMode を ON にする
3. 先頭カードと2番目のカードの間のインジケーターをタップする
4. 表示されたボトムシートで「マーク」を選択する

**期待結果:**
- ボトムシート（Mark/Link 選択）が表示される
- マーク追加画面（MarkDetail）へ遷移する
- 保存後、新しいマークが先頭カードと2番目のカードの間に追加されている

---

# End of Feature Spec
