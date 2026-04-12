# TestFlight 1.0.0(12) アップロード完了

**日付**: 2026-04-12
**ビルド番号**: 1.0.0 (12) ※アップロード時は build 10、次回用に +11 へ更新済み

## 含む変更

- UI-1: イベント削除UI変更（スワイプ廃止→詳細画面削除アイコン）Integration Test 6PASS
- UI-2: BasicInfo参照タップ編集UI改善（Teal薄背景・タップで編集モード） Integration Test 14PASS
- UI-3: MichiInfo Mark/Link削除UI変更（削除アイコン常時表示） Integration Test 5PASS/2SKIP
- UI-4: PaymentInfo カード削除UI変更（削除アイコン常時表示） Integration Test 3PASS
- UI-5: MarkDetail/LinkDetail/PaymentDetail UI改善（AppBar・保存/キャンセルボタン統一） Integration Test 18PASS
- UI-6: 概要タブ セクション名追加（基本情報・集計ラベル） Integration Test 4PASS
- B-6: 給油計算 ガソリン支払い者インラインFilterChip選択（Phase C） Integration Test 8PASS

## テスト合計

**58PASS / 0FAIL / 6SKIP**（全フィーチャー完了）

## アップロード結果

- EXPORT SUCCEEDED
- dSYM warning（objective_c.framework）あり → 動作に影響なし

## 次回

- App Store Connect で処理完了後（10〜30分）TestFlight に配信される
- 次回ビルド時は pubspec `1.0.0+11` を使用
