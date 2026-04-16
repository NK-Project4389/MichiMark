# Feature Spec: F-6 訪問作業トピックからメンバー項目を除外

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-16
Requirement: `docs/Requirements/REQ-visit_work_no_member.md`

---

# 1. Feature Overview

## Feature Name

VisitWorkNoMember

## Purpose

訪問作業（`visitWork`）トピックは個人の作業記録であり、複数メンバーでの共同作業を想定しない。
`visitWork` トピック選択時に、メンバー関連UIをすべて非表示にする。
データモデル（DB・Domain層）は変更しない。UIレベルの表示フラグによる条件分岐のみで対応する。

## Scope

### 含むもの

| 画面 | 対象要素 | 変更内容 |
|---|---|---|
| EventDetail BasicInfo | メンバー選択セクション | `visitWork` トピックの場合に非表示 |
| MarkDetail | メンバー選択UI | `visitWork` トピックの場合に非表示 |
| PaymentDetail | 割り勘メンバー選択UI | `visitWork` トピックの場合に非表示 |
| PaymentInfo | メンバー別精算セクション | `visitWork` トピックの場合に非表示 |

### 含まないもの

| 項目 | 理由 |
|---|---|
| データモデル（DB・Domain層） | UIレベルの非表示のみで対応するため変更不要 |
| `movingCost` / `movingCostEstimated` / `travelExpense` トピックのメンバー表示 | 対象外トピック。既存動作を維持する |
| メンバーマスターデータ・招待機能（INV系） | 本要件の影響範囲外 |

---

# 2. Feature Responsibility

本Featureは既存Feature（basic_info / mark_detail / payment_detail / payment_info）の表示ロジック拡張である。
新規Featureは追加しない。各Featureの Projection に `showMemberSection` フラグを追加し、
Widget がフラグを参照して条件分岐する。

- 各Feature の Projection への表示フラグ追加
- 各Feature の Adapter でのフラグ算出（TopicType を参照）
- Widget でのフラグによる条件分岐（ビジネスロジックはWidgetに書かない）

RootはこれらのFeatureの内部状態を変更しない。

---

# 3. State Structure

各Featureの既存Stateに変更はない。
Projectionに `showMemberSection: bool` フィールドを追加することでWidgetへの表示制御を行う。

---

# 4. Draft Model

変更なし。各Feature の Draft はトピックタイプを保持する（または親から参照可能な状態にする）。

---

# 5. Domain Model

変更なし。`TopicType.visitWork` は F-3 で定義済み。

---

# 6. Projection Model

以下の各Projectionに `showMemberSection: bool` フィールドを追加する。

### BasicInfoProjection への追加

| フィールド | 型 | 説明 |
|---|---|---|
| `showMemberSection` | `bool` | `visitWork` トピックの場合は `false`、それ以外は `true` |

### MarkDetailProjection への追加

| フィールド | 型 | 説明 |
|---|---|---|
| `showMemberSection` | `bool` | `visitWork` トピックの場合は `false`、それ以外は `true` |

### PaymentDetailProjection への追加

| フィールド | 型 | 説明 |
|---|---|---|
| `showMemberSection` | `bool` | `visitWork` トピックの場合は `false`、それ以外は `true` |

### PaymentInfoProjection への追加

| フィールド | 型 | 説明 |
|---|---|---|
| `showMemberSection` | `bool` | `visitWork` トピックの場合は `false`、それ以外は `true` |

---

# 7. Adapter

各FeatureのAdapterで `TopicType` を参照し `showMemberSection` を算出する。

算出ルール:
- `topicType == TopicType.visitWork` → `showMemberSection = false`
- それ以外 → `showMemberSection = true`

TopicType は各Featureが保持する EventDomain（またはその参照）から取得する。
Adapterはトピックタイプを受け取り、表示フラグを算出する責務を持つ。

---

# 8. Events

各Featureへの新規Eventは追加しない。
既存のDraft更新・初期化Eventのハンドラ内で `showMemberSection` を算出してProjectionに反映する。

---

# 9. Delegate Contract

変更なし。各Featureの既存Delegateをそのまま使用する。

---

# 10. Bloc Responsibility

各FeatureのBlocは以下を追加で行う。

- Projection生成時に Adapter から `showMemberSection` を受け取り State に反映する

禁止事項（変更なし）:
- Repository直接操作
- Navigation操作

---

# 11. Navigation

変更なし。

---

# 12. Data Flow

- EventDomain が持つ TopicType を Adapter が参照する
- Adapter が `showMemberSection` フラグを算出する
- Projection に `showMemberSection` が含まれる
- Bloc が Projection を State に乗せて emit する
- Widget が `state.projection.showMemberSection` を参照して条件分岐する
- `showMemberSection == false` の場合、メンバー関連Widgetを非表示にする（`if` ガードまたは `Visibility`）

---

# 13. Persistence

変更なし。メンバーデータはUIが非表示でも Domain / DB には保持し続ける。

---

# 14. Validation

変更なし。

`visitWork` トピックでは割り勘メンバー選択UIが非表示のため、PaymentDetailの保存バリデーションにおいて
「splitMembers が空でも保存可能」とする（既存の保存ロジックに影響しない場合はそのまま）。

---

# 15. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI Reducer |
|---|---|
| basic_info | BasicInfoReducer |
| mark_detail | MarkDetailReducer |
| payment_detail | PaymentDetailReducer |
| payment_info | PaymentInfoReducer |

SwiftUI版では `TopicConfig.showMarkMembers` / `showPayMember` を定義しており、
Flutter版でも同等のフラグを `TopicConfig` に持たせるか、Adapter内で算出するかは実装時に判断する。
なお、`TopicConfig.showMarkMembers = false` がすでに F-3 で `visitWork` に定義されている場合は、
それを `showMemberSection` の算出に使用してよい。

---

# 16. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- テスト用シードデータが投入されている（シナリオA: movingCost / シナリオC: visitWork）
- B-17 シードデータ実装が完了していること
- F-3 訪問作業トピック実装が完了していること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-NM-I001 | visitWork BasicInfo: メンバー選択セクションが非表示 | High |
| TC-NM-I002 | movingCost BasicInfo: メンバー選択セクションが表示される | High |
| TC-NM-I003 | visitWork MarkDetail: メンバー選択UIが非表示 | High |
| TC-NM-I004 | movingCost MarkDetail: メンバー選択UIが表示される | High |
| TC-NM-I005 | visitWork PaymentDetail: 割り勘メンバー選択UIが非表示 | High |
| TC-NM-I006 | movingCost PaymentDetail: 割り勘メンバー選択UIが表示される | High |
| TC-NM-I007 | visitWork PaymentInfo: メンバー別精算セクションが非表示 | High |
| TC-NM-I008 | movingCost PaymentInfo: メンバー別精算セクションが表示される | Medium |
| TC-NM-I009 | visitWork PaymentDetail: メンバー選択なしで保存できる | Medium |

## シナリオ詳細

### TC-NM-I001: visitWork BasicInfo: メンバー選択セクションが非表示

**前提:** シードデータ（シナリオC: 横浜エリア訪問ルート / visitWork）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. BasicInfo タブを表示する

**期待結果:**
- メンバー選択セクション（メンバー選択ボタン・選択済みメンバーリスト）が画面上に表示されない

**実装ノート:**
- `Key('basicInfo_memberSection')` が find できないこと（`findsNothing`）を確認する

---

### TC-NM-I002: movingCost BasicInfo: メンバー選択セクションが表示される

**前提:** シードデータ（シナリオA: 箱根日帰りドライブ / movingCost）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
3. BasicInfo タブを表示する

**期待結果:**
- メンバー選択セクションが画面上に表示される

**実装ノート:**
- `Key('basicInfo_memberSection')` が `findsOneWidget` であることを確認する

---

### TC-NM-I003: visitWork MarkDetail: メンバー選択UIが非表示

**前提:** シードデータ（シナリオC: 横浜エリア訪問ルート / visitWork）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する
4. 最初のマーク（事務所出発）をタップしてMarkDetailを開く

**期待結果:**
- MarkDetail 画面にメンバー選択UIが表示されない

**実装ノート:**
- `Key('markDetail_memberSection')` が `findsNothing` であることを確認する

---

### TC-NM-I004: movingCost MarkDetail: メンバー選択UIが表示される

**前提:** シードデータ（シナリオA: 箱根日帰りドライブ / movingCost）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
3. MichiInfo タブを表示する
4. 最初のマーク（自宅出発）をタップしてMarkDetailを開く

**期待結果:**
- MarkDetail 画面にメンバー選択UIが表示される

**実装ノート:**
- `Key('markDetail_memberSection')` が `findsOneWidget` であることを確認する

---

### TC-NM-I005: visitWork PaymentDetail: 割り勘メンバー選択UIが非表示

**前提:** シードデータ（シナリオC: 横浜エリア訪問ルート / visitWork）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する
4. 最初の支払い（駐車場(A社)）をタップしてPaymentDetailを開く

**期待結果:**
- PaymentDetail 画面に割り勘メンバー選択UIが表示されない

**実装ノート:**
- `Key('paymentDetail_splitMemberSection')` が `findsNothing` であることを確認する

---

### TC-NM-I006: movingCost PaymentDetail: 割り勘メンバー選択UIが表示される

**前提:** シードデータ（シナリオA: 箱根日帰りドライブ / movingCost）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する
4. 最初の支払い（高速代）をタップしてPaymentDetailを開く

**期待結果:**
- PaymentDetail 画面に割り勘メンバー選択UIが表示される

**実装ノート:**
- `Key('paymentDetail_splitMemberSection')` が `findsOneWidget` であることを確認する

---

### TC-NM-I007: visitWork PaymentInfo: メンバー別精算セクションが非表示

**前提:** シードデータ（シナリオC: 横浜エリア訪問ルート / visitWork）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する

**期待結果:**
- PaymentInfo 画面にメンバー別精算セクションが表示されない

**実装ノート:**
- `Key('paymentInfo_memberSettlementSection')` が `findsNothing` であることを確認する

---

### TC-NM-I008: movingCost PaymentInfo: メンバー別精算セクションが表示される

**前提:** シードデータ（シナリオA: 箱根日帰りドライブ / movingCost）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「箱根日帰りドライブ」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する

**期待結果:**
- PaymentInfo 画面にメンバー別精算セクションが表示される

**実装ノート:**
- `Key('paymentInfo_memberSettlementSection')` が `findsOneWidget` であることを確認する

---

### TC-NM-I009: visitWork PaymentDetail: メンバー選択なしで保存できる

**前提:** シードデータ（シナリオC: 横浜エリア訪問ルート / visitWork）が存在する

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 「横浜エリア訪問ルート」をタップしてイベント詳細を開く
3. PaymentInfo タブを表示する
4. 支払い追加ボタンをタップして新規PaymentDetailを開く
5. 金額に `3000` を入力する
6. メモに `テスト` を入力する
7. 保存ボタンをタップする

**期待結果:**
- エラーが発生せず PaymentInfo 画面に戻る
- 支払い一覧に新しい支払いが追加されている

**実装ノート:**
- `Key('paymentDetail_saveButton')` でタップ
- `Key('paymentInfo_card_3')` が表示されることを確認（支払い4件目）

---

# End of Feature Spec
