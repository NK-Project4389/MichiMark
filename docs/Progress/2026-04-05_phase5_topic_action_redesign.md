# 2026-04-05 Phase 5: Topic・Action 設計再定義 完了

## 完了した作業

### デザイン（designer・product-manager）

- `docs/Design/2026-04-05_topic_color_proposal.html` 作成
  - ロゴカラー（#2B7A9B スチールティール）を起点にした10色パレット設計
- `docs/Design/draft/2026-04-05_topic_color_draft.md` 作成
  - TopicThemeColor enum の Dart実装メモ・architect引き継ぎ情報
- `docs/Requirements/REQ-topic_action_redesign.md` に REQ-007・008 確定カラー情報を追記（ユーザー承認済み）

**確定10色パレット:**
| enum値 | 色名 | HEX |
|---|---|---|
| coralRed | コーラルレッド | #D94F4F |
| amberOrange | アンバーオレンジ | #E07B39 |
| goldenYellow | ゴールデンイエロー | #C4A43A |
| freshGreen | フレッシュグリーン | #4DB36B |
| emeraldGreen | エメラルドグリーン | #2E9E6B |
| tealGreen | ティールグリーン | #1E8A8A |
| brandTeal | ブランドティール | #2B7A9B |
| indigoBlue | インディゴブルー | #3D65C4 |
| violetPurple | バイオレットパープル | #7B5CC4 |
| rosePink | ローズピンク | #C4497A |

- movingCost → emeraldGreen（#2E9E6B）
- travelExpense → amberOrange（#E07B39）

### Spec作成・更新（architect）

- `docs/Spec/Features/Topic_Spec.md` v2.0 → v2.1
  - REQ-001（BasicInfo読み取り専用）・REQ-002（TopicConfig拡張）
  - §20 TopicThemeColor定義・§21 EventListCard適用・§22 EventDetailヘッダー適用 追加
- `docs/Spec/Features/ActionTime_Spec.md` v2.0
  - REQ-002・004・005 対応
- `docs/Spec/Features/System/Settings/ActionSetting_Spec.md` v2.0
  - REQ-003・004・005 対応
- `docs/Spec/Features/System/Settings/SettingsFeature_Spec.md` v2.0
  - REQ-003・006 対応
- `docs/Spec/Features/DriftRepository_Spec.md`
  - needs_transition・topics.color マイグレーション追記

### 実装（flutter-dev）

**REQ-001〜006（38ファイル変更）:**
- BasicInfo Topic → 読み取り専用ラベルに差し替え
- ActionTimeAdapter → TopicConfig.markActions/linkActions 参照に変更
- SettingsPage ActionSetting行削除（Router・BLoC維持）
- ActionDomain.fromState 全面廃止（DBカラム保持）
- needsTransition 追加・schemaVersion 2→3 マイグレーション
- SettingsBloc 新規作成・Delegate パターンで /events 遷移

**REQ-007・008（カラー実装）:**
- `topic_theme_color.dart` 新規作成（10色 × primary/dark/tint）
- TopicConfig に themeColor・displayName 追加
- TopicDomain に color フィールド・themeColor getter 追加
- EventListカード左ボーダー4dp 実装（Projection経由）
- EventDetail AppBar グラデーション + トピック名ラベル実装

### レビュー（reviewer）

- T-052（REQ-001〜006）: **PASS**
- T-055（REQ-007・008）: **PASS**
- 両レビューともアーキテクチャ違反なし・設計憲章完全準拠

---

## 未完了

- T-020: EventList Feature 実装（現状スタブのみ）
- T-021: イベント新規作成フロー（Topic選択ステップ含む）
- T-022: マスターデータ初期投入
- T-023: app_id / Bundle ID / アイコン設定
- REQ-009: TopicSetting（表示/非表示設定）Spec・実装

---

## 次回セッションで最初にやること

1. **実機 or シミュレータで動作確認**
   - EventListカードの左ボーダーカラーが正しく表示されるか
   - EventDetail AppBarのグラデーションとトピック名ラベルが表示されるか
   - ActionTimeのアクション候補が TopicConfig 定義通り表示されるか
   - Settings画面からイベント一覧へ戻れるか

2. **T-020: EventList Feature 実装**（architect → Spec作成 → flutter-dev → reviewer）
   - 現状スタブのみ。新規作成フロー（T-021）の前提

3. **REQ-009: TopicSetting Spec・実装**
   - Settings画面でTopicの表示/非表示を設定できる機能
