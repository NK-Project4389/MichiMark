# TransSetting Feature Specification

Platform: Flutter / Dart
Version: 1.0
Category: Settings Feature

---

## 1. Purpose

交通手段（Trans）のマスタデータを一覧表示・追加・編集するFeature。

---

## 2. Scope

**含むもの**
- Trans一覧表示
- Trans新規追加
- Trans既存編集（名前・燃費・メーター値・表示設定）
- バリデーション（名前必須、燃費フォーマット、メーター値フォーマット）
- 保存成功後の一覧へ戻る

**含まないもの**
- Trans物理削除（論理削除のみ）
- Transの並び順変更
- Navigation管理（Delegateで通知のみ）

---

## 3. Feature Structure

```
TransSettingFeature
 ├ TransSettingBloc（一覧管理）
 └ TransSettingDetailBloc（詳細編集）
```

---

## 4. Draft Model

### TransSettingDetailDraft

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `transName` | `String` | 交通手段名（必須・空欄不可） |
| `displayKmPerGas` | `String` | 燃費の表示文字列（例: "12.5"）。空欄許可 |
| `displayMeterValue` | `String` | メーター値の表示文字列（カンマ区切り。例: "10,000"）。空欄許可 |
| `isVisible` | `bool` | 表示設定（true=表示） |

**変換ルール**
- `displayKmPerGas` → `kmPerGas(int?)`: `Double(text) * 10`（小数第1位まで）
- `displayMeterValue` → `meterValue(int?)`: カンマ除去して `Int(text)`
- `displayMeterValue` 入力時にカンマ整形を自動適用

---

## 5. Projection Model

### TransItemProjection

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | Trans ID（UUID文字列） |
| `transName` | `String` | 交通手段名 |
| `displayKmPerGas` | `String` | 燃費表示文字列 |
| `displayMeterValue` | `String` | メーター値表示文字列（カンマ区切り） |
| `isVisible` | `bool` | 表示設定 |

---

## 6. Domain Model

`TransDomain`（`docs/Domain/TransDomain.md` 参照）

| フィールド名 | Dart型 | 備考 |
|---|---|---|
| `id` | `String` | UUID文字列 |
| `transName` | `String` | 交通手段名 |
| `kmPerGas` | `int?` | 0.1km/L単位（例: 125 = 12.5km/L） |
| `meterValue` | `int?` | 1km単位 |
| `isVisible` | `bool` | 表示設定 |
| `isDeleted` | `bool` | 論理削除フラグ |
| `createdAt` | `DateTime` | 初回登録時に設定 |
| `updatedAt` | `DateTime` | 保存時に更新 |

---

## 7. Events

### TransSettingBloc

```dart
sealed class TransSettingEvent extends Equatable {}

class TransSettingStarted extends TransSettingEvent {}

class TransSettingItemSelected extends TransSettingEvent {
  final String transId;
  const TransSettingItemSelected(this.transId);
}

class TransSettingAddTapped extends TransSettingEvent {}
```

### TransSettingDetailBloc

```dart
sealed class TransSettingDetailEvent extends Equatable {}

class TransSettingDetailStarted extends TransSettingDetailEvent {
  final String? transId; // null = 新規
  const TransSettingDetailStarted({this.transId});
}

class TransSettingDetailNameChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailNameChanged(this.value);
}

class TransSettingDetailKmPerGasChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailKmPerGasChanged(this.value);
}

class TransSettingDetailMeterValueChanged extends TransSettingDetailEvent {
  final String value;
  const TransSettingDetailMeterValueChanged(this.value);
}

class TransSettingDetailIsVisibleChanged extends TransSettingDetailEvent {
  final bool value;
  const TransSettingDetailIsVisibleChanged(this.value);
}

class TransSettingDetailSaveTapped extends TransSettingDetailEvent {}

class TransSettingDetailBackTapped extends TransSettingDetailEvent {}

class TransSettingDetailSavingFinished extends TransSettingDetailEvent {}

class TransSettingDetailSaveFailed extends TransSettingDetailEvent {
  final String message;
  const TransSettingDetailSaveFailed(this.message);
}
```

---

## 8. State Structure

### TransSettingState

```dart
class TransSettingState extends Equatable {
  final List<TransItemProjection> items;
  final TransSettingDelegate? delegate;

  const TransSettingState({
    required this.items,
    this.delegate,
  });
}
```

### TransSettingDetailState

```dart
class TransSettingDetailState extends Equatable {
  final String transId;
  final TransSettingDetailDraft draft;
  final String? validationError;    // バリデーションエラーメッセージ
  final String? saveErrorMessage;   // 保存エラーメッセージ
  final bool isSaving;
  final TransSettingDetailDelegate? delegate;

  const TransSettingDetailState({
    required this.transId,
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

### TransSettingDelegate

```dart
sealed class TransSettingDelegate extends Equatable {}

class TransSettingOpenDetailDelegate extends TransSettingDelegate {
  final String transId;
  const TransSettingOpenDetailDelegate(this.transId);
}

class TransSettingOpenNewDelegate extends TransSettingDelegate {}
```

### TransSettingDetailDelegate

```dart
sealed class TransSettingDetailDelegate extends Equatable {}

class TransSettingDetailSaveRequestedDelegate extends TransSettingDetailDelegate {
  final String transId;
  final TransSettingDetailDraft draft;
  const TransSettingDetailSaveRequestedDelegate(this.transId, this.draft);
}

class TransSettingDetailDidSaveDelegate extends TransSettingDetailDelegate {
  final String transId;
  const TransSettingDetailDidSaveDelegate(this.transId);
}

class TransSettingDetailDismissDelegate extends TransSettingDetailDelegate {}
```

---

## 10. Bloc Responsibility

### TransSettingBloc
- `TransSettingStarted`: Repository から fetchAll → `items` 更新
- `TransSettingItemSelected`: `TransSettingOpenDetailDelegate` を発火
- `TransSettingAddTapped`: `TransSettingOpenNewDelegate` を発火

### TransSettingDetailBloc
- `TransSettingDetailStarted`: transId が null なら空 Draft 生成。非 null なら Repository から fetch → Draft 生成
- `*Changed` イベント: Draft 更新・バリデーション実行
- `TransSettingDetailSaveTapped`: バリデーション → 通過なら `TransSettingDetailSaveRequestedDelegate` を発火・`isSaving = true`
- `TransSettingDetailSavingFinished`: `isSaving = false` → `TransSettingDetailDidSaveDelegate` を発火
- `TransSettingDetailSaveFailed`: `isSaving = false` → `saveErrorMessage` をセット
- `TransSettingDetailBackTapped`: `TransSettingDetailDismissDelegate` を発火

---

## 11. Validation Rules

| フィールド | ルール |
|---|---|
| `transName` | 空欄不可（`validationError` に `.empty` をセット） |
| `displayKmPerGas` | 必須・小数第1位までの正数（例: "12.5"、"5"） |
| `displayMeterValue` | 必須・正の整数（カンマ除去後に `int` 変換可能） |

バリデーションは `saveTapped` 時に実行する。
名前変更時は即時 `validationError` を更新する。

---

## 12. Navigation

```
TransSettingPage (BlocListener)
  TransSettingOpenDetailDelegate → context.go('/settings/trans/:transId')
  TransSettingOpenNewDelegate    → context.go('/settings/trans/new')

TransSettingDetailPage (BlocListener)
  TransSettingDetailSaveRequestedDelegate → ParentBloc に委譲して保存後 pop
  TransSettingDetailDismissDelegate       → context.pop()
```

> Bloc 内で `context.go()` / `context.pop()` を直接呼び出すことは禁止。

---

## 13. Data Flow

```
User Input
  ↓
TransSettingDetailEvent
  ↓
TransSettingDetailBloc（Draft更新・Validation）
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
abstract class TransRepository {
  Future<List<TransDomain>> fetchAll();
  Future<TransDomain?> fetchById(String id);
  Future<void> save(TransDomain domain);
  Future<void> update(TransDomain domain);
}
```

---

## 15. Architecture Rules

- `TransSettingDetailBloc` は `Navigator` を直接操作しない
- Widget から Repository を直接呼び出し禁止
- `dynamic` 型使用禁止
- `!`（null assertion）乱用禁止
- `switch` の `default` によるコンパイル回避禁止

---

## 16. SwiftUI版との対応

| Flutter Feature | 対応 SwiftUI Reducer |
|---|---|
| `TransSettingBloc` | `TransSettingReducer` |
| `TransSettingDetailBloc` | `TransSettingDetailReducer` |

**リファクタリング事項**
- SwiftUI版では `TransSettingReducer` 内に `@Presents var detail` としてネストされていた
- Flutter版では `TransSettingBloc` と `TransSettingDetailBloc` を独立したクラスとして分離し、go_router でナビゲーションを管理する
- SwiftUI版の `addTransTapped` / `startCreate` は Flutter版では `TransSettingAddTapped` に統合する

---

# End of TransSetting Feature Spec
