# TagSetting Feature Specification

Platform: Flutter / Dart
Version: 1.0
Category: Settings Feature

---

## 1. Purpose

イベント分類タグ（Tag）のマスタデータを一覧表示・追加・編集するFeature。

---

## 2. Scope

**含むもの**
- Tag一覧表示
- Tag新規追加
- Tag既存編集（名前・表示設定）
- バリデーション（名前必須）
- 保存成功後の一覧へ戻る

**含まないもの**
- Tag物理削除（論理削除のみ）
- Tagの並び順変更
- Navigation管理（Delegateで通知のみ）

---

## 3. Feature Structure

```
TagSettingFeature
 ├ TagSettingBloc（一覧管理）
 └ TagSettingDetailBloc（詳細編集）
```

---

## 4. Draft Model

### TagSettingDetailDraft

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `tagName` | `String` | タグ名（必須・空欄不可） |
| `isVisible` | `bool` | 表示設定（true=表示） |

---

## 5. Projection Model

### TagItemProjection

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | Tag ID（UUID文字列） |
| `tagName` | `String` | タグ名 |
| `isVisible` | `bool` | 表示設定 |

---

## 6. Domain Model

`TagDomain`（`docs/Domain/TagDomain.md` 参照）

| フィールド名 | Dart型 | 備考 |
|---|---|---|
| `id` | `String` | UUID文字列 |
| `tagName` | `String` | タグ名 |
| `isVisible` | `bool` | 表示設定 |
| `isDeleted` | `bool` | 論理削除フラグ |
| `createdAt` | `DateTime` | 初回登録時に設定 |
| `updatedAt` | `DateTime` | 保存時に更新 |

---

## 7. Events

### TagSettingBloc

```dart
sealed class TagSettingEvent extends Equatable {}

class TagSettingStarted extends TagSettingEvent {}

class TagSettingItemSelected extends TagSettingEvent {
  final String tagId;
  const TagSettingItemSelected(this.tagId);
}

class TagSettingAddTapped extends TagSettingEvent {}
```

### TagSettingDetailBloc

```dart
sealed class TagSettingDetailEvent extends Equatable {}

class TagSettingDetailStarted extends TagSettingDetailEvent {
  final String? tagId; // null = 新規
  const TagSettingDetailStarted({this.tagId});
}

class TagSettingDetailNameChanged extends TagSettingDetailEvent {
  final String value;
  const TagSettingDetailNameChanged(this.value);
}

class TagSettingDetailIsVisibleChanged extends TagSettingDetailEvent {
  final bool value;
  const TagSettingDetailIsVisibleChanged(this.value);
}

class TagSettingDetailSaveTapped extends TagSettingDetailEvent {}

class TagSettingDetailBackTapped extends TagSettingDetailEvent {}

class TagSettingDetailSavingFinished extends TagSettingDetailEvent {}

class TagSettingDetailSaveFailed extends TagSettingDetailEvent {
  final String message;
  const TagSettingDetailSaveFailed(this.message);
}
```

---

## 8. State Structure

### TagSettingState

```dart
class TagSettingState extends Equatable {
  final List<TagItemProjection> items;
  final TagSettingDelegate? delegate;

  const TagSettingState({
    required this.items,
    this.delegate,
  });
}
```

### TagSettingDetailState

```dart
class TagSettingDetailState extends Equatable {
  final String tagId;
  final TagSettingDetailDraft draft;
  final String? validationError;    // バリデーションエラーメッセージ
  final String? saveErrorMessage;   // 保存エラーメッセージ
  final bool isSaving;
  final TagSettingDetailDelegate? delegate;

  const TagSettingDetailState({
    required this.tagId,
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

### TagSettingDelegate

```dart
sealed class TagSettingDelegate extends Equatable {}

class TagSettingOpenDetailDelegate extends TagSettingDelegate {
  final String tagId;
  const TagSettingOpenDetailDelegate(this.tagId);
}

class TagSettingOpenNewDelegate extends TagSettingDelegate {}
```

### TagSettingDetailDelegate

```dart
sealed class TagSettingDetailDelegate extends Equatable {}

class TagSettingDetailSaveRequestedDelegate extends TagSettingDetailDelegate {
  final String tagId;
  final TagSettingDetailDraft draft;
  const TagSettingDetailSaveRequestedDelegate(this.tagId, this.draft);
}

class TagSettingDetailDidSaveDelegate extends TagSettingDetailDelegate {
  final String tagId;
  const TagSettingDetailDidSaveDelegate(this.tagId);
}

class TagSettingDetailDismissDelegate extends TagSettingDetailDelegate {}
```

---

## 10. Bloc Responsibility

### TagSettingBloc
- `TagSettingStarted`: Repository から fetchAll → `items` 更新
- `TagSettingItemSelected`: `TagSettingOpenDetailDelegate` を発火
- `TagSettingAddTapped`: `TagSettingOpenNewDelegate` を発火

### TagSettingDetailBloc
- `TagSettingDetailStarted`: tagId が null なら空 Draft 生成。非 null なら Repository から fetch → Draft 生成
- `*Changed` イベント: Draft 更新・バリデーション実行
- `TagSettingDetailSaveTapped`: バリデーション → 通過なら `TagSettingDetailSaveRequestedDelegate` を発火・`isSaving = true`
- `TagSettingDetailSavingFinished`: `isSaving = false` → `TagSettingDetailDidSaveDelegate` を発火
- `TagSettingDetailSaveFailed`: `isSaving = false` → `saveErrorMessage` をセット
- `TagSettingDetailBackTapped`: `TagSettingDetailDismissDelegate` を発火

---

## 11. Validation Rules

| フィールド | ルール |
|---|---|
| `tagName` | 空欄不可（`validationError` に `.empty` をセット） |

バリデーションは `saveTapped` 時に実行する。
名前変更時は即時 `validationError` を更新する。

---

## 12. Navigation

```
TagSettingPage (BlocListener)
  TagSettingOpenDetailDelegate → context.go('/settings/tag/:tagId')
  TagSettingOpenNewDelegate    → context.go('/settings/tag/new')

TagSettingDetailPage (BlocListener)
  TagSettingDetailSaveRequestedDelegate → ParentBloc に委譲して保存後 pop
  TagSettingDetailDismissDelegate       → context.pop()
```

> Bloc 内で `context.go()` / `context.pop()` を直接呼び出すことは禁止。

---

## 13. Data Flow

```
User Input
  ↓
TagSettingDetailEvent
  ↓
TagSettingDetailBloc（Draft更新・Validation）
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
abstract class TagRepository {
  Future<List<TagDomain>> fetchAll();
  Future<TagDomain?> fetchById(String id);
  Future<void> save(TagDomain domain);
  Future<void> update(TagDomain domain);
}
```

---

## 15. Architecture Rules

- `TagSettingDetailBloc` は `Navigator` を直接操作しない
- Widget から Repository を直接呼び出し禁止
- `dynamic` 型使用禁止
- `!`（null assertion）乱用禁止
- `switch` の `default` によるコンパイル回避禁止

---

## 16. SwiftUI版との対応

| Flutter Feature | 対応 SwiftUI Reducer |
|---|---|
| `TagSettingBloc` | `TagSettingReducer` |
| `TagSettingDetailBloc` | `TagSettingDetailReducer` |

**リファクタリング事項**
- SwiftUI版では `TagSettingReducer` 内に `@Presents var detail` としてネストされていた
- Flutter版では `TagSettingBloc` と `TagSettingDetailBloc` を独立したクラスとして分離し、go_router でナビゲーションを管理する
- SwiftUI版の `addTagTapped` / `startCreate` は Flutter版では `TagSettingAddTapped` に統合する

---

# End of TagSetting Feature Spec
