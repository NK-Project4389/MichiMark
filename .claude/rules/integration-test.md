# Integration Test ルール

## 実行デバイス設定

### MichiMark（シャード並行実行）

| ロール | シミュレーター | UDID |
|---|---|---|
| **shard 0（前半）** | iPhone 16 #1 | `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6` |
| **shard 1（後半）** | iPhone 16 #2 (MichiMark) | `21CE8289-283C-40FD-9A1E-43B5439CFF35` |

### NomikaiShare（独立・競合なし）

| ロール | シミュレーター | UDID |
|---|---|---|
| **shard 0** | iPhone 16 Pro #1 | `CD71EBB3-8C8F-4A72-9529-04117342F862` |
| **shard 1** | iPhone 16 Pro #2 (NomikaiShare) | `297A6330-C9FE-4FD3-8E4D-C4DF3095F2FA` |

> MichiMark と NomikaiShare はシミュレーターが別機種なので完全に独立。同時実行しても競合しない。

---

```bash
# ── 単体テスト実行（ファイル指定・シャード不要）──
flutter test integration_test/<feature>_test.dart -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6

# ── 全件実行：シャード並行（2ターミナルで同時実行）──
# ターミナル1
flutter test integration_test/ -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6 --total-shards=2 --shard-index=0

# ターミナル2
flutter test integration_test/ -d 21CE8289-283C-40FD-9A1E-43B5439CFF35 --total-shards=2 --shard-index=1
```

> ⚠️ **1シミュレーター = 1プロセス厳守**: 同一シミュレーターに複数プロセスを当てない。
> シャードは必ず別々の UDID に向ける。

NomikaiShare は別シミュレーター（iPhone 16 Pro）を使用。同時実行が可能。

## バックグラウンド監視セッション

全件実行（シャード並行）時は、テスト実行セッションとは別に **orchestrator が監視セッションを担当** する。

### 監視セッションの役割

- shard0・shard1 **両プロセスをまとめて監視**する（監視セッションは1つ）
- クラッシュ・無限ループを検知したらユーザーに報告する
- **自動リトライ・自動修正は行わない**（報告のみ）

### 異常判定の閾値

| 異常種別 | 判定条件 |
|---|---|
| **無限ループ** | 1テストファイルの実行が **5分を超えても完了しない** |
| **クラッシュ** | プロセスが予期せず終了（非ゼロ終了コード） |

### タスクボードとの関係

- 監視セッションは `IN_PROGRESS` 状態のテストタスクを **参照・更新してよい**
- ただし実装・コード変更は行わない

### 報告フォーマット

```
[監視セッション] 異常検知
- 対象: shard-index=X
- 種別: クラッシュ / 無限ループ（5分超過）
- テストファイル: <ファイル名>
- 状況: <stdout の末尾数行>
```

---

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
