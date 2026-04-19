# Integration Test ルール

## ⚠️ テスト実行スコープ（最重要）

| タイミング | 実行範囲 |
|---|---|
| **通常サイクル（新機能・バグ修正）** | **対象Featureのテストファイルのみ** |
| 本番リリース前（App Store提出前）のみ | 全テストファイル（3シャード並行） |

**全件実行（3シャード）は本番リリース前以外では絶対に行わない。**

```bash
# 通常はこれだけ（ファイル指定）
cd flutter && flutter test integration_test/<feature>_test.dart -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
```

---

## 実行デバイス設定

### MichiMark（シャード並行・リリース前のみ）

| shard | シミュレーター | UDID |
|---|---|---|
| 0 | iPhone 16 #1 | `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6` |
| 1 | iPhone 16 #2 (MichiMark) | `21CE8289-283C-40FD-9A1E-43B5439CFF35` |
| 2 | iPhone 16 #3 (MichiMark) | `B6008734-29AB-4371-9A20-BED4FE322BF4` |

```bash
# ターミナル1
flutter test integration_test/ -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6 --total-shards=3 --shard-index=0
# ターミナル2
flutter test integration_test/ -d 21CE8289-283C-40FD-9A1E-43B5439CFF35 --total-shards=3 --shard-index=1
# ターミナル3
flutter test integration_test/ -d B6008734-29AB-4371-9A20-BED4FE322BF4 --total-shards=3 --shard-index=2
```

> ⚠️ 1シミュレーター = 1プロセス厳守。同一UDIDに複数プロセスを当てない。

---

## ⚠️ テストコード実装前のシードデータレビュー（必須）

`tester` がテストコードを実装したら、`reviewer` がテスト実行前に以下を確認すること。

### チェック項目

| # | チェック内容 | NG例 | OK例 |
|---|---|---|---|
| 1 | メンバー名のハードコード禁止 | `find.text('太郎')` | `find.text(seedMembers[0].memberName)` |
| 2 | イベント名のハードコード禁止 | `find.text('箱根日帰りドライブ')` | `find.text(SeedData.event1Name)` または動的選択 |
| 3 | 交通手段名のハードコード禁止 | `find.text('マイカー')` | `find.text(seedTrans[0].transName)` |
| 4 | 計算済み金額のハードコード禁止 | `find.text('合計: ¥5,600')` | 計算ロジックから動的に生成 or expect不使用 |
| 5 | シードデータ固有IDのハードコード禁止 | `Key('event-001')` | seedDataの定数参照 or 動的取得 |
| 6 | シードデータ固有の名称のハードコード禁止 | `find.text('大涌谷')` | `find.text(seedEvents[0].markLinks[4].markLinkName)` |

### インポートパターン

```dart
// シードデータを参照する場合は必ずimportして定数を使う
import 'package:michi_mark/repository/impl/in_memory/seed_data.dart';

// ✅ OK: 定数参照
expect(find.text(seedMembers[0].memberName), findsWidgets); // '太郎'
expect(find.text(seedTrans[0].transName), findsOneWidget);   // 'マイカー'

// ❌ NG: ハードコード（シードデータ変更で即FAILになる）
expect(find.text('太郎'), findsWidgets);
expect(find.text('マイカー'), findsOneWidget);
```

### 違反が見つかった場合

reviewer は REJECTED として `tester` に修正を依頼する。シードデータ変更による自動FAILを防ぐため、このチェックは省略不可。

---

## 実装パターン

### アプリ起動ヘルパー

各テストで `GetIt.I.reset()` → `router.go('/')` → `app.main()` の順で起動する。

```dart
Future<void> startApp(WidgetTester tester) async {
  await GetIt.I.reset();
  app_router.router.go('/');
  app.main();
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text('イベント一覧').evaluate().isNotEmpty) return;
  }
  fail('[タイムアウト] ページが10秒以内にロードされませんでした');
}
```

- `router.go('/')` を `app.main()` より**先に**呼ぶ（スプラッシュスキップ）
- ❌ `setUpAll` で `app.main()` → 2本目以降のテストが全滅する

## タイムアウト標準値

- ループ回数: **20〜30回**（最大10〜15秒待機）
- 1回の待機: `await tester.pump(const Duration(milliseconds: 500))`

---

## よくある落とし穴

### ❌ `pumpAndSettle()` は使用禁止

CustomPainter など常時再描画するウィジェットがあると永遠に終わらない（無限ハング）。

```dart
// ❌ 絶対NG
await tester.pumpAndSettle();

// ✅ 必ずこれ
await tester.pump(const Duration(milliseconds: 500));
```

### ボタンが画面外に押し出される

`tester.tap()` の前に `ensureVisible` を挿入する。

```dart
await tester.ensureVisible(find.byKey(const Key('save_button')));
await tester.pump(const Duration(milliseconds: 500));  // ← pumpAndSettle() は禁止
await tester.tap(find.byKey(const Key('save_button')));
```

### ListView.builder は画面外アイテムを描画しない

```dart
// ❌ NG: 件数カウントは不可
expect(find.byKey(Key('event_card')).evaluate().length, count + 1);

// ✅ OK: スクロールして表示してから確認
for (var i = 0; i < 10; i++) {
  if (find.byKey(Key('target_item')).evaluate().isNotEmpty) break;
  await tester.drag(find.byType(ListView).first, const Offset(0, -400));
  await tester.pump(const Duration(milliseconds: 200));
}
expect(find.byKey(Key('target_item')), findsOneWidget);
```

### ListViewキーは一意にする

```dart
// ❌ NG → Duplicate Global Key エラー
.map((item) => ListTile(key: const Key('item'), ...))

// ✅ OK
.asMap().entries.map((entry) => ListTile(key: Key('item_${entry.key}'), ...))
```

### GetIt未リセットによるDI競合

各テストの起動ヘルパーで必ず `await GetIt.I.reset()` を呼ぶ。

### iOS通知許可ダイアログがテストをブロックする

**症状**: 起動ヘルパーが全テストでタイムアウト。シミュレーター消去後に顕発する。

**原因**: `main()` で `FlutterLocalNotificationsPlugin().initialize()` を呼ぶと初回起動時にiOS通知許可ダイアログが表示され `runApp` がブロックされる。

**恒久対応**: `main.dart` でテスト時は通知初期化をスキップ。

```dart
if (!Platform.environment.containsKey('FLUTTER_TEST')) {
  await notificationAdapter.initialize();
}
```

**一時対応（TCC.db直接許可）**: `xcrun simctl privacy booted grant notifications` は通知には効かない。

```bash
SIMULATOR_ID=$(xcrun simctl list devices booted | grep Booted | head -1 | grep -oE '[A-F0-9-]{36}')
TCC_DB="$HOME/Library/Developer/CoreSimulator/Devices/$SIMULATOR_ID/data/Library/TCC/TCC.db"
sqlite3 "$TCC_DB" "INSERT OR REPLACE INTO access \
  (service, client, client_type, auth_value, auth_reason, auth_version) \
  VALUES ('kTCCServiceUserNotification', '<BUNDLE_ID>', 0, 2, 4, 1);"
```
