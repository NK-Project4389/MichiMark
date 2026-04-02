# 2026-04-03 Phase 2 動作確認・バグ修正

## 完了した作業

### タスク1: ビルドエラー修正
- `event_detail_bloc.dart:131` — `state` → `state as EventDetailLoaded` キャスト修正
- `widget_test.dart` — デフォルトテストを削除、プレースホルダーに置換
- `flutter analyze` エラーゼロ確認

### タスク2: iOSシミュレーター起動確認
- `flutter build ios --simulator` ビルド成功
- iPhone 16e シミュレーターでアプリ起動確認（クラッシュなし）

### タスク3: PaymentInfo カードタップ後に登録情報が表示されないバグ修正
- **原因**: GoRouterのルート定義順序問題
  - `/event/:id`（パラメータルート）が `/event/payment`（固定ルート）より先に定義されていた
  - `context.push('/event/payment', ...)` が `/event/:id` にマッチし、`id = "payment"` として EventDetailPage が開かれていた
- **修正**: `router.dart` でルート定義順序を変更
  - `/event/mark/:markId`、`/event/link/:linkId`、`/event/payment` を `/event/:id` より前に移動
  - 固定パス・具体的パスが先にマッチするようにした

### タスク4: タスクボード運用改善
- CLAUDE.md にタスクボード即時DONE更新ルール追加
- Phase 1 タスク（T-001〜T-004）を DONE に更新
- Phase 2 タスク（T-010〜T-012）の BLOCKED 解除

## 未完了

- T-010〜T-012: 全Feature動作確認・設定Feature確認・drift永続化確認（継続中）

## 次回セッションで最初にやること

**Phase 2 動作確認の継続**

1. PaymentInfo カードタップ修正の動作確認（シミュレーター実機確認）
2. 全Feature動作確認（イベント一覧・詳細・マーク・リンク・支払）
3. 設定Feature動作確認（Trans/Member/Tag/Action）
4. drift DI切り替え・データ永続化確認
