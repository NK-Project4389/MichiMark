# Feature Spec: B-19 訪問作業シードデータ区間削除

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-16
Requirement: `docs/Requirements/REQ-visit_work_seed_data_fix.md`

---

# 1. Feature Overview

## Feature Name

VisitWorkSeedDataFix

## Purpose

訪問作業（visitWork）トピックでは仕様上「区間（Link）を作成しない」が、
シードデータ（シナリオC: 横浜エリア訪問ルート）に誤ってLink 4件が含まれている。
Linkデータを削除してシードデータを仕様と整合させる。
あわせて、Link件数を前提としている Integration Test のアサーションを修正する。

## Scope

### 含むもの

- `seed_data.dart` のシナリオC（`event-seed-c`）内の Link 生成コード 4件を削除
- `markLinks` の順序・件数が変わることによる Integration Test への影響修正

### 含まないもの

- シナリオA（箱根日帰りドライブ）・シナリオB（業務走行記録）のシードデータ
- 訪問作業トピックの業務ロジック・Domainモデル
- 既存ユーザーのデータ（InMemory実装のためアプリ再起動で自動リセット）

---

# 2. Feature Responsibility

本Featureはシードデータの修正のみ。既存のレイヤー構造・Bloc・Projection・Domain に変更はない。

- `seed_data.dart` のシナリオC部分を修正する
- Integration Test の Link 件数アサーションを修正する

---

# 3. 修正対象データ定義

## シナリオC 修正後の markLinks 構成

修正後の `event-seed-c` の `markLinks` は以下の **Mark 5件のみ** とする。

| seq | markLinkType | 名称 | 変更 |
|---|---|---|---|
| 1 | mark | 事務所出発 | 維持 |
| 2 | mark | A社（横浜駅前） | 維持 |
| 3 | mark | B社（みなとみらい） | 維持 |
| 4 | mark | C社（磯子） | 維持 |
| 5 | mark | 事務所帰着 | 維持 |

削除する Link（4件）:
- 事務所出発 → A社（横浜駅前）: 28km
- A社（横浜駅前） → B社（みなとみらい）: 5km
- B社（みなとみらい） → C社（磯子）: 12km
- C社（磯子） → 事務所帰着: 25km

## 維持するデータ

- Mark 5件: 変更なし
- PaymentDomain 3件: 変更なし（駐車場A社・駐車場B社・昼食）

---

# 4. Integration Test への影響

## 影響を受けるテストシナリオ

以下のテストは「シナリオCの件数・内容」を前提としており、修正が必要になる可能性がある。

| テストID | シナリオ | 修正方針 |
|---|---|---|
| TC-SD-001 | 新規起動時にイベント一覧に3件表示される | 影響なし |
| TC-SD-007 | シナリオCの訪問作業アクションが記録されている | MarkのインデックスがLink削除でずれる場合は修正する |
| TC-SD-008 | シナリオCの支払いタブに3件の支払いが表示される | 影響なし |

## 修正方針

- `michiInfo_markCard_N` のインデックスN が Link 削除によってずれる場合は、正しいインデックスに修正する
- Link を前提とした `michiInfo_linkCard_N` のアサーションが存在する場合は削除する
- 合計件数（例: 「9件表示される」等のアサーション）が存在する場合は5件に修正する

---

# 5. Data Flow

変更なし。データ修正のみのため、アーキテクチャへの影響はない。

- アプリ起動 → `setupDi()` 内で `InMemoryEventRepository(initialItems: seedEvents)` を生成
- `event-seed-c` の `markLinks` がMark 5件のみになり、MichiInfo 画面に Link なしで表示される

---

# 6. 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | シナリオC の `markLinks` から Link 4件を削除 |
| Integration Testファイル（seed_data_sample_test.dart 等） | Link件数・Linkインデックス前提のアサーションを修正 |

変更しないファイル:
- `flutter/lib/app/di.dart`
- Domainモデル・Adapterすべて
- シナリオA・B のシードデータ

---

# 7. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- B-17 シードデータ実装が完了していること（本Specはその修正対象）
- アプリをリセット（GetIt.I.reset()）した状態

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-B19-I001 | シナリオCのMichiInfoにLinkが表示されない | High |
| TC-B19-I002 | シナリオCのMichiInfoにMark 5件が表示される | High |
| TC-B19-I003 | シナリオCの支払い3件は正常に表示される | High |
| TC-B19-I004 | シナリオAのタイムライン（Mark7件・Link4件）は影響を受けない | Medium |

## シナリオ詳細

### TC-B19-I001: シナリオCのMichiInfoにLinkが表示されない

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する

**期待結果:**
- Link（区間）のカードが一切表示されない
- `Key('michiInfo_linkCard_0')` が存在しない

**実装ノート:**
- `find.byKey(const Key('michiInfo_linkCard_0'))` が `findsNothing` であることを確認する

---

### TC-B19-I002: シナリオCのMichiInfoにMark 5件が表示される

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する

**期待結果:**
- 「事務所出発」「A社（横浜駅前）」「B社（みなとみらい）」「C社（磯子）」「事務所帰着」の5件のMarkカードが表示される

**実装ノート:**
- スクロールで各Markカードを確認する（ListView.builder の落とし穴に注意）
- `Key('michiInfo_markCard_0')` 〜 `Key('michiInfo_markCard_4')` を順に確認する

---

### TC-B19-I003: シナリオCの支払い3件は正常に表示される

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する

**期待結果:**
- 支払い一覧に3件が表示される（駐車場(A社)・駐車場(B社)・昼食）
- Link削除による影響を受けていない

**実装ノート:**
- `Key('paymentInfo_card_0')` 〜 `Key('paymentInfo_card_2')` が存在することを確認する

---

### TC-B19-I004: シナリオAのタイムライン（Mark7件・Link4件）は影響を受けない

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する

**期待結果:**
- シナリオAのMarkLink（mark 6件・link 5件 計11件）が従来通り表示される
- B-19 の修正がシナリオAに影響していない

**実装ノート:**
- `Key('michiInfo_markCard_0')` が表示されることを確認する
- `Key('michiInfo_linkCard_0')` が表示されることを確認する（シナリオAはLinkあり）

---

# End of Feature Spec
