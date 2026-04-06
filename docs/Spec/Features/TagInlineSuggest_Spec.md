# Feature Spec: タグインラインサジェスト入力

**Spec ID**: TagInlineSuggest_Spec
**要件書**: `docs/Requirements/REQ-tag_inline_suggest.md`
**作成日**: 2026-04-07
**ステータス**: 実装済み

---

## 概要

`basic_info` Feature のタグ入力UIを選択画面遷移型からインラインサジェスト型に変更する。
BLoC パターンに従い、入力変化・サジェスト検索・タグ追加・タグ削除を Bloc で管理する。

---

## アーキテクチャ

```
_TagInputSection (View)
  ├── TextEditingController（入力フィールド管理）
  ├── BasicInfoTagInputChanged → BasicInfoBloc._onTagInputChanged
  │     └── allTags から部分一致フィルタリング → tagSuggestions 更新
  ├── BasicInfoTagSuggestionSelected → BasicInfoBloc._onTagSuggestionSelected
  │     └── selectedTags に追加・tagSuggestions クリア
  ├── BasicInfoTagInputConfirmed → BasicInfoBloc._onTagInputConfirmed
  │     ├── 既存マスタ一致 → selectedTags に追加
  │     └── マスタ未存在 → TagRepository.save() → allTags に追加 → selectedTags に追加
  └── BasicInfoTagRemoved → BasicInfoBloc._onTagRemoved
        └── selectedTags から削除
```

---

## Event 定義

```dart
// タグ入力フィールドのテキストが変化したとき
class BasicInfoTagInputChanged extends BasicInfoEvent {
  final String input;
}

// サジェストリストからタグが選択されたとき
class BasicInfoTagSuggestionSelected extends BasicInfoEvent {
  final TagDomain tag;
}

// タグ入力フィールドで確定（新規タグ作成を含む）
class BasicInfoTagInputConfirmed extends BasicInfoEvent {
  final String input;
}

// 選択済みタグが削除されたとき
class BasicInfoTagRemoved extends BasicInfoEvent {
  final TagDomain tag;
}
```

---

## State 変更

`BasicInfoLoaded` に以下フィールドを追加：

```dart
/// タグマスタ全件キャッシュ（サジェスト検索用・画面初期化時に取得）
final List<TagDomain> allTags;

/// 現在表示中のタグサジェスト一覧（入力変化のたびに更新）
final List<TagDomain> tagSuggestions;
```

---

## Bloc 変更

### `BasicInfoBloc` コンストラクタ

```dart
BasicInfoBloc({
  required EventRepository eventRepository,
  required TopicRepository topicRepository,
  required TagRepository tagRepository,   // 追加
})
```

### `_onStarted` 変更

画面初期化時に `tagRepository.fetchAll()` を呼び、`allTags` にキャッシュする。

### `_onTagInputChanged`

```
入力が空 → tagSuggestions = []
入力あり → allTags から部分一致（大小文字区別なし）でフィルタリング
          → 既選択タグを除外
          → tagSuggestions に emit
```

### `_onTagSuggestionSelected`

```
selectedTags に追加（重複チェック不要：サジェストは既選択除外済み）
tagSuggestions = [] に emit
```

### `_onTagInputConfirmed`

```
input.trim() が空 → return
既に selectedTags に同名あり → tagSuggestions = [] に emit して return
allTags に完全一致（大小文字区別なし）あり → 既存タグを使用
  なし → TagDomain を新規作成（Uuid().v4()）→ tagRepository.save() → allTags に追加
selectedTags に追加して emit
```

### `_onTagRemoved`

```
selectedTags から該当タグ（id一致）を除外して emit
```

---

## View 変更

### `_BasicInfoForm`

```dart
// tagSuggestions フィールドを追加
class _BasicInfoForm extends StatelessWidget {
  final List<TagDomain> tagSuggestions;
  ...
}

// builder で tagSuggestions を渡す
BasicInfoLoaded(:final draft, :final topicConfig, :final tagSuggestions) =>
  _BasicInfoForm(draft: draft, topicConfig: topicConfig, tagSuggestions: tagSuggestions),
```

### `_TagInputSection` 新規作成

```
StatefulWidget（TextEditingController を管理）
├── ラベル "タグ"
├── Wrap で選択済みタグを Chip 表示（onDeleted で BasicInfoTagRemoved）
├── TextField
│     onChanged → BasicInfoTagInputChanged
│     onSubmitted → BasicInfoTagInputConfirmed + _clearInput()
└── tagSuggestions が非空のとき Container + ListView.separated でサジェスト表示
      ListTile.onTap → BasicInfoTagSuggestionSelected + _clearInput()
```

---

## DI 変更

`event_detail_page.dart` の `BasicInfoBloc` 生成：

```dart
BlocProvider(
  create: (_) => BasicInfoBloc(
    eventRepository: getIt<EventRepository>(),
    topicRepository: getIt<TopicRepository>(),
    tagRepository: getIt<TagRepository>(),   // 追加
  )..add(BasicInfoStarted(eventId, initialTopicType: initialTopicType)),
),
```

---

## 削除しないもの

- `BasicInfoEditTagsPressed` イベント（コメントで「現在は基本画面から未使用」と明記）
- `BasicInfoTagsSelected` イベント（同上）
- `BasicInfoOpenTagsSelectionDelegate` delegate
- タグ選択画面（`/selection` + `SelectionType.eventTags`）
