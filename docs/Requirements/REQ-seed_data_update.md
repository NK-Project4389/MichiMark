# 要件書: テストデータ更新（トピック情報追加・Overview確認可能なデータ）

要件書ID: REQ-seed_data_update
作成日: 2026-04-08
ステータス: 確定
関連タスク: T-080（新規）

---

## 背景・目的

Phase 5 で Topic 機能・ActionTime 機能・Aggregation 機能が実装されたが、
現在の InMemory シードデータ（`seed_data.dart`）にはトピック情報・ActionTimeLogs が含まれていない。

このため以下の問題がある：
- EventList のカード左ボーダーがデフォルト色のままで Topic 機能の確認ができない
- EventDetail の「振り返り」タブ（Overview）に表示されるデータが不足している
- MichiInfo タイムラインでの動作確認に十分なマーク・リンクデータがない

実装確認・動作確認・デモに使えるシードデータに更新する。

---

## 要件一覧

### REQ-SDD-001: Topic 情報をイベントに設定する

**概要**
各シードイベントに Topic（TopicDomain）を設定する。

**変更内容**
- 少なくとも 3 件以上のイベントにそれぞれ異なる TopicType を設定する
- EventList でカード左ボーダーに Topic カラーが表示されること
- EventDetail の AppBar グラデーションが Topic カラーで表示されること
- Topic 未設定のイベントも 1 件以上残す（デフォルト表示の確認用）

---

### REQ-SDD-002: Overview タブで情報が閲覧できるデータを用意する

**概要**
EventDetail の「振り返り」タブ（Overview）で集計・サマリーが表示されるように、
マーク・支払い・メンバー情報が揃ったイベントデータを用意する。

**変更内容**
- 少なくとも 1 件のイベントに以下をすべて設定する
  - Topic 設定済み
  - メンバー 2 名以上
  - マーク 3 件以上（meterValue あり）
  - リンク 2 件以上（distanceValue あり）
  - 支払い 2 件以上（分割メンバー含む）

---

### REQ-SDD-003: MichiInfo タイムラインで各パターンが確認できるデータを用意する

**概要**
MichiInfo タイムラインの各表示パターン（Mark-Link-Mark スパン・スタンドアロン Link・Mark-Mark 直接隣接）が
1 つのイベントで確認できるシードデータを用意する。

**変更内容**
- TS-09（Mark-Mark 直接隣接パターン）を含むイベントを 1 件追加または既存イベントに追加する
- パターン1（Mark-Link-Mark）・パターン2（スタンドアロン Link）・パターン3（Mark-Mark）がすべて含まれること

---

## 実装スコープ

| 変更対象 | 内容 |
|---|---|
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | シードイベント・マーク・リンク・支払いデータを更新 |
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | seedTopics に対応した TopicDomain を各イベントに設定 |

---

## 非機能要件

- シードデータはアプリ起動時に毎回同じ状態で初期化されること（ランダム要素を含めない）
- シードデータ内の UUID は固定値とする（テストで参照しやすいように）

---

## 関連ドキュメント

- `flutter/lib/repository/impl/in_memory/seed_data.dart`
- `docs/Spec/Features/Topic_Spec.md`
- `docs/Spec/Features/EventDetailOverview_Spec.md`
