# Feature Spec: B-20 訪問作業シードデータ ActionTime情報追加

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-16
Requirement: `docs/Requirements/REQ-visit_work_seed_data_actiontime.md`

---

# 1. Feature Overview

## Feature Name

VisitWorkSeedDataActionTime

## Purpose

訪問作業トピックのシードデータ（シナリオC: 横浜エリア訪問ルート）にActionTimeLog（アクション記録）が存在しない。
A社・B社・C社の各Markにアクション記録を追加し、タイムラインタブの表示とダッシュボードの作業記録グラフへの反映を実現する。

## Scope

### 含むもの

- `seed_data.dart` シナリオC の A社・B社・C社 Markに対応する ActionTimeLog データを追加
- 各Markへの ActionTimeLog の紐付け

### 含まないもの

- ActionTimeLog の業務ロジック・Domainモデルの変更
- シナリオA・シナリオBのシードデータ
- ダッシュボードの集計ロジックの変更（データ追加のみで自動反映）
- 事務所出発・事務所帰着 のMark（アクション記録なし）

---

# 2. Feature Responsibility

本Featureはシードデータの拡充のみ。既存のレイヤー構造・Bloc・Projection・Domain に変更はない。

- `seed_data.dart` のシナリオC部分に ActionTimeLog データを追加する
- ActionTimeLog は B-19 修正後の Mark 5件のうち A社・B社・C社 の3件に紐付ける

---

# 3. ActionTimeLog データ定義

> 基準日: インストール日 -3日（シナリオCのイベント日と同じ。`_rel(-3)` で計算）

## A社（横浜駅前）の ActionTimeLog

| seedId | actionId | timestamp | 説明 |
|---|---|---|---|
| `actiontime-seed-c-a1` | `visit_work_arrive` | `_rel(-3, 9, 15)` | 到着 09:15 |
| `actiontime-seed-c-a2` | `visit_work_start` | `_rel(-3, 9, 20)` | 作業開始 09:20 |
| `actiontime-seed-c-a3` | `visit_work_end` | `_rel(-3, 10, 45)` | 作業終了 10:45 |

期待される集計: 作業時間 1時間25分

## B社（みなとみらい）の ActionTimeLog

| seedId | actionId | timestamp | 説明 |
|---|---|---|---|
| `actiontime-seed-c-b1` | `visit_work_arrive` | `_rel(-3, 11, 5)` | 到着 11:05 |
| `actiontime-seed-c-b2` | `visit_work_start` | `_rel(-3, 11, 10)` | 作業開始 11:10 |
| `actiontime-seed-c-b3` | `visit_work_break` | `_rel(-3, 12, 0)` | 休憩開始 12:00 |
| `actiontime-seed-c-b4` | `visit_work_start` | `_rel(-3, 13, 0)` | 作業再開 13:00（休憩OFF = 同アクション再記録） |
| `actiontime-seed-c-b5` | `visit_work_end` | `_rel(-3, 14, 20)` | 作業終了 14:20 |

期待される集計: 作業時間 2時間10分（休憩1時間を除く）、休憩時間 1時間

## C社（磯子）の ActionTimeLog

| seedId | actionId | timestamp | 説明 |
|---|---|---|---|
| `actiontime-seed-c-c1` | `visit_work_arrive` | `_rel(-3, 14, 50)` | 到着 14:50 |
| `actiontime-seed-c-c2` | `visit_work_start` | `_rel(-3, 14, 55)` | 作業開始 14:55 |
| `actiontime-seed-c-c3` | `visit_work_end` | `_rel(-3, 16, 10)` | 作業終了 16:10 |

期待される集計: 作業時間 1時間15分

## 合計期待値（3社合計）

| 集計項目 | 期待値 |
|---|---|
| 合計作業時間 | 約4時間50分（85 + 130 + 75 = 290分） |
| 合計休憩時間 | 1時間（B社のみ） |

---

# 4. ActionTimeLog の紐付け構造

各ActionTimeLog は、対応するMarkLinkDomain の `actionTimeLogs` リストに追加される。

- A社 MarkLinkDomain.actionTimeLogs ← A社の3件
- B社 MarkLinkDomain.actionTimeLogs ← B社の5件
- C社 MarkLinkDomain.actionTimeLogs ← C社の3件

> `actionId` は `seed_actions.dart` に定義された seedActions の固定 UUID を参照する。
> `visit_work_arrive` / `visit_work_start` / `visit_work_end` / `visit_work_break` の各IDを使用する。

---

# 5. Data Flow

変更なし。データ追加のみのため、アーキテクチャへの影響はない。

- アプリ起動 → `setupDi()` 内で `InMemoryEventRepository(initialItems: seedEvents)` を生成
- A社・B社・C社 の MarkLinkDomain に ActionTimeLog が紐付いた状態でロードされる
- MichiInfo タイムラインタブで ActionTimeLog が時系列表示される
- ダッシュボードの集計ロジックが ActionTimeLog を読んでグラフに反映する

---

# 6. 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | シナリオC の A社・B社・C社 Mark に ActionTimeLog を追加 |

変更しないファイル:
- `flutter/lib/app/di.dart`
- Domainモデル・Adapterすべて
- シナリオA・B のシードデータ
- ダッシュボード集計ロジック

---

# 7. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- B-17 シードデータ実装が完了していること
- B-19 Link削除が完了していること（Mark 5件構成が前提）
- アプリをリセット（GetIt.I.reset()）した状態

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-B20-I001 | A社マークにActionTimeLogが3件記録されている | High |
| TC-B20-I002 | B社マークにActionTimeLogが5件記録されている（休憩含む） | High |
| TC-B20-I003 | C社マークにActionTimeLogが3件記録されている | High |
| TC-B20-I004 | 概要タブの作業時間サマリーに合計作業時間が表示される | High |
| TC-B20-I005 | ダッシュボードの作業記録グラフにシナリオCのデータが反映される | Medium |

## シナリオ詳細

### TC-B20-I001: A社マークにActionTimeLogが3件記録されている

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する
4. 「A社（横浜駅前）」マークをタップしてMarkDetailを開く
5. ActionTimeLog セクションを確認する

**期待結果:**
- A社のMarkDetailにアクション記録が3件（到着・作業開始・作業終了）表示される
- 時刻が 09:15 / 09:20 / 10:45 と表示される（または -3日の同時刻）

**実装ノート:**
- `Key('markDetail_actionTimeLog_0')` 〜 `Key('markDetail_actionTimeLog_2')` が存在することを確認する
- アクション名「到着」「作業開始」「作業終了」のテキストが存在することを確認する

---

### TC-B20-I002: B社マークにActionTimeLogが5件記録されている（休憩含む）

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する
4. 「B社（みなとみらい）」マークをタップしてMarkDetailを開く
5. ActionTimeLog セクションを確認する

**期待結果:**
- B社のMarkDetailにアクション記録が5件（到着・作業開始・休憩・作業再開・作業終了）表示される
- 休憩を示すアクションログが含まれる

**実装ノート:**
- `Key('markDetail_actionTimeLog_0')` 〜 `Key('markDetail_actionTimeLog_4')` が存在することを確認する
- 「休憩」のテキストが存在することを確認する

---

### TC-B20-I003: C社マークにActionTimeLogが3件記録されている

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する
4. スクロールして「C社（磯子）」マークをタップしてMarkDetailを開く
5. ActionTimeLog セクションを確認する

**期待結果:**
- C社のMarkDetailにアクション記録が3件（到着・作業開始・作業終了）表示される
- 時刻が 14:50 / 14:55 / 16:10 と表示される（または -3日の同時刻）

**実装ノート:**
- `Key('markDetail_actionTimeLog_0')` 〜 `Key('markDetail_actionTimeLog_2')` が存在することを確認する

---

### TC-B20-I004: 概要タブの作業時間サマリーに合計作業時間が表示される

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. 概要（Overview / Dashboard）タブを表示する
4. 作業時間サマリーセクションを確認する

**期待結果:**
- 作業時間の合計として約4時間50分（290分）に相当する時間が表示される
- 休憩時間が1時間として表示される

**実装ノート:**
- `Key('visitWork_workingTime')` または集計セクションのキーで作業時間テキストを確認する
- 正確な時間フォーマットは実装に依存するため、「0時間」でないことを確認する最低限の検証でもよい

---

### TC-B20-I005: ダッシュボードの作業記録グラフにシナリオCのデータが反映される

**前提:** アプリをリセットした状態でシードデータが投入される

**操作手順:**
1. アプリを起動する
2. ダッシュボードタブを表示する
3. 作業記録グラフセクションを確認する

**期待結果:**
- 作業記録グラフ（または訪問作業集計エリア）にシナリオCのActionTimeLogデータが反映されている
- グラフデータが「0件」ではなく何らかの集計値が表示されている

**実装ノート:**
- `Key('dashboard_visitWorkSection')` または関連するキーでセクション存在を確認する
- 詳細なグラフ値の検証は実装に依存するため、セクションが空でないことの確認にとどめてよい

---

# End of Feature Spec
