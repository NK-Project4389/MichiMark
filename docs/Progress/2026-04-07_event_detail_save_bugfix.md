# 進捗記録: イベント詳細画面 保存バグ修正

- 作成日: 2026-04-07
- セッション: EventDetail保存バグ調査・修正

---

## バグの根本原因

### Bug 1（主因）: `BasicInfoBloc` タグ系イベントハンドラ未登録

**ファイル**: `lib/features/basic_info/bloc/basic_info_bloc.dart`

以下の4イベントが `BasicInfoEvent` に定義済み・View で使用済みにもかかわらず、`BasicInfoBloc` のコンストラクタに `on<>()` 登録が漏れていた。

- `BasicInfoTagInputChanged`
- `BasicInfoTagSuggestionSelected`
- `BasicInfoTagInputConfirmed`
- `BasicInfoTagRemoved`

**影響**: flutter_bloc v9 のデバッグモードでは、未登録イベントを `add()` すると `assert` により `StateError` がスローされてアプリがクラッシュ。タグ入力フィールドに触れた瞬間にクラッシュするため、保存ボタンに辿り着けなかった。

**修正内容**:
- `TagRepository` 依存を追加（コンストラクタ引数・フィールド）
- `_onStarted` で `allTags = await _tagRepository.fetchAll()` をロードして `BasicInfoLoaded` に渡す
- 4つのハンドラを登録・実装:
  - `_onTagInputChanged`: 入力文字列で `allTags` をフィルタして `tagSuggestions` を更新
  - `_onTagSuggestionSelected`: サジェストからタグを追加・候補クリア
  - `_onTagInputConfirmed`: 完全一致 → 既存タグ追加。不一致 → 新規タグ作成・DB保存
  - `_onTagRemoved`: 選択済みタグを削除

### Bug 2（副次）: `EventDetailBloc` 保存時に `actionTimeLogs` が消失

**ファイル**: `lib/features/event_detail/bloc/event_detail_bloc.dart`

`_onSaveRequested` で `EventDomain` を再構築する際に `actionTimeLogs` フィールドを渡し忘れており、保存のたびに `[]` にリセットされていた。

**修正**: `actionTimeLogs: existing.actionTimeLogs` を追加。

### 補足: `_EventDetailScaffold` の DI 更新

**ファイル**: `lib/features/event_detail/view/event_detail_page.dart`

`BasicInfoBloc` 生成時に `tagRepository: getIt<TagRepository>()` を追加。

---

## 完了した作業

- Bug 1 修正 (基本画面タグ操作クラッシュ)
- Bug 2 修正 (保存時 actionTimeLogs 消失)
- DI 更新
- dart analyze エラー 0 確認
- コミット・プッシュ

---

## 未完了

- Drift実装への切り替え（DI は InMemory のまま）
- T-052 レビューは別セッション

---

## 次回セッションで最初にやること

1. **動作確認**: タグ追加・削除→保存が正しく動くか実機/シミュレータで確認
2. **T-052: Topic・Action再定義 レビュー**（設計憲章に沿っているか）

---
