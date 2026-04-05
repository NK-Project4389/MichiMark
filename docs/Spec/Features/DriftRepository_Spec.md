# DriftRepository Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: InMemoryリポジトリをdrift（SQLite）ベースのリポジトリに置き換え、データの永続化を実現する。

---

# 1. Feature Overview

## Feature Name

DriftRepository

## Purpose

MichiMarkアプリの全データをSQLiteに永続化する。drift のコード生成を使用し、既存の Repository インターフェースの実装として作成する。

## Scope

含むもの
- drift テーブル定義（全エンティティ + 中間テーブル）
- DAO 定義
- drift Row と Domain の変換
- Repository インターフェースの drift 実装
- マイグレーション方針
- DI 切り替え方針

含まないもの
- UI変更
- Bloc変更
- Domain / Draft / Projection / Adapter の変更
- InMemory実装の削除（併存する）

---

# 2. テーブル定義

## 2.1 マスターテーブル

### actions

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| action_name | TEXT | NOT NULL | アクション名 |
| is_visible | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 表示フラグ |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日（Unix milliseconds） |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日（Unix milliseconds） |

### members

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| member_name | TEXT | NOT NULL | メンバー名 |
| mail_address | TEXT | NULLABLE | メールアドレス |
| is_visible | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 表示フラグ |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

### tags

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| tag_name | TEXT | NOT NULL | タグ名 |
| is_visible | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 表示フラグ |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

### transports

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| trans_name | TEXT | NOT NULL | 交通手段名 |
| km_per_gas | INTEGER | NULLABLE | 燃費（0.1km/L単位の10倍整数値） |
| meter_value | INTEGER | NULLABLE | 累積メーター初期値（km） |
| is_visible | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 表示フラグ |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

## 2.2 トランザクションテーブル

### events

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| event_name | TEXT | NOT NULL | イベント名 |
| trans_id | TEXT | NULLABLE, FK → transports(id) | 交通手段ID |
| km_per_gas | INTEGER | NULLABLE | 燃費（イベント単位の上書き値） |
| price_per_gas | INTEGER | NULLABLE | ガソリン単価 |
| pay_member_id | TEXT | NULLABLE, FK → members(id) | ガソリン支払者ID |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

### mark_links

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| event_id | TEXT | NOT NULL, FK → events(id) | 所属イベントID |
| mark_link_seq | INTEGER | NOT NULL | 表示順 |
| mark_link_type | TEXT | NOT NULL | 'mark' or 'link' |
| mark_link_date | INTEGER (DateTime) | NOT NULL | 記録日時 |
| mark_link_name | TEXT | NULLABLE | 名称 |
| meter_value | INTEGER | NULLABLE | 累積メーター（km） |
| distance_value | INTEGER | NULLABLE | 区間距離（km） |
| memo | TEXT | NULLABLE | メモ |
| is_fuel | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 給油フラグ |
| price_per_gas | INTEGER | NULLABLE | ガソリン単価 |
| gas_quantity | INTEGER | NULLABLE | 給油量（0.1L単位の10倍整数値） |
| gas_price | INTEGER | NULLABLE | 給油金額 |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

### payments

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | UUID |
| event_id | TEXT | NOT NULL, FK → events(id) | 所属イベントID |
| payment_seq | INTEGER | NOT NULL | 表示順 |
| payment_amount | INTEGER | NOT NULL | 支払金額 |
| payment_member_id | TEXT | NOT NULL, FK → members(id) | 支払メンバーID |
| payment_memo | TEXT | NULLABLE | メモ |
| is_deleted | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| created_at | INTEGER (DateTime) | NOT NULL | 登録日 |
| updated_at | INTEGER (DateTime) | NOT NULL | 更新日 |

## 2.3 中間テーブル

### event_members

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| event_id | TEXT | NOT NULL, FK → events(id) ON DELETE CASCADE | イベントID |
| member_id | TEXT | NOT NULL, FK → members(id) | メンバーID |

- PRIMARY KEY: (event_id, member_id)

### event_tags

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| event_id | TEXT | NOT NULL, FK → events(id) ON DELETE CASCADE | イベントID |
| tag_id | TEXT | NOT NULL, FK → tags(id) | タグID |

- PRIMARY KEY: (event_id, tag_id)

### mark_link_members

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| mark_link_id | TEXT | NOT NULL, FK → mark_links(id) ON DELETE CASCADE | マーク/リンクID |
| member_id | TEXT | NOT NULL, FK → members(id) | メンバーID |

- PRIMARY KEY: (mark_link_id, member_id)

### mark_link_actions

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| mark_link_id | TEXT | NOT NULL, FK → mark_links(id) ON DELETE CASCADE | マーク/リンクID |
| action_id | TEXT | NOT NULL, FK → actions(id) | アクションID |

- PRIMARY KEY: (mark_link_id, action_id)

### payment_split_members

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| payment_id | TEXT | NOT NULL, FK → payments(id) ON DELETE CASCADE | 支払ID |
| member_id | TEXT | NOT NULL, FK → members(id) | メンバーID |

- PRIMARY KEY: (payment_id, member_id)

---

# 3. DAO構成

## 3.1 MasterDao

担当テーブル: actions, members, tags, transports

責務:
- 各マスターテーブルの CRUD 操作
- fetchAll は `is_deleted = false` でフィルタリング
- save は `insertOnConflictUpdate`（upsert）

## 3.2 EventDao

担当テーブル: events, mark_links, payments, 全中間テーブル（event_members, event_tags, mark_link_members, mark_link_actions, payment_split_members）

責務:
- Event の CRUD 操作
- Event 保存時のトランザクション処理（後述）
- Event 取得時の関連データ結合（MarkLinks, Payments, Members, Tags, Trans, PayMember）

---

# 4. Domain変換方針

## 4.1 方向

- **保存時**: Domain → drift Row（テーブルへの INSERT/UPDATE 用 Companion に変換）
- **取得時**: drift Row → Domain（JOIN 結果や関連テーブルの取得結果を組み立てて Domain に変換）

## 4.2 変換責務の配置

Domain変換ロジックは **DAO 内のプライベートメソッド** として配置する。理由:

- 変換はテーブル構造に依存するため、DAO が最も適切な場所
- 外部に公開する必要がない
- Adapter レイヤー（Draft ↔ Domain 変換）とは責務が異なる

## 4.3 マスター参照の解決

EventDomain には MemberDomain, TagDomain, TransDomain などのマスタードメインが含まれる。

取得時の方針:
- EventDao は MasterDao に依存せず、必要なマスターデータを直接 JOIN またはサブクエリで取得する
- 中間テーブル経由でマスターテーブルを JOIN し、Domain のリストフィールドを構築する

保存時の方針:
- マスターデータ自体は保存しない（EventDao は event/mark_link/payment と中間テーブルのみ操作）
- 中間テーブルには ID のみを保存する

## 4.4 MarkOrLink enum の変換

- DB保存: `MarkOrLink.mark` → `'mark'`, `MarkOrLink.link` → `'link'`
- DB取得: `'mark'` → `MarkOrLink.mark`, `'link'` → `MarkOrLink.link`

## 4.5 DateTime の変換

- drift はデフォルトで DateTime を Unix milliseconds (INTEGER) として保存する
- drift の型コンバーターにより自動変換されるため、明示的な変換は不要

---

# 5. Event保存トランザクション

EventRepository.save(EventDomain) の呼び出し時、以下の操作を **単一トランザクション** 内でアトミックに実行する。

## 5.1 処理順序

1. events テーブルへの upsert
2. 既存の中間テーブルレコードを削除（event_members, event_tags）
3. event_members の再挿入
4. event_tags の再挿入
5. mark_links テーブルへの upsert（event_id に紐づく全件）
6. 既存の mark_link_members, mark_link_actions を削除（該当 mark_link_id 分）
7. mark_link_members の再挿入
8. mark_link_actions の再挿入
9. payments テーブルへの upsert（event_id に紐づく全件）
10. 既存の payment_split_members を削除（該当 payment_id 分）
11. payment_split_members の再挿入

## 5.2 削除されたサブエンティティの処理

- MarkLink / Payment が Domain 上で `isDeleted = true` の場合、DB上でも `is_deleted = true` に更新する
- DB 上に存在するが Domain のリストに含まれない MarkLink / Payment は `is_deleted = true` に更新する（孤立レコード防止）

## 5.3 EventRepository.delete(id) の処理

- events テーブルの `is_deleted` を true に更新する
- 子テーブル（mark_links, payments）の論理削除は行わない（Event が論理削除されていれば子も表示されない）

---

# 6. Event取得クエリ方針

## 6.1 fetchAll

1. events テーブルから `is_deleted = false` のレコードを `updated_at DESC` で取得
2. 各 Event に対して以下を取得:
   - transports テーブルから trans_id で取得（NULLABLE）
   - members テーブルから pay_member_id で取得（NULLABLE）
   - event_members 中間テーブル経由で members を取得
   - event_tags 中間テーブル経由で tags を取得
   - mark_links テーブルから `is_deleted = false` のレコードを `mark_link_seq ASC` で取得
   - 各 mark_link に対して mark_link_members, mark_link_actions を取得
   - payments テーブルから `is_deleted = false` のレコードを `payment_seq ASC` で取得
   - 各 payment に対して payment_member, payment_split_members を取得

## 6.2 fetch(id)

fetchAll と同じ関連データ取得を、指定 ID の Event 1件に対して行う。存在しない場合は `NotFoundError` をスローする。

## 6.3 パフォーマンス考慮

- fetchAll では N+1 問題が発生する可能性がある
- 初期実装では各 Event ごとにサブクエリを発行するシンプルな方式で実装する
- パフォーマンスが問題になった場合に最適化（一括取得 + メモリ上での組み立て）を検討する

---

# 7. マイグレーション方針

## 7.1 初期バージョン

- schemaVersion = 1
- 全テーブルを初期作成として定義する
- マイグレーション（onUpgrade）は空で用意する

## 7.2 今後のバージョンアップ

- テーブル変更時に schemaVersion を +1 する
- onUpgrade で前バージョンからの差分 SQL を記述する
- drift の `MigrationStrategy` を使用する

## 7.3 REQ-002〜005対応マイグレーション（v2.0）

ActionTime Spec実装時（schemaVersion 2）、Topic Spec実装時（topics・events.topic_id追加）に引き続き、本変更ではさらに +1 する。

> 現時点でのschemaVersionは実装状況による。以下の変更をすべて1つのバージョンアップに含めることも、別々に含めることもできる。実装時に実際のschemaVersionを確認すること。

### actions テーブル変更（REQ-004・005）

```
ALTER TABLE actions ADD COLUMN needs_transition INTEGER NOT NULL DEFAULT 1
```

- `from_state` カラムは **削除しない**（NULLABLEのまま残す）
- `needs_transition` カラムを追加。既存レコードにはデフォルト値 1（true）が適用される

### topics テーブル変更（REQ-007確定）

```
ALTER TABLE topics ADD COLUMN color TEXT
```

- `color` カラムを追加（NULLABLE）
- 保存値は `TopicThemeColor` の enum name 文字列（例: `'emeraldGreen'`、`'amberOrange'`）
- SeedData値: movingCost → `'emeraldGreen'`、travelExpense → `'amberOrange'`
- null の場合は `TopicConfig.forType(topicType).themeColor` にフォールバックする（アプリ側で解決）

---

# 8. ファイル構成

```
flutter/lib/repository/impl/drift/
  database.dart              -- @DriftDatabase 定義（テーブル一覧・DAO一覧）
  tables/
    master_tables.dart       -- actions, members, tags, transports テーブル定義
    event_tables.dart        -- events, mark_links, payments テーブル定義
    junction_tables.dart     -- 全中間テーブル定義
  dao/
    master_dao.dart          -- MasterDao（@DriftAccessor）
    event_dao.dart           -- EventDao（@DriftAccessor）
  repository/
    drift_event_repository.dart     -- EventRepository の drift 実装
    drift_action_repository.dart    -- ActionRepository の drift 実装
    drift_member_repository.dart    -- MemberRepository の drift 実装
    drift_tag_repository.dart       -- TagRepository の drift 実装
    drift_trans_repository.dart     -- TransRepository の drift 実装
```

生成ファイル（.g.dart）は同ディレクトリに出力される（drift の標準動作）。

---

# 9. DI切り替え方針

- get_it の登録で InMemory 実装と drift 実装を切り替える
- 切り替えは `main.dart` の DI 設定で行う
- Repository インターフェースは変更しない

```
// 切り替えイメージ（実装コードではなく方針のみ）
// InMemory:  getIt.registerSingleton<EventRepository>(InMemoryEventRepository(...))
// drift:     getIt.registerSingleton<EventRepository>(DriftEventRepository(database))
```

---

# 10. Repository インターフェース契約

drift 実装は既存の Repository インターフェースを **そのまま** implements する。契約の変更は行わない。

| Repository | メソッド | 備考 |
|---|---|---|
| EventRepository | fetchAll() | is_deleted = false, updated_at DESC |
| EventRepository | fetch(id) | NotFoundError スロー |
| EventRepository | save(event) | トランザクション処理 |
| EventRepository | delete(id) | 論理削除 |
| ActionRepository | fetchAll() | is_deleted = false |
| ActionRepository | save(action) | upsert |
| MemberRepository | fetchAll() | is_deleted = false |
| MemberRepository | save(member) | upsert |
| TagRepository | fetchAll() | is_deleted = false |
| TagRepository | save(tag) | upsert |
| TransRepository | fetchAll() | is_deleted = false |
| TransRepository | save(trans) | upsert |

---

# 11. エラーハンドリング

- drift 操作で例外が発生した場合は `SaveFailedError` でラップしてスローする
- fetch で該当レコードが見つからない場合は `NotFoundError` をスローする
- 既存の `RepositoryError` sealed class を使用する（追加の定義は不要）

---

# 12. 依存パッケージ

| パッケージ | 用途 |
|---|---|
| drift | テーブル定義・クエリ・トランザクション |
| drift_dev | コード生成（dev_dependency） |
| build_runner | コード生成実行（dev_dependency） |
| sqlite3_flutter_libs | iOS/Android の SQLite バインディング |
| path_provider | DB ファイルの保存先パス取得 |
| path | パス操作 |

---

# End of DriftRepository Spec
