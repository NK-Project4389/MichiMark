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

移動にかかるコスト（燃料・距離・燃費）を記録・把握するための用途。高速代等の支払いも記録対象。

#### 表示制御

**MarkDetail**

| 項目 | 表示 |
|---|---|
| 名称 | ✅ |
| 日付 | ✅ |
| メンバー | ✅ |
| 累積メーター | ✅ |
| アクション | ✅ |
| メモ | ✅ |
| 給油スイッチ + FuelDetail | ✅ |

**LinkDetail**

| 項目 | 表示 |
|---|---|
| 名称 | ✅ |
| 走行距離 | ✅ |
| メンバー | ✅ |
| アクション | ✅ |
| メモ | ✅ |
| 給油スイッチ + FuelDetail | ✅ |

> Linkの追加：✅ 可能

**BasicInfo（イベント基本情報タブ）**

| 項目 | 表示 |
|---|---|
| イベント名 | ✅ |
| 交通手段 | ✅ |
| 燃費 (km/L) | ✅ |
| ガソリン単価 (円/L) | ✅ |
| メンバー | ✅ |
| タグ | ✅ |
| ガソリン支払者 | ✅ |

**EventDetailタブ**

| タブ | 表示 |
|---|---|
| 基本情報 | ✅ |
| MichiInfo（タイムライン） | ✅ |
| PaymentInfo | ✅（高速代・駐車場代等） |

#### Overview表示内容

| 項目 | 算出方法 |
|---|---|
| 総走行距離 | 全Linkの走行距離合計 |
| 給油量合計 | 全MarkLinkのgasQuantity合計 |
| ガソリン代合計 | 全MarkLinkのgasPrice合計 |
| 燃費 | kmPerGas（イベント設定値） |

---

### 旅費可視化（travelExpense）

出張・訪問に伴う経費（交通費・宿泊費・飲食費等）を記録・精算するための用途。レンタカー利用を想定。
ガソリン代は支払いとして登録するため、給油情報・距離情報は不要。

#### 表示制御

**MarkDetail**

| 項目 | 表示 |
|---|---|
| 名称 | ✅ |
| 日付 | ✅ |
| メンバー | ✅ |
| 累積メーター | ❌ 非表示 |
| アクション | ✅ |
| メモ | ✅ |
| 給油スイッチ + FuelDetail | ❌ 非表示 |

> Linkの追加：❌ 不可（区間記録不要）

**BasicInfo（イベント基本情報タブ）**

| 項目 | 表示 |
|---|---|
| イベント名 | ✅ |
| 交通手段 | ✅ |
| 燃費 (km/L) | ❌ 非表示 |
| ガソリン単価 (円/L) | ❌ 非表示 |
| メンバー | ✅ |
| タグ | ✅ |
| ガソリン支払者 | ❌ 非表示 |

**EventDetailタブ**

| タブ | 表示 |
|---|---|
| 基本情報 | ✅ |
| MichiInfo（タイムライン） | ✅ |
| PaymentInfo | ✅（経費全般） |

#### Overview表示内容

| 項目 | 算出方法 |
|---|---|
| 経費合計 | 全PaymentのpaymentAmount合計 |
| メンバー別トータルコスト | 各メンバーが負担すべき金額の合計（splitMembersから算出） |
| メンバー別収支バランス | 各メンバーの支払額 − 負担額（全員の合計が0になる） |

**収支バランスの計算ロジック**

各Paymentに対して：
- `paymentMember`（支払者）が `paymentAmount` を立替払い
- `splitMembers`（割り勘メンバー）で均等に分担
- `splitMembers` が空のとき → 支払者1人負担（割り勘なし）
- `paymentMember` が `splitMembers` に含まれる場合 → 自分の分は差し引く

```
例：
  田中が¥6,000支払い、割り勘：田中・佐藤・鈴木
    → 各自の負担：¥2,000
  佐藤が¥3,000支払い、割り勘なし（splitMembers空）
    → 佐藤の負担：¥3,000

  トータルコスト（各自の負担合計）：
    田中: ¥2,000
    佐藤: ¥5,000（¥2,000 + ¥3,000）
    鈴木: ¥2,000

  収支バランス（支払額 − 負担額）：
    田中: +¥4,000（¥6,000支払 − ¥2,000負担）
    佐藤: +¥1,000（¥3,000支払 − ¥2,000負担 − ¥3,000負担 = -¥2,000 → バランス +¥1,000）
    鈴木: -¥5,000（¥0支払 − ¥2,000負担 − ¥3,000負担）
    合計: ¥0 ✅
```

**収支バランスの表示形式**

- プラス（+）= 受け取る側（払い過ぎ）
- マイナス（-）= 支払う側（払い足りない）
- メンバー一覧形式で全員の収支を並べて表示

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

### PaymentDomain 確認事項

`splitMembers: List<MemberDomain>` が空（`[]`）のとき = **支払者1人負担（割り勘なし）** として扱う。

---

## 非機能要件

- Topic未設定のイベントはmovingCost相当の表示にフォールバックする
- Phase 3のカスタマイズ対応を見越して、表示制御ロジックはTopicTypeを参照する形で実装する（ハードコード禁止）
- 収支バランスの集計ロジックはAdapter/UseCase層に実装する（View/BLoCに書かない）

---

## スコープ外（Phase 2以降）

- 固定Topic以外のカテゴリ追加（Phase 2）
- ユーザーによるカスタムTopic作成（Phase 3）
- Topic別の集計・レポート（Aggregation要件書を参照）
- 「誰が誰にいくら払う」形式の精算アドバイス表示（検討余地あり）

---

## 受け入れ条件

- [ ] EventDetailの基本情報タブでTopicを選択できる
- [ ] movingCost選択時：累積メーター・給油Detail・PaymentInfoがすべて表示される
- [ ] movingCost選択時：BasicInfoに燃費・ガソリン単価・ガソリン支払者が表示される
- [ ] movingCost選択時：Linkの追加が可能
- [ ] travelExpense選択時：累積メーター・給油Detail が非表示になる
- [ ] travelExpense選択時：BasicInfoの燃費・ガソリン単価・ガソリン支払者が非表示になる
- [ ] travelExpense選択時：Linkの追加ボタンが非表示になる
- [ ] travelExpense選択時：PaymentInfoが表示される
- [ ] travelExpense OverviewにメンバーごとのトータルコストとしてsplitMembersから算出した負担合計が表示される
- [ ] travelExpense OverviewのメンバーごとのバランスはすべてのPaymentを集計して全員の合計が0になる
- [ ] splitMembers が空のPaymentは支払者1人負担として計算される
- [ ] Topic変更後も既存のMark/Link/Paymentデータが失われない
- [ ] Topic未設定のイベントはmovingCost相当で表示される
