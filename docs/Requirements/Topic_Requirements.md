# Topic 要件書

## 背景・目的

MichiMarkは「移動コスト可視化」「旅費可視化」など用途が異なるユーザーが使用する。
用途に応じて表示する項目・Overviewの内容を切り替えることで、ユーザーが必要な情報に集中できるようにする。

この用途カテゴリを **Topic** と定義する。

---

## フェーズ定義

| フェーズ | 内容 |
|---|---|
| Phase 1 | 固定Topic 2種（移動コスト可視化・旅費可視化）を提供 |
| Phase 2 | 固定Topicを追加（業種別・用途別など） |
| Phase 3 | ユーザーがカスタムTopicを作成・編集できる |

本要件書はPhase 1のスコープを定義する。

---

## ユーザーストーリー

- ユーザーとして、イベントにTopicを設定して、用途に合った入力項目だけを表示したい
- ユーザーとして、Topicに応じたOverviewでドライブの概要を把握したい
- ユーザーとして、Topicを変更してもすでに記録したデータは失われないようにしたい

---

## Phase 1 Topic 定義

### 移動コスト可視化（movingCost）

移動にかかるコスト（燃料・距離・燃費）を記録・把握するための用途。

**表示項目（MarkDetail / LinkDetail）**

| 項目 | 表示 |
|---|---|
| meterValue / distanceValue | ✅ |
| FuelDetail（給油情報） | ✅ |
| PaymentInfo / PaymentDetail | ❌ 非表示 |
| actions | ✅ |
| memo | ✅ |

**Overview表示内容**

| 項目 | 内容 |
|---|---|
| 総走行距離 | 全Linkの走行距離合計 |
| 給油量合計 | 全MarkLinkのgasQuantity合計 |
| ガソリン代合計 | 全MarkLinkのgasPrice合計 |
| 燃費 | kmPerGas（イベント設定値） |

---

### 旅費可視化（travelExpense）

出張・訪問に伴う経費（交通費・宿泊費・飲食費等）を記録・精算するための用途。

**表示項目（MarkDetail / LinkDetail）**

| 項目 | 表示 |
|---|---|
| meterValue / distanceValue | ✅ |
| FuelDetail（給油情報） | ❌ 非表示 |
| PaymentInfo / PaymentDetail | ✅ |
| actions | ✅ |
| memo | ✅ |

**Overview表示内容**

| 項目 | 内容 |
|---|---|
| 総走行距離 | 全Linkの走行距離合計 |
| 経費合計 | 全PaymentのpaymentPrice合計 |
| メンバー別経費 | メンバーごとの経費内訳 |
| 精算額 | 各メンバーの支払い差額（均等割り想定） |

---

## 機能要件

### Topic設定

- Topicはイベント単位で設定する
- EventDetailの基本情報タブで選択する
- デフォルト値は **movingCost**（移動コスト可視化）
- Topic変更時に既存データは保持する（表示項目が変わるだけで削除しない）

### Topicマスタ（Phase 1は固定値）

| topicType | topicName | Phase |
|---|---|---|
| `movingCost` | 移動コスト可視化 | 1 |
| `travelExpense` | 旅費可視化 | 1 |

---

## ドメイン変更

### TopicDomain（新規）

| フィールド名 | Dart型 | NULL許容 | デフォルト値 | 備考 |
|---|---|---|---|---|
| `id` | `String` | ❌ | - | PK（UUID文字列） |
| `topicName` | `String` | ❌ | - | 表示名 |
| `topicType` | `TopicType` | ❌ | - | enum（固定種別） |
| `isVisible` | `bool` | ❌ | `true` | 選択画面での表示制御 |
| `isDeleted` | `bool` | ❌ | `false` | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | - | |
| `updatedAt` | `DateTime` | ❌ | - | |

### TopicType enum

```dart
enum TopicType {
  movingCost,    // 移動コスト可視化
  travelExpense, // 旅費可視化
}
```

### EventDomain 変更

| 変更 | 内容 |
|---|---|
| フィールド追加 | `topic: TopicDomain?`（nullable・デフォルトnull → UI層でmovingCostとして扱う） |

---

## 非機能要件

- Topic未設定のイベントはmovingCost相当の表示にフォールバックする
- Phase 3のカスタマイズ対応を見越して、表示制御ロジックはTopicTypeを参照する形で実装する（ハードコード禁止）

---

## スコープ外（Phase 2以降）

- 固定Topic以外のカテゴリ追加（Phase 2）
- ユーザーによるカスタムTopic作成（Phase 3）
- Topic別の集計・レポート（Aggregation要件書を参照）

---

## 受け入れ条件

- [ ] EventDetailの基本情報タブでTopicを選択できる
- [ ] movingCost選択時：FuelDetailが表示され、PaymentInfoが非表示になる
- [ ] travelExpense選択時：PaymentInfoが表示され、FuelDetailが非表示になる
- [ ] OverviewがTopicに応じた項目を表示する
- [ ] Topic変更後も既存のMark/Link/Paymentデータが失われない
- [ ] Topic未設定のイベントはmovingCost相当で表示される
