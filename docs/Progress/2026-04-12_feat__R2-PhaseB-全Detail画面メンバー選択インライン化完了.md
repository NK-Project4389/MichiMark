# R-2 Phase B: Detail画面 メンバー選択インライン化 完了

**日付**: 2026-04-12
**担当**: flutter-dev / tester / reviewer

---

## 完了した作業

### T-202a: 実装（flutter-dev）

MarkDetail・LinkDetail・PaymentDetail のメンバー選択UIをインラインチップ式に置き換え。

**変更ファイル（12件）**

- `mark_detail_event.dart` — `EditMembersPressed`/`MembersSelected`削除、`MemberChipToggled`追加
- `mark_detail_state.dart` — `OpenMembersSelectionDelegate`削除
- `mark_detail_bloc.dart` — `_onMemberChipToggled`ハンドラ追加
- `mark_detail_page.dart` — `_MemberChipSection`追加、`_SelectionRow`（メンバー）削除
- 同様に `link_detail_*` 4ファイル
- `payment_detail_event.dart` — 遷移系4イベント削除、`PayMemberChipToggled`/`SplitMemberChipToggled`追加
- `payment_detail_state.dart` — 遷移系Delegate2件削除
- `payment_detail_bloc.dart` — single選択・支払者常にON固定ロジック
- `payment_detail_page.dart` — `_PayMemberChipSection`/`_SplitMemberChipSection`追加

`dart analyze` エラーゼロ確認済み。

### T-202b: テストコード実装（tester）

`flutter/integration_test/event_detail_member_chip_inline_test.dart` 作成。TC-PBM-001〜014b（22ケース）実装。

### T-203: レビュー（reviewer）

承認・設計憲章違反なし。全チェック項目OK。

### T-204: テスト実行（tester）

**22PASS / 0FAIL / 0SKIP**

途中MarkDetail/LinkDetail 12件のWidgetKeyミスマッチ（`michi_info_mark_card_ml-001` → `michi_info_card_slidable_ml-001`）をflutter-devが修正して全件PASS達成。

---

## 未完了

なし。R-2 Phase B 全タスク完了。

---

## 次回セッションで最初にやること

以下のうちどれかをユーザーと相談して着手する：

1. **R-2 Phase B 確認後 TestFlight アップロード**（任意）
2. **UI-1: イベント削除UI変更** — T-211 Spec作成（要件書 `REQ-event_delete_ui_redesign.md` 済み）
3. **UI-2: BasicInfo タップ編集** — T-221 要件書作成（デザイン `basic_info_tap_to_edit_design.html` 済み）
4. **UI-3: MichiInfo削除UI変更** — T-231 要件書作成（デザイン `michi_info_delete_icon_design.html` 済み）
5. **UI-4: PaymentInfo削除UI変更** — T-241 Spec作成（要件書 `REQ-payment_info_delete_icon.md` 済み）
6. **UI-5: Detail画面UI改善** — T-251 Spec作成（要件書 `REQ-detail_screen_ui_improvement.md` 済み）
