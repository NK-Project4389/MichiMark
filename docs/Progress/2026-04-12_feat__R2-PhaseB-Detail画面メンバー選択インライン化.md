# R-2 Phase B: Detail画面 メンバー選択インライン化 実装完了

**日付**: 2026-04-12
**タスクID**: T-202a
**担当**: flutter-dev

---

## 完了した作業

### MarkDetail
- `MarkDetailEditMembersPressed` / `MarkDetailMembersSelected` イベント削除
- `MarkDetailMemberChipToggled(MemberDomain member)` イベント追加
- `MarkDetailOpenMembersSelectionDelegate` Delegate削除
- `mark_detail_bloc.dart`: `_onMemberChipToggled` ハンドラ追加（multiple選択）
- `mark_detail_page.dart`: `_SelectionRow`（メンバー）→ `_MemberChipSection`（FilterChip × Wrap）に置き換え
- BlocListenerの `MarkDetailOpenMembersSelectionDelegate` ハンドリング削除

### LinkDetail
- `LinkDetailEditMembersPressed` / `LinkDetailMembersSelected` イベント削除
- `LinkDetailMemberChipToggled(MemberDomain member)` イベント追加
- `LinkDetailOpenMembersSelectionDelegate` Delegate削除
- `link_detail_bloc.dart`: `_onMemberChipToggled` ハンドラ追加（multiple選択）
- `link_detail_page.dart`: `_SelectionRow`（メンバー）→ `_MemberChipSection`（FilterChip × Wrap）に置き換え
- BlocListenerの `LinkDetailOpenMembersSelectionDelegate` ハンドリング削除

### PaymentDetail
- `PaymentDetailEditMemberPressed` / `PaymentDetailMemberSelected` / `PaymentDetailEditSplitMembersPressed` / `PaymentDetailSplitMembersSelected` イベント削除
- `PaymentDetailPayMemberChipToggled(MemberDomain member)` / `PaymentDetailSplitMemberChipToggled(MemberDomain member)` イベント追加
- `PaymentDetailOpenMemberSelectionDelegate` / `PaymentDetailOpenSplitMembersSelectionDelegate` Delegate削除
- `payment_detail_bloc.dart`: `_onPayMemberChipToggled`（single選択）/ `_onSplitMemberChipToggled`（multiple選択、支払者常にON固定）ハンドラ追加
- `payment_detail_page.dart`: `_SelectionRow`（支払者・割り勘）→ `_PayMemberChipSection` / `_SplitMemberChipSection` に置き換え
- BlocListenerの遷移系Delegateハンドリング削除

### Widget Key
- `Key('markDetail_chip_member_${member.id}')` — MarkDetailメンバーチップ
- `Key('linkDetail_chip_member_${member.id}')` — LinkDetailメンバーチップ
- `Key('paymentDetail_chip_payMember_${member.id}')` — PaymentDetail支払者チップ
- `Key('paymentDetail_chip_splitMember_${member.id}')` — PaymentDetail割り勘メンバーチップ

### 品質確認
- `dart analyze` エラーゼロ確認済み（既存warningはすべて今回変更外）

---

## 未完了

- T-202b: Phase B テストコード実装（tester担当・別セッション IN_PROGRESS）
- T-203: Phase B レビュー（T-202b完了後）
- T-204: Phase B テスト実行（T-203承認後）

---

## 次回セッションで最初にやること

- T-202bのテスト実装完了を確認
- T-203 Phase B レビューに着手
