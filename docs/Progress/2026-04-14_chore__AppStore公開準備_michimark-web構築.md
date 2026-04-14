# 2026-04-14 AppStore公開準備 michimark-web構築

## 完了した作業

### 未使用変数・関数の警告修正
- `gas_payer_chip_test.dart`: `hasGasPayerChips`・`hasGasPayerChipSection` 関数削除・`gasPayerSection` 変数削除
- `michi_info_layout_test.dart`: `okutamaText` 変数削除
- `payment_info_fab_color_test.dart`: `fabLabel` 変数削除

### REL-1: AppStore公開準備 置き場所構築（T-260a〜c）
- `michimark-web` パブリックリポジトリ作成（GitHub: NK-Project4389/michimark-web）
- Vercelデプロイ設定完了 → https://michimark-web.vercel.app
- `privacy.html` 作成 → https://michimark-web.vercel.app/privacy.html
- `support.html` 作成 → https://michimark-web.vercel.app/support.html
- `index.html` 作成（トップページ）

### 方針確認
- AppStore初回リリース：全機能開放・無料版
- 今後のサブスク追加は次期機能追加で順次対応
- Web資材（LP・招待ページ等）は michimark-web に集約

## 未完了

- T-260d: App Store Connect 基本情報入力
- T-260e: アプリ説明文・キーワード作成
- T-260f: スクリーンショット撮影・登録
- T-260g: 全件 Integration Test フルスイート PASS（UI-8完了待ち）
- T-260h: 本番ビルド → TF最終確認 → 審査提出

## 次回セッションで最初にやること

1. **T-260d**: App Store Connect を開いてアプリ基本情報（カテゴリ・価格・プライバシーポリシーURL・サポートURL）を入力する
2. **T-260e**: アプリ説明文・キーワードを作成する
3. UI-8（イベント追加スキップ遷移）の完了状況を確認し、全件テスト実行へ進む
