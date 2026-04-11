# Feature Spec: MichiInfo カード削除機能

- **Spec ID**: MichiInfoCardDelete_Spec
- **要件ID**: REQ-michi_info_card_delete
- **作成日**: 2026-04-11
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要

MichiInfo（ミチタブ）の Mark カード・Link カードを左スワイプで削除できるようにする。
削除は論理削除（`is_deleted = true`）。Mark と Link に関係性はなく、独立して削除する。
削除後はリストを再取得して再描画し、距離表現ロジックを正しく反映する。

---

## 2. 変更対象一覧

| 層 | ファイル | 変更種別 |
|---|---|---|
| Repository（I/F） | `flutter/lib/repository/event_repository.dart` | メソッド追加 |
| Repository（Drift実装） | `flutter/lib/repository/impl/drift/drift_event_repository.dart` | メソッド追加 |
| Repository（InMemory実装） | `flutter/lib/repository/impl/in_memory/in_memory_event_repository.dart` | メソッド追加 |
| Bloc Event | `flutter/lib/features/michi_info/bloc/michi_info_event.dart` | Event クラス追加 |
| Bloc | `flutter/lib/features/michi_info/bloc/michi_info_bloc.dart` | ハンドラー追加 |
| View | `flutter/lib/features/michi_info/view/michi_info_view.dart` | Slidable ラップ追加 |

---

## 3. Repository 変更

### 3.1 EventRepository（I/F）追加メソッド

`flutter/lib/repository/event_repository.dart` に以下を追加する：

```dart
/// MarkLink（Mark または Link）を論理削除する
Future<void> deleteMarkLink(String markLinkId);
```

### 3.2 Drift 実装

`drift_event_repository.dart` の実装：

```dart
@override
Future<void> deleteMarkLink(String markLinkId) async {
  final now = DateTime.now();
  await (db.update(db.markLinks)
        ..where((t) => t.id.equals(markLinkId)))
      .write(MarkLinksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ));
}
```

### 3.3 InMemory 実装

`in_memory_event_repository.dart` の実装（テスト用）：

```dart
@override
Future<void> deleteMarkLink(String markLinkId) async {
  // InMemory はイベント全体でカードを管理しているため、
  // 全イベントを走査して該当 markLinkId のカードを isDeleted = true にする
  // 実装は flutter-dev に委ねる
}
```

---

## 4. Bloc Event 追加

`michi_info_event.dart` に以下を追加する：

```dart
/// カード（Mark または Link）の削除ボタンがタップされたとき
class MichiInfoCardDeleteRequested extends MichiInfoEvent {
  final String markLinkId;
  const MichiInfoCardDeleteRequested(this.markLinkId);

  @override
  List<Object?> get props => [markLinkId];
}
```

---

## 5. Bloc ハンドラー追加

`MichiInfoBloc` コンストラクタに登録：

```dart
on<MichiInfoCardDeleteRequested>(_onCardDeleteRequested);
```

ハンドラー実装：

```dart
Future<void> _onCardDeleteRequested(
  MichiInfoCardDeleteRequested event,
  Emitter<MichiInfoState> emit,
) async {
  if (state case MichiInfoLoaded current) {
    try {
      // 1. DB に論理削除
      await _eventRepository.deleteMarkLink(event.markLinkId);
      // 2. DB から projection を再取得（_onReloadRequested と同じパターン）
      final domain = await _eventRepository.fetch(_eventId);
      final projection = EventDetailAdapter.toProjection(domain).michiInfo;
      emit(current.copyWith(
        projection: projection,
        isInsertMode: false,
        pendingInsertAfterSeq: null,
      ));
    } on Exception {
      // サイレント失敗（既存の projection を維持）
    }
  }
}
```

**注意**: `MichiInfoReloadedDelegate` は emit しない（削除は画面遷移を伴わない）。

---

## 6. View 変更

### 6.1 対象箇所

`michi_info_view.dart` の通常モード SliverList（`!widget.isInsertMode` ブランチ内）で
各カードをレンダリングしている箇所を `Slidable` でラップする。

### 6.2 import 追加

```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

（`flutter_slidable ^3.1.0` は `pubspec.yaml` に既に追加済み）

### 6.3 Slidable ラップ

**Mark カード・Link カード共通**で以下のパターンを適用する：

```dart
Slidable(
  key: Key('michi_info_card_slidable_${item.id}'),
  enabled: !widget.isInsertMode,  // 挿入モード中はスワイプ無効
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        key: Key('michi_info_card_delete_action_${item.id}'),
        onPressed: (_) => context
            .read<MichiInfoBloc>()
            .add(MichiInfoCardDeleteRequested(item.id)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: '削除',
      ),
    ],
  ),
  child: /* 既存の Mark/Link カード Widget */,
)
```

### 6.4 挿入モード中の制御

- `enabled: !widget.isInsertMode` により挿入モード中はスワイプ操作を完全に無効化する
- 挿入モード用 SliverList（`widget.isInsertMode` ブランチ）には Slidable を追加しない

---

## 7. 距離表現の再描画

削除後に `_eventRepository.fetch()` → `EventDetailAdapter.toProjection()` → `projection` を更新することで、
`_MichiTimelineCanvas`（CustomPainter）が自動的に再描画される。

カード構成変化による距離表現の変化は `MichiInfoListProjection` と CustomPainter のロジックが吸収するため、
追加の対応は不要。

ただし、以下のパターンで表示が崩れないことを tester が確認する（テストシナリオ参照）。

---

## 8. テストシナリオ

Integration Test グループ `TC-MCD`（MichiInfo Card Delete）

### 前提条件

- シードデータで対象イベントに Mark・Link が複数件存在する
- テストは各シナリオで個別に `app.main()` を呼び出す（統合テスト標準パターン）

---

### TC-MCD-001: Mark カードをスワイプすると削除ボタンが表示される

**手順**:
1. MichiInfo 画面（ミチタブ）を表示する
2. Mark カードを左スワイプする

**期待**: `Key('michi_info_card_delete_action_${markId}')` を持つ赤い削除ボタンが表示される

---

### TC-MCD-002: Link カードをスワイプすると削除ボタンが表示される

**手順**:
1. MichiInfo 画面を表示する
2. Link カードを左スワイプする

**期待**: `Key('michi_info_card_delete_action_${linkId}')` を持つ赤い削除ボタンが表示される

---

### TC-MCD-003: Mark を削除するとカードが一覧から消える

**前提**: Mark が 2 件以上存在する

**手順**:
1. MichiInfo 画面を表示する
2. Mark カードの 1 つを左スワイプして削除ボタンをタップする

**期待**:
- 削除した Mark カードが一覧に表示されなくなる
- 他のカードは引き続き表示されている

---

### TC-MCD-004: Link を削除するとカードが一覧から消える

**前提**: Link が 1 件以上存在する

**手順**:
1. MichiInfo 画面を表示する
2. Link カードを左スワイプして削除ボタンをタップする

**期待**: 削除した Link カードが一覧に表示されなくなる

---

### TC-MCD-005: Mark→Link→Mark の Link を削除 → 残存 2 Mark が崩れずに表示される

**前提**: シードデータに Mark → Link → Mark の順で 3 件存在する

**手順**:
1. MichiInfo 画面を表示する
2. 中間の Link カードを左スワイプして削除する

**期待**:
- Link カードが消え、Mark 2 件が正しく表示される
- タイムライン縦線・スパン矢印が崩れていない（エラーなし）
- 距離表示が不正な値を表示しない

---

### TC-MCD-006: Mark→Link→Mark の先頭 Mark を削除 → Link→Mark が崩れずに表示される

**前提**: シードデータに Mark → Link → Mark の順で 3 件存在する

**手順**:
1. MichiInfo 画面を表示する
2. 先頭の Mark カードを左スワイプして削除する

**期待**:
- Link → Mark の 2 件が正しく表示される
- タイムラインが崩れていない（エラーなし）

---

### TC-MCD-007: Mark→Link→Mark の末尾 Mark を削除 → Mark→Link が崩れずに表示される

**前提**: シードデータに Mark → Link → Mark の順で 3 件存在する

**手順**:
1. MichiInfo 画面を表示する
2. 末尾の Mark カードを左スワイプして削除する

**期待**:
- Mark → Link の 2 件が正しく表示される
- タイムラインが崩れていない（エラーなし）

---

### TC-MCD-008: 最後の 1 件を削除すると空状態 UI が表示される

**前提**: シードデータにカードが 1 件のみ存在するイベントを使用する

**手順**:
1. MichiInfo 画面を表示する（カード 1 件）
2. そのカードを左スワイプして削除する

**期待**: カードが 0 件になり、空状態 UI（「まだ地点がありません」等）が表示される

---

### TC-MCD-009: 削除後に確認ダイアログが表示されない

**手順**:
1. MichiInfo 画面を表示する
2. Mark または Link カードを左スワイプして削除ボタンをタップする

**期待**: AlertDialog / ConfirmationDialog が表示されない（即座に削除される）

---

### TC-MCD-010: 挿入モード中はスワイプが無効になる

**手順**:
1. MichiInfo 画面を表示する
2. 挿入モード FAB（＋ボタン）をタップして挿入モードに入る
3. Mark または Link カードを左スワイプしようとする

**期待**: 削除ボタンが表示されない（スワイプが無効になっている）

---

## 9. 対象外

- 削除取り消し（Undo）
- 物理削除
- 挿入モード中の削除
- `seq` の再採番
- カスケード削除（他レコードへの影響なし）
