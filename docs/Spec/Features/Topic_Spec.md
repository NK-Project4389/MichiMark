# Topic Feature Specification

Platform: **Flutter / Dart**
Version: 2.0
Purpose: MichiMarkのイベント単位にTopicを設定し、用途に応じた表示制御とOverview集計を実現する。

## 改版履歴

| バージョン | 日付 | 変更概要 |
|---|---|---|
| 1.0 | 初版 | Topic Feature 初期設計 |
| 2.0 | 2026-04-05 | REQ-001〜002・007（枠）対応。BasicInfoのTopic選択UI廃止・TopicConfig拡張 |
| 2.1 | 2026-04-05 | REQ-007・008確定対応。TopicThemeColor enum定義・EventListカード色・EventDetailヘッダーグラデーション適用 |

---

# 1. Feature Overview

## Feature Name

Topic

## Purpose

ユーザーがイベントに「用途カテゴリ（Topic）」を設定することで、不要な入力項目を非表示にし、用途に合ったOverview集計を提供する。Phase 1では「移動コスト可視化（movingCost）」と「旅費可視化（travelExpense）」の2種を固定値として提供する。

## Scope

含むもの
- TopicDomain・TopicType enum の新規定義
- TopicConfig（表示制御設定・アクション候補リスト）の定義
- EventDomain への `topic` フィールド追加
- BasicInfo Feature への Topic読み取り専用表示（REQ-001）
- MarkDetail / LinkDetail Feature への TopicConfig受け渡しと表示切替
- EventDetail Feature への TopicConfig伝播設計
- travelExpense用のOverview集計ロジック（Adapter/UseCase層）
- EventRepository・driftテーブルへの topic 永続化対応
- SelectionType への `eventTopic` 追加
- TopicConfigへの `markActions`・`linkActions` 追加（REQ-002）
- TopicConfigへの `themeColor` 定義（REQ-007確定値で設定）
- TopicDomainへの `color` フィールド追加（REQ-007対応）
- `TopicThemeColor` enum の定義（10色 × Primary/Dark/Tint）（REQ-007）
- EventListカードへのTopicカラー左ボーダー適用（REQ-007）
- EventDetailヘッダーへのグラデーション・トピック名ラベル適用（REQ-008）

含まないもの
- カスタムTopic作成・編集（Phase 3）
- 固定Topic追加（Phase 2）
- Topic別集計レポート（Aggregation要件書参照）
- 精算アドバイス表示（「誰が誰にいくら払う」形式）
- BasicInfoでのTopic変更UI（REQ-001により廃止。EventList新規作成フローはT-021で対応）

---

# 2. TopicDomain 定義（新規）

## フィールド定義

| フィールド名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `id` | `String` | ❌ | - | PK（UUID文字列） |
| `topicName` | `String` | ❌ | - | 表示名（例: 「移動コスト可視化」） |
| `topicType` | `TopicType` | ❌ | - | 用途種別enum |
| `isVisible` | `bool` | ❌ | `true` | 選択画面での表示制御 |
| `isDeleted` | `bool` | ❌ | `false` | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | - | 登録日時 |
| `updatedAt` | `DateTime` | ❌ | - | 更新日時 |
| `color` | `String?` | ✅ | `null` | `TopicThemeColor` の enum name を保存する文字列（例: `'emeraldGreen'`）。null の場合は TopicConfig のデフォルト themeColor にフォールバックする |

- `Equatable` を継承する
- `const` コンストラクタ使用
- UIを知らない・Draftを知らない

`themeColor` getter の設計:
- `TopicThemeColor.values.firstWhere((c) => c.name == color, orElse: () => TopicConfig.forType(topicType).themeColor)` のロジックで解決する
- `color` が null または未知の名前の場合は TopicConfig に定義されたデフォルト値にフォールバックする

> **[REQ-007 確定]** デザイン確定（2026-04-05）に伴い、`color` フィールドの値は `TopicThemeColor` の enum name 文字列を使用する。SeedData値: movingCost → `'emeraldGreen'`、travelExpense → `'amberOrange'`。

## TopicType enum

| 値 | 表示名 | 説明 |
|---|---|---|
| `movingCost` | 移動コスト可視化 | 燃料・距離・燃費の記録が主目的 |
| `travelExpense` | 旅費可視化 | 経費・精算の記録が主目的 |

> Phase 3でカスタム種別が追加される可能性を想定し、enumを参照する形で表示制御を実装する（ハードコード禁止）。

---

# 3. TopicConfig 定義（新規・REQ-002対応で拡張）

TopicConfigはTopicTypeを入力として表示制御フラグのセットを返す値オブジェクト。BlocやWidgetから参照される読み取り専用の設定値。

## フィールド定義

| フィールド名 | 型 | 説明 |
|---|---|---|
| `showMeterValue` | `bool` | MarkDetailの累積メーターを表示するか |
| `showFuelDetail` | `bool` | MarkDetail/LinkDetailの給油スイッチ+FuelDetailを表示するか |
| `allowLinkAdd` | `bool` | LinkDetailの新規追加を許可するか |
| `showLinkDistance` | `bool` | LinkDetailの走行距離を表示するか |
| `showKmPerGas` | `bool` | BasicInfoの燃費フィールドを表示するか |
| `showPricePerGas` | `bool` | BasicInfoのガソリン単価フィールドを表示するか |
| `showPayMember` | `bool` | BasicInfoのガソリン支払者フィールドを表示するか |
| `showPaymentInfoTab` | `bool` | EventDetailのPaymentInfoタブを表示するか |
| `markActions` | `List<String>` | 地点（Mark）タップ時に提示するActionIDのリスト（REQ-002） |
| `linkActions` | `List<String>` | 区間（Link）タップ時に提示するActionIDのリスト（REQ-002） |
| `themeColor` | `TopicThemeColor` | テーマカラー（REQ-007確定値）。Topic未設定のフォールバック用にデフォルト値を持たせる |

## TopicType別の設定値

| フィールド | movingCost | travelExpense |
|---|---|---|
| `showMeterValue` | `true` | `false` |
| `showFuelDetail` | `true` | `false` |
| `allowLinkAdd` | `true` | `false` |
| `showLinkDistance` | `true` | `false` |
| `showKmPerGas` | `true` | `false` |
| `showPricePerGas` | `true` | `false` |
| `showPayMember` | `true` | `false` |
| `showPaymentInfoTab` | `true` | `true` |
| `markActions` | `[出発ActionID, 到着ActionID]` | `[]` |
| `linkActions` | `[]` | `[]` |
| `themeColor` | `TopicThemeColor.emeraldGreen` | `TopicThemeColor.amberOrange` |

> **Action IDの確定値** SeedDataで定義されるUUIDを使用する。SeedData定義はActionTime_Spec.md §3を参照。

## 設計方針

- `TopicConfig.fromTopicType(TopicType type)` のファクトリ経由でのみ生成する
- Topic未設定（null）の場合は `TopicType.movingCost` 相当の設定にフォールバックする
- TopicConfigはAdapterまたはBlocが生成し、Stateに乗せてWidgetに渡す
- WidgetはTopicConfigのフラグを参照して表示を切り替える（if文でTopicTypeを直接比較しない）
- `markActions`・`linkActions` はActionTimeAdapterが参照する（REQ-002）。WidgetはこのリストのActionIDでActionTimeAdapterに問い合わせる
- `themeColor` は `TopicConfig.forType()` 内で各 TopicType に対応する `TopicThemeColor` 値を返す（REQ-007確定値）
- Topic未設定（フォールバック時）は `TopicThemeColor.defaultThemeColor` を使用する

---

# 4. EventDomain 変更

## フィールド追加

| フィールド名 | 型 | NULL許容 | デフォルト値 | 説明 |
|---|---|---|---|---|
| `topic` | `TopicDomain?` | ✅ | `null` | 設定されたTopic。null = movingCost相当にフォールバック |

> Topic変更時に既存のMarkLink・Payment・データは保持する。表示項目が変わるだけでデータの削除は行わない。

---

# 5. EventDomain.md 更新方針

`docs/Domain/EventDomain.md` に以下を追記する。

- フィールド一覧に `topic: TopicDomain?`（nullable、デフォルト null、削除ルール: nullify）を追加
- 関連Domain一覧に `TopicDomain` を追加

---

# 6. 永続化対応（drift）

## topicsテーブル（新規）

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID |
| `topic_name` | TEXT | NOT NULL | 表示名 |
| `topic_type` | TEXT | NOT NULL | 'movingCost' / 'travelExpense' |
| `is_visible` | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 1 | 表示フラグ |
| `is_deleted` | INTEGER (BOOLEAN) | NOT NULL, DEFAULT 0 | 論理削除フラグ |
| `created_at` | INTEGER (DateTime) | NOT NULL | 登録日時 |
| `updated_at` | INTEGER (DateTime) | NOT NULL | 更新日時 |
| `color` | TEXT | NULLABLE | テーマカラーコード文字列（例: `#2B7A9B`）。REQ-007用枠。デザイン確定後に値を設定 |

## eventsテーブル変更

| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| `topic_id` | TEXT | NULLABLE, FK → topics(id) ON DELETE SET NULL | TopicID |

## マイグレーション

- `DriftRepository_Spec.md` の schemaVersion を +1 する
- onUpgrade でtopicsテーブル作成・events.topic_idカラム追加を行う

## TopicRepository（新規インターフェース）

| メソッド | 説明 |
|---|---|
| `fetchAll()` | is_deleted = false の全Topic取得 |
| `fetchByType(TopicType type)` | 指定typeのTopic取得 |
| `save(TopicDomain topic)` | upsert |

Phase 1では固定2種のTopicをアプリ起動時またはDIセットアップ時にDBへseedする。

---

# 7. SelectionType 追加

既存の `SelectionType` enumに以下を追加する。

| 値 | 用途 |
|---|---|
| `eventTopic` | BasicInfoでのTopic単一選択 |

選択モードは `SelectionMode.single`。

---

# 8. BasicInfo Feature 拡張

## [v2.0変更] REQ-001対応: Topic選択UIを読み取り専用ラベルに変更

### 変更前（v1.0）
- BasicInfoViewにTopic選択行（`_SelectionRow`）を追加
- `BasicInfoEditTopicPressed`・`BasicInfoTopicSelected`・`BasicInfoAvailableTopicsReceived` Eventでの選択フロー
- `BasicInfoOpenTopicSelectionDelegate`・`BasicInfoTopicChangedDelegate` Delegate発火

### 変更後（v2.0 / REQ-001対応）
- BasicInfoViewのTopic選択行を **読み取り専用ラベル** に変更する
- ラベルは `event.topic?.topicName`（未設定時は「未設定」）を表示する
- 編集ボタン・タップ操作は表示しない
- Topic変更フローに関連するEvent・Delegateは **廃止** する（下記参照）

### BasicInfoDraft 変更

| フィールド | 型 | 説明 | 変更 |
|---|---|---|---|
| `selectedTopic` | `TopicDomain?` | 選択中のTopic（null = 未設定） | **残す（読み取り専用表示用）** |
| `availableTopics` | `List<TopicDomain>` | 選択可能なTopic一覧 | **廃止（選択UIが不要のため削除）** |

### BasicInfoState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | 現在のTopicに基づく表示制御設定 |

`BasicInfoLoaded` の `topicConfig` は `selectedTopic?.topicType` から `TopicConfig.fromTopicType()` で生成する。（変更なし）

### BasicInfoEvent 変更

| Event名 | 発火タイミング | 説明 | 変更 |
|---|---|---|---|
| `BasicInfoEditTopicPressed` | Topic選択行の編集ボタン押下 | Topic選択画面へのDelegate発火 | **廃止（選択UI削除のため）** |
| `BasicInfoTopicSelected` | Topic選択画面から結果返却時 | Draft.selectedTopicを更新 | **廃止（選択UI削除のため）** |
| `BasicInfoAvailableTopicsReceived` | EventDetailBlocからTopic一覧が渡されたとき | Draft.availableTopics更新 | **廃止（availableTopics削除のため）** |

### BasicInfoDelegate 変更

| Delegate名 | 遷移先 | 変更 |
|---|---|---|
| `BasicInfoOpenTopicSelectionDelegate` | `/selection`（eventTopic） | **廃止** |
| `BasicInfoTopicChangedDelegate` | EventDetailBloc | **廃止** |

### BasicInfoView 変更（v2.0）

- Topic行を「読み取り専用ラベル」として表示する（タップ不可・編集アイコンなし）
- `topicConfig.showKmPerGas` が false の場合、燃費フィールドを非表示にする
- `topicConfig.showPricePerGas` が false の場合、ガソリン単価フィールドを非表示にする
- `topicConfig.showPayMember` が false の場合、ガソリン支払者フィールドを非表示にする

### BasicInfoBloc 変更（v2.0）

- `BasicInfoStarted` 処理時に `domain.topic` から Draft.selectedTopic を初期化し、TopicConfigを生成してStateに反映する
- Topic変更に関するEvent処理はすべて削除する
- `TopicRepository` はコンストラクタ注入しない

### 影響するクラス・ファイル（REQ-001）

| ファイル | 変更内容 |
|---|---|
| `features/basic_info/draft/basic_info_draft.dart` | `availableTopics` フィールド削除 |
| `features/basic_info/bloc/basic_info_event.dart` | `BasicInfoEditTopicPressed`・`BasicInfoTopicSelected`・`BasicInfoAvailableTopicsReceived` 削除 |
| `features/basic_info/bloc/basic_info_bloc.dart` | 上記Event処理削除 |
| `features/basic_info/view/basic_info_view.dart` | Topic選択行をラベル表示に変更 |
| `features/event_detail/bloc/event_detail_event.dart` | `EventDetailTopicChanged` 削除（TopicChangedDelegate廃止のため） |
| `features/event_detail/bloc/event_detail_bloc.dart` | `EventDetailTopicChanged` 処理削除・TopicRepositoryのavailableTopics取得処理削除 |

---

# 9. MarkDetail Feature 拡張

## MarkDetailState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | EventDetailBlocから受け取る表示制御設定 |

## MarkDetailEvent 追加

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `MarkDetailTopicConfigUpdated` | EventDetailBlocからtopicが変更されたとき | MarkDetailBlocのtopicConfigを更新する |

## MarkDetailView 変更

- `topicConfig.showMeterValue` が false の場合、累積メーターフィールドを非表示にする
- `topicConfig.showFuelDetail` が false の場合、給油スイッチとFuelDetailセクションを非表示にする

---

# 10. LinkDetail Feature 拡張

## LinkDetailState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | EventDetailBlocから受け取る表示制御設定 |

## LinkDetailEvent 追加

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `LinkDetailTopicConfigUpdated` | EventDetailBlocからtopicが変更されたとき | LinkDetailBlocのtopicConfigを更新する |

## LinkDetailView 変更

- `topicConfig.showLinkDistance` が false の場合、走行距離フィールドを非表示にする
- `topicConfig.showFuelDetail` が false の場合、給油スイッチとFuelDetailセクションを非表示にする

## MichiInfo Feature 変更

- `topicConfig.allowLinkAdd` が false の場合、Link追加ボタンを非表示にする
- MichiInfoBlocもtopicConfigをStateに保持し、EventDetailBlocから受け取る

---

# 11. EventDetail Feature 拡張（TopicConfig伝播）

## 設計方針

TopicConfigはEventDetailレベルで保持し、子Feature（BasicInfo・MichiInfo・MarkDetail・LinkDetail）へEventを送信することで伝播させる。

- EventDetailBlocは子Blocの内部状態を参照・制御しない
- EventDetailBlocはTopicConfigが変化したとき、各子BlocへEventを一方向で送信（push）する責務のみを持つ
- 子Blocは受け取ったEventに基づき自身のStateを自律的に更新する（受動的更新）
- EventDetailBlocは子BlocのStateを読み取らない

## [v2.0変更] REQ-001対応

v2.0ではBasicInfoからのTopic変更フローが廃止されたため、以下が変更される。

### 変更前（v1.0）
- EventDetailBlocが起動時にTopicRepository.fetchAll()を呼び出してavailableTopicsを取得し、BasicInfoBlocに送信
- EventDetailTopicChanged Eventで子BlocへTopicConfig伝播
- TopicRepositoryをEventDetailBlocにDI注入

### 変更後（v2.0）
- EventDetailBlocはTopicRepositoryを使用しない（BasicInfoへのavailableTopics送信が不要のため）
- EventDetailTopicChanged EventはTopicがEventDetail初回起動時にドメインから読み込む用途のみに限定
- TopicConfigは `EventDetailStarted` 処理時に `domain.topic` から一度だけ生成してStateに保持する

## EventDetailBloc 変更（v2.0）

- `EventDetailStarted` 処理時に `domain.topic` からTopicConfigを生成してStateに保持する
- `EventDetailTopicChanged` は **廃止**（Topic変更フロー廃止のため）
- TopicConfigが変化した場合（現フェーズでは起動時のみ）、`MarkDetailTopicConfigUpdated` / `LinkDetailTopicConfigUpdated` / `MichiInfoTopicConfigUpdated` を各子Blocへ送信する
- EventDetailBlocはTopicRepositoryをDI注入しない（v2.0以降）

## EventDetailEvent 変更（v2.0）

| Event名 | 発火タイミング | 説明 | 変更 |
|---|---|---|---|
| `EventDetailTopicChanged` | BasicInfoTopicChangedDelegate受信時 | TopicConfig再生成・子Bloc伝播 | **廃止**（REQ-001によりTopic変更UI廃止） |

## 伝播フロー（v2.0）

```
EventDetailBloc（EventDetailStarted時）
  ↓ domain.topicからTopicConfig生成
  ↓ 各子BlocへEvent送信（一方向push）
MichiInfoBloc / MarkDetailBloc / LinkDetailBloc（各自のStateを自律的に更新）
BasicInfoBloc（domain.topicをDraftに保持・読み取り専用表示）
```

## EventDetailState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | 現在の有効なTopicConfig |

---

# 12. Overview集計ロジック（travelExpense）

## Overview Feature との分担方針

> [懸念2対応] movingCost vs travelExpense の切り替え責務（どちらのOverviewを表示するか）は EventDetailOverview Feature が担う。EventDetailOverview Feature の詳細設計は独立したSpecで定義する（`EventDetailOverview_Spec.md`）。本Specはtravelexpense用のAdapter・Projection定義のみを担当する。

## 設計方針

収支バランスの集計ロジックはAdapter/UseCase層に実装する。View・BLoCへの直接実装は禁止。

## TravelExpenseOverviewAdapter（新規）

担当: `EventDomain` を受け取り `TravelExpenseOverviewProjection` を返す。

### TravelExpenseOverviewProjection フィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `totalExpense` | `int` | 全PaymentのpaymentAmount合計（円） |
| `memberCosts` | `List<MemberCostProjection>` | メンバー別トータルコスト一覧 |
| `memberBalances` | `List<MemberBalanceProjection>` | メンバー別収支バランス一覧 |

### MemberCostProjection フィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `memberName` | `String` | メンバー名（表示用） |
| `totalCost` | `int` | このメンバーが負担すべき金額の合計（円） |

### MemberBalanceProjection フィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `memberName` | `String` | メンバー名（表示用） |
| `balance` | `int` | 支払額 − 負担額（プラス=受け取る側、マイナス=支払う側） |

## 収支バランス算出ロジック（Adapterが実装）

各Paymentに対して以下を処理する。

1. `paymentAmount` / `splitMembers.length` = 1人あたり負担額（端数は整数除算で切り捨て）
2. `splitMembers` が空の場合 → `paymentMember` のみが `paymentAmount` 全額を負担する（割り勘なし）
3. `splitMembers` が空でない場合 → 各splitMemberに均等分を加算する
4. `paymentMember` の「支払額」に `paymentAmount` を加算する
5. balance = 各メンバーの支払額合計 − 負担額合計

> 全メンバーのbalance合計は必ず0になる（整数除算の端数が生じる場合の処理は実装時に検討、基本は切り捨て）。

## Overview BLoC設計

- OverviewBlocはEventDomainとtopicConfigを受け取り、topicTypeに応じてProjectionを切り替える
- `topicConfig` が `movingCost` 相当 → movingCost用Projectionを生成する
- `topicConfig` が `travelExpense` 相当 → `TravelExpenseOverviewAdapter.toProjection(domain)` を呼ぶ
- OverviewBlocはAdapterのみを呼び出す。集計ロジックをBloC内に書かない

---

# 13. Data Flow

## Topic表示フロー（v2.0 / REQ-001対応）

- EventDetailBloc が `EventDetailStarted` 処理時に `domain.topic` からTopicConfigを生成してStateに保持する
- EventDetailBloc が MarkDetailBloc・LinkDetailBloc・MichiInfoBloc へ `*TopicConfigUpdated` Eventを一方向で送信する
- BasicInfoBloc が `BasicInfoStarted` 処理時に `domain.topic` を Draft.selectedTopic に保持し、TopicConfigを生成してStateに反映する
- BasicInfoView が `topicConfig` フラグに基づいて表示を制御する
- BasicInfoView のTopic行は読み取り専用ラベルとして表示する（タップ操作なし）

> [変更理由] v1.0ではBasicInfoからのTopic選択フローが存在したが、REQ-001によりTopic変更UIを廃止。起動時の一方向初期化フローのみが残る。

## Overview集計フロー（travelExpense）

- OverviewBloc が EventDomain と TopicConfig を受け取る
- topicConfig の内容に応じて TravelExpenseOverviewAdapter を呼ぶ
- Adapter が PaymentDomainのリストを処理して TravelExpenseOverviewProjection を生成する
- OverviewBloc が Projection を State に乗せる
- OverviewView が State から Projection を受け取って表示する

---

# 14. BLoC Event 一覧

## BasicInfoBloc Event（v2.0）

| Event名 | 発火タイミング | ペイロード | 変更 |
|---|---|---|---|
| `BasicInfoEditTopicPressed` | Topic選択ボタン押下 | なし | **廃止**（REQ-001） |
| `BasicInfoTopicSelected` | 選択画面から返却 | `TopicDomain? topic` | **廃止**（REQ-001） |
| `BasicInfoAvailableTopicsReceived` | EventDetailBlocから初期化時 | `List<TopicDomain> topics` | **廃止**（REQ-001） |

## EventDetailBloc Event（v2.0）

| Event名 | 発火タイミング | ペイロード | 変更 |
|---|---|---|---|
| `EventDetailTopicChanged` | BasicInfoTopicChangedDelegate受信時 | `TopicDomain? topic` | **廃止**（REQ-001） |

## MarkDetailBloc 追加Event（変更なし）

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `MarkDetailTopicConfigUpdated` | EventDetailBlocからの一方向push | `TopicConfig config` |

## LinkDetailBloc 追加Event（変更なし）

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `LinkDetailTopicConfigUpdated` | EventDetailBlocからの一方向push | `TopicConfig config` |

## MichiInfoBloc 追加Event（変更なし）

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `MichiInfoTopicConfigUpdated` | EventDetailBlocからの一方向push | `TopicConfig config` |

---

# 15. Delegate Contract（v2.0）

| Delegate名 | 所属Feature | 受取先 | 遷移・処理内容 | 変更 |
|---|---|---|---|---|
| `BasicInfoOpenTopicSelectionDelegate` | BasicInfoBloc | BasicInfoViewのBlocListener | `/selection`（eventTopic, single）へ `context.push` する | **廃止**（REQ-001） |
| `BasicInfoTopicChangedDelegate` | BasicInfoBloc | EventDetailPageのBlocListener | `EventDetailTopicChanged` をEventDetailBlocへ送信する | **廃止**（REQ-001） |

> [v2.0] REQ-001によりTopic選択UIが廃止されたため、BasicInfo関連のDelegate Contract（Topic系）はすべて廃止。

---

# 16. ファイル構成

```
flutter/lib/
  domain/
    topic/
      topic_domain.dart         -- TopicDomain, TopicType enum
      topic_config.dart         -- TopicConfig（値オブジェクト）。displayName フィールド含む
      topic_theme_color.dart    -- TopicThemeColor enum（10色 × primaryColor/darkColor/tintColor）
  repository/
    topic_repository.dart       -- TopicRepository（abstract class）
    impl/
      in_memory/
        in_memory_topic_repository.dart
      drift/
        repository/
          drift_topic_repository.dart
  adapter/
    travel_expense_overview_adapter.dart  -- 収支バランス集計ロジック
  features/
    basic_info/
      bloc/
        basic_info_event.dart   -- 既存拡張（Topic関連Event追加）
        basic_info_state.dart   -- 既存拡張（topicConfig追加）
        basic_info_bloc.dart    -- 既存拡張（Topic処理追加）
      draft/
        basic_info_draft.dart   -- 既存拡張（selectedTopic追加）
    mark_detail/
      bloc/
        mark_detail_event.dart  -- 既存拡張（TopicConfigUpdated追加）
        mark_detail_state.dart  -- 既存拡張（topicConfig追加）
        mark_detail_bloc.dart   -- 既存拡張（TopicConfig処理追加）
    link_detail/
      bloc/
        link_detail_event.dart  -- 既存拡張（TopicConfigUpdated追加）
        link_detail_state.dart  -- 既存拡張（topicConfig追加）
        link_detail_bloc.dart   -- 既存拡張（TopicConfig処理追加）
    michi_info/
      bloc/
        michi_info_event.dart   -- 既存拡張（TopicConfigUpdated追加）
        michi_info_state.dart   -- 既存拡張（topicConfig追加）
        michi_info_bloc.dart    -- 既存拡張（TopicConfig処理追加）
    event_detail/
      bloc/
        event_detail_event.dart -- 既存拡張（EventDetailTopicChanged追加）
        event_detail_state.dart -- 既存拡張（topicConfig追加）
        event_detail_bloc.dart  -- 既存拡張（TopicConfig管理・子Blocへの一方向Event送信追加）
```

---

# 17. 受け入れ条件

## REQ-001 対応

- [ ] EventDetailの基本情報タブでTopicが読み取り専用ラベルとして表示される（選択・変更UIが存在しない）
- [ ] Topicラベルにタップしても何も起きない（遷移・操作なし）

## REQ-007 対応（EventListカード色分け）

詳細は §21 参照。

- [ ] EventListカードの左に4dpのTopicカラーボーダーが表示されること
- [ ] Topic未設定カードはグレー（`Color(0xFF9E9E9E)`）ボーダーで表示されること
- [ ] TopicType ごとにボーダーカラーが異なること（movingCost: emeraldGreen、travelExpense: amberOrange）

## REQ-008 対応（EventDetailヘッダー）

詳細は §22 参照。

- [ ] EventDetailのAppBarがTopicのグラデーションカラーで表示されること
- [ ] AppBarにトピック名ラベルが白テキストで表示されること
- [ ] Topic未設定のEventDetailはデフォルトのAppBar表示であること

## 既存条件

- [ ] Topic未設定のイベントはmovingCost相当で表示される
- [ ] movingCost選択時：累積メーター・給油Detail・Linkの追加・燃費・ガソリン単価・ガソリン支払者・PaymentInfoがすべて表示される
- [ ] travelExpense選択時：累積メーターが非表示になる
- [ ] travelExpense選択時：MarkDetail・LinkDetailの給油スイッチとFuelDetailが非表示になる
- [ ] travelExpense選択時：MichiInfoのLink追加ボタンが非表示になる
- [ ] travelExpense選択時：BasicInfoの燃費・ガソリン単価・ガソリン支払者が非表示になる
- [ ] travelExpense選択時：PaymentInfoタブが表示される
- [ ] travelExpense OverviewにメンバーごとのトータルコストとしてsplitMembersから算出した負担合計が表示される
- [ ] travelExpense OverviewのメンバーごとのbalanceはすべてのPaymentを集計して全員の合計が0になる
- [ ] splitMembers が空のPaymentは支払者1人負担として計算される
- [ ] Topic変更後も既存のMarkLink・Payment・データが失われない
- [ ] 収支バランスの集計ロジックがAdapter層に実装されている（View・BLoCに書かれていない）
- [ ] TopicConfigのフラグを参照して表示制御している（TopicTypeを直接if比較していない）

---

# 18. 非機能方針

- Phase 3のカスタマイズ対応を見越してTopicConfigは `TopicConfig.fromTopicType()` ファクトリ経由で生成する
- Widget内でTopicTypeをswitch/if比較する実装は禁止する（TopicConfigのフラグのみ参照する）
- Adapter/UseCase層に集計ロジックを置き、BLocはAdapterの呼び出しのみを行う
- Topic未設定はmovingCostにフォールバックする。この処理はTopicConfig生成時に実装する

---

# 19. SwiftUI版との対応

| Flutter設計 | 対応SwiftUI要素 |
|---|---|
| TopicDomain / TopicType | SwiftUI版には相当概念なし（新規） |
| TopicConfig | SwiftUI版には相当概念なし（新規） |
| TravelExpenseOverviewAdapter | SwiftUI版のOverviewReducer集計ロジックに相当 |

---

# 20. TopicThemeColor 定義（REQ-007）

## 目的

Topic ごとに異なるカラーアクセントを EventList カードおよび EventDetail ヘッダーへ適用するため、カラーパレットを enum として定義する。

## TopicThemeColor enum（10色）

| enum値 | Primary HEX | Flutter Color |
|---|---|---|
| `coralRed` | #D94F4F | Color(0xFFD94F4F) |
| `amberOrange` | #E07B39 | Color(0xFFE07B39) |
| `goldenYellow` | #C4A43A | Color(0xFFC4A43A) |
| `freshGreen` | #4DB36B | Color(0xFF4DB36B) |
| `emeraldGreen` | #2E9E6B | Color(0xFF2E9E6B) |
| `tealGreen` | #1E8A8A | Color(0xFF1E8A8A) |
| `brandTeal` | #2B7A9B | Color(0xFF2B7A9B) |
| `indigoBlue` | #3D65C4 | Color(0xFF3D65C4) |
| `violetPurple` | #7B5CC4 | Color(0xFF7B5CC4) |
| `rosePink` | #C4497A | Color(0xFFC4497A) |

## 各色が持つ3値の定義

各 `TopicThemeColor` 値は以下の3つの getter を持つ。

| getter名 | 説明 | 算出方法 |
|---|---|---|
| `primaryColor` | メインカラー | 上記テーブルの Primary HEX をそのまま使用 |
| `darkColor` | ダークバリアント（グラデーション開始色） | Primary の輝度を 0.75 倍にした色 |
| `tintColor` | 淡い背景色（カード背景への Tint 用） | Primary を不透明度 0.15 で白背景に重ねた色 |

> `darkColor` と `tintColor` の具体的な計算（HSL輝度操作・alphaブレンド）は実装時に Dart レベルで定義する。Spec には計算方針のみを記載する。

## デフォルトカラー（Topic未設定時）

```
TopicThemeColor.defaultThemeColor → Color(0xFF9E9E9E)（グレー）
```

- `defaultThemeColor` は `TopicThemeColor` enum の static getter として定義する
- Topic が null または未設定の EventListCard・EventDetail はこのカラーで表示する

## TopicType へのデフォルト割り当て

| TopicType | デフォルト TopicThemeColor |
|---|---|
| `movingCost` | `TopicThemeColor.emeraldGreen` |
| `travelExpense` | `TopicThemeColor.amberOrange` |

---

# 21. EventListCard への Topicカラー適用（REQ-007）

## 概要

EventList の各カードに Topic のテーマカラーを左ボーダーとして適用する。

## カード表示仕様

| 要素 | 仕様 |
|---|---|
| 左ボーダー幅 | 4dp |
| 左ボーダーカラー | `topic.themeColor.primaryColor` |
| 背景 Tint | `topic.themeColor.tintColor`（任意・実装時に適用可否を判断） |
| Topic 未設定時 | `TopicThemeColor.defaultThemeColor`（グレー `Color(0xFF9E9E9E)`）で左ボーダーを表示 |

## カラー取得フロー

- EventListCard は EventListProjection（または同等の Projection）を受け取る
- Projection に `themeColor: TopicThemeColor` フィールドを持たせる
- Projection の `themeColor` は `event.topic?.themeColor ?? TopicThemeColor.defaultThemeColor` で解決する
- Widget は直接 Domain を参照せず Projection のみを参照する

## 受け入れ条件（REQ-007）

- [ ] EventListカードの左に 4dp のTopicカラーボーダーが表示されること
- [ ] Topic未設定カードはグレー（`Color(0xFF9E9E9E)`）ボーダーで表示されること
- [ ] TopicType ごとにボーダーカラーが異なること（movingCost: emeraldGreen、travelExpense: amberOrange）
- [ ] Widget が TopicDomain を直接参照していないこと（Projection 経由であること）

---

# 22. EventDetail ヘッダーへの Topicカラー適用（REQ-008）

## 概要

EventDetail 画面の AppBar またはヘッダーエリアに TopicThemeColor のグラデーションを適用し、トピック名ラベルを白テキストで表示する。

## ヘッダー表示仕様

| 要素 | 仕様 |
|---|---|
| グラデーション種別 | LinearGradient |
| グラデーション開始色 | `topicThemeColor.darkColor` |
| グラデーション終了色 | `topicThemeColor.primaryColor` |
| グラデーション方向 | `begin: Alignment.topLeft, end: Alignment.bottomRight` |
| テキストカラー | `Colors.white` |
| アイコンカラー | `Colors.white` |
| トピック名ラベル | `TopicConfig.forType(event.topicType).displayName`（日本語名） |
| Topic 未設定時 | グラデーションなし・デフォルト AppBar 表示（ラベル非表示） |

## `displayName` の値

| TopicType | displayName |
|---|---|
| `movingCost` | 「移動コスト可視化」 |
| `travelExpense` | 「旅費可視化」 |

> `displayName` は `TopicConfig` に追加する文字列フィールドとして定義する。

## TopicConfig フィールド追加（REQ-008対応）

| フィールド名 | 型 | 説明 |
|---|---|---|
| `displayName` | `String` | トピックの日本語表示名。EventDetailヘッダーラベルに使用 |

## EventDetailState への影響

- `EventDetailLoaded` 状態に `topicThemeColor: TopicThemeColor?` フィールドを追加する
- Topic未設定の場合は `null` とし、Widget 側でデフォルト AppBar を表示する
- `topicDisplayName: String?` フィールドも追加し、ヘッダーラベルの文字列を State から受け取る

## カラー取得フロー

- EventDetailBloc は `EventDetailStarted` 処理時に `domain.topic` から `topicThemeColor` を解決して State に保持する
- Topic が null の場合、State の `topicThemeColor` も null とする
- EventDetailPage の BlocBuilder が `topicThemeColor` を参照し、AppBar の decoration を切り替える
- Widget は TopicDomain を直接参照しない（State 経由のみ）

## 受け入れ条件（REQ-008）

- [ ] EventDetailのAppBarがTopicのグラデーションカラー（dark → primary）で表示されること
- [ ] AppBarにトピック名ラベルが白テキストで表示されること
- [ ] Topic未設定のEventDetailはデフォルトのAppBar表示であること（ラベル・グラデーションなし）
- [ ] Widget が TopicDomain を直接参照せず State 経由で色を取得していること

---

# End of Topic Spec
