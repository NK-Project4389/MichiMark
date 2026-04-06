# 進捗記録: Xcode ビルドエラー調査・対応

- 作成日: 2026-04-07
- セッション: Xcode ビルドエラー調査

---

## 問題

XCode から直接ビルドすると以下のエラーが連続発生。

```
/GeneratedPluginRegistrant.m:12:9 Module 'integration_test' not found
/GeneratedPluginRegistrant.m:12:9 Module 'sqlite3_flutter_libs' not found
```

---

## 根本原因の調査結果

### 原因1: `integration_test` が `dev_dependencies` に追加されていた

前回セッション（testerエージェント設定）で `integration_test` が `pubspec.yaml` の `dev_dependencies` に追加された。
Flutter はこれを `GeneratedPluginRegistrant.m` に自動登録するが、`integration_test` の Pod が正しくビルドされず "Module not found" エラーが発生。

**対処**: `integration_test` を `pubspec.yaml` の `dev_dependencies` から削除。`flutter pub get` → `pod install` で `GeneratedPluginRegistrant.m` を再生成。

### 原因2: xcscheme に `integration_test.framework` の古い参照が残存

`integration_test` を削除後も `Runner.xcscheme` に以下のビルドエントリが残っていた。

```xml
<BuildActionEntry ...>
  <BuildableReference
     BuildableName = "integration_test.framework"
     BlueprintName = "integration_test"
     ReferencedContainer = "container:Pods/Pods.xcodeproj">
  </BuildableReference>
</BuildActionEntry>
```

この参照が残ったまま Xcode がビルドしようとするため、`sqlite3_flutter_libs` を含む後続の Pod も全てビルド失敗の連鎖が発生。

**対処**: 上記エントリを `Runner.xcscheme` から削除。

---

## 実施した対処

| 手順 | 内容 |
|---|---|
| `integration_test` 削除 | `pubspec.yaml` の `dev_dependencies` から除去 |
| `flutter clean` | ビルドキャッシュ・Generated.xcconfig をクリア |
| `flutter pub get` | `GeneratedPluginRegistrant.m` を再生成（integration_test なし） |
| `pod install` | Pods を再構成（2 deps / 3 total pods） |
| xcscheme 修正 | `Runner.xcscheme` から `integration_test.framework` のエントリを削除 |

---

## `flutter build ios --no-codesign` での確認

CLIビルドは成功（`✓ Built build/ios/iphoneos/Runner.app 18.4MB`）。
Xcode 直接ビルドの結果は未確認のまま次のタスクへ進む。

---

## 未解決

- **Xcode 直接ビルドが通るかどうか未確認**
  - xcscheme 修正後、Xcode クリーンビルドを試みてもらう必要あり
  - もし引き続き失敗する場合は、DerivedData の手動削除も検討:
    ```
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
    ```

---

## 次回セッションで最初にやること

1. **T-010 Phase2動作確認** の継続（`flutter run` でシミュレータ起動・各画面動作確認）
2. タグ追加・削除 → 保存が正しく動くか確認

---
