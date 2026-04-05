# ActionSetting Feature Specification

Platform: Flutter / Dart
Version: 2.0
Category: Settings Feature

## 改版履歴

| バージョン | 日付 | 変更概要 |
|---|---|---|
| 1.0 | 初版 | ActionSetting Feature 初期設計 |
| 2.0 | 2026-04-05 | REQ-003・004・005対応。UI非表示化・fromState廃止・needsTransition追加 |

---

## 1. Purpose

行動イベント（Action）のマスタデータを一覧表示・追加・編集するFeature。

> **[v2.0 REQ-003]** SettingsPageからActionSetting画面への導線を **一時非表示** にする。コード・Router・BloC・Repositoryは削除しない。将来フェーズで再公開可能なよう実装を維持する。

---

## 2. Scope

**含むもの**
- Action一覧表示（実装維持・UI導線のみ非表示）
- Action既存編集（名前・toState・isToggle・needsTransition）
- バリデーション（名前必須）
- 保存成功後の一覧へ戻る

**含まないもの**
- Action物理削除（論理削除のみ）
- Actionの並び順変更
- Navigation管理（Delegateで通知のみ）
- SettingsPageからActionSettingへの導線（REQ-003で非表示化）
- fromState設定UI（REQ-004で廃止）

---

## 3. Feature Structure

```
ActionSettingFeature
 ├ ActionSettingBloc（一覧管理）
 └ ActionSettingDetailBloc（詳細編集）
```

---

## 4. Draft Model（v2.0 / REQ-004・005対応）

### ActionSettingDetailDraft

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `actionName` | `String` | 行動名（必須・空欄不可） | 変更なし |
| `isVisible` | `bool` | 表示設定（true=表示） | 変更なし |
| `fromState` | `ActionState?` | 遷移前の状態 | **廃止**（REQ-004） |
| `toState` | `ActionState?` | 遷移後の状態 | 変更なし（ActionTime_Specより引き継ぎ） |
| `isToggle` | `bool` | トグル型かどうか | 変更なし |
| `togglePairId` | `String?` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | 状態遷移フラグ（デフォルト: `true`） | **新規追加**（REQ-005） |

---

## 5. Projection Model（v2.0）

### ActionItemProjection（変更なし）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `id` | `String` | Action ID（UUID文字列） |
| `actionName` | `String` | 行動名 |
| `isVisible` | `bool` | 表示設定 |

### ActionSettingDetailProjection（v2.0 / REQ-004・005対応）

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `actionName` | `String` | 行動名表示文字列 | 変更なし |
| `isVisible` | `bool` | 表示フラグ | 変更なし |
| `fromStateLabel` | `String?` | fromStateの表示文字列 | **廃止**（REQ-004） |
| `toStateLabel` | `String?` | toStateの表示文字列（未設定時は「変化なし」） | 変更なし |
| `isToggle` | `bool` | トグル表示用フラグ | 変更なし |
| `togglePairId` | `String?` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | 状態遷移フラグ | **新規追加**（REQ-005） |

---

## 6. Domain Model（v2.0）

`ActionDomain`（`docs/Domain/ActionDomain.md` 参照・`ActionTime_Spec.md §2.2` 参照）

| フィールド名 | Dart型 | 備考 | 変更 |
|---|---|---|---|
| `id` | `String` | UUID文字列 | 変更なし |
| `actionName` | `String` | 行動名 | 変更なし |
| `isVisible` | `bool` | 表示設定 | 変更なし |
| `isDeleted` | `bool` | 論理削除フラグ | 変更なし |
| `createdAt` | `DateTime` | 初回登録時に設定 | 変更なし |
| `updatedAt` | `DateTime` | 保存時に更新 | 変更なし |
| `fromState` | `ActionState?` | 遷移前状態 | **廃止**（REQ-004） |
| `toState` | `ActionState?` | 遷移後状態 | 変更なし |
| `isToggle` | `bool` | トグル型フラグ | 変更なし |
| `togglePairId` | `String?` | 対ActionのID | 変更なし |
| `needsTransition` | `bool` | 状態遷移フラグ（デフォルト: `true`） | **新規追加**（REQ-005） |

---

## 7. Events（v2.0）

### ActionSettingBloc（変更なし）

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `ActionSettingStarted` | 画面表示時 | Repository から fetchAll → `items` 更新 |
| `ActionSettingItemSelected` | 一覧アイテムタップ | `ActionSettingOpenDetailDelegate` を発火 |
| `ActionSettingAddTapped` | 追加ボタンタップ | `ActionSettingOpenNewDelegate` を発火 |

### ActionSettingDetailBloc（v2.0）

| Event名 | 発火タイミング | 説明 | 変更 |
|---|---|---|---|
| `ActionSettingDetailStarted` | 画面表示時 | actionId が null なら空 Draft 生成。非 null なら fetch → Draft 生成 | 変更なし |
| `ActionSettingDetailNameChanged` | 名前入力変更時 | Draft の actionName を更新 | 変更なし |
| `ActionSettingDetailIsVisibleChanged` | 表示フラグ変更時 | Draft の isVisible を更新 | 変更なし |
| `ActionSettingDetailFromStateChanged` | fromState選択時 | Draft の fromState を更新 | **廃止**（REQ-004） |
| `ActionSettingDetailToStateChanged` | toState選択時 | Draft の toState を更新 | 変更なし |
| `ActionSettingDetailIsToggleChanged` | トグルスイッチ変更時 | Draft の isToggle を更新 | 変更なし |
| `ActionSettingDetailNeedsTransitionChanged` | needsTransitionスイッチ変更時 | Draft の needsTransition を更新 | **新規追加**（REQ-005） |
| `ActionSettingDetailSaveTapped` | 保存ボタンタップ | バリデーション → Delegate発火 | 変更なし |
| `ActionSettingDetailBackTapped` | 戻るボタンタップ | `ActionSettingDetailDismissDelegate` を発火 | 変更なし |
| `ActionSettingDetailSavingFinished` | 保存完了通知 | `ActionSettingDetailDidSaveDelegate` を発火 | 変更なし |
| `ActionSettingDetailSaveFailed` | 保存エラー通知 | `saveErrorMessage` をセット | 変更なし |

---

## 8. State Structure（v2.0）

### ActionSettingState（変更なし）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `items` | `List<ActionItemProjection>` | Action一覧表示用データ |
| `delegate` | `ActionSettingDelegate?` | 遷移意図の通知 |

### ActionSettingDetailState（v2.0）

| フィールド名 | Dart型 | 説明 | 変更 |
|---|---|---|---|
| `actionId` | `String` | 対象ActionのID | 変更なし |
| `draft` | `ActionSettingDetailDraft` | 編集中データ（fromState削除・needsTransition追加） | 構造変更（REQ-004・005） |
| `projection` | `ActionSettingDetailProjection` | 表示用データ（fromStateLabel削除・needsTransition追加） | 構造変更（REQ-004・005） |
| `validationError` | `String?` | バリデーションエラーメッセージ | 変更なし |
| `saveErrorMessage` | `String?` | 保存エラーメッセージ | 変更なし |
| `isSaving` | `bool` | ローディング中フラグ | 変更なし |
| `delegate` | `ActionSettingDetailDelegate?` | 遷移意図の通知 | 変更なし |

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

## 10. Bloc Responsibility（v2.0）

### ActionSettingBloc（変更なし）
- `ActionSettingStarted`: Repository から fetchAll → `items` 更新
- `ActionSettingItemSelected`: `ActionSettingOpenDetailDelegate` を発火
- `ActionSettingAddTapped`: `ActionSettingOpenNewDelegate` を発火

### ActionSettingDetailBloc（v2.0）
- `ActionSettingDetailStarted`: actionId が null なら空 Draft 生成。非 null なら Repository から fetch → Draft 生成
- `*Changed` イベント: Draft 更新・バリデーション実行
- `ActionSettingDetailFromStateChanged`: **廃止**（REQ-004）
- `ActionSettingDetailNeedsTransitionChanged`: Draft の needsTransition を更新（REQ-005）
- `ActionSettingDetailSaveTapped`: バリデーション → 通過なら `ActionSettingDetailSaveRequestedDelegate` を発火・`isSaving = true`
- `ActionSettingDetailSavingFinished`: `isSaving = false` → `ActionSettingDetailDidSaveDelegate` を発火
- `ActionSettingDetailSaveFailed`: `isSaving = false` → `saveErrorMessage` をセット
- `ActionSettingDetailBackTapped`: `ActionSettingDetailDismissDelegate` を発火

### REQ-003 実装指示

- SettingsPageの「行動」行は非表示にする（**UIレベルの非表示のみ**）
- ActionSettingBloc・ActionSettingDetailBloc・Router定義・Repository は削除しない
- ActionSeedData（出発・到着）のアプリ起動時自動投入は維持する（ActionSetting経由での編集不可）

### 影響するクラス・ファイル（REQ-003）

| ファイル | 変更内容 |
|---|---|
| `features/settings/view/settings_page.dart` | 「行動」`_SettingsRow` の表示を `false` にする（コメントアウトまたは条件分岐） |

### 影響するクラス・ファイル（REQ-004・005）

| ファイル | 変更内容 |
|---|---|
| `features/settings/action_setting/draft/action_setting_detail_draft.dart` | `fromState` 削除・`needsTransition` 追加 |
| `features/settings/action_setting/projection/action_setting_detail_projection.dart` | `fromStateLabel` 削除・`needsTransition` 追加 |
| `features/settings/action_setting/bloc/action_setting_detail_event.dart` | `ActionSettingDetailFromStateChanged` 削除・`ActionSettingDetailNeedsTransitionChanged` 追加 |
| `features/settings/action_setting/bloc/action_setting_detail_bloc.dart` | fromState処理削除・needsTransition処理追加 |
| `features/settings/action_setting/view/action_setting_detail_page.dart` | fromState設定UI削除・needsTransition設定UI追加 |

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
