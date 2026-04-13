# Feature Spec: メンバー選択 全選択 / 全解除ボタン追加

- **Spec ID**: FS-member_select_all_clear
- **要件ID**: REQ-member_select_all_clear
- **作成日**: 2026-04-13
- **担当**: architect
- **ステータス**: Draft
- **対象UI-ID**: UI-11

---

## 1. Feature Overview

### Feature Name

MemberSelectAllClear（横断的UI改善 — MarkDetail / LinkDetail / PaymentDetail）

### Purpose

MarkDetail・LinkDetail・PaymentDetail の各メンバー選択セクションに「全選択」「全解除」ボタンを追加し、メンバー数が多いときの一括操作を可能にする。

### Scope

含むもの

- MarkDetail メンバー選択セクションへの全選択・全解除ボタン追加
- LinkDetail メンバー選択セクションへの全選択・全解除ボタン追加
- PaymentDetail 割り勘メンバー選択セクションへの全選択・全解除ボタン追加
- PaymentDetail 全解除における支払者（payer）の除外ロジック

含まないもの

- メンバー管理設定画面（member_setting）
- イベント作成時のメンバー選択
- MarkDetail / LinkDetail のガソリン支払者チップへの全選択・全解除

---

## 2. 変更対象 Feature 一覧

| Feature | 変更箇所 |
|---|---|
| mark_detail | BlocEvent 2件追加 / View の `_MemberChipSection` にボタン追加 |
| link_detail | BlocEvent 2件追加 / View の `_MemberChipSection` にボタン追加 |
| payment_detail | BlocEvent 2件追加 / View の `_SplitMemberChipSection` にボタン追加 |

---

## 3. 新規 BlocEvent 定義

### 3.1 MarkDetail

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `MarkDetailMembersAllSelected` | 「全選択」ボタンタップ時 | `availableMembers` の全メンバーを `selectedMembers` にセットする |
| `MarkDetailMembersAllCleared` | 「全解除」ボタンタップ時 | `selectedMembers` を空リストにする |

### 3.2 LinkDetail

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `LinkDetailMembersAllSelected` | 「全選択」ボタンタップ時 | `availableMembers` の全メンバーを `selectedMembers` にセットする |
| `LinkDetailMembersAllCleared` | 「全解除」ボタンタップ時 | `selectedMembers` を空リストにする |

### 3.3 PaymentDetail

| イベント名 | 発火タイミング | 説明 |
|---|---|---|
| `PaymentDetailSplitMembersAllSelected` | 「全選択」ボタンタップ時 | `availableMembers` の全メンバーを `splitMembers` にセットする（支払者も含む） |
| `PaymentDetailSplitMembersAllCleared` | 「全解除」ボタンタップ時 | `splitMembers` から支払者（`paymentMember`）以外を全て除去する。支払者は常に選択状態を維持する |

---

## 4. Bloc ハンドラ実装方針

### 4.1 MarkDetailBloc

**`_onMembersAllSelected`**

- `state` が `MarkDetailLoaded` であることを確認する
- `current.availableMembers` を `draft.selectedMembers` にそのままセットする
- `draft.copyWith(selectedMembers: current.availableMembers)` で新しい Draft を生成し emit する

**`_onMembersAllCleared`**

- `state` が `MarkDetailLoaded` であることを確認する
- `draft.copyWith(selectedMembers: [])` で新しい Draft を生成し emit する
- 既存の保存時バリデーション（メンバー未選択エラー）はそのまま維持する

### 4.2 LinkDetailBloc

MarkDetailBloc と同じ方針。`availableMembers` フィールドは `LinkDetailLoaded.availableMembers` を参照する。

### 4.3 PaymentDetailBloc

**`_onSplitMembersAllSelected`**

- `state` が `PaymentDetailLoaded` であることを確認する
- `current.availableMembers` の全メンバーを `splitMembers` にセットする
- 支払者（`draft.paymentMember`）が未選択の場合でも、全メンバーをそのままセットする（支払者除外の制約は「全解除」のみ）
- `draft.copyWith(splitMembers: current.availableMembers)` で emit する

**`_onSplitMembersAllCleared`**

- `state` が `PaymentDetailLoaded` であることを確認する
- 現在の `draft.paymentMember` の ID を取得する
- `splitMembers` から `paymentMember?.id` に一致するメンバーのみを残した新しいリストを生成する
  - 支払者が `null` の場合は空リストになる
- `draft.copyWith(splitMembers: <payerのみのリスト>)` で emit する
- 既存の `_onSplitMemberChipToggled` で `paymentMember?.id == event.member.id` の場合に return する処理と同じ思想を踏襲する

---

## 5. Draft / State フィールド変更

**Draft / State への変更は不要。** 既存フィールドのみで全選択・全解除は実現できる。

| Feature | 参照フィールド | 型 |
|---|---|---|
| MarkDetail | `MarkDetailLoaded.availableMembers` | `List<MemberDomain>` |
| MarkDetail | `MarkDetailDraft.selectedMembers` | `List<MemberDomain>` |
| LinkDetail | `LinkDetailLoaded.availableMembers` | `List<MemberDomain>` |
| LinkDetail | `LinkDetailDraft.selectedMembers` | `List<MemberDomain>` |
| PaymentDetail | `PaymentDetailLoaded.availableMembers` | `List<MemberDomain>` |
| PaymentDetail | `PaymentDetailDraft.paymentMember` | `MemberDomain?`（支払者・除外判定に使用） |
| PaymentDetail | `PaymentDetailDraft.splitMembers` | `List<MemberDomain>` |

---

## 6. View 層 ボタン配置・スタイル方針

### 共通方針

- 「全選択」「全解除」ボタンをメンバーチップ一覧の上部ヘッダー行に横並びで配置する
- ヘッダー行の左側に既存の「メンバー」「割り勘」ラベルを配置し、右側に `Row` で両ボタンを配置する
- ボタンスタイルは `TextButton` または小サイズの `OutlinedButton` とし、既存チップUIの視覚的重さに合わせる（サイズは小さめ）
- ボタンラベルは「全選択」「全解除」の文字列とする

### MarkDetail / LinkDetail の `_MemberChipSection`

- 現在の `Text('メンバー', style: labelStyle)` 行を `Row` に変更する
- `Row` の左端にラベルテキスト、右端に「全選択」「全解除」の 2 ボタンを配置する

### PaymentDetail の `_SplitMemberChipSection`

- 現在の `Text('割り勘', style: labelStyle)` 行を `Row` に変更する
- `Row` の左端にラベルテキスト、右端に「全選択」「全解除」の 2 ボタンを配置する

---

## 7. Data Flow

- ユーザーが「全選択」ボタンをタップする
- View が対応する `AllSelected` イベントを Bloc に送出する
- Bloc が `availableMembers`（または全メンバーリスト）を `selectedMembers` / `splitMembers` にセットした新しい Draft で emit する
- State が更新され、各チップが選択状態に再描画される

- ユーザーが「全解除」ボタンをタップする
- View が対応する `AllCleared` イベントを Bloc に送出する
- Bloc が `selectedMembers` / `splitMembers` を空（または支払者のみ残したリスト）にした新しい Draft で emit する
- State が更新され、各チップが非選択状態に再描画される（PaymentDetail の支払者チップは選択状態を維持）

---

## 8. Navigation

本 Feature に新規の Navigation 変更はない。

---

## 9. テストシナリオ

### 前提条件

- テスト用イベントが存在し、複数メンバー（2名以上）が登録されていること
- 各詳細画面（MarkDetail / LinkDetail / PaymentDetail）に遷移できること
- PaymentDetail のテストでは支払者が選択済みの状態でシナリオを開始すること

### テストシナリオ一覧

| ID | シナリオ名 | 対象画面 | 優先度 |
|---|---|---|---|
| TC-MSA-001 | MarkDetail 全選択 | MarkDetail | High |
| TC-MSA-002 | MarkDetail 全解除 | MarkDetail | High |
| TC-MSA-003 | LinkDetail 全選択 | LinkDetail | High |
| TC-MSA-004 | LinkDetail 全解除 | LinkDetail | High |
| TC-MSA-005 | PaymentDetail 割り勘メンバー全選択 | PaymentDetail | High |
| TC-MSA-006 | PaymentDetail 割り勘メンバー全解除（支払者除外） | PaymentDetail | High |

---

### TC-MSA-001: MarkDetail 全選択

**前提:**
- MarkDetail 画面が表示されていること
- メンバーが 2名以上存在し、少なくとも 1名が非選択状態であること

**操作手順:**
1. MarkDetail 画面のメンバー選択セクションで「全選択」ボタンをタップする

**期待結果:**
- `availableMembers` の全メンバーのチップが選択状態（`selected: true`）になる

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('markDetail_button_selectAllMembers')` | button | 全選択ボタン |
| `Key('markDetail_button_clearAllMembers')` | button | 全解除ボタン |
| `Key('markDetail_chip_member_${member.id}')` | chip | 個別メンバーチップ（既存） |

---

### TC-MSA-002: MarkDetail 全解除

**前提:**
- MarkDetail 画面が表示されていること
- 全員または複数名が選択状態であること

**操作手順:**
1. MarkDetail 画面のメンバー選択セクションで「全解除」ボタンをタップする

**期待結果:**
- 全メンバーのチップが非選択状態（`selected: false`）になる

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('markDetail_button_selectAllMembers')` | button | 全選択ボタン |
| `Key('markDetail_button_clearAllMembers')` | button | 全解除ボタン |
| `Key('markDetail_chip_member_${member.id}')` | chip | 個別メンバーチップ（既存） |

---

### TC-MSA-003: LinkDetail 全選択

**前提:**
- LinkDetail 画面が表示されていること
- メンバーが 2名以上存在し、少なくとも 1名が非選択状態であること

**操作手順:**
1. LinkDetail 画面のメンバー選択セクションで「全選択」ボタンをタップする

**期待結果:**
- `availableMembers` の全メンバーのチップが選択状態になる

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('linkDetail_button_selectAllMembers')` | button | 全選択ボタン |
| `Key('linkDetail_button_clearAllMembers')` | button | 全解除ボタン |
| `Key('linkDetail_chip_member_${member.id}')` | chip | 個別メンバーチップ（既存） |

---

### TC-MSA-004: LinkDetail 全解除

**前提:**
- LinkDetail 画面が表示されていること
- 全員または複数名が選択状態であること

**操作手順:**
1. LinkDetail 画面のメンバー選択セクションで「全解除」ボタンをタップする

**期待結果:**
- 全メンバーのチップが非選択状態になる

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('linkDetail_button_selectAllMembers')` | button | 全選択ボタン |
| `Key('linkDetail_button_clearAllMembers')` | button | 全解除ボタン |
| `Key('linkDetail_chip_member_${member.id}')` | chip | 個別メンバーチップ（既存） |

---

### TC-MSA-005: PaymentDetail 割り勘メンバー全選択

**前提:**
- PaymentDetail 画面が表示されていること
- メンバーが 2名以上存在すること
- 支払者（paymentMember）が選択済みであること
- 少なくとも 1名の割り勘メンバーが非選択状態であること

**操作手順:**
1. PaymentDetail 画面の割り勘セクションで「全選択」ボタンをタップする

**期待結果:**
- `availableMembers` の全メンバーのチップが選択状態になる（支払者を含む全員）

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('paymentDetail_button_selectAllSplitMembers')` | button | 全選択ボタン |
| `Key('paymentDetail_button_clearAllSplitMembers')` | button | 全解除ボタン |
| `Key('paymentDetail_chip_splitMember_${member.id}')` | chip | 個別割り勘メンバーチップ（既存） |

---

### TC-MSA-006: PaymentDetail 割り勘メンバー全解除（支払者除外）

**前提:**
- PaymentDetail 画面が表示されていること
- メンバーが 2名以上存在すること
- 支払者（paymentMember）が選択済みであること（支払者 A、それ以外の割り勘メンバー B が選択済みの状態）

**操作手順:**
1. PaymentDetail 画面の割り勘セクションで「全解除」ボタンをタップする

**期待結果:**
- 支払者（A）のチップは選択状態を維持する
- 支払者以外のメンバー（B）のチップは非選択状態になる

**実装ノート（ウィジェットキー一覧）:**

| キー | 種別 | 説明 |
|---|---|---|
| `Key('paymentDetail_button_selectAllSplitMembers')` | button | 全選択ボタン |
| `Key('paymentDetail_button_clearAllSplitMembers')` | button | 全解除ボタン |
| `Key('paymentDetail_chip_splitMember_${member.id}')` | chip | 個別割り勘メンバーチップ（既存） |
| `Key('paymentDetail_chip_payMember_${member.id}')` | chip | 支払者チップ（既存・確認用） |

---

## 10. 変更ファイル一覧（参考）

| ファイルパス | 変更種別 |
|---|---|
| `flutter/lib/features/mark_detail/bloc/mark_detail_event.dart` | イベント 2件追加 |
| `flutter/lib/features/mark_detail/bloc/mark_detail_bloc.dart` | ハンドラ 2件追加 |
| `flutter/lib/features/mark_detail/view/mark_detail_page.dart` | `_MemberChipSection` にボタン追加 |
| `flutter/lib/features/link_detail/bloc/link_detail_event.dart` | イベント 2件追加 |
| `flutter/lib/features/link_detail/bloc/link_detail_bloc.dart` | ハンドラ 2件追加 |
| `flutter/lib/features/link_detail/view/link_detail_page.dart` | `_MemberChipSection` にボタン追加 |
| `flutter/lib/features/payment_detail/bloc/payment_detail_event.dart` | イベント 2件追加 |
| `flutter/lib/features/payment_detail/bloc/payment_detail_bloc.dart` | ハンドラ 2件追加 |
| `flutter/lib/features/payment_detail/view/payment_detail_page.dart` | `_SplitMemberChipSection` にボタン追加 |

---

# End of Feature Spec
