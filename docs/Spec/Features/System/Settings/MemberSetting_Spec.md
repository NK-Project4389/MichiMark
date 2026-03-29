# MemberSetting Feature Specification

Platform: Flutter / Dart
Version: 1.0
Category: Settings Feature

---

## 1. Purpose

イベント参加者（Member）のマスタデータを一覧表示・追加・編集するFeature。

---

## 2. Scope

**含むもの**
- Member一覧表示
- Member新規追加
- Member既存編集（名前・表示設定）
- バリデーション（名前必須）
- 保存成功後の一覧へ戻る

**含まないもの**
- Member物理削除（論理削除のみ）
- mailAddress の編集（現時点では未使用フィールド）
- Memberの並び順変更
- Navigation管理（Delegateで通知のみ）

---

## 3. Feature Structure

```
MemberSettingFeature
 ├ MemberSettingBloc（一覧管理）
 └ MemberSettingDetailBloc（詳細編集）
```

---

## 4. Draft Model

### MemberSettingDetailDraft

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `memberName` | `String` | メンバー名（必須・空欄不可） |
| `isVisible` | `bool` | 表示設定（true=表示） |

> `mailAddress` は現時点で未使用のため Draft に含まない。

---

## 5. Projection Model

### MemberItemProjection

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | Member ID（UUID文字列） |
| `memberName` | `String` | メンバー名 |
| `mailAddress` | `String?` | メールアドレス（表示のみ・編集不可） |
| `isVisible` | `bool` | 表示設定 |

---

## 6. Domain Model

`MemberDomain`（`docs/Domain/MemberDomain.md` 参照）

| フィールド名 | Dart型 | 備考 |
|---|---|---|
| `id` | `String` | UUID文字列 |
| `memberName` | `String` | メンバー名 |
| `mailAddress` | `String?` | 将来拡張用・現時点では未使用 |
| `isVisible` | `bool` | 表示設定 |
| `isDeleted` | `bool` | 論理削除フラグ |
| `createdAt` | `DateTime` | 初回登録時に設定 |
| `updatedAt` | `DateTime` | 保存時に更新 |

---

## 7. Events

### MemberSettingBloc

```dart
sealed class MemberSettingEvent extends Equatable {}

class MemberSettingStarted extends MemberSettingEvent {}

class MemberSettingItemSelected extends MemberSettingEvent {
  final String memberId;
  const MemberSettingItemSelected(this.memberId);
}

class MemberSettingAddTapped extends MemberSettingEvent {}
```

### MemberSettingDetailBloc

```dart
sealed class MemberSettingDetailEvent extends Equatable {}

class MemberSettingDetailStarted extends MemberSettingDetailEvent {
  final String? memberId; // null = 新規
  const MemberSettingDetailStarted({this.memberId});
}

class MemberSettingDetailNameChanged extends MemberSettingDetailEvent {
  final String value;
  const MemberSettingDetailNameChanged(this.value);
}

class MemberSettingDetailIsVisibleChanged extends MemberSettingDetailEvent {
  final bool value;
  const MemberSettingDetailIsVisibleChanged(this.value);
}

class MemberSettingDetailSaveTapped extends MemberSettingDetailEvent {}

class MemberSettingDetailBackTapped extends MemberSettingDetailEvent {}

class MemberSettingDetailSavingFinished extends MemberSettingDetailEvent {}

class MemberSettingDetailSaveFailed extends MemberSettingDetailEvent {
  final String message;
  const MemberSettingDetailSaveFailed(this.message);
}
```

---

## 8. State Structure

### MemberSettingState

```dart
class MemberSettingState extends Equatable {
  final List<MemberItemProjection> items;
  final MemberSettingDelegate? delegate;

  const MemberSettingState({
    required this.items,
    this.delegate,
  });
}
```

### MemberSettingDetailState

```dart
class MemberSettingDetailState extends Equatable {
  final String memberId;
  final MemberSettingDetailDraft draft;
  final String? validationError;    // バリデーションエラーメッセージ
  final String? saveErrorMessage;   // 保存エラーメッセージ
  final bool isSaving;
  final MemberSettingDetailDelegate? delegate;

  const MemberSettingDetailState({
    required this.memberId,
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

### MemberSettingDelegate

```dart
sealed class MemberSettingDelegate extends Equatable {}

class MemberSettingOpenDetailDelegate extends MemberSettingDelegate {
  final String memberId;
  const MemberSettingOpenDetailDelegate(this.memberId);
}

class MemberSettingOpenNewDelegate extends MemberSettingDelegate {}
```

### MemberSettingDetailDelegate

```dart
sealed class MemberSettingDetailDelegate extends Equatable {}

class MemberSettingDetailSaveRequestedDelegate extends MemberSettingDetailDelegate {
  final String memberId;
  final MemberSettingDetailDraft draft;
  const MemberSettingDetailSaveRequestedDelegate(this.memberId, this.draft);
}

class MemberSettingDetailDidSaveDelegate extends MemberSettingDetailDelegate {
  final String memberId;
  const MemberSettingDetailDidSaveDelegate(this.memberId);
}

class MemberSettingDetailDismissDelegate extends MemberSettingDetailDelegate {}
```

---

## 10. Bloc Responsibility

### MemberSettingBloc
- `MemberSettingStarted`: Repository から fetchAll → `items` 更新
- `MemberSettingItemSelected`: `MemberSettingOpenDetailDelegate` を発火
- `MemberSettingAddTapped`: `MemberSettingOpenNewDelegate` を発火

### MemberSettingDetailBloc
- `MemberSettingDetailStarted`: memberId が null なら空 Draft 生成。非 null なら Repository から fetch → Draft 生成
- `*Changed` イベント: Draft 更新・バリデーション実行
- `MemberSettingDetailSaveTapped`: バリデーション → 通過なら `MemberSettingDetailSaveRequestedDelegate` を発火・`isSaving = true`
- `MemberSettingDetailSavingFinished`: `isSaving = false` → `MemberSettingDetailDidSaveDelegate` を発火
- `MemberSettingDetailSaveFailed`: `isSaving = false` → `saveErrorMessage` をセット
- `MemberSettingDetailBackTapped`: `MemberSettingDetailDismissDelegate` を発火

---

## 11. Validation Rules

| フィールド | ルール |
|---|---|
| `memberName` | 空欄不可（`validationError` に `.empty` をセット） |

バリデーションは `saveTapped` 時に実行する。
名前変更時は即時 `validationError` を更新する。

---

## 12. Navigation

```
MemberSettingPage (BlocListener)
  MemberSettingOpenDetailDelegate → context.go('/settings/member/:memberId')
  MemberSettingOpenNewDelegate    → context.go('/settings/member/new')

MemberSettingDetailPage (BlocListener)
  MemberSettingDetailSaveRequestedDelegate → ParentBloc に委譲して保存後 pop
  MemberSettingDetailDismissDelegate       → context.pop()
```

> Bloc 内で `context.go()` / `context.pop()` を直接呼び出すことは禁止。

---

## 13. Data Flow

```
User Input
  ↓
MemberSettingDetailEvent
  ↓
MemberSettingDetailBloc（Draft更新・Validation）
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
abstract class MemberRepository {
  Future<List<MemberDomain>> fetchAll();
  Future<MemberDomain?> fetchById(String id);
  Future<void> save(MemberDomain domain);
  Future<void> update(MemberDomain domain);
}
```

---

## 15. Architecture Rules

- `MemberSettingDetailBloc` は `Navigator` を直接操作しない
- Widget から Repository を直接呼び出し禁止
- `dynamic` 型使用禁止
- `!`（null assertion）乱用禁止
- `switch` の `default` によるコンパイル回避禁止

---

## 16. SwiftUI版との対応

| Flutter Feature | 対応 SwiftUI Reducer |
|---|---|
| `MemberSettingBloc` | `MemberSettingReducer` |
| `MemberSettingDetailBloc` | `MemberSettingDetailReducer` |

**リファクタリング事項**
- SwiftUI版では `MemberSettingReducer` 内に `@Presents var detail` としてネストされていた
- Flutter版では `MemberSettingBloc` と `MemberSettingDetailBloc` を独立したクラスとして分離し、go_router でナビゲーションを管理する
- SwiftUI版の `addMemberTapped` / `startCreate` は Flutter版では `MemberSettingAddTapped` に統合する
- SwiftUI版の `MemberDomain` ではコンストラクタで `isVisible` を渡していたが、Flutter版では `MemberDomain` の `isVisible` デフォルト値 `true` を使用する

---

# End of MemberSetting Feature Spec
