# MichiMark Feature Specification Template

Platform: **Flutter / Dart**
Version: 1.0
Purpose: MichiMark FlutterアプリのFeature設計を統一フォーマットで記述するためのテンプレート

---

# 1. Feature Overview

## Feature Name

例: MarkDetail

## Purpose

このFeatureの目的を記述する。

例:
マーク詳細情報を編集・表示する。

## Scope

含むもの
- （例）マーク日時・参加メンバー・アクション・メモの編集
- （例）給油フラグON時のFuelDetail表示

含まないもの
- （例）マーク一覧
- （例）リンク詳細

---

# 2. Feature Responsibility

このFeatureの責務

- Draft所有
- Draft更新
- Domain生成
- Domain更新（Adapter経由）
- Projection生成（Adapter経由）

RootはこのFeatureの内部状態を変更しない。

---

# 3. State Structure

Stateの構造

```dart
class FeatureState extends Equatable {
  final FeatureDraft draft;
  final FeatureProjection projection;
  final FeatureDelegate? delegate;

  const FeatureState({
    required this.draft,
    required this.projection,
    this.delegate,
  });

  FeatureState copyWith({...}) => ...;

  @override
  List<Object?> get props => [draft, projection, delegate];
}
```

---

# 4. Draft Model

Draftは編集状態を保持する。

```dart
class FeatureDraft extends Equatable {
  // 編集中フィールドを定義
  const FeatureDraft({...});

  @override
  List<Object?> get props => [...];
}
```

例

```dart
class MarkDetailDraft extends Equatable {
  final MarkLinkId id;
  final DateTime date;
  final Set<MemberId> selectedMemberIds;
  final Set<ActionId> selectedActionIds;
  final bool isFuel;
  final String memo;

  const MarkDetailDraft({...});
}
```

Draftは未確定データであり、Domainと完全一致する必要はない。

---

# 5. Domain Model

このFeatureが扱うDomain

```dart
class FeatureDomain extends Equatable {
  // 確定済みデータ
  const FeatureDomain({...});

  @override
  List<Object?> get props => [...];
}
```

Domainは

- UIを知らない
- Draftを知らない

---

# 6. Projection Model

Projectionは表示専用。

```dart
class FeatureProjection extends Equatable {
  // 表示に必要なデータのみ（表示文字列・フォーマット済み値）
  const FeatureProjection({...});

  @override
  List<Object?> get props => [...];
}
```

例

```dart
class MarkDetailProjection extends Equatable {
  final String displayDate;
  final List<String> memberNames;
  final List<String> actionNames;
  final bool isFuel;

  const MarkDetailProjection({...});
}
```

Projectionは

- 状態を持たない
- Domainを書き換えない

---

# 7. Adapter

Adapterの役割

- Draft → Domain
- Domain → Projection

```dart
class FeatureAdapter {
  static FeatureDomain toDomain(FeatureDraft draft) { ... }
  static FeatureProjection toProjection(FeatureDomain domain) { ... }
}
```

---

# 8. Events

Feature Event

```dart
abstract class FeatureEvent extends Equatable {}

class AppStarted extends FeatureEvent {
  @override
  List<Object?> get props => [];
}

class DraftUpdated extends FeatureEvent {
  final FeatureDraft draft;
  const DraftUpdated(this.draft);

  @override
  List<Object?> get props => [draft];
}

class SaveButtonPressed extends FeatureEvent {
  @override
  List<Object?> get props => [];
}

class DeleteButtonPressed extends FeatureEvent {
  @override
  List<Object?> get props => [];
}
```

---

# 9. Delegate

親Feature / Rootへ通知する意図

```dart
abstract class FeatureDelegate extends Equatable {}

class FeatureSavedDelegate extends FeatureDelegate {
  final FeatureDomain domain;
  const FeatureSavedDelegate(this.domain);

  @override
  List<Object?> get props => [domain];
}

class FeatureDeletedDelegate extends FeatureDelegate {
  final String id;
  const FeatureDeletedDelegate(this.id);

  @override
  List<Object?> get props => [id];
}
```

Delegateは

- Domain変更しない
- Draft変更しない

---

# 10. Bloc Responsibility

Blocは以下のみ行う

- Draft更新
- Adapter呼び出し
- Delegate発火

禁止事項

- Repository直接操作
- Navigation操作

---

# 11. Navigation

NavigationはRootが管理する。

FeatureはDelegateで遷移意図を通知する。

```dart
// Feature内での通知例
emit(state.copyWith(delegate: OpenSelectionDelegate(type: SelectionType.markMembers)));
```

---

# 12. Data Flow

データの流れ

```
User Input
  ↓
Event（Bloc）
  ↓
Draft更新
  ↓
Adapter
  ↓
Domain
  ↓
Projection
  ↓
Widget
```

---

# 13. Persistence

永続化はRepositoryが行う。

```dart
abstract class FeatureRepository {
  Future<FeatureDomain> load(String id);
  Future<void> save(FeatureDomain domain);
  Future<void> delete(String id);
}
```

FeatureはRepositoryを直接知らない。

---

# 14. Validation

Draft入力チェック

- ValidationはDraftまたはAdapterで行う
- エラーはDraftのフィールドまたはStateで保持する

例

```dart
class MarkDetailDraftValidator {
  static bool isValid(MarkDetailDraft draft) {
    return draft.selectedMemberIds.isNotEmpty;
  }
}
```

---

# 15. SwiftUI版との対応

このFeatureがSwiftUI版のどのReducerに対応するかを記述する。

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| （例）mark_detail | MarkDetailReducer |

SwiftUI版から移植する際のリファクタリング事項を記述する。

例:
- SwiftUI版では FuelDetailReducer がMarkDetailReducer内にネストされていた
- Flutter版では fuel_detail を独立したFeatureとして切り出す

---

# End of Feature Spec Template
