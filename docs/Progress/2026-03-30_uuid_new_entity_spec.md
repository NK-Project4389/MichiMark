# 2026-03-30 UUID化・新規エンティティ作成フロー Spec設計

## 完了した作業

### 調査（architect）

- 全 Domain クラスが `String id` 済みであることを確認 ✅
- `uuid: ^4.5.1` が pubspec に追加済みであることを確認 ✅
- Settings / PaymentDetail BLoC が `Uuid().v4()` を使用済みであることを確認 ✅
- 新規イベント・Mark・Link の作成フローが未対応（`/event/new`, `/event/mark/new` が壊れている）ことを確認 ✅

### Spec 更新（architect）

方針A（Router で UUID を生成して渡す）を採用。

- `EventDetail_Spec.md` — 新規イベント作成フロー追加（NotFoundError → 空ドメイン作成・保存）
- `MarkDetailFeature_Spec.md` — New Mark Creation Flow 追加・ルート統合・Started 署名更新
- `LinkDetailFeature_Spec.md` — New Link Creation Flow 追加・ルート統合・Started 署名更新
- `MichiInfoFeature_Spec.md` — AddMark/AddLink Delegate に UUID 生成タイミング注記追加

---

## 設計まとめ

### UUID 生成タイミング（方針A）

| ケース | UUID生成場所 | 遷移先 |
|---|---|---|
| 新規イベント | EventList BlocListener | `/event/{uuid}` |
| 新規Mark | MichiInfo BlocListener | `/event/mark/{uuid}` |
| 新規Link | MichiInfo BlocListener | `/event/link/{uuid}` |

BLoC は UUID を生成しない。View（BlocListener）で生成してルートに埋め込む。

### ルート統合

- `/event/mark/new` → **廃止**（`/event/mark/:markId` に統合）
- `/event/link/new` → **廃止**（`/event/link/:linkId` に統合）
- BLoC は markLinkId が EventDomain.markLinks に存在しない場合に新規モードとして判断

---

## 次回やること

### flutter-dev 実装タスク（Spec 完成済み・実装可能）

1. `event_list_page.dart` — `OpenAddEventDelegate` → `context.go('/event/${Uuid().v4()}')`
2. `event_detail_bloc.dart` — `_onStarted`: NotFoundError → 空ドメイン作成・保存
3. `michi_info_view.dart` — `AddMarkDelegate` / `AddLinkDelegate` → `Uuid().v4()` 生成して遷移
4. `router.dart` — `/event/mark/new` と `/event/link/new` 削除・`:markId` / `:linkId` に統合
5. `mark_detail_bloc.dart` — `_onStarted`: markLinkId が markLinks に存在しない → 空 Draft で新規モード
6. `link_detail_bloc.dart` — 同上（Link版）

### その後のタスク（Phase 1 残作業）

7. InMemory seed data 投入
8. drift Repository 実装
9. get_it DI セットアップ
