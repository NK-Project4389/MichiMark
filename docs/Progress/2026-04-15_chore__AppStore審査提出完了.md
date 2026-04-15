# App Store 審査提出完了

日付: 2026-04-15
担当: orchestrator / marketer

---

## 完了した作業

### App Store公開準備（T-260）
- T-260d: App Store Connect 基本情報入力（アプリ名・カテゴリ・価格・URL）
- T-260e: 説明文・プロモーションテキスト・キーワード入力
- T-260f: スクリーンショット撮影・登録完了
  - iPhone 6.9インチ（1320×2868）5枚アップロード済み
  - マーケター推奨順：イベント一覧→ミチタブ→概要→支払い→給油
  - 保存場所: `docs/AppStore/screenshots/`
- T-260h: 審査提出完了
  - ビルド: 1.0.0 (18)
  - 提出日: 2026年4月15日 9:19
  - 審査ステータス: 審査待ち

### ビルド変更
- iPhone専用ビルドに変更（TARGETED_DEVICE_FAMILY=1・UIDeviceFamily=1）
- iPhoneのみ対応としてiPadスクリーンショット要求を解消

### マーケター / デザイナー成果物
- `.claude/agents/marketer.md` 新規作成
- `docs/Marketing/draft/screenshot_visual_req_2026-04-15.md` 作成
- `docs/Design/DESIGN-appstore-screenshot-2026-04-15.html` デザイン提案

### シードデータ追加
- event-006（伊豆半島ツーリング）/ event-007（大阪出張）/ event-008（京都一泊旅行）追加
- topic-004（ツーリング）/ topic-005（仕事移動）追加
- tag-004〜008・member-004追加

### テスト修正（flutter-devエージェント）
- 全件: 241PASS / 112SKIP / 11FAIL（修正前39FAIL+38FAILから大幅改善）
- 残11FAIL調査中（basic_info_trans_fuel / custom_numeric_keypadで2件特定済み）

---

## 未完了・次回やること

1. **残11件のFAIL修正**（T-260g完了のため必要）
   - basic_info_trans_fuel_test.dart で2件特定済み → 内容確認・修正
   - 全件PASS後にgit push

2. **審査結果待ち**（通常1〜3日）
   - 審査通過 → App Store公開設定
   - リジェクト → 指摘事項に対応して再提出
