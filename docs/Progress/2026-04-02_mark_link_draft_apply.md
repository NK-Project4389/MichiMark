# 2026-04-02 MarkDetail/LinkDetail Draft反映フロー実装

## 完了した作業

### タスク1: SaveTapped / SaveDraftDelegate 追加（MarkDetail / LinkDetail）
- `mark_detail_event.dart` / `link_detail_event.dart` — `SaveTapped` Event 追加
- `mark_detail_state.dart` / `link_detail_state.dart` — `SaveDraftDelegate(draft)` 追加
- `mark_detail_bloc.dart` / `link_detail_bloc.dart` — `_onSaveTapped` ハンドラ追加
- `mark_detail_page.dart` / `link_detail_page.dart` — AppBar に「反映」ボタン追加・`SaveDraftDelegate` で `context.pop(draft)`

### タスク2: MichiInfoView 接続（context.go → context.push）
- `michi_info_view.dart` — StatelessWidget → StatefulWidget に変換
- `context.go` → `context.push<MarkDetailDraft / LinkDetailDraft>` に変更
- 返ってきた draft を `MichiInfoMarkDraftApplied` / `MichiInfoLinkDraftApplied` Event として MichiInfoBloc に渡す

### タスク3: MichiInfoBloc への Draft 受け取りハンドラ追加
- `michi_info_event.dart` — `MichiInfoMarkDraftApplied`・`MichiInfoLinkDraftApplied` Event 追加
- `michi_info_bloc.dart` — `_onMarkDraftApplied` / `_onLinkDraftApplied` ハンドラ追加
  - Draft を受け取り `_applyMarkDraft` / `_applyLinkDraft` で projection を再構築
  - 既存アイテムは上書き、新規アイテムは末尾に追加（markLinkSeq でソート）

### タスク4: MarkLinkDraftAdapter 新規作成
- `adapter/mark_link_draft_adapter.dart` — `MarkDetailDraft` / `LinkDetailDraft` → `MarkLinkItemProjection` 変換

### タスク5: Spec 更新
- `MarkDetailFeature_Spec.md` / `LinkDetailFeature_Spec.md` に以下を追記
  - `SaveTapped → SaveDraftDelegate → context.pop(draft)` の実装フロー
  - `CancelTapped = DismissPressed` の対応関係
  - NotFound（新規作成）フローの実装詳細

## コミット

- `dcaa4dc` feat: MarkDetail/LinkDetail に SaveTapped・SaveDraftDelegate・反映ボタン追加
- `c48ce16` feat: MichiInfoView draft受け取り接続・MarkLinkDraftAdapter追加・Spec更新

## 未完了

なし（全タスク完了）

## 次回セッションで最初にやること

**InMemory seed data 投入**（動作確認用のダミーデータ）

### Phase 1 残タスク

1. InMemory seed data 投入
2. drift Repository 実装
3. get_it DI セットアップ
