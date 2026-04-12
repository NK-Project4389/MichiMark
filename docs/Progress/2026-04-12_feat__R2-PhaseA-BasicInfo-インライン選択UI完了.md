# 進捗: R-2 Phase A BasicInfo インライン選択UI 完了

**日時**: 2026-04-12
**ステータス**: 完了

---

## 完了した作業

### 要件整理・設計
- 旧REQ-member_selection_tag_style を廃止
- REQ-event_detail_inline_selection_ui を新規作成（タグ・メンバー・Trans・ガソリン支払者の統合要件）
- FS-event_detail_inline_selection_ui_phaseA.md Spec作成（TC-BII-001〜016）

### Phase A 実装（BasicInfo インライン化）
- **交通手段**: `_SelectionRow`（別画面）→ `_TransChipSection`（FilterChip、全件横並び、単一選択）
- **メンバー**: `_SelectionRow`（別画面）→ `_MemberInputSection`（チップ+OverlayEntryドロップダウン）
- **タグ**: `_TagInputSection`（3ブロック縦並び）→ チップ+インライン入力欄+ドロップダウン改善
- **ガソリン支払者**: `_SelectionRow`（別画面）→ `_GasPayMemberChipSection`（イベントメンバー全件チップ、単一選択）
- BasicInfoBloc に MemberRepository・TransRepository を追加DI
- BasicInfoLoaded に allTrans・allMembers・memberSuggestions フィールド追加
- 別画面遷移系のイベント8件・Delegate4件を削除
- 新イベント追加: TransChipToggled・MemberInput系5件・PayMemberChipToggled

### テスト
- TC-BII-001〜016 実装・実行
- **12 PASS / 0 FAIL / 4 SKIP**
- SKIP 4件（TC-BII-013〜016）: テスト用イベントTopicが showPayMember=false のため正常スキップ

---

## 未完了・次回やること

### Phase B（次のステップ）
- T-201: Phase B Spec作成 → **DONE**（FS-event_detail_inline_selection_ui_phaseB.md 作成済み）
- T-202a: MarkDetail・LinkDetail・PaymentDetail メンバー選択インライン化 実装（TODO）
- T-202b: Phase B テストコード実装（TODO）

### その他タスクボードのTODO
- T-205: B-5 MichiInfo タブ切り替え追加モード終了バグ修正
- T-210: UI-1 イベント削除UI変更 要件書作成
- T-220: UI-2 BasicInfo参照タップ編集 デザイン提案
- T-230: UI-3 MichiInfo削除UI変更 デザイン提案
- T-240: UI-4 PaymentInfo削除UI変更 要件書作成
- T-250: UI-5 Detail画面UI改善 要件書作成
