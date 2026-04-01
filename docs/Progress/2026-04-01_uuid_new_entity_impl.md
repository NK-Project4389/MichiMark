# 2026-04-01 UUID化・新規エンティティ作成フロー 実装

## 完了した作業

### タスク1: `event_list_page.dart`
- `OpenAddEventDelegate` 発火時に `Uuid().v4()` でUUID生成し `/event/{uuid}` へ遷移するよう修正
- `import 'package:uuid/uuid.dart'` 追加

### タスク2: `event_detail_bloc.dart`
- `_onStarted` で Repository.fetch が `NotFoundError` をthrowした場合に新規作成モードとして処理
- 空の `EventDomain(id: eventId, eventName: '', createdAt: now, updatedAt: now)` を生成・保存してから画面ロード
- `repository_error.dart` のimport追加

### タスク3: `michi_info_view.dart`
- `MichiInfoAddMarkDelegate` 発火時: `Uuid().v4()` でmarkId生成し `/event/mark/{markId}` へ遷移
- `MichiInfoAddLinkDelegate` 発火時: `Uuid().v4()` でlinkId生成し `/event/link/{linkId}` へ遷移
- `import 'package:uuid/uuid.dart'` 追加

### タスク4: `router.dart`
- `/event/mark/new` ルートを削除
- `/event/link/new` ルートを削除
- 新規・編集ともに `/event/mark/:markId` と `/event/link/:linkId` に統合

### タスク5: `mark_detail_bloc.dart`
- `_onStarted` ハンドラを修正
- 常にRepositoryからEventDomainをfetchし、markLinkId が markLinks に存在しない場合は新規作成モード（空Draft）として処理
- 旧来の `markLinkId == null` 分岐を廃止し、UUID統合フローに対応

### タスク6: `link_detail_bloc.dart`
- タスク5と同様（Link版）

## コミット

- `3c6731d` feat: UUID化・新規エンティティ作成フロー実装（方針A）

## 未完了

なし（全タスク完了）

## 次回セッションで最初にやること

- drift を使った EventRepository の永続化実装（現在はInMemoryスタブ）
- もしくは新機能Specがあれば architect → flutter-dev フローで対応
