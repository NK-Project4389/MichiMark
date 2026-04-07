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
- docs: 進捗記録更新・MichiCanvasLayout 要件書・Spec追加 (8f0a725)
- fix: Xcodeビルドエラー対応（integration_test削除・xcscheme修正） (1e1dd24)
- feat: testerエージェント追加・Integration Test基盤整備 (202578e)
- feat: 割り勘メンバー選択で支払者を常にON固定・非活性化 (9667daa)
- feat: 割り勘メンバー選択で支払者を常にON固定・非活性化 (9667daa)
- docs: MichiInfo Canvas/Path再設計の進捗ファイル追加 (f4d1f41)
- feat: MichiInfo タイムラインUI Canvas/Path ベースに全面再設計 (68af4a1)
- feat: ミチ情報一覧への地点アクションボタン追加 (d85801e)
- fix: UIの表示名を「マーク→地点」「リンク→区間」に変更 (f62cc6c)
- docs: タグインラインサジェスト実装内容を進捗ファイルに追記 (f5fe7b4)

### バグ修正（d15f26c）
- Bug 1 修正: BasicInfoBloc タグ系イベントハンドラ未登録（TagInputChanged/SuggestionSelected/InputConfirmed/Removed）
- Bug 2 修正: EventDetailBloc 保存時 actionTimeLogs 消失
- DI 更新: BasicInfoBloc に TagRepository 注入

### feat: タグインラインサジェスト入力実装（d7f29d7）
- `basic_info_event.dart`: 新イベント4種追加（TagInputChanged/SuggestionSelected/InputConfirmed/TagRemoved）
- `basic_info_state.dart`: `BasicInfoLoaded` に `allTags`・`tagSuggestions` フィールド追加
- `basic_info_view.dart`: タグ行を `_TagInputSection`（インラインサジェスト・Chip表示）に置き換え
- 要件書: `docs/Requirements/REQ-tag_inline_suggest.md`
- Spec: `docs/Spec/Features/TagInlineSuggest_Spec.md`
- dart analyze エラー 0 確認

---

### feat: MichiInfo レイアウト変更 Spec v2.0 実装

- `michi_info_view.dart` を統合 CustomPainter + Stack overlay 型に全面置き換え
- `_MarkGroup` / `_TimelineGroupConnector` / `_BubbleCardPainter` / `_LinkCard` / `_MarkCard` 廃止
- `_TimelineItem` + `_MichiTimelinePainter`（統合 CustomPainter）追加
- `_cardHeight = 72.0` 定数導入・全描画座標を基準値から算出
- 太線判定ロジックを ListView.builder の index から導出
- `_MarkActionButtons` / `_DistanceLegend` / `_DistanceColumn` は維持
- dart analyze エラー・警告 0 確認

---

## 未完了

- Drift実装への切り替え（DI は InMemory のまま）

---

## 次回セッションで最初にやること

1. **動作確認**: MichiInfo タイムライン表示が正しく見えるか実機/シミュレータで確認
2. **タグ追加・削除→保存** が正しく動くか実機/シミュレータで確認
3. **T-010 Phase2動作確認** の継続

---
