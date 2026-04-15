# Firebase セットアップ手順

新しい環境（新しいMac・再クローン後）でFirebase関連ファイルを復元する手順。

## 背景

以下のファイルはAPIキーを含むためgit管理外（.gitignore）。
環境構築時に手動で配置が必要。

```
flutter/ios/Runner/dev/GoogleService-Info.plist   ← gitignore対象
flutter/ios/Runner/prod/GoogleService-Info.plist  ← gitignore対象
flutter/lib/firebase/firebase_options_dev.dart    ← gitignore対象
flutter/lib/firebase/firebase_options_prod.dart   ← gitignore対象
```

---

## 手順

### 1. GoogleService-Info.plist を配置

**dev:**
1. [Firebase Console](https://console.firebase.google.com) を開く
2. `michimark-dev` プロジェクトを選択
3. 歯車アイコン → 「プロジェクトを設定」→「全般」タブ
4. 「マイアプリ」セクションのiOSアプリ → 「GoogleService-Info.plist をダウンロード」
5. `flutter/ios/Runner/dev/GoogleService-Info.plist` に配置

**prod:**
1. 同様に `michimark-prod` プロジェクトで実施
2. `flutter/ios/Runner/prod/GoogleService-Info.plist` に配置

---

### 2. firebase_options_*.dart を生成

**方法A: flutterfire CLI で自動生成（推奨）**

```bash
# flutterfire CLI がなければインストール
dart pub global activate flutterfire_cli

# dev 用（flutter ディレクトリで実行）
cd flutter
flutterfire configure \
  --project=michimark-dev \
  --out=lib/firebase/firebase_options_dev.dart \
  --platforms=ios

# prod 用
flutterfire configure \
  --project=michimark-prod \
  --out=lib/firebase/firebase_options_prod.dart \
  --platforms=ios
```

**方法B: plist から手動作成**

`GoogleService-Info.plist` を開いて以下のフィールドを読み取り、ファイルを作成する。

| plistキー | dart フィールド |
|---|---|
| `API_KEY` | `apiKey` |
| `GCM_SENDER_ID` | `messagingSenderId` |
| `GOOGLE_APP_ID` | `appId` |
| `PROJECT_ID` | `projectId` |
| `BUNDLE_ID` | `iosBundleId` |
| `STORAGE_BUCKET` | `storageBucket` |

```dart
// flutter/lib/firebase/firebase_options_dev.dart（dev例）
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => ios;

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '<API_KEY>',
    appId: '<GOOGLE_APP_ID>',
    messagingSenderId: '<GCM_SENDER_ID>',
    projectId: '<PROJECT_ID>',
    storageBucket: '<STORAGE_BUCKET>',
    iosBundleId: '<BUNDLE_ID>',
  );
}
```

---

### 3. Firebase Auth を有効化（新しいプロジェクトの場合のみ）

1. Firebase Console → 対象プロジェクト → セキュリティ → Authentication
2. 「Sign-in method」タブ
3. **匿名（Anonymous）** → 有効にする → 保存
4. **Apple** → 有効にする → 保存

---

### 4. Xcode Build Phase の確認

`flutter/ios/Runner.xcodeproj` を Xcode で開いて、
TARGETS → Runner → Build Phases に以下のスクリプトが存在することを確認する。

存在しない場合は「+」→「New Run Script Phase」で追加し、
**Copy Bundle Resources より前**に配置する。

```bash
# FLAVOR に応じて GoogleService-Info.plist をコピー
FLAVOR=${DART_DEFINES:-""}
if echo "$FLAVOR" | grep -q "FLAVOR=prod"; then
  SOURCE="${SRCROOT}/Runner/prod/GoogleService-Info.plist"
else
  SOURCE="${SRCROOT}/Runner/dev/GoogleService-Info.plist"
fi
cp "$SOURCE" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
```

「Based on dependency analysis」のチェックは**外す**こと。

---

## 動作確認

```bash
cd flutter
flutter run  # dev（デフォルト）
flutter run --dart-define=FLAVOR=prod  # prod
```

起動時にFirebase Anonymous Authが自動で実行される。
ログに `Firebase initialized` が出ていれば正常。
