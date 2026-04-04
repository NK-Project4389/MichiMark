# Topic Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: MichiMarkのイベント単位にTopicを設定し、用途に応じた表示制御とOverview集計を実現する。

---

# 1. Feature Overview

## Feature Name

Topic

## Purpose

ユーザーがイベントに「用途カテゴリ（Topic）」を設定することで、不要な入力項目を非表示にし、用途に合ったOverview集計を提供する。Phase 1では「移動コスト可視化（movingCost）」と「旅費可視化（travelExpense）」の2種を固定値として提供する。

## Scope

含むもの
- TopicDomain・TopicType enum の新規定義
- TopicConfig（表示制御設定）の定義
- EventDomain への `topic` フィールド追加
- BasicInfo Feature への Topic選択UI追加（既存Blocの拡張）
- MarkDetail / LinkDetail Feature への TopicConfig受け渡しと表示切替
- EventDetail Feature への TopicConfig伝播設計
- travelExpense用のOverview集計ロジック（Adapter/UseCase層）
- EventRepository・driftテーブルへの topic 永続化対応
- SelectionType への `eventTopic` 追加

含まないもの
- カスタムTopic作成・編集（Phase 3）
- 固定Topic追加（Phase 2）
- Topic別集計レポート（Aggregation要件書参照）
- 精算アドバイス表示（「誰が誰にいくら払う」形式）

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

- `Equatable` を継承する
- `const` コンストラクタ使用
- UIを知らない・Draftを知らない

## TopicType enum

| 値 | 表示名 | 説明 |
|---|---|---|
| `movingCost` | 移動コスト可視化 | 燃料・距離・燃費の記録が主目的 |
| `travelExpense` | 旅費可視化 | 経費・精算の記録が主目的 |

> Phase 3でカスタム種別が追加される可能性を想定し、enumを参照する形で表示制御を実装する（ハードコード禁止）。

---

# 3. TopicConfig 定義（新規）

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

## 設計方針

- `TopicConfig.fromTopicType(TopicType type)` のファクトリ経由でのみ生成する
- Topic未設定（null）の場合は `TopicType.movingCost` 相当の設定にフォールバックする
- TopicConfigはAdapterまたはBlocが生成し、Stateに乗せてWidgetに渡す
- WidgetはTopicConfigのフラグを参照して表示を切り替える（if文でTopicTypeを直接比較しない）

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

## BasicInfoDraft 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `selectedTopic` | `TopicDomain?` | 選択中のTopic（null = 未設定） |

## BasicInfoState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | 現在のTopicに基づく表示制御設定 |

`BasicInfoLoaded` に `topicConfig` を追加する。topicConfigは `selectedTopic?.topicType` から `TopicConfig.fromTopicType()` で生成する。

## BasicInfoEvent 追加

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `BasicInfoEditTopicPressed` | Topic選択行の編集ボタン押下 | Topic選択画面へのDelegate発火 |
| `BasicInfoTopicSelected` | Topic選択画面から結果返却時 | Draft.selectedTopicを更新しtopicConfigも再生成 |

## BasicInfoDelegate 追加

| Delegate名 | 遷移先 | 説明 |
|---|---|---|
| `BasicInfoOpenTopicSelectionDelegate` | `/selection`（eventTopic） | Topic選択画面を開く |

## BasicInfoView 変更

- Topic選択行を `_SelectionRow` として既存UI形式で追加する
- `topicConfig.showKmPerGas` が false の場合、燃費フィールドを非表示にする
- `topicConfig.showPricePerGas` が false の場合、ガソリン単価フィールドを非表示にする
- `topicConfig.showPayMember` が false の場合、ガソリン支払者フィールドを非表示にする

## BasicInfoBloc 変更

- `BasicInfoStarted` 処理時に `domain.topic` から Draft を初期化する
- `BasicInfoTopicSelected` 処理時に Draft.selectedTopic を更新し、TopicConfigを再生成してStateに反映する
- `TopicRepository` をコンストラクタ注入する（Selection画面向けにfetchAllが必要なため）

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

TopicConfigはEventDetailレベルで保持し、子Feature（BasicInfo・MichiInfo・MarkDetail・LinkDetail）へ伝播させる。

## EventDetailBloc 変更

- EventDetailBlocはEventDomainのtopicからTopicConfigを生成・保持する
- BasicInfoBlocでTopicが変更されたとき、EventDetailBlocがTopicConfigを更新し、MichiInfoBloc等に伝播する

## 伝播フロー

```
BasicInfoBloc（Topic変更）
  ↓ Delegate（BasicInfoTopicChangedDelegate）
EventDetailBloc（TopicConfig再生成）
  ↓ 各子BlocへEvent送信
MichiInfoBloc / MarkDetailBloc / LinkDetailBloc（TopicConfig更新）
```

## EventDetailState 変更

| フィールド | 型 | 説明 |
|---|---|---|
| `topicConfig` | `TopicConfig` | 現在の有効なTopicConfig |

## BasicInfoDelegate 追加（EventDetail向け）

| Delegate名 | 説明 |
|---|---|
| `BasicInfoTopicChangedDelegate` | Topic変更をEventDetailBlocに通知する |

---

# 12. Overview集計ロジック（travelExpense）

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

## Topic設定フロー

- BasicInfoView がTopic選択行のボタン押下を受け取る
- `BasicInfoEditTopicPressed` イベントを BasicInfoBloc に送る
- BasicInfoBloc が `BasicInfoOpenTopicSelectionDelegate` を Stateに乗せる
- BasicInfoView の BlocListener が Delegate を受け取り `/selection`（eventTopic）へ `context.push` する
- 選択画面から `TopicSelectionResult` が返却される
- BasicInfoView が `BasicInfoTopicSelected` を BasicInfoBloc に送る
- BasicInfoBloc が Draft.selectedTopic を更新し、TopicConfigを再生成してStateに反映する
- BasicInfoLoaded に `BasicInfoTopicChangedDelegate` を乗せてEventDetailBlocに通知する
- EventDetailBloc が TopicConfig を更新し、子BlocへTopicConfigUpdatedイベントを送る

## Overview集計フロー（travelExpense）

- OverviewBloc が EventDomain と TopicConfig を受け取る
- topicConfig の内容に応じて TravelExpenseOverviewAdapter を呼ぶ
- Adapter が PaymentDomainのリストを処理して TravelExpenseOverviewProjection を生成する
- OverviewBloc が Projection を State に乗せる
- OverviewView が State から Projection を受け取って表示する

---

# 14. BLoC Event 一覧

## BasicInfoBloc 追加Event

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `BasicInfoEditTopicPressed` | Topic選択ボタン押下 | なし |
| `BasicInfoTopicSelected` | 選択画面から返却 | `TopicDomain? topic` |

## MarkDetailBloc 追加Event

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `MarkDetailTopicConfigUpdated` | EventDetailBlocからの伝播 | `TopicConfig config` |

## LinkDetailBloc 追加Event

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `LinkDetailTopicConfigUpdated` | EventDetailBlocからの伝播 | `TopicConfig config` |

## MichiInfoBloc 追加Event

| Event名 | 発火タイミング | ペイロード |
|---|---|---|
| `MichiInfoTopicConfigUpdated` | EventDetailBlocからの伝播 | `TopicConfig config` |

---

# 15. Delegate Contract

| Delegate名 | 所属Feature | 通知先 | 遷移・処理内容 |
|---|---|---|---|
| `BasicInfoOpenTopicSelectionDelegate` | BasicInfoBloc | BasicInfoView | `/selection`（eventTopic, single）へ push |
| `BasicInfoTopicChangedDelegate` | BasicInfoBloc | EventDetailBloc | TopicConfigの更新を通知する |

---

# 16. ファイル構成

```
flutter/lib/
  domain/
    topic/
      topic_domain.dart         -- TopicDomain, TopicType enum
      topic_config.dart         -- TopicConfig（値オブジェクト）
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
        event_detail_event.dart -- 既存拡張（TopicConfig伝播処理追加）
        event_detail_state.dart -- 既存拡張（topicConfig追加）
        event_detail_bloc.dart  -- 既存拡張（TopicConfig管理追加）
```

---

# 17. 受け入れ条件

- [ ] EventDetailの基本情報タブでTopicを選択できる
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

# End of Topic Spec
