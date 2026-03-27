# PaymentInfo Feature Specification

Feature
PaymentInfoFeature (PaymentInfoReducer)

Parent Feature
EventDetailFeature

Purpose

イベントに紐づく支払情報（Payment）の一覧を表示し、
支払の追加・編集（PaymentDetail）への導線を提供する。

PaymentInfoFeatureは編集中心アーキテクチャにおける「一覧入口」Featureであり、
永続化やDomain更新は行わず、操作意図をDelegateで親（EventDetail）へ通知する。

---

# Responsibilities

PaymentInfoFeatureは以下を担当する。

1 Payment一覧表示（Projection）
2 追加ボタン（plus）押下 → PaymentDetail起動要求
3 一覧アイテムタップ → PaymentDetail（既存Payment）起動要求

PaymentInfoFeatureは禁止

- Navigation管理（Rootのみ）
- Repositoryアクセス
- EventDomain / PaymentDomain の直接更新・保存

---

# State Structure

PaymentInfoReducer.State

projection: PaymentInfoProjection
- 表示専用投影モデル（Domain→ProjectionAdapterで生成し、親から注入される）

eventID: EventID
- 親へ通知するための識別子（現状、delegateのpayloadにはeventIDは含めない設計）

---

# Projection Model

## PaymentInfoProjection

Purpose
Payment一覧画面の表示専用モデル

fields
items: [PaymentItemProjection]
displayTotalAmount: String

empty
items: []
displayTotalAmount: "0円"

Notes
- Projectionは表示専用であり、編集状態を持たない。

---

# Projection Adapter

## PaymentInfoProjectionAdapter

Purpose
PaymentDomain[] → PaymentInfoProjection 変換

Behavior
- isDeleted == true を除外して validPayments を作る
- paymentSeq 昇順でソート
- 各要素を PaymentItemProjection へ変換
- 合計金額 total = sum(paymentAmount)
- displayTotalAmount を "\\(total) 円" として返す

Notes
- 現状 empty は "0円"、adapter は "円" 形式になっているため、
  表示統一が必要なら将来調整候補（仕様としては現実装に準拠）。

---

# Actions

PaymentInfoReducer.Action

paymentTapped(PaymentID)
- 一覧の支払タップ（既存編集）

plusButtonTapped
- 追加ボタン押下（新規作成）

delegate(Delegate)
- 親へ意図を通知

---

# Delegate Contract

PaymentInfoReducer.Delegate

openPaymentDetail(PaymentDraft)
- 新規作成のPaymentDetailを開く要求
- 現実装: plusButtonTapped で PaymentDraft.initial() を生成して渡す

openPaymentDetailByID(PaymentID)
- 既存Paymentを開く要求（PaymentID指定）

Notes
- Delegateは意図のみ運び、Domain/Draft/Repositoryを直接変更しない。

---

# UI Interaction Flow

## Add Flow (New Payment)

User taps plus button
↓
Action: plusButtonTapped
↓
Delegate: openPaymentDetail(PaymentDraft.initial())
↓
Parent/Root handles:
- PaymentDetail画面遷移
- Draft所有（PaymentDetailFeatureがDraftを編集）
- 保存時にEvent側へ反映

## Tap Flow (Existing Payment)

User taps a payment item
↓
Action: paymentTapped(paymentID)
↓
Delegate: openPaymentDetailByID(paymentID)
↓
Parent/Root handles:
- PaymentDomainの取得（Event側が保持する想定）
- PaymentDetailの起動方法は上位で決定

---

# Ordering Rule

一覧表示順は paymentSeq 昇順で保証する。

Source of truth
PaymentInfoProjectionAdapter

---

# Architecture Rules Alignment

Root
- routing only (StackState)
- Draftを編集しない

PaymentInfoFeature
- Navigationしない
- Repositoryへアクセスしない
- Domain永続化しない
- 操作はDelegateで親へ通知する

Projection
- 表示専用
- Domain/Draftを変更しない

---

# Future Extensions (Non-blocking)

- 支払のフィルタ（支払者/カテゴリ）
- 集計粒度（イベント合計/メンバー別/カテゴリ別）
- 表示フォーマット統一（"0円" vs "0 円" など）

---

# End of PaymentInfo Feature Spec