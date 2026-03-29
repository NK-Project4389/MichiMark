# ActionSetting Feature Specification

Platform: Flutter / Dart
Version: 1.0
Category: Settings Feature

---

## 1. Purpose

行動イベント（Action）のマスタデータを一覧表示・追加・編集するFeature。

---

## 2. Scope

**含むもの**
- Action一覧表示
- Action新規追加
- Action既存編集（名前・表示設定）
- バリデーション（名前必須）
- 保存成功後の一覧へ戻る

**含まないもの**
- Action物理削除（論理削除のみ）
- Actionの並び順変更
- Navigation管理（Delegateで通知のみ）

---

## 3. Feature Structure

```
ActionSettingFeature
 ├ ActionSettingBloc（一覧管理）
 └ ActionSettingDetailBloc（詳細編集）
```

---

## 4. Draft Model

### ActionSettingDetailDraft

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `actionName` | `String` | 行動名（必須・空欄不可） |
| `isVisible` | `bool` | 表示設定（true=表示） |

---

## 5. Projection Model

### ActionItemProjection

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | Action ID（UUID文字列） |
| `actionName` | `String` | 行動名 |
| `isVisible` | `bool` | 表示設定 |

---

## 6. Domain Model

`ActionDomain`（`docs/Domain/ActionDomain.md` 参照）

| フィールド名 | Dart型 | 備考 |
|---|---|---|
| `id` | `String` | UUID文字列 |
| `actionName` | `String` | 行動名 |
| `isVisible` | `bool` | 表示設定 |
| `isDeleted` | `bool` | 論理削除フラグ |
| `createdAt` | `DateTime` | 初回登録時に設定 |
| `updatedAt` | `DateTime` | 保存時に更新 |

---

## 7. Events

### ActionSettingBloc

```dart
sealed class ActionSettingEvent extends Equatable {}

class ActionSettingStarted extends ActionSettingEvent {}

class ActionSettingItemSelected extends ActionSettingEvent {
  final String actionId;
  const ActionSettingItemSelected(this.actionId);
}

class ActionSettingAddTapped extends ActionSettingEvent {}
```

### ActionSettingDetailBloc

```dart
sealed class ActionSettingDetailEvent extends Equatable {}

class ActionSettingDetailStarted extends ActionSettingDetailEvent {
  final String? actionId; // null = 新規
  const ActionSettingDetailStarted({this.actionId});
}

class ActionSettingDetailNameChanged extends ActionSettingDetailEvent {
  final String value;
  const ActionSettingDetailNameChanged(this.value);
}

class ActionSettingDetailIsVisibleChanged extends ActionSettingDetailEvent {
  final bool value;
  const ActionSettingDetailIsVisibleChanged(this.value);
}

class ActionSettingDetailSaveTapped extends ActionSettingDetailEvent {}

class ActionSettingDetailBackTapped extends ActionSettingDetailEvent {}

class ActionSettingDetailSavingFinished extends ActionSettingDetailEvent {}

class ActionSettingDetailSaveFailed extends ActionSettingDetailEvent {
  final String message;
  const ActionSettingDetailSaveFailed(this.message);
}
```

---

## 8. State Structure

### ActionSettingState

```dart
class ActionSettingState extends Equatable {
  final List<ActionItemProjection> items;
  final ActionSettingDelegate? delegate;

  const ActionSettingState({
    required this.items,
    this.delegate,
  });
}
```

### ActionSettingDetailState

```dart
class ActionSettingDetailState extends Equatable {
  final String actionId;
  final ActionSettingDetailDraft draft;
  final String? validationError;    // バリデーションエラーメッセージ
  final String? saveErrorMessage;   // 保存エラーメッセージ
  final bool isSaving;
  final ActionSettingDetailDelegate? delegate;

  const ActionSettingDetailState({
    required this.actionId,
    required this.draft,
    this.validationError,
    this.saveErrorMessage,
    this.isSaving = false,
    this.delegate,
  });
}
```

---

## 9. Delegate Contract

### ActionSettingDelegate

```dart
sealed class ActionSettingDelegate extends Equatable {}

class ActionSettingOpenDetailDelegate extends ActionSettingDelegate {
  final String actionId;
  const ActionSettingOpenDetailDelegate(this.actionId);
}

class ActionSettingOpenNewDelegate extends ActionSettingDelegate {}
```

### ActionSettingDetailDelegate

```dart
sealed class ActionSettingDetailDelegate extends Equatable {}

class ActionSettingDetailSaveRequestedDelegate extends ActionSettingDetailDelegate {
  final String actionId;
  final ActionSettingDetailDraft draft;
  const ActionSettingDetailSaveRequestedDelegate(this.actionId, this.draft);
}

class ActionSettingDetailDidSaveDelegate extends ActionSettingDetailDelegate {
  final String actionId;
  const ActionSettingDetailDidSaveDelegate(this.actionId);
}

class ActionSettingDetailDismissDelegate extends ActionSettingDetailDelegate {}
```

---

## 10. Bloc Responsibility

### ActionSettingBloc
- `ActionSettingStarted`: Repository から fetchAll → `items` 更新
- `ActionSettingItemSelected`: `ActionSettingOpenDetailDelegate` を発火
- `ActionSettingAddTapped`: `ActionSettingOpenNewDelegate` を発火

### ActionSettingDetailBloc
- `ActionSettingDetailStarted`: actionId が null なら空 Draft 生成。非 null なら Repository から fetch → Draft 生成
- `*Changed` イベント: Draft 更新・バリデーション実行
- `ActionSettingDetailSaveTapped`: バリデーション → 通過なら `ActionSettingDetailSaveRequestedDelegate` を発火・`isSaving = true`
- `ActionSettingDetailSavingFinished`: `isSaving = false` → `ActionSettingDetailDidSaveDelegate` を発火
- `ActionSettingDetailSaveFailed`: `isSaving = false` → `saveErrorMessage` をセット
- `ActionSettingDetailBackTapped`: `ActionSettingDetailDismissDelegate` を発火

---

## 11. Validation Rules

| フィールド | ルール |
|---|---|
| `actionName` | 空欄不可（`validationError` に `.empty` をセット） |

バリデーションは `saveTapped` 時に実行する。
名前変更時は即時 `validationError` を更新する。

---

## 12. Navigation

```
ActionSettingPage (BlocListener)
  ActionSettingOpenDetailDelegate → context.go('/settings/action/:actionId')
  ActionSettingOpenNewDelegate    → context.go('/settings/action/new')

ActionSettingDetailPage (BlocListener)
  ActionSettingDetailSaveRequestedDelegate → ParentBloc に委譲して保存後 pop
  ActionSettingDetailDismissDelegate       → context.pop()
```

> Bloc 内で `context.go()` / `context.pop()` を直接呼び出すことは禁止。

---

## 13. Data Flow

```
User Input
  ↓
ActionSettingDetailEvent
  ↓
ActionSettingDetailBloc（Draft更新・Validation）
  ↓
Delegate（SaveRequested）
  ↓
ParentBloc / BlocListener
  ↓
Repository（DI経由）
  ↓
Domain保存
  ↓
SavedDelegate → 一覧リロード
```

---

## 14. Repository Interface

```dart
abstract class ActionRepository {
  Future<List<ActionDomain>> fetchAll();
  Future<ActionDomain?> fetchById(String id);
  Future<void> save(ActionDomain domain);
  Future<void> update(ActionDomain domain);
}
```

---

## 15. Architecture Rules

- `ActionSettingDetailBloc` は `Navigator` を直接操作しない
- Widget から Repository を直接呼び出し禁止
- `dynamic` 型使用禁止
- `!`（null assertion）乱用禁止
- `switch` の `default` によるコンパイル回避禁止

---

## 16. SwiftUI版との対応

| Flutter Feature | 対応 SwiftUI Reducer |
|---|---|
| `ActionSettingBloc` | `ActionSettingReducer` |
| `ActionSettingDetailBloc` | `ActionSettingDetailReducer` |

**リファクタリング事項**
- SwiftUI版では `ActionSettingReducer` 内に `@Presents var detail` としてネストされていた
- Flutter版では `ActionSettingBloc` と `ActionSettingDetailBloc` を独立したクラスとして分離し、go_router でナビゲーションを管理する
- SwiftUI版の `addActionTapped` / `startCreate` は Flutter版では `ActionSettingAddTapped` に統合する
- SwiftUI版では `ActionDomain(id: UUID(), ...)` で `UUID` 型を使用していたが、Flutter版では `const Uuid().v4()` による `String` 型 UUID を使用する

---

# End of ActionSetting Feature Spec
