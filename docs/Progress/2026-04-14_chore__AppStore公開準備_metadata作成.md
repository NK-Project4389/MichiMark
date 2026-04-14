# App Store公開準備 メタデータ作成

**日付**: 2026-04-14
**担当**: orchestrator

---

## 完了した作業

| タスク | 内容 |
|---|---|
| T-260d | App Store Connect 入力内容まとめ（docs/AppStore/metadata_ja.md） |
| T-260e | アプリ説明文・プロモーションテキスト・キーワード草案作成（docs/AppStore/metadata_ja.md） |

### 作成内容（docs/AppStore/metadata_ja.md）

- **アプリ名**: MichiMark
- **サブタイトル**: ドライブ・旅行の移動ログ＆集計（14文字）
- **カテゴリ**: ナビゲーション / 旅行
- **価格**: 無料
- **プライバシーポリシーURL**: https://michimark-web.vercel.app/privacy.html
- **サポートURL**: https://michimark-web.vercel.app/support.html
- **プロモーションテキスト**: 85文字（170文字以内）
- **説明文**: 日本語・機能紹介＋ユースケース形式
- **キーワード**: 48文字（100文字以内）

### アイコン場所（確認済み）

```
flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
```

---

## 未完了・次回やること

| タスク | 内容 |
|---|---|
| T-260d | App Store Connect に実際に入力する（手動作業・ユーザー実施） |
| T-260f | スクリーンショット撮影・登録（iPhone 6.9インチ必須・6.5インチ推奨） |
| T-260g | 全件 Integration Test フルスイート PASS（2シャード並行実行） |
| T-260h | 本番ビルド → TestFlight最終確認 → 審査提出 |
