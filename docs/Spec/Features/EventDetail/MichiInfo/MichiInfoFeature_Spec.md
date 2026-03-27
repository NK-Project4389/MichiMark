# MichiInfo Feature Specification

Feature
MichiInfoFeature (MichiInfoReducer)

Parent Feature
EventDetailFeature

Purpose

イベント内の「マーク / リンク」(MarkLink) を時系列で一覧表示し、
各アイテムの詳細画面（MarkDetail / LinkDetail）へ遷移する入口となる。

本Featureは「時系列順」を最重要とし、表示順は markLinkSeq 昇順で保証する。

---

# Responsibilities

MichiInfoFeatureは以下を担当する。

1 MarkLink の時系列一覧表示（Mark / Link 混在の1リスト）

2 Mark タップ → MarkDetail を開く要求を親へ通知

3 Link タップ → LinkDetail を開く要求を親へ通知

4 Addボタン → Mark/Link追加導線の要求を親へ通知

MichiInfoFeatureは禁止

- Navigation管理（Rootのみ）
- Repositoryアクセス
- Domain永続化

---

# State Structure

MichiInfoReducer.State

projection: MichiInfoListProjection
- 表示用の投影モデル（Domain→Projectionで作られ、親から注入される想定）

eventID: EventID
- Delegateで親へ通知するために保持

markDrafts: IdentifiedArrayOf<MarkDetailDraft>
linkDrafts: IdentifiedArrayOf<LinkDetailDraft>
- 編集途中のDraftから表示用リストを合成するための保持（displayItemsで利用）

---

# Ordering Rule (Time Series)

表示順は「時系列順」として以下で定義する。

Primary key: markLinkSeq (ascending)

実装上:
- markDrafts / linkDrafts 由来の表示は displayItems で合成し、
  markLinkSeq 昇順でソートされる。

---

# Projection Models

## MichiInfoListProjection

Purpose
MichiInfo一覧の表示データコンテナ

Structure
items: [MarkLinkItemProjection]

empty
items: []

dummy
時系列の例データ（Mark/Link混在、seqで並ぶ）

---

## MarkLinkItemProjection

Purpose
MarkLink 1件分の一覧表示モデル（Mark/Link共通）

Key fields
id: MarkLinkID
markLinkSeq: Int
markLinkType: MarkOrLink (mark / link)

displayDate: String (yyyy/MM/dd)
markLinkName: String

members: [MemberItemProjection]

displayMeterValue: String? (Markのみ)
displayDistanceValue: String? (Linkのみ)

actions: [ActionItemProjection]

Fuel fields (isFuel == true のときのみ有効)
isFuel: Bool
pricePerGas: Int?
gasQuantity: Double? (0.1L整数を /10 してDouble化)
gasPrice: Int?

memo: String?

Notes
- Projectionは表示専用で、Domain/Draftを変更しない。

---

# Domain Model (Reference)

## MarkLinkDomain

Purpose
MarkLinkのビジネスデータ（Mark/Linkを統合したDomain）

Important fields
id
markLinkSeq
markLinkType
markLinkDate
markLinkName
members
meterValue (Mark)
distanceValue (Link)
actions
memo
isFuel + fuel related fields
isDeleted
createdAt / updatedAt

Notes
- DomainはUIを知らない。
- isDeleted == true は一覧から除外される。

---

# Projection Adapter

## MarkLinkProjectionAdapter

Purpose
Domain → Projection 変換（一覧/単体）

Public API
adaptList(markLinks: [MarkLinkDomain]) -> [MarkLinkItemProjection]
- isDeleted を除外
- markLinkSeq 昇順ソート
- adaptで各要素を投影

adapt(domain: MarkLinkDomain) -> MarkLinkItemProjection
- displayDate は "yyyy/MM/dd" にフォーマット
- members/actions は isDeleted==false && isVisible==true のみ投影
- meterValueは Mark のみ表示
- distanceValueは Link のみ表示
- Fuel関連は isFuel==true の場合のみ値を出す（gasQuantityは /10）

Notes
- 表示フォーマットはProjectionAdapter内で完結（現実装準拠）。

---

# Reducer Actions

MichiInfoReducer.Action

appeared
- 画面表示イベント（現状は副作用なし）

markTapped(MarkLinkID)
- Mark item tap

linkTapped(MarkLinkID)
- Link item tap

addButtonTapped
- 追加ボタン

delegate(Delegate)
- 親へ意図を通知

---

# Delegate Contract

MichiInfoReducer.Action.Delegate

openMarkDetail(EventID, MarkLinkID)
- Mark詳細を開く要求（Navigationは親/Rootが実施）

openLinkDetail(EventID, MarkLinkID)
- Link詳細を開く要求

addMarkOrLinkRequested
- Mark/Linkの追加導線を開始する要求
  （例: 種別選択 → Draft生成 → Detailへ遷移、などは上位で決める）

Notes
- Delegateは意図のみ運び、Domain/Draftを直接変更しない。

---

# UI Interaction Flow

## Tap Flow (Mark)

User taps mark item
↓
Action: markTapped(id)
↓
Delegate: openMarkDetail(eventID, id)
↓
Parent/Root handles navigation

## Tap Flow (Link)

User taps link item
↓
Action: linkTapped(id)
↓
Delegate: openLinkDetail(eventID, id)
↓
Parent/Root handles navigation

## Add Flow

User taps add button
↓
Action: addButtonTapped
↓
Delegate: addMarkOrLinkRequested
↓
Parent decides:
- add Mark or Link
- initialize Draft
- navigate to corresponding Detail

---

# Display Items Construction (Draft Merge)

Current implementation provides:

State.displayItems: [MarkLinkItemProjection]

- MarkLinkDraftProjectionAdapter で markDrafts / linkDrafts を投影
- markItems + linkItems を結合
- markLinkSeq 昇順にソートし返す

Notes
- projection.items から表示する形にも拡張可能だが、
  現時点の実装では Draft 合成表示を提供している（現実装準拠）。

---

# Architecture Rules Alignment

Root
- routing only (StackState)
- Draftを編集しない

MichiInfoFeature
- Navigationしない
- Repositoryへアクセスしない
- Domain永続化しない
- Draft編集は自Feature内に閉じる（親へはDelegateで意図通知）

Projection
- 表示専用
- Domain/Draftを変更しない

---

# Future Extensions (Non-blocking)

- Action / Segment を含む高度な時系列整合（本Specでは未確定領域として扱う）
- イベントパターンに応じた表示項目の出し分け（visibleFields/visibleTabs連携）
- 並び替えUI（将来的に markLinkSeq 再計算）

---

# ===============================
# Patch : Distance Priority Rule
# ===============================

## 追加対象
MichiMarkの距離採用ルールをSpecに明記する

採用ルール

distancePriority

1 meter差分
2 distanceValue

---

# MichiInfoFeature_Spec.md 追記

## Distance Display Rule

Linkの距離表示は以下の優先順位で決定する。

1 meter差分（前後MarkのmeterValue差分が妥当な場合）
2 distanceValue（LinkDomainが保持する走行距離）

distanceValueはユーザー入力または実測値として保存される。

meter差分が利用可能な場合はmeter差分を優先する。

---

# End of MichiInfo Feature Spec