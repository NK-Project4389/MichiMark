# 2026-03-30 EventDetail全タブ一括保存実装

## 完了した作業

### 実装（flutter-dev）§17

**`event_detail_event.dart`**
- `EventDetailSaveRequested` イベント追加
  - `eventId: String`、`basicInfoDraft: BasicInfoDraft` を受け取る

**`event_detail_state.dart`**
- `EventDetailSavedDelegate` 追加
- `EventDetailLoaded` に `isSaving: bool`、`saveErrorMessage: String?` フィールド追加

**`event_detail_bloc.dart`**
- `_onSaveRequested` ハンドラ追加
  - 既存ドメインを fetch → BasicInfoDraft からフィールドを適用 → EventDomain を直接構築（copyWith非使用・nullable clearに対応）
  - `markLinks` / `payments` / `isDeleted` / `createdAt` は既存ドメインから保持
  - 保存成功 → `EventDetailSavedDelegate` を emit
  - 保存失敗 → `saveErrorMessage` を emit

**`event_detail_page.dart`**
- `_EventDetailScaffold` AppBar に保存ボタン（`Icons.check`）追加
  - `BlocBuilder<BasicInfoBloc>` で BasicInfo がロード済みのときのみ有効
  - 保存中（`isSaving: true`）はインジケーター表示
- `_handleDelegate` に `EventDetailSavedDelegate` ケース追加（SnackBar「保存しました」）
- `saveErrorMessage` 非null時にエラーSnackBar表示

---

## 設計メモ

- 保存ボタンは `_EventDetailScaffold`（MultiBlocProvider の内側）に配置
  → `context.read<BasicInfoBloc>()` が利用可能なスコープ
- `EventDomain.copyWith` はnullableフィールドをnullにできないため、直接コンストラクタで構築
- kmPerGasInput → int変換: `(double.parse(input) * 10).round()`
- pricePerGasInput → int変換: `int.tryParse(input)`

---

## 次回やること

1. InMemory スタブへのテストデータ投入（seed data）
2. drift Repository 実装（永続化）
3. get_it DI セットアップ
