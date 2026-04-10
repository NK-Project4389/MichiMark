# MichiMark CLAUDE.md

## プロジェクト概要

MichiMarkはドライブ記録・マーク・リンク管理アプリ（SwiftUIからFlutterへ移植）。

- プラットフォーム：iOS / Android
- フレームワーク：Flutter / Dart
- 状態管理：flutter_bloc（BLoC パターン）
- DB：drift（SQLite）
- DI：get_it
- ナビゲーション：go_router

---

## Git操作ルール

- コミットメッセージに `Co-Authored-By` トレーラーを含めない

---

## Integration Test 実装ルール

Integration Test を書くときは必ず以下のパターンに従うこと。

### NG パターン（絶対に使わない）

```dart
setUpAll(() {
  app.main(); // ❌ 初回テストにしか効かない！
});
```

`IntegrationTestWidgetsFlutterBinding` は各 `testWidgets` でウィジェットツリーをリセットする。
`setUpAll` で `app.main()` を一度だけ呼ぶパターンは **2番目以降のテストでアプリが未起動になり全滅する**。

### OK パターン（必ずこれを使う）

```dart
// setUpAll は不要

Future<void> goToXxxPage(WidgetTester tester) async {
  app_router.router.go('/target-path'); // runApp より先にセット → スプラッシュスキップ
  app.main();                           // 各テストで個別に起動
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.byKey(const Key('target_widget_key')).evaluate().isNotEmpty) return;
  }
  fail('[タイムアウト] ページが10秒以内にロードされませんでした');
}

testWidgets('シナリオX', (tester) async {
  await goToXxxPage(tester); // 各テストの先頭で呼ぶ
  // ...
});
```

**ポイント：**
- `router.go('/path')` を `app.main()` より**先に**呼ぶことでスプラッシュをスキップできる
- GoRouter はグローバルシングルトンのため、`runApp` 前に設定した location が適用される

---

## Integration Test よくある落とし穴

### 落とし穴 1: iOS通知許可ダイアログがテストをブロックする

**症状**: `goToXxxPage` が全テストでタイムアウト。シミュレーターを消去した後に顕発する。

**原因**: `main()` で `FlutterLocalNotificationsPlugin().initialize()` を呼ぶと、
初回起動時にiOS通知許可ダイアログが表示され、`runApp` の完了がブロックされる。

**恒久対応（コード修正）**: `main.dart` でテスト時は通知初期化をスキップ。

```dart
import 'dart:io';

if (!Platform.environment.containsKey('FLUTTER_TEST')) {
  await notificationAdapter.initialize();
}
```

**一時対応（TCC.db直接許可）**: `xcrun simctl privacy booted grant notifications` は通知には効かないため、以下のSQLを使う。

```bash
SIMULATOR_ID=$(xcrun simctl list devices booted | grep Booted | head -1 | grep -oE '[A-F0-9-]{36}')
TCC_DB="$HOME/Library/Developer/CoreSimulator/Devices/$SIMULATOR_ID/data/Library/TCC/TCC.db"
sqlite3 "$TCC_DB" "INSERT OR REPLACE INTO access \
  (service, client, client_type, auth_value, auth_reason, auth_version) \
  VALUES ('kTCCServiceUserNotification', '<BUNDLE_ID>', 0, 2, 4, 1);"
```

---

### 落とし穴 2: ボタンがキーボード・スクロールで画面外に押し出される

**症状**: `tester.tap(button)` で `"would not hit test"` 警告 → タップが無効。

**対処**: `tester.tap()` の前に `ensureVisible` を挿入する。

```dart
await tester.ensureVisible(find.byKey(const Key('save_button')));
await tester.pump(const Duration(milliseconds: 500));
await tester.tap(find.byKey(const Key('save_button')));
```

---

### 落とし穴 3: ListView.builder は画面外のアイテムを描画しない

**症状**: 保存後にアイテム数をカウントしても増えない。

**原因**: `ListView.builder` はlazyレンダリング。ビューポート外のWidgetはWidget treeに存在しない。

**対処**: `scrollUntilVisible` や `drag` でスクロールしてから `find` する。

```dart
// スクロールして対象を表示してから確認
for (var i = 0; i < 10; i++) {
  if (find.byKey(Key('target_item')).evaluate().isNotEmpty) break;
  await tester.drag(find.byType(ListView).first, const Offset(0, -400));
  await tester.pump(const Duration(milliseconds: 200));
}
expect(find.byKey(Key('target_item')), findsOneWidget);
```

---

### 落とし穴 5: pumpAndSettle() は Integration Test で使わない

**症状**: テストが数十分経っても終わらず無限ハング。

**原因**: `pumpAndSettle()` は「アニメーションが全部止まるまで無限に待つ」仕様。
MichiInfo の CustomPainter など**常に再描画し続けるウィジェット**が画面上に存在すると永遠に終わらない。

**対処**: `pumpAndSettle()` を固定時間の `pump()` に置き換える。

```dart
// ❌ NG: CustomPainter や RepaintBoundary があると無限ハング
await tester.ensureVisible(find.byKey(const Key('save_button')));
await tester.pumpAndSettle();
await tester.tap(find.byKey(const Key('save_button')));

// ✅ OK: 固定時間で待つ
await tester.ensureVisible(find.byKey(const Key('save_button')));
await tester.pump(const Duration(milliseconds: 500));
await tester.tap(find.byKey(const Key('save_button')));
```

**ルール: Integration Test 内での `pumpAndSettle()` 使用は禁止。必ず `pump(Duration(...))` を使うこと。**

---

### 落とし穴 4: ListView.builder 内のウィジェットキーは一意にする

```dart
// ❌ NG: 全アイテムに同じキー → Duplicate Global Key エラー
.map((item) => ListTile(key: const Key('item'), ...))

// ✅ OK: インデックス付きキー
.asMap().entries.map((entry) =>
  ListTile(key: Key('item_${entry.key}'), ...))
```

---
