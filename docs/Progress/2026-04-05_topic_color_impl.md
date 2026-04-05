# 進捗: REQ-007/008 トピックテーマカラー実装

日付: 2026-04-05
担当: flutter-dev（T-055）

---

## 完了した作業

### T-055: EventListカード色・EventDetailテーマカラー 実装（REQ-007・REQ-008）

#### 1. TopicThemeColor enum 新規作成
- `flutter/lib/domain/topic/topic_theme_color.dart`
- 10色 × primaryColor / darkColor / tintColor の3値を定義
- `defaultBorderColor`（グレー `Color(0xFF9E9E9E)`）を static プロパティとして追加
- `darkColor`: HSL輝度 × 0.75 で算出
- `tintColor`: `withValues(alpha: 0.15)` で算出

#### 2. TopicConfig 更新
- `themeColor: TopicThemeColor` フィールド追加
- `displayName: String` フィールド追加
- `forType()` static メソッド追加（エイリアス）
- movingCost: themeColor=emeraldGreen, displayName='移動コスト可視化'
- travelExpense: themeColor=amberOrange, displayName='旅費可視化'

#### 3. TopicDomain 更新
- `color: String?` フィールド追加
- `themeColor` getter 追加（color → TopicThemeColor 解決、フォールバックあり）

#### 4. SeedData 更新
- movingCost: color = 'emeraldGreen'
- travelExpense: color = 'amberOrange'

#### 5. EventListProjection 更新
- `EventSummaryItemProjection` に `themeColor: TopicThemeColor?` を追加

#### 6. EventListAdapter 更新
- `event.topic?.themeColor` を Projection に渡すように更新

#### 7. EventListPage 更新（REQ-007）
- `_EventListItem` のカードに左ボーダー（幅4dp）を追加
- Topic設定済み: `themeColor.primaryColor` でボーダー表示
- Topic未設定: `TopicThemeColor.defaultBorderColor`（グレー）でボーダー表示

#### 8. EventDetailState 更新
- `topicThemeColor: TopicThemeColor?` フィールド追加
- `topicDisplayName: String?` フィールド追加

#### 9. EventDetailBloc 更新
- `_resolveThemeColor()` / `_resolveDisplayName()` ヘルパーメソッド追加
- `EventDetailStarted` 処理時に topicThemeColor / topicDisplayName を解決してStateに設定

#### 10. EventDetailPage 更新（REQ-008）
- `_EventDetailScaffold` / `_EventDetailScaffoldInner` に topicThemeColor / topicDisplayName を追加
- `_buildAppBar()` メソッドを追加
  - Topic設定済み: LinearGradient（darkColor → primaryColor）を AppBar に適用
  - Topic設定済み: トピック名サブラベルを白テキストで表示
  - Topic未設定: デフォルトAppBar表示

---

## 未完了

なし（T-055完了）

---

## 次回セッションで最初にやること

- T-052: Topic・Action再定義 レビュー（IN_PROGRESS中）の継続確認
- T-020: EventList Feature 実装（TODO）
- T-021: イベント新規作成フロー実装（TODO）

---

## 変更ファイル一覧

| ファイル | 変更種別 |
|---|---|
| `flutter/lib/domain/topic/topic_theme_color.dart` | 新規作成 |
| `flutter/lib/domain/topic/topic_config.dart` | themeColor・displayName追加 |
| `flutter/lib/domain/topic/topic_domain.dart` | color・themeColor getter追加 |
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | Topic color追加 |
| `flutter/lib/features/event_list/projection/event_list_projection.dart` | themeColor追加 |
| `flutter/lib/adapter/event_list_adapter.dart` | themeColor Projection追加 |
| `flutter/lib/features/event_list/view/event_list_page.dart` | 左ボーダー適用 |
| `flutter/lib/features/event_detail/bloc/event_detail_state.dart` | topicThemeColor・topicDisplayName追加 |
| `flutter/lib/features/event_detail/bloc/event_detail_bloc.dart` | themeColor・displayName解決処理追加 |
| `flutter/lib/features/event_detail/view/event_detail_page.dart` | AppBarグラデーション適用 |
