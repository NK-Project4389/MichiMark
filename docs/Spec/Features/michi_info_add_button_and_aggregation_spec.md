# Feature Spec: MichiInfo追加ボタン改善・集計ページ整理

**ID**: SPEC-michi_info_add_button_and_aggregation
**要件書**: REQ-michi_info_add_button_and_aggregation
**日付**: 2026-04-09
**ステータス**: 確定

---

# 1. Feature Overview

## Feature Name

MichiInfo追加ボタン改善・MovingCostOverview整理

## Purpose

以下4点を一括対応し、UIの操作性とトピック設定の一貫性を向上させる。

1. MovingCostOverviewViewの時間セクションを非表示にする
2. MichiInfoのFABカラーをTopicConfigのテーマカラーに合わせる
3. TopicConfigの追加メニュー項目を `addMenuItems` 配列で管理し、FAB動作を自動制御する
4. シードデータ「近所のドライブ」にTopicTypeを明示する

## Scope

含むもの
- `MovingCostOverviewView` の時間セクション行（UI表示のみ）削除
- `TopicThemeColor.primaryColor` getter のFABへの適用
- `AddMenuItemType` enum 新規定義
- `TopicConfig.allowLinkAdd` を `addMenuItems: List<AddMenuItemType>` へ置き換え
- `michi_info_view.dart` の FAB制御ロジック変更
- シードデータ `_event3` への `topicType` 追加

含まないもの
- `MovingCostOverviewProjection` や Bloc の時間計算ロジック削除（将来用に保持）
- 3種類以上の追加メニュー項目への対応
- 時間セクションの別トピックでの再利用設計

---

# 2. 変更対象ファイル一覧

| ファイル | 変更種別 |
|---|---|
| `flutter/lib/domain/topic/topic_config.dart` | フィールド変更・enum追加 |
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | FABカラー適用・FAB制御ロジック変更 |
| `flutter/lib/features/overview/view/moving_cost_overview_view.dart` | 時間セクション表示削除 |
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | `_event3` にtopicType追加 |

---

# 3. 変更詳細

## 3-1. MovingCostOverviewView 時間セクション削除

**対象**: `flutter/lib/features/overview/view/moving_cost_overview_view.dart`

`MovingCostOverviewView.build()` の children から以下を削除する。

削除対象:
- `_SectionTitle(title: '時間')`
- `_InfoRow(label: '移動時間', value: projection.movingTimeLabel)`
- `_InfoRow(label: '作業時間', value: projection.workingTimeLabel)`
- `_InfoRow(label: '休憩時間', value: projection.breakTimeLabel)`
- `_InfoRow(label: '滞留時間', value: projection.waitingTimeLabel)`
- 時間セクション直後の `SizedBox(height: 16)`

残す項目（変更しない）:
- 距離セクション（`_SectionTitle(title: '距離')` + `総走行距離`行）
- 費用セクション（`_SectionTitle(title: '費用')` + `給油量` / `ガソリン代` / `経費合計`行）

**注意**: `MovingCostOverviewProjection` の時間フィールド（`movingTimeLabel` 等）および Bloc の計算ロジックは削除しない。

---

## 3-2. TopicThemeColor.primaryColor の FAB への適用

**対象**: `flutter/lib/features/michi_info/view/michi_info_view.dart`

### 現状確認

`TopicThemeColor` には既に `Color get primaryColor` getter が全 enum 値に定義済み（実装不要）。

要件書の「getter追加」記述は現行コードでは不要。FABへの適用のみ実装する。

### FAB の変更

現在の FAB（2箇所、空リスト時と通常時の両方）に以下を追加する。

- `backgroundColor: widget.topicConfig.themeColor.primaryColor`
- `foregroundColor: Colors.white`

---

## 3-3. TopicConfig: addMenuItems 導入

**対象**: `flutter/lib/domain/topic/topic_config.dart`

### AddMenuItemType enum 定義

同ファイル内（`TopicConfig` クラスの上）に定義する。

| 値 | 意味 |
|---|---|
| `mark` | 地点（Mark）追加メニュー項目 |
| `link` | 区間（Link）追加メニュー項目 |

### TopicConfig フィールド変更

| 変更前 | 変更後 |
|---|---|
| `final bool allowLinkAdd` | `final List<AddMenuItemType> addMenuItems` |

コンストラクタも合わせて変更する。

### TopicConfig.fromTopicType の addMenuItems 設定値

| TopicType | addMenuItems |
|---|---|
| `movingCost` | `[AddMenuItemType.mark, AddMenuItemType.link]` |
| `travelExpense` | `[AddMenuItemType.mark]` |

### TopicConfig.props 変更

`allowLinkAdd` を props リストから削除し、`addMenuItems` を追加する。

---

## 3-4. MichiInfoView FAB制御ロジック変更

**対象**: `flutter/lib/features/michi_info/view/michi_info_view.dart`

### FAB 表示制御

`addMenuItems.isEmpty` のとき、FAB を非表示にする。
- 空リスト時の Scaffold では `floatingActionButton` を `null` にする。
- 通常時の Scaffold でも同様。

### onPressed ロジック変更

現在の `onPressed: () => _showAddMenu(context)` を `onPressed: () => _onAddPressed(context)` に変更する。

`_onAddPressed` の振る舞いは以下の通り。

| `addMenuItems` の要素数 | 動作 |
|---|---|
| 0 | 何もしない（FABが非表示のため到達しない想定だが安全ガード） |
| 1 かつ `mark` | `MichiInfoBloc` に `MichiInfoAddMarkPressed` を add |
| 1 かつ `link` | `MichiInfoBloc` に `MichiInfoAddLinkPressed` を add |
| 2（mark と link） | `_showAddMenu` を呼び出してボトムシートを表示 |

### _showAddMenu の変更

ボトムシート内の「区間を追加」`ListTile` の表示条件を変更する。

| 変更前 | 変更後 |
|---|---|
| `if (widget.topicConfig.allowLinkAdd)` | `if (widget.topicConfig.addMenuItems.contains(AddMenuItemType.link))` |

---

## 3-5. シードデータ修正

**対象**: `flutter/lib/repository/impl/in_memory/seed_data.dart`

`_event3`（近所のドライブ）に以下を追加する。

- `topic: seedTopics[0]`（移動コスト可視化トピック）

現在 `_event3` は `topic` フィールドを持たず（`TopicConfig.fromTopicType` が null フォールバックを使用している）、明示的に `movingCost` を設定する。

---

# 4. Data Flow

変更による追加データフローはなし。既存の MichiInfoBloc / MichiInfoState / Delegate は変更しない。

FAB制御ロジックのフロー（変更後）:

- Widget が `topicConfig.addMenuItems` を参照して FAB 表示／非表示を決定する
- FAB タップ → `_onAddPressed` → items 数に応じて `MichiInfoBloc` に Event を add、またはボトムシート表示
- Bloc が Delegate を State に乗せ → BlocListener が `context.go()` で遷移

---

# 5. 既存コードの更新箇所（影響分析）

## allowLinkAdd を参照している箇所

| ファイル | 行 | 変更内容 |
|---|---|---|
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | L634 | `allowLinkAdd` → `addMenuItems.contains(AddMenuItemType.link)` |
| `flutter/lib/domain/topic/topic_config.dart` | コンストラクタ・fromTopicType・props | フィールド置換 |

他ファイルでの `allowLinkAdd` 参照は実装前に `Grep` で確認すること。

---

# 6. 非機能要件

- `TopicConfig` は `Equatable` を継承しているため、`props` の変更を忘れずに行う
- `AddMenuItemType` は Dart 標準 enum として定義する（Equatable 不要）
- `switch` に `default` を追加してコンパイルを通すことは禁止（設計憲章 §14.6）

---

# 7. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- シードデータが読み込まれた状態でアプリが起動していること
- シードデータには以下が存在する:
  - `event-001`（箱根日帰りドライブ）: `movingCost` トピック、addMenuItems = [mark, link]
  - `event-002`（富士五湖キャンプ）: `travelExpense` トピック、addMenuItems = [mark]
  - `event-003`（近所のドライブ）: `movingCost` トピック（本Spec対応後）

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MAB-001 | movingCost FABタップでボトムシート表示（地点・区間の両方） | High |
| TC-MAB-002 | travelExpense FABタップで直接MarkDetail画面へ遷移 | High |
| TC-MAB-003 | MovingCostOverviewViewに時間セクションが表示されないこと | High |
| TC-MAB-004 | FABのbackgroundColorがテーマカラーと一致すること（目視確認） | Medium |

---

## TC-MAB-001: movingCost FABタップでボトムシート表示

**対象イベント**: `event-001`（箱根日帰りドライブ / movingCost トピック）

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）をタップする

**期待結果:**
- ボトムシートが表示される
- ボトムシート内に「地点を追加」の選択肢が存在する
- ボトムシート内に「区間を追加」の選択肢が存在する

---

## TC-MAB-002: travelExpense FABタップで直接MarkDetail画面へ遷移

**対象イベント**: `event-002`（富士五湖キャンプ / travelExpense トピック）

**操作手順:**
1. アプリを起動する
2. イベント一覧から「富士五湖キャンプ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）をタップする

**期待結果:**
- ボトムシートは表示されない
- MarkDetail 画面（地点追加画面）が直接表示される

---

## TC-MAB-003: MovingCostOverviewViewに時間セクションが表示されないこと

**対象イベント**: `event-001`（箱根日帰りドライブ / movingCost トピック）

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「概要」タブ（Overview）を表示する

**期待結果:**
- 「時間」というセクションタイトルが表示されない
- 「移動時間」「作業時間」「休憩時間」「滞留時間」のラベルが表示されない
- 「距離」セクション（総走行距離）が表示される
- 「費用」セクション（給油量・ガソリン代・経費合計）が表示される

---

## TC-MAB-004: FABのbackgroundColorがテーマカラーと一致すること（目視確認）

**対象イベント**: `event-001`（箱根日帰りドライブ / movingCost / emeraldGreen）

**操作手順:**
1. アプリを起動する
2. イベント一覧から「箱根日帰りドライブ」をタップして EventDetail を開く
3. 「記録」タブ（MichiInfo）を表示する
4. FAB（追加ボタン）の色を目視確認する

**期待結果:**
- FABの背景色が emeraldGreen のプライマリカラー（`Color(0xFF2E9E6B)` 相当のグリーン系）であること
- FABのアイコン・テキスト色が白であること

**備考**: この TC は自動判定が困難なため目視確認項目として記録する。tester は Integration Test として Widget Key を使い FABの存在確認のみ自動化し、色確認は手動確認とする。

---

# End of Feature Spec
