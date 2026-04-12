# Integration Test ルール

## 実行デバイス設定

| アプリ | シミュレーター | UDID |
|---|---|---|
| **MichiMark** | iPhone 16 | `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6` |

```bash
# 単体テスト実行
flutter test integration_test/<feature>_test.dart -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6

# 全件実行（本番リリース前）
flutter test integration_test/ -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
```

NomikaiShare は別シミュレーター（iPhone 16 Pro）を使用。同時実行が可能。

## テスト実行タイミング

| タイミング | 実行範囲 |
|---|---|
| 通常のサイクル（新機能・バグ修正後） | 対象Featureのテストファイルのみ |
| 本番リリース前（App Store提出前） | 全テストファイルをフルスイート実行 |

`flutter test` 実行時は確認プロンプトなしで自動許可して進める。

## 実装パターン

### アプリ起動ヘルパー

MichiMark では各テストで `GetIt.I.reset()` → `router.go('/')` → `app.main()` の順で起動する。

リファレンス実装: `integration_test/basic_info_tap_to_edit_test.dart`

**ポイント:**
- `GetIt.I.reset()` をテストごとに呼んでDIコンテナをリセットする
- `router.go('/')` を `app.main()` より**先に**呼ぶ（スプラッシュスキップ）

**NG（絶対に使わない）:** `setUpAll` での `app.main()` 呼び出し — 2番目以降のテストでアプリが未起動になり全滅する

## タイムアウト標準値

- ループ回数: **20〜30回**（最大10〜15秒待機）
- 1回の待機: `await tester.pump(const Duration(milliseconds: 500))`
- エラーメッセージ: `'[タイムアウト] XXXページが15秒以内にロードされませんでした'`

## よくある落とし穴

### 落とし穴1: ボタンがキーボード・スクロールで画面外に押し出される

**症状**: `tester.tap(button)` で `"would not hit test"` 警告 → タップが無効

**対処**: `tester.tap()` の前に `ensureVisible` を挿入する。

```dart
await tester.ensureVisible(find.byKey(const Key('save_button')));
await tester.pumpAndSettle();
await tester.tap(find.byKey(const Key('save_button')));
```

### 落とし穴2: ListView.builder は画面外のアイテムを描画しない

**症状**: 保存後に `find.byKey('item')` でカード数を数えても増えない

**原因**: `ListView.builder` はlazyレンダリングのため、ビューポート内のWidgetのみが存在する。

**対処**: 数を数えるのではなく、対象要素をスクロールで表示してから検証する。

```dart
// ❌ NG
expect(find.byKey(Key('event_card')).evaluate().length, count + 1);

// ✅ OK
for (var i = 0; i < 10; i++) {
  if (find.byKey(Key('target_item')).evaluate().isNotEmpty) break;
  await tester.drag(find.byType(ListView).first, const Offset(0, -400));
  await tester.pump(const Duration(milliseconds: 200));
}
expect(find.byKey(Key('target_item')), findsOneWidget);
```

### 落とし穴3: ListView.builder 内のウィジェットキーは一意にする

**症状**: `Duplicate Global Key` エラーでビルドクラッシュ

**対処**: インデックス付きキーを使う。

```dart
// ❌ NG
.map((item) => ListTile(key: const Key('item'), ...))

// ✅ OK
.asMap().entries.map((entry) =>
  ListTile(key: Key('item_${entry.key}'), ...))
```

### 落とし穴4: GetIt未リセットによるDI競合

**症状**: 2本目以降のテストでDIエラーやデータ混在が発生

**対処**: 各テストの起動ヘルパーで必ず `await GetIt.I.reset()` を呼ぶ。
