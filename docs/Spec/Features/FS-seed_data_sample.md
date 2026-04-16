# Feature Spec: B-17 本番シードデータ見直し

Platform: **Flutter / Dart**
Version: 1.0
要件書: `docs/Requirements/REQ-seed_data_sample.md`

---

# 1. Feature Overview

## Feature Name

SeedDataSample

## Purpose

テストデータが本番配信されているため、新規インストール時に表示されるシードデータを、アプリの使い方が伝わるサンプルデータ（シナリオA・B・C の3イベント）に差し替える。

既存ユーザーのデータは保護し、初回起動フラグで制御する。

## Scope

含むもの
- `flutter/lib/repository/impl/in_memory/seed_data.dart` のイベントデータ（seedEvents）を3シナリオに差し替え
- 既存マスタデータ（seedTopics / seedActions / seedMembers / seedTags / seedTrans）の見直し・必要なメンバー追加
- 日付を相対日付（`DateTime.now()` 基準）で計算するヘルパー関数の追加
- 初回起動フラグ（`shared_preferences` の `seed_data_seeded` キー）による既存ユーザー保護の実装方針定義

含まないもの
- DBマイグレーション（InMemory実装のため不要）
- BLoC / State の新規追加
- 画面UIの変更

---

# 1-2. 本番/テスト シードデータ分離（必須要件）

## 背景

Integration Test の全件スイートは現在のシードデータ（event-001〜008）に強く依存している。
本番用サンプルデータ（シナリオA・B・C）に置き換えると全テストが崩壊するため、
**本番とテストでシードデータを完全に分離することは必須要件**である。

## 分離方針

`FLUTTER_TEST` 環境変数を用いて実行環境を判別し、`seedEvents` の内容を切り替える。
`flutter test` 実行時は Dart ランタイムが自動的に `FLUTTER_TEST` をセットするため、
追加の設定や引数なしに切り替えが機能する。

```dart
import 'dart:io';

// 本番用: シナリオA・B・C（3件）
final _prodSeedEvents = [...]; // 新規作成

// テスト用: 既存 event-001〜008（現行のまま維持）
final _testSeedEvents = [...]; // 現行コードをそのまま移動

// di.dart から参照される公開変数
final seedEvents = Platform.environment.containsKey('FLUTTER_TEST')
    ? _testSeedEvents
    : _prodSeedEvents;
```

## ファイル構成

変更対象は `seed_data.dart` 1ファイルのみ。分割はしない。

| 変数名 | 内容 | 参照元 |
|---|---|---|
| `_prodSeedEvents` | シナリオA・B・C（3件） | `seedEvents`（本番時） |
| `_testSeedEvents` | 既存 event-001〜008（8件） | `seedEvents`（テスト時） |
| `seedEvents` | 上記いずれか（環境に応じて自動切替） | `di.dart` |

## 注意事項

- `di.dart` の変更は不要（`seedEvents` という名前を維持するため）
- `_testSeedEvents` は現行の `seedEvents` 定義（event-001〜008）をそのまま `_testSeedEvents` にリネームして移動するだけでよい
- マスタデータ（seedTopics / seedActions / seedMembers / seedTags / seedTrans）は本番・テスト共通のまま変更しない

---

# 2. 既存シードデータの場所

| ファイル | 役割 |
|---|---|
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | シードデータ定義（seedEvents・seedTopics・seedMembers・seedTrans・seedTags・seedActions） |
| `flutter/lib/app/di.dart` | DIコンテナ。seedEventsをInMemoryEventRepositoryに渡している |

**変更対象**: `seed_data.dart` の seedEvents 定義のみを差し替える。di.dart は変更不要。

---

# 3. 相対日付の計算方針

固定日付（例: `DateTime(2026, 3, 15)`）は使用しない。
`DateTime.now()` を基点に相対オフセットで計算するヘルパー関数を `seed_data.dart` に定義する。

**ヘルパー仕様（設計方針）:**

```
// 基点日（インストール日相当）
final _base = DateTime.now();

// オフセット計算
DateTime _rel(int dayOffset, [int hour = 0, int minute = 0])
  → _base から dayOffset日前/後の DateTime を返す

// 当月起算（シナリオB用）
DateTime _monthStart(int dayOfMonth, [int hour = 0, int minute = 0])
  → _base の年・月の dayOfMonth 日を返す
```

**各シナリオの基点:**
- シナリオA（箱根日帰りドライブ）: `_base - 7日`
- シナリオB（業務走行記録）: `_base の当月1日〜`
- シナリオC（横浜エリア訪問ルート）: `_base - 3日`

---

# 4. マスタデータ定義

## 4-1. 維持するマスタ（変更不要）

既存の seedTopics・seedActions・seedTags・seedTrans はそのまま維持する。
ただしシナリオAで使用するメンバーを追加する。

## 4-2. メンバー（seedMembers）の見直し

要件書の登場人物に合わせてメンバー名を整理する。

| ID | 名前 | 備考 |
|---|---|---|
| `member-001` | 自分（太郎） | 既存維持 |
| `member-002` | 田中 | 既存「花子」から変更 |
| `member-003` | 鈴木 | 既存「健太」から変更 |

> 既存テストがメンバー名に依存している場合は tester が調整する。

## 4-3. 使用するトピック

| シナリオ | 使用トピック | TopicType |
|---|---|---|
| A（箱根日帰りドライブ） | 移動コスト（給油から計算） | `movingCost` |
| B（業務走行記録） | 移動コスト（給油から計算） | `movingCost` |
| C（横浜エリア訪問ルート） | 訪問作業 | `visitWork` |

---

# 5. シナリオA: 箱根日帰りドライブ

## 5-1. EventDomain フィールド

| フィールド | 値 |
|---|---|
| id | `event-seed-a` |
| eventName | `箱根日帰りドライブ` |
| topic | seedTopics[movingCost] |
| trans | `マイカー`（trans-001） |
| members | 自分・田中・鈴木（3名） |
| tags | `日帰り`（tag-002） |
| kmPerGas | 155（15.5km/L） |
| pricePerGas | 175 |
| payMember | 自分 |
| createdAt / updatedAt | `_rel(-7, 8, 0)` |

## 5-2. Mark（地点）一覧

| seq | markLinkType | 名称 | 距離km | meterValue | 備考 |
|---|---|---|---|---|---|
| 1 | mark | 自宅出発 | — | 45000 | 出発地点 |
| 2 | link | — | 65 | — | 足柄SA方面 |
| 3 | mark | 足柄SA | — | 45065 | 休憩・給油（isFuel=true, 35L, 175円/L, 6125円） |
| 4 | link | — | 20 | — | 箱根神社方面 |
| 5 | mark | 箱根神社 | — | 45085 | アクション: 観光 |
| 6 | link | — | 8 | — | 大涌谷方面 |
| 7 | mark | 大涌谷 | — | 45093 | アクション: 観光 |
| 8 | link | — | 12 | — | 箱根湯本方面 |
| 9 | mark | 箱根湯本（昼食） | — | 45105 | アクション: 食事 |
| 10 | link | — | 85 | — | 帰路 |
| 11 | mark | 帰宅 | — | 45190 | — |

> isFuelがtrueのとき: pricePerGas=175, gasQuantity=350（35.0L）, gasPrice=6125, gasPayer=自分

## 5-3. 日付割り当て

全地点に `_rel(-7)` を基点として時刻オフセットを付与する（例: 8:00, 9:30, 11:00... と順に割り当て）。

## 5-4. PaymentDomain 一覧

| id | 金額 | 支払者 | 割り勘対象 | メモ |
|---|---|---|---|---|
| `pay-seed-a1` | 3200 | 自分 | 3名全員 | 高速代（往復） |
| `pay-seed-a2` | 4500 | 自分 | 3名全員 | ガソリン代 |
| `pay-seed-a3` | 8700 | 田中 | 3名全員 | 昼食 |
| `pay-seed-a4` | 1000 | 鈴木 | 3名全員 | 駐車場 |

割り勘精算済みの状態（全員splitMembersに含まれる）。

---

# 6. シナリオB: 4月 業務走行記録

## 6-1. EventDomain フィールド

| フィールド | 値 |
|---|---|
| id | `event-seed-b` |
| eventName | `4月 業務走行記録` |
| topic | seedTopics[movingCost] |
| trans | `マイカー`（trans-001） |
| members | 自分（1名） |
| tags | `[]`（なし） |
| kmPerGas | 155 |
| pricePerGas | 173（平均） |
| payMember | 自分 |
| createdAt / updatedAt | `_monthStart(1, 8, 0)` |

## 6-2. Mark（地点・日別走行）一覧

移動コストトピックは markLinkName を省略してよい（距離・給油情報が主役）。

| seq | markLinkType | 日 | 距離km | isFuel | 給油情報 |
|---|---|---|---|---|---|
| 1 | link | 当月1日 | 42 | false | — |
| 2 | mark | 当月3日 | — | true | 40L, 172円/L, 6880円 |
| 3 | link | 当月3日 | 87 | false | — |
| 4 | mark | 当月7日 | — | false | — |
| 5 | link | 当月7日 | 38 | false | — |
| 6 | mark | 当月10日 | — | true | 45L, 174円/L, 7830円 |
| 7 | link | 当月10日 | 112 | false | — |
| 8 | mark | 当月14日 | — | false | — |
| 9 | link | 当月14日 | 55 | false | — |

> 日付は `_monthStart(dayOfMonth)` で計算する。
> 当月の指定日がまだ来ていない場合でも、同じ計算式で生成する（過去/未来を問わず固定）。

## 6-3. PaymentDomain 一覧

| id | 金額 | 支払者 | 割り勘対象 | メモ |
|---|---|---|---|---|
| `pay-seed-b1` | 6880 | 自分 | 自分のみ | ガソリン代（当月3日） |
| `pay-seed-b2` | 7830 | 自分 | 自分のみ | ガソリン代（当月10日） |

---

# 7. シナリオC: 横浜エリア訪問ルート

## 7-1. EventDomain フィールド

| フィールド | 値 |
|---|---|
| id | `event-seed-c` |
| eventName | `横浜エリア訪問ルート` |
| topic | seedTopics[visitWork] |
| trans | `マイカー`（trans-001） |
| members | 自分（1名） |
| tags | `[]`（なし） |
| payMember | 自分 |
| createdAt / updatedAt | `_rel(-3, 8, 0)` |

## 7-2. Mark（地点）一覧

visitWorkトピックは到着・作業開始・休憩・作業終了・出発アクションを記録する。

| seq | markLinkType | 名称 | 距離km | アクション |
|---|---|---|---|---|
| 1 | mark | 事務所出発 | — | 出発（visit_work_depart） |
| 2 | link | — | 28 | — |
| 3 | mark | A社（横浜駅前） | — | 到着・作業開始・作業終了 |
| 4 | link | — | 5 | — |
| 5 | mark | B社（みなとみらい） | — | 到着・作業開始・休憩・作業終了 |
| 6 | link | — | 12 | — |
| 7 | mark | C社（磯子） | — | 到着・作業開始・作業終了 |
| 8 | link | — | 25 | — |
| 9 | mark | 事務所帰着 | — | 到着（visit_work_arrive） |

> アクションIDは既存 seedActions の `visit_work_arrive` / `visit_work_depart` / `visit_work_start` / `visit_work_end` / `visit_work_break` を使用する。

## 7-3. 日付割り当て

全地点に `_rel(-3)` を基点として時刻オフセットを付与する（9:00〜17:30 の範囲）。

## 7-4. PaymentDomain 一覧

| id | 金額 | 支払者 | 割り勘対象 | メモ |
|---|---|---|---|---|
| `pay-seed-c1` | 500 | 自分 | 自分のみ | 駐車場（A社） |
| `pay-seed-c2` | 800 | 自分 | 自分のみ | 駐車場（B社） |
| `pay-seed-c3` | 950 | 自分 | 自分のみ | 昼食 |

---

# 8. 初回起動フラグ（既存ユーザー保護）

## 8-1. 目的

既存ユーザーのデータを上書きしないよう、アプリ初回起動時のみシードデータを投入する。

## 8-2. フラグ仕様

| 項目 | 仕様 |
|---|---|
| ライブラリ | `shared_preferences` |
| キー名 | `seed_data_seeded` |
| 型 | bool |
| 初期値（未設定） | false（シード未済） |
| シード実行後 | true に更新 |

## 8-3. 実装方針

現在は InMemory 実装のため、アプリ再起動のたびにシードデータが再ロードされる。
`shared_preferences` で管理するフラグは、drift 実装（本番DB）への移行後に有効化されるものとして設計を定義しておく。

**InMemory 実装フェーズ（現状）:**
- `di.dart` で `InMemoryEventRepository(initialItems: seedEvents)` を呼び出す既存の仕組みを維持する
- 特別なフラグ制御は不要

**drift 実装フェーズ（将来）:**
- アプリ起動時に `shared_preferences` の `seed_data_seeded` を確認する
- `false` の場合のみシードデータをDBに投入し、フラグを `true` に更新する
- `true` の場合は何もしない（既存データ保護）
- この処理は `di.dart` の `setupDi()` 内または専用の `SeedService` として実装する

---

# 9. Data Flow

- アプリ起動 → `setupDi()` 内で `InMemoryEventRepository(initialItems: seedEvents)` を生成
- `seedEvents` は `seed_data.dart` に定義された3シナリオ（A・B・C）のリスト
- `EventListBloc` が Repository から全イベントをロードし、event_list 画面に3件表示される
- 各イベントの詳細画面（BasicInfo・MichiInfo・PaymentInfo）はそれぞれ正しいデータを参照する

---

# 10. 変更ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | seedEvents を3シナリオに差し替え。相対日付ヘルパー追加。メンバー名見直し |

変更しないファイル:
- `flutter/lib/app/di.dart`（変更不要）
- 各 InMemory Repository 実装

---

# 11. テストシナリオ

## 前提条件

- iOSシミュレーター起動済み
- アプリを新規インストール（または GetIt.I.reset() でリセット）した状態
- シードデータが投入されること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-SD-001 | 新規起動時にイベント一覧に3件表示される | High |
| TC-SD-002 | シナリオA（箱根日帰りドライブ）のタイムラインが正しく表示される | High |
| TC-SD-003 | シナリオA の支払いタブに4件の支払いが表示される | High |
| TC-SD-004 | シナリオA の給油情報が記録されている（足柄SA） | High |
| TC-SD-005 | シナリオB（業務走行記録）の集計タブで走行距離合計が表示される | High |
| TC-SD-006 | シナリオB の支払いタブに2件の支払いが表示される | Medium |
| TC-SD-007 | シナリオC（横浜エリア訪問ルート）の訪問作業アクションが記録されている | High |
| TC-SD-008 | シナリオC の支払いタブに3件の支払いが表示される | Medium |
| TC-SD-009 | 各イベントの日付が現在日付に対する相対日付で表示される（固定日付でない） | Medium |

---

## シナリオ詳細

### TC-SD-001: 新規起動時にイベント一覧に3件表示される

**前提:** アプリを新規インストール（またはリセット）した状態

**操作手順:**
1. アプリを起動してイベント一覧画面を表示する

**期待結果:**
- イベント一覧に3件のイベントカードが表示される
- 「箱根日帰りドライブ」「4月 業務走行記録」「横浜エリア訪問ルート」が表示される

**実装ノート:**
- `Key('eventList_card_0')` / `Key('eventList_card_1')` / `Key('eventList_card_2')` を確認する
- イベント名は `Key('eventList_eventName_0')` などで確認する

---

### TC-SD-002: シナリオA のタイムラインが正しく表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
2. MichiInfo タブを表示する

**期待結果:**
- タイムラインに11件のMarkLink（mark 7件・link 4件）が表示される
- 「自宅出発」「足柄SA」「箱根神社」「大涌谷」「箱根湯本（昼食）」「帰宅」の地点名が確認できる

**実装ノート:**
- `Key('michiInfo_tab')` でタブ切り替え
- `Key('michiInfo_markCard_0')` ... でカード確認（スクロール対応）

---

### TC-SD-003: シナリオA の支払いタブに4件の支払いが表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
2. PaymentInfo タブを表示する

**期待結果:**
- 支払い一覧に4件が表示される
- 「高速代（往復）」「ガソリン代」「昼食」「駐車場」のメモが確認できる

**実装ノート:**
- `Key('paymentInfo_tab')` でタブ切り替え
- `Key('paymentInfo_card_0')` ... で支払いカード確認

---

### TC-SD-004: シナリオA の給油情報が記録されている（足柄SA）

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
2. MichiInfo タブを表示する
3. 「足柄SA」マークをタップして詳細を確認する

**期待結果:**
- マーク詳細に給油情報が表示される（35L / 175円/L / 6,125円）

**実装ノート:**
- `Key('markDetail_fuelSection')` で給油セクション確認

---

### TC-SD-005: シナリオB の集計タブで走行距離合計が表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「4月 業務走行記録」をタップしてイベント詳細を開く
2. 集計タブ（Overview / Dashboard）を表示する

**期待結果:**
- 走行距離合計（42+87+38+112+55 = 334km）が表示される
- 燃料コスト合計（6880+7830 = 14710円）が表示される

**実装ノート:**
- `Key('dashboard_totalDistance')` または集計セクションのキーで確認

---

### TC-SD-006: シナリオB の支払いタブに2件の支払いが表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「4月 業務走行記録」をタップしてイベント詳細を開く
2. PaymentInfo タブを表示する

**期待結果:**
- 支払い一覧に2件が表示される（「ガソリン代（当月3日）」「ガソリン代（当月10日）」）

**実装ノート:**
- `Key('paymentInfo_card_0')` / `Key('paymentInfo_card_1')` で確認

---

### TC-SD-007: シナリオC の訪問作業アクションが記録されている

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
2. MichiInfo タブを表示する
3. 「A社（横浜駅前）」マークを確認する

**期待結果:**
- タイムラインに9件のMarkLinkが表示される
- A社マークに「到着」「作業開始」「作業終了」アクションが記録されている
- B社マークに「到着」「作業開始」「休憩」「作業終了」アクションが記録されている

**実装ノート:**
- `Key('michiInfo_markCard_2')` でA社カード確認（スクロール対応）

---

### TC-SD-008: シナリオC の支払いタブに3件の支払いが表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
2. PaymentInfo タブを表示する

**期待結果:**
- 支払い一覧に3件が表示される（「駐車場（A社）」「駐車場（B社）」「昼食」）

**実装ノート:**
- `Key('paymentInfo_card_0')` / `Key('paymentInfo_card_1')` / `Key('paymentInfo_card_2')` で確認

---

### TC-SD-009: 各イベントの日付が相対日付で表示される

**前提:** TC-SD-001 が成立している状態

**操作手順:**
1. イベント一覧を確認する
2. 「箱根日帰りドライブ」をタップしてMichiInfoを開く
3. 先頭のマーク（自宅出発）の日付を確認する

**期待結果:**
- 「箱根日帰りドライブ」の日付が現在日から7日前の日付で表示される（固定日付 2026-03-15 ではない）
- 「横浜エリア訪問ルート」の日付が現在日から3日前の日付で表示される

**実装ノート:**
- 日付文字列を取得して `DateTime.now()` との差分で検証する
- `Key('michiInfo_markDate_0')` で先頭マーク日時を確認

---

# 12. 注意事項

## 既存テストへの影響

既存の Integration Test はシードデータのイベント名・件数・メンバー名を参照している可能性がある。
シードデータ変更後に既存テストが FAIL した場合は tester が修正する。

特に以下のテストファイルは変更影響を受ける可能性が高い:
- `integration_test/dashboard_test.dart`（シードデータの件数・金額参照）
- `integration_test/payment_from_mark_link_test.dart`（イベント・メンバー参照）

## Member名変更の影響

`member-002`（花子 → 田中）・`member-003`（健太 → 鈴木）の名前変更は、
これらのメンバー名を検索している既存テストに影響する。
flutter-dev は実装前に既存テストを確認し、tester と連携して修正方針を決める。

---

# End of Feature Spec
