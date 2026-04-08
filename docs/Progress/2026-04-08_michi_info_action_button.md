# 進捗: MichiInfo アクションボタン UI（Phase 10 完了）

日付: 2026-04-08

---

## 完了した作業

### T-094〜T-098: MichiInfo アクションボタン UI（全工程完了）

#### T-094 要件書作成
- 要件書: `docs/Requirements/REQ-michi_info_action_button.md`
- 採用案: B案（Mark カード右上に Violet ⚡ ボタン + ボトムシート + 状態バッジ）
- デザイン提案: `docs/Design/draft/2026-04-08_action_time_button_proposal.html`

#### T-095 Spec 作成
- `docs/Spec/Features/MichiInfo/ActionTimeButton_Spec.md`
- ActionTimeBloc はボトムシート内で独立生成（MichiInfoBloc ツリーとは分離）
- `MichiInfoLoaded` に `markActionStateLabels: Map<String, String>` 追加

#### T-096 実装
変更ファイル:
- `michi_info_event.dart`: `MichiInfoActionButtonPressed` / `MichiInfoActionStateLabelUpdated` 追加
- `michi_info_state.dart`: `MichiInfoOpenActionTimeDelegate` / `markActionStateLabels` 追加
- `michi_info_bloc.dart`: `_onActionButtonPressed` / `_onActionStateLabelUpdated` / `_onStarted` で topicConfig 設定
- `michi_info_view.dart`: ⚡ ボタン・状態バッジ・ボトムシート表示実装
- `action_time_view.dart`: アクションボタンにキー追加
- `action_time_bloc.dart`: 記録後に `ActionTimeNavigateBackDelegate` を emit

#### T-097 レビュー
- 全項目 PASS。アーキテクチャ違反なし

#### T-098 テスト
- **8 PASS / 1 SKIP / 0 FAIL**
- TC-MAB-007（スワイプ閉じ）のみ SKIP（DraggableScrollableSheet + showModalBottomSheet の Flutter テスト制約）

### バグ修正・改善（テスト過程で発覚・修正）

1. **Drift DB にアクションマスタシードデータ投入**
   - `database.dart` の `onCreate` で `_insertSeedActions()` を呼ぶよう修正
   - 7件のアクション（出発・到着・観光・食事・休憩・買い物・写真撮影）を初回起動時に自動投入
   - `action-seed-depart` / `action-seed-arrive` は固定ID（`TopicConfig.markActions` で参照される）

2. **MichiInfoBloc._onStarted で topicConfig 設定漏れを修正**
   - `TopicConfig.fromTopicType(domain.topic?.topicType)` で起動時から正しい topicConfig を設定
   - これにより EventDetail を経由しなくても MichiInfo 単体で正しいアクション候補が表示される

3. **タスクボード一括更新（実機確認済みタスク）**
   - T-064〜067, T-070〜075, T-080〜081, T-020, T-022, T-023 を DONE に更新

4. **アプリ表示名変更**
   - `Michi Mark` → `MichiMark`（Info.plist の CFBundleDisplayName）

5. **Phase 11 追加**
   - T-099〜T-103: MichiInfo タイムライン カード挿入機能（FAB 型）
   - T-099 要件書作成完了（REQ-michi_info_card_insert.md）

---

## 未完了・次回やること

1. **T-100**: カード挿入機能 Spec 作成（architect）
2. **T-101〜103**: カード挿入機能 実装・レビュー・テスト

---

## 備考

- Phase 10 完全完了
- 残タスクは Phase 11（カード挿入機能）のみ
- アクション設定は設定画面から非表示（固定マスタ運用）
