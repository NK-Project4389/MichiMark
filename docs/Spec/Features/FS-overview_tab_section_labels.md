# Feature Spec: 概要タブ セクション名追加

- **Spec ID**: FS-overview_tab_section_labels
- **作成日**: 2026-04-12
- **担当**: architect
- **要件**: docs/Requirements/REQ-overview_tab_section_labels.md
- **対象タスク**: T-265 / T-266a / T-266b

---

## 1. 概要

概要タブの `_OverviewTabContent` に「基本情報」「集計」のセクション名ラベルを追加する。
変更は `event_detail_page.dart` の `_OverviewTabContent` ウィジェット内のみ。Bloc・State・Repository の変更なし。

---

## 2. 変更対象ファイル

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/event_detail/view/event_detail_page.dart` | `_OverviewTabContent.build()` にセクションラベルを追加 |

---

## 3. 変更仕様

### 現状

```dart
class _OverviewTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BasicInfoView(),
          Divider(height: 1),
          EventDetailOverviewPage(),
        ],
      ),
    );
  }
}
```

### 変更後

```dart
class _OverviewTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(key: const Key('overview_sectionLabel_basicInfo'), label: '基本情報'),
          const BasicInfoView(),
          const Divider(height: 1),
          _SectionLabel(key: const Key('overview_sectionLabel_overview'), label: '集計'),
          const EventDetailOverviewPage(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

## 4. ウィジェットキー一覧

| キー | 用途 |
|---|---|
| `Key('overview_sectionLabel_basicInfo')` | 「基本情報」ラベル検索用 |
| `Key('overview_sectionLabel_overview')` | 「集計」ラベル検索用 |

---

## 5. テストシナリオ

| TC-ID | シナリオ | 手順 | 期待結果 |
|---|---|---|---|
| TC-OSL-001 | 「基本情報」ラベルが表示される | 概要タブを開く | `Key('overview_sectionLabel_basicInfo')` を持つウィジェットが存在し、テキストが「基本情報」 |
| TC-OSL-002 | 「集計」ラベルが表示される | 概要タブを開く | `Key('overview_sectionLabel_overview')` を持つウィジェットが存在し、テキストが「集計」 |
