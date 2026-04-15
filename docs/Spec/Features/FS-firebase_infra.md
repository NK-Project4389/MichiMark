# Feature Spec: Firebase基盤整備（INFRA-1）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-15
Requirement: `docs/Requirements/REQ-firebase_infra.md`

---

# 1. Feature Overview

## Feature Name

FirebaseInfra

## Purpose

MichiMarkのデータ基盤をFirestore中心に移行する。
Anonymous Auth + Apple Sign Inによるユーザー識別基盤を構築し、driftローカルDBからFirestoreへのデータ移行フローを設計する。
将来のイベント共有・招待機能（INV-1〜4）およびWebアプリからの参照を可能にするコレクション設計を確立する。

## Scope

含むもの
- Firebase Flutter統合（firebase_core / cloud_firestore / firebase_auth）
- 開発・本番環境分離設定
- Anonymous Auth UID発行フロー
- Apple Sign In → Anonymous Authリンクフロー
- AuthRepositoryインターフェースおよびGetIt登録
- Firestoreコレクション設計（全ドメイン対応）
- Security Rules設計
- drift → Firestoreデータ移行戦略
- Bloc/Repository層の差し替え方針

含まないもの
- UI変更（招待画面・設定画面のUI）
- INV-1〜4の実装（本Specの完了後に別Specで対応）
- Web側実装（michimark-web側のFirestore参照）
- Firebaseコンソール上の手動設定手順（運用ドキュメントで別管理）

---

# 2. 前提条件

- AppStore無料版リリース（REL-1）完了後に着手する
- 本Spec完了がINV-1〜4の前提条件となる
- 既存のdrift実装（DriftRepository Spec参照）は移行完了まで並存させる
- Domainモデル・Adapter・BlocのAPIは変更しない（Repository層のみ差し替え）

---

# 3. Firebase設定・Flutter連携

## 3.1 パッケージ構成

追加するパッケージ（pubspec.yaml）

| パッケージ | 用途 |
|---|---|
| firebase_core | Firebase初期化 |
| cloud_firestore | Firestoreアクセス |
| firebase_auth | Authentication |
| sign_in_with_apple | Apple Sign Inネイティブ連携 |
| crypto | Apple Sign Inのnonce生成（SHA256） |

## 3.2 環境分離方針

**採用方式: `--dart-define` による環境フラグ + Flavorなしの単一ビルドターゲット**

- `--dart-define=FLAVOR=dev` / `--dart-define=FLAVOR=prod` で切り替える
- `main_dev.dart` / `main_prod.dart` のEntryPoint分離は行わない
- `firebase_options_dev.dart` / `firebase_options_prod.dart` を別ファイルで用意し、FLAVOR値に応じて起動時に選択する

理由:
- Flavorのネイティブ設定（Xcode Scheme / Android buildType）は設定コストが高い
- dart-defineはCI/CD・テスト環境での切り替えが容易
- 現状のシングルターゲット運用を維持できる

## 3.3 設定ファイルの配置

| ファイル | 配置場所 | 用途 |
|---|---|---|
| GoogleService-Info.plist（dev） | `flutter/ios/Runner/dev/` | iOS dev環境Firebase設定 |
| GoogleService-Info.plist（prod） | `flutter/ios/Runner/prod/` | iOS prod環境Firebase設定 |
| google-services.json（dev） | `flutter/android/app/src/dev/` | Android dev環境Firebase設定 |
| google-services.json（prod） | `flutter/android/app/src/prod/` | Android prod環境Firebase設定 |
| firebase_options_dev.dart | `flutter/lib/firebase/` | FlutterFire dev設定 |
| firebase_options_prod.dart | `flutter/lib/firebase/` | FlutterFire prod設定 |

iOS側はRunScript（Build Phase）でFLAVOR値に応じたGoogleService-Info.plistをRunnerディレクトリにコピーするスクリプトを追加する。

## 3.4 Firebase初期化タイミング

- `main.dart` の `main()` 内、`runApp()` より前に `Firebase.initializeApp()` を呼ぶ
- FLAVOR値に応じて `firebase_options_dev.dart` / `firebase_options_prod.dart` を選択する
- テスト環境（Integration Test）では `FLUTTER_TEST` 環境変数を確認し、Firebaseモック（fake_cloud_firestore）に差し替える

---

# 4. ユーザーID管理（AuthRepository）

## 4.1 基本フロー

### 初回起動時（Anonymous Auth）

1. `FirebaseAuth.instance.currentUser` を確認する
2. `null` の場合 → `signInAnonymously()` を呼び出してUIDを発行する
3. 発行されたUIDを以後のFirestoreアクセスに使用する
4. UIDはFirebase Auth内で永続化されるため、アプリ再起動後も同一UIDを返す

### 機種変更・データ引き継ぎ（Apple Sign In リンクフロー）

1. ユーザーが設定画面からApple Sign Inをタップする（画面はINV系Specで設計）
2. Apple Sign Inのnonce + OAuthCredentialを生成する
3. `currentUser.linkWithCredential(credential)` でAnonymous AuthアカウントにApple IDをリンクする
4. リンク成功後 → UIDは変わらない（データの継続性を保証）
5. 別デバイスでApple Sign Inを実行した場合 → 同一UID・同一Firestoreデータにアクセスできる

### リンク済みユーザーの再ログイン（別デバイス）

1. `currentUser` が `null` の場合にApple Sign Inを実行する
2. `signInWithCredential(credential)` でApple IDに紐づくUIDでサインインする
3. 同一UIDでFirestoreデータにアクセスする

## 4.2 AuthRepositoryインターフェース

格納場所: `flutter/lib/repository/auth_repository.dart`

メソッド一覧:

| メソッド名 | 戻り値型 | 説明 |
|---|---|---|
| `currentUid` | `String?` | 現在のFirebase Auth UID（未サインインならnull） |
| `signInAnonymously()` | `Future<String>` | Anonymous Authサインイン。発行されたUIDを返す |
| `signInWithApple()` | `Future<String>` | Apple Sign Inサインイン。UIDを返す |
| `linkWithApple()` | `Future<void>` | AnonymousアカウントにApple IDをリンクする |
| `isAppleLinked` | `bool` | Apple Sign In連携済みかどうか |
| `signOut()` | `Future<void>` | サインアウト（AnonymousユーザーはUIDが失われるため要注意） |

## 4.3 GetIt登録

- `AuthRepository` はabstract classとして定義する
- 実装クラス: `FirebaseAuthRepository`
- GetItへの登録: `getIt.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository())`
- テスト環境: `FakeAuthRepository` をInMemory実装として用意する

## 4.4 AppStartイベントでの自動サインイン

- アプリ起動時（AppBloc または main.dart の初期化フロー）でAuthRepositoryの `currentUid` を確認する
- `null` の場合は自動的に `signInAnonymously()` を呼び出す
- 失敗した場合はオフラインキャッシュモードで動作する（Firestoreオフラインキャッシュを使用）

---

# 5. Firestoreコレクション設計

## 5.1 設計方針

- `organizations/{orgId}` を起点にトランザクション系・マスター系データを格納する
- **`orgId = ownerのuid`**（現時点）。将来的に組織エンティティを独立させる際もIDを変えずに移行できる
- マスターデータ（members/trans/tags/actions/topics）は `organizations/{orgId}` 配下で管理する（組織単位で共有）
- イベント（events）とサブデータ（markLinks/payments）はサブコレクションで管理する
- イベントへのアクセス制御は **イベント単位**（`participants` サブコレクション）で行う。org所属だけではイベントを閲覧できない
- `users/{uid}` はプロフィールのみを持つ（個人アカウント情報）
- 「自分が参加しているイベント一覧」はFirestoreコレクショングループクエリ（`participants`）で取得する。逆引きインデックスは持たない
- IDはすべてUUID文字列を使用する（drift既存IDをそのまま移行できる）

### orgId = uid の根拠

```
User A（uid = "uid-aaa"）がアプリを初回起動
→ organizations/uid-aaa/ が自動的に存在する扱い
→ 追加コストゼロで自分がadminの組織を持つ

将来 organizations を本格エンティティ化するときも
orgId の値は変わらないためデータ移行不要
```

## 5.2 コレクション構造

```
organizations/{orgId}/               # orgId = ownerのuid
  ├── members/{memberId}             # メンバーマスター（人名簿）
  ├── trans/{transId}                # 交通手段マスター
  ├── tags/{tagId}                   # タグマスター
  ├── actions/{actionId}             # アクションマスター
  ├── topics/{topicId}               # トピックマスター
  │
  └── events/{eventId}/              # イベント（トランザクション系）
        ├── （eventドキュメント本体）
        ├── markLinks/{markLinkId}   # マーク/リンク
        ├── payments/{paymentId}     # 支払情報
        ├── actionTimeLogs/{logId}   # アクションタイムログ
        └── participants/{memberId}  # イベント単位アクセス制御

users/{uid}/
  └── profile                        # 個人プロフィールのみ
```

## 5.3 各ドキュメントのフィールド定義

### users/{uid}/profile

| フィールド | 型 | 説明 |
|---|---|---|
| uid | String | Firebase Auth UID |
| isAppleLinked | Boolean | Apple Sign In連携済みフラグ |
| createdAt | Timestamp | アカウント作成日時 |
| updatedAt | Timestamp | 更新日時 |
| schemaVersion | Number | データ移行バージョン（移行完了後に更新） |

### organizations/{orgId}/members/{memberId}

人名簿。org所属の証明であり、イベントアクセス権とは独立する。

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID（driftのIDをそのまま使用） |
| memberName | String | メンバー名（必須） |
| linkedUid | String? | 招待・参加後に紐づくFirebase UID（null = 未参加） |
| mailAddress | String? | メールアドレス（将来拡張用） |
| isVisible | Boolean | 表示フラグ |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### organizations/{orgId}/trans/{transId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| transName | String | 交通手段名（必須） |
| kmPerGas | Number? | 燃費（0.1km/L単位の10倍整数値） |
| meterValue | Number? | 累積メーター初期値（km） |
| isVisible | Boolean | 表示フラグ |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### organizations/{orgId}/tags/{tagId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| tagName | String | タグ名（必須） |
| isVisible | Boolean | 表示フラグ |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### organizations/{orgId}/actions/{actionId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| actionName | String | アクション名（必須） |
| isVisible | Boolean | 表示フラグ |
| isDeleted | Boolean | 論理削除フラグ |
| toState | String? | 遷移後の状態（ActionState enum name） |
| isToggle | Boolean | トグル型フラグ |
| togglePairId | String? | 対になるActionのID |
| needsTransition | Boolean | 状態遷移フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### organizations/{orgId}/topics/{topicId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| topicName | String | トピック名（必須） |
| topicType | String | TopicType enum name（'movingCost' / 'movingCostEstimated' / 'travelExpense'） |
| isVisible | Boolean | 表示フラグ |
| isDeleted | Boolean | 論理削除フラグ |
| color | String? | TopicThemeColor enum name |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### organizations/{orgId}/events/{eventId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| eventName | String | イベント名（必須） |
| transId | String? | 交通手段ID（TransDocumentへの参照用） |
| kmPerGas | Number? | 燃費（イベント上書き値） |
| pricePerGas | Number? | ガソリン単価 |
| payMemberId | String? | ガソリン支払者メンバーID |
| ownerUid | String | イベントオーナーのFirebase UID（= orgId） |
| memberIds | Array\<String\> | 参加メンバーIDリスト |
| tagIds | Array\<String\> | タグIDリスト |
| topicId | String? | トピックID |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

備考: members/tags/topicはIDのみをeventドキュメントに保持し、実体はマスターコレクションを参照して解決する。

### organizations/{orgId}/events/{eventId}/participants/{memberId}

イベント単位のアクセス制御。org所属だけではイベントを閲覧できない。

| フィールド | 型 | 説明 |
|---|---|---|
| memberId | String | organizations/{orgId}/members のmemberId（ドキュメントIDと同一） |
| linkedUid | String? | 招待・参加後のFirebase UID（null = 未参加） |
| role | String | `'editor'` または `'viewer'` |
| invitedAt | Timestamp | 招待日時 |
| joinedAt | Timestamp? | 参加確定日時（null = 未参加） |

**整合性保証:** 参加確定時（招待受け入れ時）は以下2ドキュメントをFirestoreトランザクションで同時更新する：
1. `organizations/{orgId}/members/{memberId}.linkedUid = uid`
2. `organizations/{orgId}/events/{eventId}/participants/{memberId}.linkedUid = uid`

**逆引き（自分が参加しているイベント一覧）:** `participants` コレクショングループクエリを使用する：
```
db.collectionGroup('participants').where('linkedUid', '==', currentUid)
```

### organizations/{orgId}/events/{eventId}/markLinks/{markLinkId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| markLinkSeq | Number | 表示順 |
| markLinkType | String | 'mark' / 'link' |
| markLinkDate | Timestamp | 記録日時 |
| markLinkName | String? | 名称 |
| ownerUid | String | イベントオーナーのFirebase UID（= orgId） |
| memberIds | Array\<String\> | 参加メンバーIDリスト |
| meterValue | Number? | 累積メーター（km） |
| distanceValue | Number? | 区間距離（km） |
| actionIds | Array\<String\> | アクションIDリスト |
| memo | String? | メモ |
| isFuel | Boolean | 給油フラグ |
| pricePerGas | Number? | ガソリン単価 |
| gasQuantity | Number? | 給油量（0.1L単位の10倍整数値） |
| gasPrice | Number? | 給油金額 |
| gasPayerId | String? | 給油支払者メンバーID |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### users/{uid}/events/{eventId}/payments/{paymentId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| paymentSeq | Number | 表示順 |
| paymentAmount | Number | 支払金額（円） |
| paymentMemberId | String | 支払メンバーID（必須） |
| splitMemberIds | Array\<String\> | 割り勘メンバーIDリスト |
| paymentMemo | String? | メモ |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

### users/{uid}/events/{eventId}/actionTimeLogs/{logId}

| フィールド | 型 | 説明 |
|---|---|---|
| id | String | UUID |
| actionId | String | アクションID（actionsコレクション参照） |
| timestamp | Timestamp | アクション実行日時 |
| isDeleted | Boolean | 論理削除フラグ |
| createdAt | Timestamp | 登録日時 |
| updatedAt | Timestamp | 更新日時 |

備考: actionTimeLogsはMarkLink単位ではなくイベント単位のサブコレクションとする。
アクションの現在状態は「イベント内の全actionTimeLogsの順序付き履歴」から決定されるため、
特定のMarkLinkに紐づけると状態解決ロジックが複雑になる。イベント全体のログとして管理する。

## 5.4 設計判断の根拠

**organizations配下にマスター・イベントをまとめた理由:**
- 招待機能でイベントを複数ユーザーが共有するとき、`users/{uid}/events/` 配下だと他ユーザーがアクセスできない
- `orgId = uid` により既存UIDをそのまま流用でき、将来の組織エンティティ化もデータ移行不要

**イベント単位のアクセス制御（participants）にした理由:**
- org所属 ≠ 全イベント閲覧。会社旅行に招待しても家族旅行は見せたくない
- イベントごとに招待・閲覧権限を個別設定できる

**逆引きインデックスを持たない理由:**
- `users/{uid}/eventAccess/` のような逆引きを持つと更新箇所が増え整合性リスクが上がる
- Firestoreのコレクショングループクエリ（`participants`）で代替できる
- 整合性保証が必要な更新箇所を2ドキュメント（members + participants）に絞れる

**Firestoreトランザクションで整合性を保つ範囲:**
- 招待受け入れ時: `members/{memberId}.linkedUid` と `participants/{memberId}.linkedUid` を同時更新
- 件数が少ない（2ドキュメント）のでトランザクションで完結する

---

# 6. Security Rules設計

## 6.1 基本方針

- 認証済みユーザー（isAnonymousを含む）のみアクセスを許可する
- `organizations/{orgId}` 配下はオーナー（`request.auth.uid == orgId`）のみ読み書きを許可する
- `participants` への招待ユーザーのアクセス制御はバックエンドAPI（Admin SDK）経由で行う
- `users/{uid}` 配下は自分のUIDのみアクセスを許可する
- 未認証アクセスは全て拒否する

## 6.2 ルール構造

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 未認証は全て拒否
    match /{document=**} {
      allow read, write: if false;
    }

    // 個人プロフィール
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // organizations配下: オーナー（orgId == uid）のみ
    // 招待ユーザーのイベントアクセスはバックエンドAPI（Admin SDK）経由
    match /organizations/{orgId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == orgId;
    }

    // invitationsコレクション: クライアント直接アクセス禁止（Admin SDKのみ）
    match /invitations/{document=**} {
      allow read, write: if false;
    }
  }
}
```

## 6.3 招待ユーザーのイベントアクセス方針

招待されたユーザー（`participants` に登録済み）がイベントデータを読み書きする場合は、
Flutter → Next.js API（INV系）→ Firebase Admin SDK の経路を経由する。
クライアントが直接 `organizations/{orgId}/events/` を読み書きすることは現時点では禁止する。

将来的にFlutterクライアントから直接参照する場合は、セキュリティルールに以下を追加する：
```
// 将来対応例（参考）
match /organizations/{orgId}/events/{eventId}/{document=**} {
  allow read: if request.auth != null && (
    request.auth.uid == orgId ||
    exists(/databases/$(database)/documents/organizations/$(orgId)/events/$(eventId)/participants/$(getMemberId(request.auth.uid)))
  );
}
```

---

# 7. drift → Firestoreデータ移行戦略

## 7.1 移行フロー概要

```
アプリ起動
  ↓
profile.schemaVersion を確認
  ↓
schemaVersionが未設定 or 0
  ↓
[移行処理開始]
  1. driftからの全データ読み込み
  2. Firestoreへの書き込み（UID配下のコレクション）
  3. profile.schemaVersion = 1 を書き込み
  ↓
移行完了 → 以後はFirestoreのみ使用
```

## 7.2 移行対象データ

| driftテーブル | Firestoreコレクション |
|---|---|
| actions | users/{uid}/actions |
| members | users/{uid}/members |
| tags | users/{uid}/tags |
| transports | users/{uid}/trans |
| topics | users/{uid}/topics |
| events + 中間テーブル | users/{uid}/events（IDのみに変換） |
| mark_links + 中間テーブル | users/{uid}/events/{id}/markLinks（IDのみに変換） |
| payments + 中間テーブル | users/{uid}/events/{id}/payments（IDのみに変換） |

## 7.3 移行中の動作方針

- 移行中はスプラッシュ画面またはローディングインジケーターを表示する（UI設計はこのSpec外）
- 移行中にエラーが発生した場合 → `profile.schemaVersion` を更新せずリトライ可能にする
- Firestoreへの書き込みはバッチ書き込み（WriteBatch）を使用してアトミックに実行する（500件/バッチの上限に注意）
- 移行完了後もdriftのDBファイルはすぐに削除せず、次のメジャーバージョンで削除方針を決める

## 7.4 オフライン時の動作

- Firestoreのオフラインキャッシュ（persistenceEnabled）を有効にする
- オフライン時でもキャッシュから読み書きが可能
- オンライン復帰時に自動でFirestoreに同期される
- drift → Firestore移行前のオフライン状態では引き続きdriftから読み込む

## 7.5 ロールバック方針

- 移行失敗時はdriftから引き続き読み込みを続ける（`profile.schemaVersion` が更新されない限りdriftを優先）
- 移行完了後のロールバックは提供しない（Firestoreをマスターとして扱う）

## 7.6 MigrationRepositoryインターフェース

格納場所: `flutter/lib/repository/migration_repository.dart`

| メソッド名 | 戻り値型 | 説明 |
|---|---|---|
| `isMigrationNeeded()` | `Future<bool>` | Firestoreへの移行が必要かどうかを返す |
| `migrate()` | `Future<void>` | driftからFirestoreへ全データを移行する |
| `getMigrationVersion()` | `Future<int>` | 現在のschemaVersion（0=未移行） |

---

# 8. Bloc/Repository層の設計変更方針

## 8.1 基本方針

- 既存のRepositoryインターフェース（abstract class）は**変更しない**
- drift実装の隣にFirestore実装を追加し、GetItの登録先を切り替える
- BlocはRepositoryインターフェースに依存しているため、Bloc側の変更は不要

## 8.2 ファイル構成

```
flutter/lib/
  repository/
    auth_repository.dart                  # 新規: AuthRepository abstract class
    migration_repository.dart             # 新規: MigrationRepository abstract class
    impl/
      drift/                              # 既存: drift実装（変更なし）
      firestore/                          # 新規: Firestore実装
        firestore_event_repository.dart
        firestore_action_repository.dart
        firestore_member_repository.dart
        firestore_tag_repository.dart
        firestore_trans_repository.dart
        firestore_topic_repository.dart
        firestore_auth_repository.dart
        firestore_migration_repository.dart
  firebase/
    firebase_options_dev.dart             # 新規: dev環境Firebase設定
    firebase_options_prod.dart            # 新規: prod環境Firebase設定
```

## 8.3 GetIt登録変更箇所

対象ファイル: `flutter/lib/di/` または `main.dart` のDI設定箇所

変更方針:
- FLAVOR値（dart-define）に基づいて、drift実装 or Firestore実装をGetItに登録する
- 移行フェーズ（schemaVersion確認後）にFirestore実装へ切り替える
- テスト環境（FLUTTER_TEST）ではFake実装を使用する

## 8.4 段階的移行 vs 一括切替の判断

**一括切替を採用する**

理由:
- Repositoryインターフェースが統一されているため、一括切替がシンプル
- drift → Firestore移行完了（schemaVersion = 1）後、GetItの登録をFirestore実装に切り替える
- 部分移行（テーブルごとに切り替え）は整合性リスクが高い

切替タイミング:
- 起動時にMigrationRepositoryで移行完了を確認してから、GetItのRepository登録を決定する
- 未移行状態ではdrift実装を使用し、移行完了後はFirestore実装を使用する

## 8.5 新規追加するRepositoryインターフェース

### AuthRepository（新規）

格納場所: `flutter/lib/repository/auth_repository.dart`
詳細は「4.2 AuthRepositoryインターフェース」を参照。

### TopicRepository（既存インターフェースの確認）

TopicDomainは既存domainに存在する。drift実装の確認後、Firestore実装を追加する。

---

# 9. テストシナリオ

## 前提条件

- iOSシミュレーターが起動済みであること
- テスト実行時は `FLUTTER_TEST` 環境変数が設定されること
- `fake_cloud_firestore` パッケージを使用してFirestoreをモックする
- `firebase_auth_mocks` パッケージを使用してAuthをモックする
- driftはInMemoryデータベースを使用する

## テストシナリオ一覧

| ID | シナリオ名 | 種別 | 優先度 |
|---|---|---|---|
| TC-INFRA-001 | Anonymous AuthでUIDが発行される | Unit | High |
| TC-INFRA-002 | 既存UIDがある場合は再発行しない | Unit | High |
| TC-INFRA-003 | Apple Sign InでAnonymousアカウントにリンクできる | Unit | High |
| TC-INFRA-004 | Firestoreにメンバーを保存・取得できる | Unit | High |
| TC-INFRA-005 | Firestoreにイベントを保存・取得できる | Unit | High |
| TC-INFRA-006 | driftからFirestoreへのデータ移行が完了する | Unit | High |
| TC-INFRA-007 | 移行完了後にschemaVersionが更新される | Unit | High |
| TC-INFRA-008 | 移行済み状態ではdriftではなくFirestoreから読み込む | Unit | Medium |
| TC-INFRA-009 | アプリ起動時に自動でAnonymous Authサインインが実行される | Widget | High |
| TC-INFRA-010 | オフライン時でもFirestoreキャッシュからデータを表示できる | Integration | Medium |

## シナリオ詳細

### TC-INFRA-001: Anonymous AuthでUIDが発行される

**種別:** Unit Test

**前提:**
- `currentUser` が `null`（未サインイン状態）

**手順:**
1. `FirebaseAuthRepository.signInAnonymously()` を呼び出す

**期待結果:**
- 空でないUID文字列が返される
- `currentUid` が発行されたUIDと一致する

**実装ノート:**
- `firebase_auth_mocks` の `MockFirebaseAuth` を使用する
- UIDの形式検証（空文字でないこと）のみを確認する

---

### TC-INFRA-002: 既存UIDがある場合は再発行しない

**種別:** Unit Test

**前提:**
- Anonymous Authで既にサインイン済み（UID = 'existing-uid'）

**手順:**
1. `FirebaseAuthRepository.signInAnonymously()` を呼び出す

**期待結果:**
- 既存のUID 'existing-uid' が返される（新規UIDが発行されない）

**実装ノート:**
- MockFirebaseAuthに初期ユーザーをセットして確認する

---

### TC-INFRA-003: Apple Sign InでAnonymousアカウントにリンクできる

**種別:** Unit Test

**前提:**
- Anonymous Authでサインイン済み

**手順:**
1. `FirebaseAuthRepository.linkWithApple()` を呼び出す（AppleCredentialはモック）

**期待結果:**
- エラーなく完了する
- `isAppleLinked` が `true` になる
- UIDが変わらない

**実装ノート:**
- Apple Sign Inのネイティブダイアログはテストできないため、Credentialのモックで代替する

---

### TC-INFRA-004: Firestoreにメンバーを保存・取得できる

**種別:** Unit Test

**前提:**
- `fake_cloud_firestore` のFakeFirestoreInstanceを使用する
- UID = 'test-uid' でサインイン済み

**手順:**
1. `FirestoreMemberRepository.save(memberDomain)` を呼び出す
2. `FirestoreMemberRepository.fetchAll()` を呼び出す

**期待結果:**
- fetchAllの結果に保存したメンバーが含まれる
- 保存前後でmemberDomainの全フィールドが一致する

---

### TC-INFRA-005: Firestoreにイベントを保存・取得できる

**種別:** Unit Test

**前提:**
- `fake_cloud_firestore` のFakeFirestoreInstanceを使用する
- UID = 'test-uid' でサインイン済み
- 関連するmembers/trans/tags/actionsがFirestoreに存在する

**手順:**
1. `FirestoreEventRepository.save(eventDomain)` を呼び出す
2. `FirestoreEventRepository.fetchAll()` を呼び出す

**期待結果:**
- fetchAllの結果に保存したイベントが含まれる
- EventDomainの全フィールド（markLinks・paymentsのサブコレクション含む）が一致する

---

### TC-INFRA-006: driftからFirestoreへのデータ移行が完了する

**種別:** Unit Test

**前提:**
- driftInMemoryデータベースにイベント1件・メンバー2件が存在する
- `fake_cloud_firestore` のFakeFirestoreInstanceを使用する
- `profile.schemaVersion` = 0（未移行）

**手順:**
1. `FirestoreMigrationRepository.isMigrationNeeded()` を呼び出す（trueを期待）
2. `FirestoreMigrationRepository.migrate()` を呼び出す

**期待結果:**
- Firestoreの `users/{uid}/events` コレクションに1件のイベントが存在する
- Firestoreの `users/{uid}/members` コレクションに2件のメンバーが存在する
- エラーなく完了する

---

### TC-INFRA-007: 移行完了後にschemaVersionが更新される

**種別:** Unit Test

**前提:**
- TC-INFRA-006と同じ初期状態

**手順:**
1. `FirestoreMigrationRepository.migrate()` を呼び出す
2. `FirestoreMigrationRepository.getMigrationVersion()` を呼び出す

**期待結果:**
- `getMigrationVersion()` が `1` を返す
- `profile.schemaVersion` フィールドが `1` になっている

---

### TC-INFRA-008: 移行済み状態ではdriftではなくFirestoreから読み込む

**種別:** Unit Test

**前提:**
- `profile.schemaVersion` = 1（移行済み）
- driftにはイベントA、FirestoreにはイベントBが存在する（内容が異なる）

**手順:**
1. DI設定でFirestore実装がGetItに登録されている状態で
2. `EventRepository.fetchAll()` を呼び出す

**期待結果:**
- イベントBが返される（Firestoreから読み込み）
- イベントAは返されない（driftから読み込みされていない）

**実装ノート:**
- このシナリオはDIの切り替えロジックのテスト
- GetIt設定の差し替えがテスト可能な構造にすること

---

### TC-INFRA-009: アプリ起動時に自動でAnonymous Authサインインが実行される

**種別:** Widget Test

**前提:**
- `currentUser` が `null`（未サインイン）
- `firebase_auth_mocks` / `fake_cloud_firestore` を使用

**手順:**
1. `app.main()` を呼び出してアプリを起動する
2. イベント一覧画面の表示を待つ

**期待結果:**
- アプリが正常に起動する
- `AuthRepository.currentUid` が null でない値を持つ
- イベント一覧画面が表示される

**実装ノート（ウィジェットキー一覧）:**
- `Key('eventList_list_events')`: イベント一覧のListView

---

### TC-INFRA-010: オフライン時でもFirestoreキャッシュからデータを表示できる

**種別:** Integration Test（手動確認を推奨）

**前提:**
- 移行完了済みでFirestoreにイベントが1件以上存在する
- Firestoreのオフラインキャッシュが有効

**手順:**
1. オンライン状態でアプリを起動してイベント一覧を表示する
2. デバイスをオフラインにする（機内モード）
3. アプリを再起動する

**期待結果:**
- オフライン状態でもイベント一覧が表示される（キャッシュから読み込み）
- エラー画面にならない

**実装ノート:**
- fake_cloud_firestoreはオフラインキャッシュのシミュレーションが困難なため、実機またはシミュレーターでの手動確認を推奨する
- Integration Testとしての自動化は将来対応

---

# 10. Data Flow

## 10.1 通常起動時（移行完了済み）

1. `main()` でFirebase.initializeAppを呼ぶ
2. `AuthRepository.currentUid` を確認する
3. null の場合 → `signInAnonymously()` でUID発行
4. `MigrationRepository.getMigrationVersion()` を確認する
5. schemaVersion = 1 → Firestore実装をGetItに登録する
6. アプリ起動（EventListPage表示）
7. `EventRepository.fetchAll()` → Firestore読み込み → EventDomain生成 → Projection → Widget

## 10.2 初回起動時（移行前）

1. 上記1〜3と同じ
4. `MigrationRepository.getMigrationVersion()` → 0（未移行）
5. drift実装をGetItに登録する
6. バックグラウンドで `MigrationRepository.migrate()` を実行する
7. アプリ起動（driftから読み込み）
8. 移行完了後 → 次回起動からFirestore実装を使用する

---

# 11. 依存パッケージ

| パッケージ | 用途 |
|---|---|
| firebase_core | Firebase初期化 |
| cloud_firestore | Firestoreアクセス |
| firebase_auth | Authentication |
| sign_in_with_apple | Apple Sign Inネイティブ連携 |
| crypto | nonce生成（SHA256） |
| fake_cloud_firestore | テスト用Firestoreモック（dev_dependency） |
| firebase_auth_mocks | テスト用Authモック（dev_dependency） |

---

# 12. Router変更方針

- `go_router` のルート定義変更は不要
- 移行フロー中のローディング表示はSplashPageまたは既存のローディングWidgetを流用する（UI設計は別途）
- Apple Sign In設定画面のRouteはINV系Specで定義する

---

# 13. 関連Spec・ドキュメント

| ドキュメント | 関連内容 |
|---|---|
| `docs/Spec/Features/DriftRepository_Spec.md` | drift実装の詳細（移行元） |
| `docs/Requirements/REQ-firebase_infra.md` | 要件書 |
| INV-1〜4 Spec（未作成） | 招待機能（本Spec依存） |

---

# End of FS-firebase_infra
