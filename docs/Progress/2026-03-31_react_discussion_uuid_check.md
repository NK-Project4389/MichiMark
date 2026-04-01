# 2026-03-31 React換装検討・UUID実装確認

## 完了した作業

### orchestrator — React換装検討
- React換装の要否を議論・整理
- 結論：**Flutter継続・換装不要**
  - Webは管理画面のみ（将来）・本筋はモバイルアプリ
  - 永続化・ロジック共有はバックエンドAPIで対応（将来フェーズ）
  - まずはアプリリリースでファーストキャッシュ獲得を最優先

### reviewer — UUID実装状況確認
- settings系・payment_detail は `Uuid().v4()` 実装済み ✅
- 新規イベント・Mark・Link の UUID実装は**未完了** ❌

---

## 未完了（次回やること）

### flutter-dev 実装タスク（Spec完成済み・実装可能）

1. `event_list_page.dart` — `context.go('/event/${Uuid().v4()}')`
2. `event_detail_bloc.dart` — `_onStarted`: NotFoundError → 空ドメイン作成・保存
3. `michi_info_view.dart` — `AddMarkDelegate` / `AddLinkDelegate` → UUID生成して遷移
4. `router.dart` — `/event/mark/new` `/event/link/new` 削除・`:markId` / `:linkId` に統合
5. `mark_detail_bloc.dart` — markLinkId 不在 → 空Draft新規モード
6. `link_detail_bloc.dart` — 同上（Link版）

### その後のタスク（Phase 1 残作業）

7. InMemory seed data 投入
8. drift Repository 実装
9. get_it DI セットアップ
