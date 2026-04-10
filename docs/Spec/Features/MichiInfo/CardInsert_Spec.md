# Feature Spec: MichiInfo カード間挿入機能

- **Spec ID**: MichiInfo_CardInsert_Spec
- **要件ID**: REQ-michi_info_card_insert
- **作成日**: 2026-04-10
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要

MichiInfo タイムラインにカードを任意の位置に挿入する機能を実装する。
FAB タップ → 挿入モード → インジケーター選択 → BottomSheet（Mark/Link 選択）→ 詳細画面遷移 → 保存 → 指定位置に挿入。

---

## 2. スコープ外

- カードの並び替え（ドラッグ＆ドロップ）
- 挿入後のカード削除・移動
- 先頭（全カードより前）への挿入（インジケーターは最初のカードの前には表示しない）

---

## 3. UI仕様

### 3-1. 通常モード

- **FAB**: 画面右下に Amber FAB（背景 `#F59E0B`、アイコン白 `+`）を表示
  - `TopicConfig.addMenuItems` が空の場合は非表示（既存挙動と同じ）
  - 現在のテーマカラー FAB を Amber FAB に置き換える
- タップ → 挿入モードへ遷移

### 3-2. 挿入モード

- **FAB**: アイコンを `close` に変更（背景は Amber のまま）
- **インジケーター**: 各カードの間（および末尾）にAmber の水平インジケーターを表示
  - インジケーター線色: `#F59E0B` 40% alpha（`Color(0x66F59E0B)`）
  - インジケーター高さ: 24dp（上下 12dp のタップ領域）
  - インジケーター中央に `+` アイコン（Amber、サイズ 16dp）
- FAB 再タップ → 通常モードへ戻る

### 3-3. 挿入ポイント確定後

- BottomSheet 表示（Mark を追加 / Link を追加）
- BottomSheet を閉じる（スワイプ・外側タップ）→ 挿入モードに戻る（インジケーター継続表示）
- 選択後 → MarkDetail / LinkDetail 新規作成画面へ遷移

### 3-4. カラー定義

| 用途 | カラー |
|---|---|
| FAB 背景・インジケーターアイコン | `Color(0xFFF59E0B)` Amber |
| FAB 前景（アイコン） | `Colors.white` |
| インジケーター線 | `Color(0x66F59E0B)` Amber 40% |

---

## 4. 状態設計

### 4-1. `MichiInfoLoaded` に追加するフィールド

```dart
/// 挿入モード中かどうか
final bool isInsertMode;

/// 挿入モードで選択されたインジケーターの直前カードの markLinkSeq
/// null = まだ未選択（挿入モード中）
final int? pendingInsertAfterSeq;
```

`copyWith` にも追加する。`isInsertMode` のデフォルト値は `false`、`pendingInsertAfterSeq` のデフォルトは `null`。

### 4-2. `MichiInfoState.props` 更新

`isInsertMode` と `pendingInsertAfterSeq` を props に追加する。

---

## 5. Event 設計

### 5-1. 追加する Event

```dart
/// FAB タップ（挿入モードのトグル）
class MichiInfoInsertModeFabPressed extends MichiInfoEvent {
  const MichiInfoInsertModeFabPressed();
}

/// インジケータータップ（挿入ポイント確定）
/// [insertAfterSeq] 直前カードの markLinkSeq。末尾インジケーターの場合は全アイテムの最大 seq
class MichiInfoInsertPointSelected extends MichiInfoEvent {
  final int insertAfterSeq;
  const MichiInfoInsertPointSelected(this.insertAfterSeq);
}

/// 挿入モードで Mark 追加を選択したとき
class MichiInfoInsertMarkPressed extends MichiInfoEvent {
  const MichiInfoInsertMarkPressed();
}

/// 挿入モードで Link 追加を選択したとき
class MichiInfoInsertLinkPressed extends MichiInfoEvent {
  const MichiInfoInsertLinkPressed();
}
```

### 5-2. 既存 Event の維持

`MichiInfoAddMarkPressed` / `MichiInfoAddLinkPressed` は削除しない（既存テストへの影響を防ぐ）。
ただし、View 側からのトリガーは Amber FAB（挿入モード経由）に一本化する。

---

## 6. Delegate 設計

### 6-1. 既存 Delegate への追加フィールド

`MichiInfoAddMarkDelegate` と `MichiInfoAddLinkDelegate` に `insertAfterSeq: int?` を追加する。

```dart
class MichiInfoAddMarkDelegate extends MichiInfoDelegate {
  // ... 既存フィールド
  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;
  const MichiInfoAddMarkDelegate(
    this.eventId,
    this.topicConfig, {
    this.insertAfterSeq,
    // ... 既存オプション引数
  });
}

class MichiInfoAddLinkDelegate extends MichiInfoDelegate {
  // ... 既存フィールド
  final int? insertAfterSeq;
  const MichiInfoAddLinkDelegate(
    this.eventId,
    this.topicConfig, {
    this.insertAfterSeq,
    // ... 既存オプション引数
  });
}
```

---

## 7. Bloc ハンドラー

### 7-1. `MichiInfoInsertModeFabPressed`

```
isInsertMode が false → true に変更（pendingInsertAfterSeq は null のまま）
isInsertMode が true → false に変更（pendingInsertAfterSeq も null にリセット）
```

### 7-2. `MichiInfoInsertPointSelected`

```
state.pendingInsertAfterSeq = event.insertAfterSeq に更新し、
BottomSheet 表示 Delegate をトリガーしない
（BottomSheet は View 側で BlocListener で検出して表示する）
→ state を copyWith(pendingInsertAfterSeq: event.insertAfterSeq) で更新
```

### 7-3. `MichiInfoInsertMarkPressed`

```
pendingInsertAfterSeq を使って MichiInfoAddMarkDelegate を emit
（initialMeterValueInput / initialSelectedMembers / initialMarkLinkDate の引き継ぎは既存ロジックを維持）
```

### 7-4. `MichiInfoInsertLinkPressed`

```
pendingInsertAfterSeq を使って MichiInfoAddLinkDelegate を emit
```

### 7-5. `MichiInfoMarkSaved` / `MichiInfoLinkSaved` ハンドラー更新

保存完了時に `isInsertMode = false` / `pendingInsertAfterSeq = null` にリセットする。

---

## 8. View 設計

### 8-1. FAB の変更

`_MichiInfoListState._onAddPressed` は廃止し、Amber FAB の `onPressed` で `MichiInfoInsertModeFabPressed` を dispatch する。

```dart
floatingActionButton: widget.topicConfig.addMenuItems.isEmpty
    ? null
    : FloatingActionButton(
        onPressed: () => context.read<MichiInfoBloc>().add(
          const MichiInfoInsertModeFabPressed(),
        ),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        child: Icon(
          widget.isInsertMode ? Icons.close : Icons.add,
        ),
      ),
```

### 8-2. インジケーターの表示

`SliverList` の `childCount: items.length` を変更し、カード間にインジケーターを挟む。

インジケーター位置（インデックス計算）：
```
通常モード: childCount = items.length  → index i => items[i]
挿入モード: childCount = items.length * 2 + 1
  index 0          → 不要（先頭インジケーターは表示しない。要件外）
  index 1          → items[0]
  index 2          → インジケーター（insertAfterSeq = items[0].markLinkSeq）
  index 3          → items[1]
  index 4          → インジケーター（insertAfterSeq = items[1].markLinkSeq）
  ...
  index 2*n-1      → items[n-1]
  index 2*n        → 末尾インジケーター（insertAfterSeq = items[n-1].markLinkSeq）
```

インジケーターWidget：

```dart
class _InsertIndicator extends StatelessWidget {
  final int insertAfterSeq;
  const _InsertIndicator({required this.insertAfterSeq});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<MichiInfoBloc>().add(
        MichiInfoInsertPointSelected(insertAfterSeq),
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Expanded(
              child: Divider(
                color: const Color(0x66F59E0B),
                thickness: 1.5,
              ),
            ),
            const Icon(Icons.add_circle_outline, color: Color(0xFFF59E0B), size: 16),
            Expanded(
              child: Divider(
                color: const Color(0x66F59E0B),
                thickness: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8-3. BottomSheet トリガー

`MichiInfoLoaded` の `pendingInsertAfterSeq` が non-null になったとき（前の状態から変化したとき）に BottomSheet を表示する。

`BlocConsumer` の `listenWhen` で検出：

```dart
listenWhen: (prev, curr) {
  if (prev is MichiInfoLoaded && curr is MichiInfoLoaded) {
    return prev.pendingInsertAfterSeq == null &&
           curr.pendingInsertAfterSeq != null;
  }
  return false;
},
```

BottomSheet の内容：Mark を追加 / Link を追加（`addMenuItems` に含まれるもののみ表示）。

BottomSheet を閉じた場合（キャンセル）は `pendingInsertAfterSeq` を null にリセット。
→ `MichiInfoInsertModeFabPressed` を再利用せず、専用の `MichiInfoInsertPointCancelled` Event を追加。

```dart
class MichiInfoInsertPointCancelled extends MichiInfoEvent {
  const MichiInfoInsertPointCancelled();
}
```

ハンドラー: `pendingInsertAfterSeq = null`（`isInsertMode` は `true` のまま維持）

### 8-4. `_handleDelegate` の変更

`MichiInfoAddMarkDelegate` / `MichiInfoAddLinkDelegate` に `insertAfterSeq` が追加されるため、`MarkDetailArgs` / `LinkDetailArgs` にも渡す。

---

## 9. MarkDetailArgs / LinkDetailArgs 変更

```dart
class MarkDetailArgs {
  // ... 既存フィールド
  /// null = 末尾追加（現行動作）、non-null = 指定位置に挿入
  final int? insertAfterSeq;
  const MarkDetailArgs({
    required this.eventId,
    required this.topicConfig,
    this.insertAfterSeq,
    // ... 既存オプション
  });
}

class LinkDetailArgs {
  // ... 既存フィールド
  final int? insertAfterSeq;
  const LinkDetailArgs({
    required this.eventId,
    required this.topicConfig,
    this.insertAfterSeq,
    // ... 既存オプション
  });
}
```

---

## 10. MarkDetailBloc / LinkDetailBloc の変更

### 10-1. 保存時の `markLinkSeq` 算出変更

`MarkDetailBloc` の保存ハンドラー（`MarkDetailSavePressed`相当）を変更する。

**既存（末尾追加）**:
```dart
final seq = activeMarkLinks.isEmpty
    ? 0
    : activeMarkLinks.map((ml) => ml.markLinkSeq).reduce(max) + 1;
```

**変更後**:
```dart
int seq;
if (_insertAfterSeq != null) {
  // 挿入モード: insertAfterSeq より大きい seq を全て +1
  final needShift = activeMarkLinks.where((ml) => ml.markLinkSeq > _insertAfterSeq!);
  for (final ml in needShift) {
    event.markLinks[ml.id].seq += 1; // EventDomain を更新してから save
  }
  seq = _insertAfterSeq! + 1;
} else {
  // 末尾追加（従来）
  seq = activeMarkLinks.isEmpty
      ? 0
      : activeMarkLinks.map((ml) => ml.markLinkSeq).reduce(max) + 1;
}
```

実装上の注意点：
- `EventDomain` は不変オブジェクトのため、`markLinks` の seq を更新した新しい `EventDomain` を構築してから save する
- `_insertAfterSeq` は `MarkDetailBloc` のコンストラクタ引数として受け取る（`MarkDetailArgs.insertAfterSeq` から渡す）

### 10-2. `LinkDetailBloc` も同様に対応

`LinkDetailBloc` にも `insertAfterSeq: int?` コンストラクタ引数を追加し、同じロジックを適用する。

---

## 11. テストシナリオ

| ID | シナリオ | 確認内容 |
|---|---|---|
| TC-MCI-001 | アイテムが1件以上ある状態でMichiInfoを開く | Amber FAB（`+`アイコン）が表示される |
| TC-MCI-002 | Amber FAB をタップする | 挿入モードになる：FAB アイコンが `close` に変わり、インジケーターが各カード間に表示される |
| TC-MCI-003 | 挿入モード中に FAB を再タップする | 通常モードに戻る：FAB が `+` に戻り、インジケーターが消える |
| TC-MCI-004 | 挿入モード中に任意のインジケーターをタップする | BottomSheet が表示される（Mark を追加 / Link を追加） |
| TC-MCI-005 | BottomSheet でスワイプ（閉じる） | BottomSheet が閉じ、挿入モードが継続する（インジケーター表示されたまま） |
| TC-MCI-006 | BottomSheet で「Mark を追加」を選択する | MarkDetail 新規作成画面に遷移する |
| TC-MCI-007 | Mark 詳細を入力して保存する | タイムラインに指定位置（インジケーター位置）でカードが挿入されている |
| TC-MCI-008 | BottomSheet で「Link を追加」を選択する | LinkDetail 新規作成画面に遷移する |
| TC-MCI-009 | Link 詳細を入力して保存する | タイムラインに指定位置（インジケーター位置）でカードが挿入されている |
| TC-MCI-010 | 末尾インジケーターをタップして Mark を追加・保存する | 末尾に Mark カードが追加されている |

---

## 12. 既存テストへの影響

- `TC-MAD-001〜008`（MarkAdditionDefaults）: 末尾追加フローを使用 → `insertAfterSeq = null` のパスが維持されるため影響なし
- `TC-FCM-001〜008`（MovingCostFuelMode）: 影響なし

---

## 13. ファイル変更一覧

| ファイル | 変更内容 |
|---|---|
| `michi_info_state.dart` | `isInsertMode`, `pendingInsertAfterSeq` フィールド追加 |
| `michi_info_event.dart` | `MichiInfoInsertModeFabPressed`, `MichiInfoInsertPointSelected`, `MichiInfoInsertMarkPressed`, `MichiInfoInsertLinkPressed`, `MichiInfoInsertPointCancelled` 追加 |
| `michi_info_state.dart` | `MichiInfoAddMarkDelegate`, `MichiInfoAddLinkDelegate` に `insertAfterSeq` 追加 |
| `michi_info_bloc.dart` | 上記 Event のハンドラー追加、既存ハンドラー修正 |
| `michi_info_view.dart` | FAB Amber 化、インジケーター表示、BottomSheet トリガー変更 |
| `mark_detail_args.dart` | `insertAfterSeq: int?` 追加 |
| `link_detail_args.dart` | `insertAfterSeq: int?` 追加 |
| `mark_detail_bloc.dart` | 挿入 seq ロジック追加、コンストラクタ引数 `insertAfterSeq` 追加 |
| `link_detail_bloc.dart` | 挿入 seq ロジック追加、コンストラクタ引数 `insertAfterSeq` 追加 |
