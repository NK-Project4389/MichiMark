# 進捗記録: T-201 Phase B Spec作成 / B-5 タブ切替追加モード修正

**日付**: 2026-04-12
**セッション**: T-200並行セッション

---

## 完了した作業
- chore: タスクボード棚卸し DONEタスクをアーカイブセクションに移動 (9efe56a)
- docs: UI-1〜UI-5 要件書・Spec作成完了 進捗記録 (38080cf)
- docs: 進捗記録追加 B-6・UI-6 タスクボード追加セッション (0653488)
- chore: UI-6 概要タブセクション名追加タスク追加 (T-264〜268) (2db5280)
- chore: B-6 給油計算ガソリン支払い者チップ選択バグ修正タスク追加 (T-261〜263) (0cbc811)
- docs: TestFlight 1.0.0(11) アップロード完了記録 (44cd050)
- feat: R-2 Phase B Detail画面メンバー選択インライン化完了（22PASS/0FAIL/0SKIP） (e32fe8b)
- feat(R-2 Phase B): MarkDetail・LinkDetail・PaymentDetail メンバー選択インライン化（T-202a） (b763fb0)
- docs: 進捗記録 T-201 Phase B Spec / B-5 完了セッション (6a91527)

### T-201: R-2 Phase B Spec作成
- `docs/Spec/Features/FS-event_detail_inline_selection_ui_phaseB.md` 作成
- **スコープ**: MarkDetail・LinkDetail・PaymentDetail のメンバー選択インライン化
  - MarkDetail/LinkDetail: `_MemberChipSection`（multiple選択）
  - PaymentDetail: `_PayMemberChipSection`（single）+ `_SplitMemberChipSection`（multiple・支払者はON固定）
- 削除するEvent/Delegate・追加するイベント・ハンドラ詳細・ウィジェットキー一覧
- テストシナリオ **TC-PBM-001〜014**（14件）

### T-205/T-205b/T-206/T-207: B-5 バグ修正完了
- **バグ内容**: MichiInfoで追加モード中に別タブへ切り替えると追加モードが残り続ける
- **実装**:
  - `MichiInfoTabDeactivated` イベント追加（`michi_info_event.dart`）
  - `_onTabDeactivated` ハンドラ（`michi_info_bloc.dart`）: `isInsertMode: false` / `pendingInsertAfterSeq: null` にリセット
  - `event_detail_page.dart` に `BlocListener<EventDetailBloc>` 追加: ミチタブ→他タブへの切り替えのみ検知して発火
- **テスト**: TC-B5-001〜002 **2PASS/0FAIL/0SKIP**
- **レビュー**: 承認・違反なし
- **コミット**: `78c7a71`

---

## 未完了・次回やること

### 最優先
- **T-202a/T-202b**: R-2 Phase B 実装+テストコード（IN_PROGRESS中）→ 完了後レビュー(T-203)→テスト実行(T-204)

### その後
- **UI-1〜5**: 要件書作成・デザイン提案（T-210/T-220/T-230/T-240/T-250）
- **REL-1**: AppStore無料版リリース準備（T-260）

---

## タスクボード状態（セッション終了時）

| タスク | status |
|---|---|
| T-201 Phase B Spec | DONE |
| T-202a Phase B 実装 | IN_PROGRESS（別セッション着手中） |
| T-202b Phase B テスト | IN_PROGRESS（別セッション着手中） |
| T-205/T-206/T-207 B-5 | DONE（全完了） |
