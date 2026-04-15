---
name: testflight
description: "Flutter iOSアプリをTestFlightにアップロードする。ビルド・アーカイブ・署名・アップロードを自動で行う。ユーザーが「TestFlight」「テストフライト」「TFにアップ」「ビルドしてアップロード」「配信」「App Store Connectにアップ」などと言ったら、このスキルを使う。Flutterプロジェクトでなくても、Xcodeプロジェクトであれば対応可能。"
---

# TestFlight Upload Skill

FlutterまたはXcode iOSプロジェクトをビルドしてTestFlightにアップロードする。

## 設定ファイル

プロジェクトルートの `.claude/testflight.json` に認証情報を保存する。
存在しない場合はユーザーに聞いて作成する。

```json
{
  "teamId": "XXXXXXXXXX",
  "keyId": "XXXXXXXXXX",
  "issuerId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "keyPath": "~/private_keys/AuthKey_XXXXXXXXXX.p8",
  "workspace": "Runner.xcworkspace",
  "scheme": "Runner"
}
```

## 実行手順

### Step 0: 設定ファイルを読む

`.claude/testflight.json` を読む。存在しない場合：

1. ユーザーに以下を聞く:
   - Team ID（Xcode の Signing & Capabilities で確認可能）
   - App Store Connect API Key ID
   - Issuer ID
   - .p8 キーファイルのパス
2. `.claude/testflight.json` を作成して保存

### Step 1: Flutter ビルド＆アーカイブ（Flutterプロジェクトの場合）

`pubspec.yaml` が存在するか確認し、存在すればFlutterプロジェクトと判定する。

`flutter build ipa` を使う（`flutter build ios --release` + `xcodebuild archive` の組み合わせより確実）。
アーカイブは `build/ios/archive/Runner.xcarchive` に作成される。

```bash
flutter build ipa --release \
  --export-options-plist /tmp/ExportOptions.plist
```

**注意**: `flutter build ipa` は "Failed to Use Accounts" エラーで export が失敗することがあるが、
**アーカイブは正常に作成される**。エラーを無視して Step 2.5 へ進む。

Flutterプロジェクトでない場合はこのステップをスキップ。

### Step 2: Xcode アーカイブ（非Flutterプロジェクトの場合のみ）

.xcworkspace を探す。flutter/ios/ にあることが多い。

```bash
xcodebuild -workspace {workspace_path} \
  -scheme {scheme} \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/{AppName}.xcarchive \
  archive 2>&1 | tail -5
```

**ビルドエラー**: `| tail -30` でエラー末尾を確認し、ユーザーに報告する。

### Step 2.5: objective_c.framework の x86_64 バイナリ差し替え（Flutter必須手順）

Flutterプロジェクトでは `objective_c.framework` に **x86_64 のみのバイナリ** が混入し、
App Store Connect でエラー 90087/90203 が発生する**既知の問題**がある。
`EXCLUDED_ARCHS=x86_64` を指定しても解決しない。**アーカイブ後に必ず実行する**。

```bash
# Step 1 で flutter build ipa を使った場合（パスを直接指定すること・変数代入禁止）
lipo -info "build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"

# Step 2 で xcodebuild archive を使った場合
# lipo -info "/tmp/{AppName}.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
```

**注意: `FRAMEWORK="..."` のような変数代入と `&&` の組み合わせは許可ダイアログが発生するため禁止。パスは必ず直接引数として渡すこと。**

x86_64 のみの場合、arm64 バイナリを探して差し替える。

```bash
# 1. プロジェクト内の worktree アーカイブを探す（最速）
find .claude/worktrees -name "objective_c" -path "*/Runner.xcarchive/*" 2>/dev/null | xargs -I{} sh -c 'lipo -info "{}" 2>/dev/null | grep arm64 && echo "{}"'

# 2. Xcode アーカイブから探す
find ~/Library/Developer/Xcode/Archives -name "objective_c" 2>/dev/null | xargs -I{} sh -c 'lipo -info "{}" 2>/dev/null | grep arm64 && echo "{}"'

# arm64 バイナリが見つかったら差し替え（パスを直接指定すること・$変数禁止）
cp {arm64のパス} "build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"

# 差し替え後に確認
lipo -info "build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
# → "arm64" と出ればOK
```

arm64 バイナリが全く見つからない場合（初回ビルド等）:
- 一度 `flutter run --release -d {実機デバイスID}` を実行してキャッシュを作る
- または Xcode で直接 Archive して arm64 バイナリを得る

### Step 3: ExportOptions.plist 作成

**必ず `Write` ツールを使って作成すること（Bash heredoc は許可ダイアログが発生するため禁止）。**

Write ツールで `/tmp/ExportOptions.plist` に以下の内容を書き込む:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>destination</key>
  <string>upload</string>
  <key>teamID</key>
  <string>{teamId}</string>
  <key>signingStyle</key>
  <string>automatic</string>
</dict>
</plist>
```

`signingStyle` は必ず `automatic` にする。これにより Distribution 証明書がローカルになくても Cloud Signing で自動生成される。

### Step 4: アップロード

```bash
# flutter build ipa を使った場合のアーカイブパス
ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"

# xcodebuild archive を使った場合
# ARCHIVE_PATH="/tmp/{AppName}.xcarchive"

rm -rf /tmp/{AppName}Export && xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath /tmp/{AppName}Export \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -authenticationKeyPath {keyPath} \
  -authenticationKeyID {keyId} \
  -authenticationKeyIssuerID {issuerId} \
  -allowProvisioningUpdates 2>&1 | tail -10
```

出力の最後を `| tail -20` で確認し、`EXPORT SUCCEEDED` を確認する。

#### エラー対処

**Cloud signing permission error / No signing certificate "iOS Distribution" found**:
APIキーの権限が不足している。App Store Connect でキーの権限を **Admin** に変更する必要がある。
ユーザーに以下を案内する:
- App Store Connect → ユーザとアクセス → 統合 → App Store Connect API
- キーの権限を Admin に変更（または Admin 権限で新しいキーを発行）

**Failed to Use Accounts**:
`-authenticationKeyPath` 等のパラメータが不足している。設定ファイルを確認する。

**exportPath already exists**:
`rm -rf /tmp/{AppName}Export` を先に実行する。

### Step 5: 完了報告

成功したらユーザーに以下を報告:
- アップロード成功
- App Store Connect で処理完了後（通常10〜30分）TestFlight に配信される
- dSYM の warning が出ても動作に影響はない

## 注意事項

- `.p8` キーファイルは一度しかダウンロードできない。紛失した場合は再発行が必要
- API キーは `~/private_keys/` に配置するのが慣例
- `.claude/testflight.json` は `.gitignore` に追加することを推奨（認証情報を含むため）
