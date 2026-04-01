# 2026-04-01 UUID化・新規エンティティ作成フロー 実装

## 完了した作業

### flutter-dev — UUID実装（方針A）

- `event_list_page.dart` — `OpenAddEventDelegate` で `Uuid().v4()` 生成・`/event/{uuid}` 遷移
- `event_detail_bloc.dart` — `_onStarted`: NotFoundError → 空 EventDomain 作成・保存（新規作成モード）
- `michi_info_view.dart` — AddMark/LinkDelegate で `Uuid().v4()` 生成・遷移
- `router.dart` — `/event/mark/new` `/event/link/new` 廃止・`:markId` / `:linkId` に統合
- `mark_detail_bloc.dart` — markLinkId が markLinks に存在しない場合に空Draft新規モード
- `link_detail_bloc.dart` — 同上（Link版）

### reviewer → flutter-dev — レビュー指摘修正

- `mark_detail_event.dart` / `link_detail_event.dart` — `markLinkId` を `String?` → `String`（non-nullable）に変更
- `mark_detail_bloc.dart` / `link_detail_bloc.dart` — `if (markLinkId == null)` 死にコード削除
- `event_detail_bloc.dart` — 全ハンドラの `state as X` 二度判定を `if (state case final X current)` パターンに統一（`_onSaveRequested` のみ型明示代入で対応）

---

## 未完了（次回やること）

### 次回最初にやること: InMemory seed data 投入

### Phase 1 残タスク

1. InMemory seed data 投入
2. drift Repository 実装
3. get_it DI セットアップ
4. MarkDetail/LinkDetail の SaveTapped・CancelTapped Event と SaveDraftDelegate 追加（保存ロジック実装）
