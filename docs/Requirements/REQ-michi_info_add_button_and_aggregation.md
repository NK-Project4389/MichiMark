# 要件書: MichiInfo追加ボタン改善・集計ページ整理

**ID**: REQ-michi_info_add_button_and_aggregation
**日付**: 2026-04-09
**ステータス**: 承認済み

---

## 背景

- 移動コスト可視化の概要タブ（MovingCostOverviewView）に時間セクション（移動時間・作業時間・休憩時間・滞留時間）が残っている
- MichiInfoの追加FABがテーマのプライマリカラー（紫）になっており、トピックのテーマカラーと一致していない
- 旅費可視化（travelExpense）のMichiInfoで追加FABを押すと選択肢1つのみのボトムシートが表示されるが、ユーザーの操作として無駄な1タップが発生している
- シードデータ「近所のドライブ」にトピック設定がなく、TopicConfig.fromTopicTypeがnullフォールバックを使用している

---

## 要件

### REQ-001: 移動コスト概要タブ 時間セクション削除

**対象ファイル**: `flutter/lib/features/overview/view/moving_cost_overview_view.dart`

- `MovingCostOverviewView` の「時間」セクション全体を削除する
  - `_SectionTitle(title: '時間')`
  - 移動時間・作業時間・休憩時間・滞留時間の `_InfoRow` 4行
  - セクション間の `SizedBox(height: 16)` も整合性を保つよう調整
- 残す項目: 「距離」セクション（総走行距離）、「費用」セクション（給油量・ガソリン代・経費合計）
- **時間データのProjection・Bloc計算ロジック（MovingCostOverviewProjection等）は削除しない**（将来の別トピック用に資源として残す）

### REQ-002: MichiInfo 追加FABのカラーをTopicConfigのテーマカラーに合わせる

**対象ファイル**:
- `flutter/lib/domain/topic/topic_theme_color.dart`
- `flutter/lib/features/michi_info/view/michi_info_view.dart`

- `TopicThemeColor` に `Color get primaryColor` getter を追加する
  - `emeraldGreen` → `Color(0xFF2D6A6A)`（既存の `_markPrimaryColor` と同色）
  - `amberOrange` → `Color(0xFFF09000)`
  - その他の色も将来追加できるよう全enumに定義
- `FloatingActionButton.extended` に以下を設定:
  - `backgroundColor: widget.topicConfig.themeColor.primaryColor`
  - `foregroundColor: Colors.white`（アイコン・テキスト色固定）

### REQ-003: TopicConfigの追加メニュー項目を配列管理し、遷移を自動制御

**対象ファイル**:
- `flutter/lib/domain/topic/topic_config.dart`
- `flutter/lib/features/michi_info/view/michi_info_view.dart`

#### 設計方針

追加FABのメニュー項目（Mark追加 / Link追加）をTopicConfigで配列として定義する。
これにより3種類のパターンをトピック設定のみで制御できる:

| `addMenuItems` の値 | 動作 |
|---|---|
| `[mark, link]` | ボトムシートに「地点を追加」「区間を追加」の両方を表示 |
| `[mark]` | ボトムシートなし、直接MarkDetailへ遷移 |
| `[link]` | ボトムシートなし、直接LinkDetailへ遷移 |
| `[]` | FABを非表示にする |

#### `AddMenuItemType` enum 追加

```dart
/// MichiInfoの追加FABメニューに表示できる項目の種別
enum AddMenuItemType { mark, link }
```

格納場所: `flutter/lib/domain/topic/topic_config.dart`（同ファイル内 or 別ファイル）

#### TopicConfig フィールド変更

- 既存の `allowLinkAdd: bool` を **`addMenuItems: List<AddMenuItemType>`** に置き換える
- movingCost: `addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link]`
- travelExpense: `addMenuItems: [AddMenuItemType.mark]`
- `allowLinkAdd` を参照していた既存コードは `addMenuItems.contains(AddMenuItemType.link)` に更新する

#### MichiInfoView の追加ボタン制御

```dart
void _onAddPressed(BuildContext context) {
  final items = widget.topicConfig.addMenuItems;
  if (items.isEmpty) return; // FABが表示されないはずだが安全のため
  if (items.length == 1) {
    // 1種類のみ → メニューなしで直接遷移
    if (items.first == AddMenuItemType.mark) {
      context.read<MichiInfoBloc>().add(const MichiInfoAddMarkPressed());
    } else {
      context.read<MichiInfoBloc>().add(const MichiInfoAddLinkPressed());
    }
  } else {
    // 複数 → ボトムシートでユーザーに選択させる
    _showAddMenu(context, items);
  }
}
```

- FABの表示自体も `addMenuItems.isEmpty` のときは非表示にする

### REQ-004: シードデータ「近所のドライブ」にトピック設定追加

**対象ファイル**: `flutter/lib/repository/impl/in_memory/seed_data.dart`

- `_event3`（近所のドライブ）に `topicType: TopicType.movingCost` を明示的に追加する

---

## 非機能要件

- `TopicConfig.props` に `addMenuItems` を追加する（`allowLinkAdd` を削除）
- `TopicThemeColor.primaryColor` getter をすべての enum 値に定義する（未定義のまま残さない）

---

## スコープ外

- 時間データのProjection・Bloc計算ロジックは今回削除しない（将来のトピック追加時に使用）
- 3種類以上の追加メニュー項目には対応しない（Mark/Linkの2種類のみ）
