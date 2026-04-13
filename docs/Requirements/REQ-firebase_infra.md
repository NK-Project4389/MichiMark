# 要件書：Firebase基盤整備（INFRA-1）

## 概要

ミチマークのデータ基盤を **Firestore中心** に移行する。
現在はローカルDB（drift/SQLite）のみだが、複数ユーザー間でのイベント共有・招待機能の実現と、
将来的なWeb側からのDB参照を見据えてFirebaseを導入する。

## ユーザーストーリー

- ユーザーとして、機種変更してもドライブログデータを引き継ぎたい
- ユーザーとして、Apple IDでサインインすればどのデバイスからでも同じデータにアクセスしたい
- 開発者として、WebアプリからもFirestoreを参照して機能拡張できる基盤がほしい

## スコープ

### Firebase設定・Flutter連携

- Firebase プロジェクト作成
- `firebase_core` / `cloud_firestore` / `firebase_auth` の Flutter 統合
- 開発環境・本番環境の分離設定

### ユーザーID管理

**基本方針：Firebase Anonymous Auth ＋ Apple Sign In**

| フェーズ | 動作 |
|---|---|
| アプリ初回起動 | Firebase Anonymous Auth で自動的に UID を発行（ログイン不要） |
| 機種変更・データ引き継ぎ | Apple ID でリンク（Firebase Auth の連携機能）→ 同一 UID で引き継ぎ |

- `identifierForVendor` は機種変更・再インストールで失われるため不採用
- Apple Sign In は Sign in with Apple（Firebase Auth 連携）で実装

### Firestoreデータモデル設計

現在のローカルDBドメイン（EventDomain・BasicInfo・MichiInfo・PaymentInfo）を
Firestoreのコレクション・ドキュメント構造に設計する。

設計方針：
- Web側からも参照しやすいフラットな構造を優先
- オーナーの `uid` をドキュメントに持たせ、アクセス制御の基盤とする
- Security Rules でオーナー・招待メンバーのアクセス制御を実装

### ローカルdrift → Firestoreへの移行

- 既存ローカルデータのFirestoreへの移行方法を設計する
- アプリ内での移行フロー（初回Firestore接続時に自動移行 or 手動移行）
- 移行後もオフライン時はFirestoreのオフラインキャッシュで動作

## 前提・制約

- AppStore 無料版リリース（REL-1）完了後に着手する
- INV-1〜4（招待機能）はこのINFRA-1の完了が前提
- 将来のWeb側機能拡張を見据えたスキーマ設計にすること
- Firestoreのセキュリティルールを必ず設計・実装すること

## 関連タスク

- INV-1: 招待機能バックエンド実装（依存）
- INV-2: 招待中間Webページ（依存）
- INV-3: 招待コード入力画面（依存）
- INV-4: 招待リンク生成・共有（依存）
