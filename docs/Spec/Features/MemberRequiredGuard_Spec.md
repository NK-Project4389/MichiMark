# Feature Spec: メンバー未選択時の入力ガード

- **要件番号**: REQ-member_required_guard
- **Spec番号**: FS-member_required_guard
- **バージョン**: 1.0
- **作成日**: 2026-04-11

---

## 概要

メンバーが未選択（またはメンバー情報が空）の場合、メンバーに関連する選択行を非活性化する。
各画面の `_SelectionRow` に `enabled` パラメータを追加し、条件に応じてタップ無効・グレー表示にする。

---

## 対象画面・条件・対象行

| 画面 | 対象行 | 非活性条件 |
|---|---|---|
| BasicInfo | ガソリン支払者 | `draft.selectedMembers.isEmpty` |
| MarkDetail | 参加メンバー | `state.availableMembers.isEmpty` |
| LinkDetail | 参加メンバー | `state.availableMembers.isEmpty` |
| PaymentDetail | 支払い者 | `state.availableMembers.isEmpty` |
| PaymentDetail | 割り勘メンバー | `state.availableMembers.isEmpty` |

> **注**: FuelDetailWidget に支払者選択行は存在しないため REQ-MRG-005 は対象外。

---

## 実装仕様

### `_SelectionRow` 変更

各画面の `_SelectionRow` に `enabled` パラメータを追加する（デフォルト `true`）。

```dart
class _SelectionRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEditPressed;
  final bool enabled; // 追加（デフォルト true）
  ...
}
```

#### `enabled: false` 時の挙動

| 要素 | 変更内容 |
|---|---|
| `InkWell.onTap` | `null`（タップ無効） |
| value テキストの色 | `colorScheme.onSurfaceVariant` |
| `chevron_right` アイコンの色 | `colorScheme.onSurfaceVariant` |

#### `enabled: true` 時（既存動作）

変更なし。

---

## 各画面での `enabled` 渡し方

### BasicInfo (`basic_info_view.dart`)

```dart
_SelectionRow(
  label: 'ガソリン支払者',
  value: draft.selectedPayMember?.memberName ?? '未選択',
  enabled: draft.selectedMembers.isNotEmpty,
  onEditPressed: () => ...,
),
```

### MarkDetail (`mark_detail_page.dart`)

```dart
_SelectionRow(
  label: '参加メンバー',
  value: ...,
  enabled: state.availableMembers.isNotEmpty,
  onEditPressed: () => ...,
),
```

### LinkDetail (`link_detail_page.dart`)

同上。`state.availableMembers.isNotEmpty` を渡す。

### PaymentDetail (`payment_detail_page.dart`)

支払い者・割り勘メンバーの両行に `enabled: state.availableMembers.isNotEmpty` を渡す。

---

## テストシナリオ

### TC-MRG-001: BasicInfo ガソリン支払者 — メンバー未選択時に非活性

**前提**: シードイベントに参加メンバー 0 人
**手順**:
1. イベント詳細 → 概要タブを開く
2. ガソリン支払者の行を確認する
3. ガソリン支払者の行をタップする

**期待結果**:
- 行がグレー表示になっている
- タップしても選択画面に遷移しない

---

### TC-MRG-002: BasicInfo ガソリン支払者 — メンバー選択済みで活性

**前提**: シードイベントに参加メンバーが 1 人以上存在する
**手順**:
1. イベント詳細 → 概要タブを開く
2. ガソリン支払者の行をタップする

**期待結果**:
- タップで選択画面に遷移する

---

### TC-MRG-003: MarkDetail 参加メンバー — メンバー未選択時に非活性

**前提**: シードイベントのメンバーが 0 人
**手順**:
1. MichiInfo → マークカードをタップしてMarkDetail を開く
2. 参加メンバーの行を確認する
3. 参加メンバーの行をタップする

**期待結果**:
- 行がグレー表示になっている
- タップしても選択画面に遷移しない

---

### TC-MRG-004: MarkDetail 参加メンバー — メンバー存在で活性

**前提**: シードイベントにメンバーが 1 人以上存在する
**手順**:
1. MarkDetail を開く
2. 参加メンバーの行をタップする

**期待結果**:
- タップで選択画面に遷移する

---

### TC-MRG-005: PaymentDetail 支払い者・割り勘メンバー — メンバー未選択時に非活性

**前提**: シードイベントのメンバーが 0 人
**手順**:
1. PaymentInfo → 支払いカードをタップして PaymentDetail を開く
2. 支払い者・割り勘メンバーの行を確認する
3. 各行をタップする

**期待結果**:
- 両行がグレー表示になっている
- タップしても選択画面に遷移しない

---

### TC-MRG-006: PaymentDetail 支払い者・割り勘メンバー — メンバー存在で活性

**前提**: シードイベントにメンバーが 1 人以上存在する
**手順**:
1. PaymentDetail を開く
2. 支払い者・割り勘メンバーの行を各々タップする

**期待結果**:
- 各行タップで選択画面に遷移する

---

## SKIPシナリオ

| TC | 理由 |
|---|---|
| TC-MRG LinkDetail | MarkDetail と同一パターンのため省略可（実装は対象） |
