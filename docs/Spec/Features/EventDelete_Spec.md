# Feature Spec: イベント削除機能

- **Spec ID**: EventDelete_Spec
- **要件ID**: T-130（タスクボード記載仕様）
- **作成日**: 2026-04-11
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要

イベント一覧画面でイベントをスワイプすると削除ボタンが現れ、タップすると確認ダイアログなしで即座に論理削除する。
削除時は関連する子レコードも論理削除（カスケード削除）する。

---

## 2. 要件

| 項目 | 内容 |
|---|---|
| 操作 | イベントカードを左スワイプ → 赤い削除ボタンが出現 |
| 確認ダイアログ | **なし**（タップ即削除） |
| 削除方式 | 論理削除（`is_deleted = true`） |
| カスケード削除 | イベント削除時に関連子レコードも全て論理削除 |
| UIライブラリ | `flutter_slidable ^3.1.0` を使用 |

---

## 3. 変更対象

### 3.1 pubspec.yaml

`flutter/pubspec.yaml` の `dependencies` に追加：

```yaml
flutter_slidable: ^3.1.0
```

---

### 3.2 DAO: `flutter/lib/repository/impl/drift/dao/event_dao.dart`

#### 変更箇所: `deleteEvent` メソッド

既存実装はイベント本体のみを論理削除している。以下の子テーブルも同時に論理削除するよう拡張する。

**カスケード対象テーブル（全て `eventId` カラムを持つ）**:

| テーブル | 対応モデル |
|---|---|
| `mark_links` | MichiInfo の各地点・マーク |
| `payments` | 支払いレコード |
| `event_members` | イベント参加者中間テーブル（論理削除カラムなし → 物理削除） |
| `event_tags` | イベントタグ中間テーブル（論理削除カラムなし → 物理削除） |
| `action_time_logs` | アクション時間ログ |

**注意**: `event_members` / `event_tags` は `is_deleted` カラムを持たないため、物理削除（`DELETE FROM`）で対応する。

**変更後の実装イメージ**:

```dart
Future<void> deleteEvent(String id) async {
  final now = DateTime.now();
  await transaction(() async {
    // 1. 子テーブル: mark_links 論理削除
    await (update(markLinks)..where((t) => t.eventId.equals(id))).write(
      MarkLinksCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    // 2. 子テーブル: payments 論理削除
    await (update(payments)..where((t) => t.eventId.equals(id))).write(
      PaymentsCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    // 3. 子テーブル: action_time_logs 論理削除
    await (update(actionTimeLogs)..where((t) => t.eventId.equals(id))).write(
      ActionTimeLogsCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    // 4. 中間テーブル: event_members 物理削除
    await (delete(eventMembers)..where((t) => t.eventId.equals(id))).go();
    // 5. 中間テーブル: event_tags 物理削除
    await (delete(eventTags)..where((t) => t.eventId.equals(id))).go();
    // 6. events 本体 論理削除
    await (update(events)..where((t) => t.id.equals(id))).write(
      EventsCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
  });
}
```

---

### 3.3 View: `flutter/lib/features/event_list/view/event_list_page.dart`

#### 変更箇所: `_EventListItem` ウィジェット

`GestureDetector` を `Slidable` でラップし、左スワイプで削除ボタンを表示する。

**追加 import**:
```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

**Key 命名規則（設計憲章 §Widget Key 命名規則に準拠）**:
- Slidable: `Key('event_list_item_slidable_${item.id}')`
- 削除アクション: `Key('event_list_delete_action_${item.id}')`

**実装イメージ**:
```dart
return Slidable(
  key: Key('event_list_item_slidable_${item.id}'),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        key: Key('event_list_delete_action_${item.id}'),
        onPressed: (_) => context
            .read<EventListBloc>()
            .add(EventListDeleteRequested(item.id)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: '削除',
      ),
    ],
  ),
  child: GestureDetector(...), // 既存の GestureDetector をそのまま child へ
);
```

---

### 3.4 InMemory リポジトリ: `flutter/lib/repository/impl/in_memory/in_memory_event_repository.dart`

`delete(id)` の実装をカスケード削除に対応させる（テスト用）。
InMemory では `EventDomain` の子コレクション（`markLinks`, `payments` など）も含めてマップから除去、
もしくは `event.copyWith(isDeleted: true)` フラグ立てで統一する。
実装は flutter-dev に委ねる（InMemory は単体テストに使われないため優先度低）。

---

## 4. Bloc への変更

**不要**。`EventListDeleteRequested` イベント・`_onDeleteRequested` ハンドラーは実装済み。

---

## 5. テストシナリオ

Integration Test グループ `TC-ELD`（Event List Delete）として `IntegrationTest_Spec.md` に追加する。

### TC-ELD-001: イベントを左スワイプすると削除アクションが表示される

**前提**: シードデータでイベントが1件以上存在する
**手順**:
1. EventListPage を表示する
2. イベントカードを左スワイプする

**期待**: 赤い削除ボタン（ラベル「削除」）が表示される

---

### TC-ELD-002: 削除ボタンをタップするとイベントが一覧から消える

**前提**: シードデータでイベントが複数件存在する
**手順**:
1. EventListPage を表示する
2. 削除対象のイベント名を記録する
3. そのカードを左スワイプして削除ボタンをタップする

**期待**:
- 削除したイベントが一覧に表示されなくなる
- 他のイベントは引き続き表示されている

---

### TC-ELD-003: 削除後に確認ダイアログが表示されない

**前提**: シードデータでイベントが1件以上存在する
**手順**:
1. EventListPage を表示する
2. イベントカードを左スワイプして削除ボタンをタップする

**期待**: AlertDialog / ConfirmationDialog が表示されない（即座に削除される）

---

## 6. 対象外

- 削除取り消し（Undo）機能
- 物理削除
- EventDetail画面からの削除
