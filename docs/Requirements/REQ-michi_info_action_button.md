# 要件書: MichiInfo アクションボタン UI

- **要件ID**: REQ-michi_info_action_button
- **作成日**: 2026-04-08
- **担当**: product-manager
- **ステータス**: 確定

---

## 背景・目的

MichiInfo タイムラインの Mark カードから ActionTime（出発・到着・休憩などの状態遷移）をワンタップで記録できる UI を追加する。
ActionTime の Bloc / Repository / View は実装済み。本要件は MichiInfo への組み込み UI を定義する。

---

## 採用案: 案B「アイコンボタン + ボトムシート + 状態バッジ」

デザイン提案: `docs/Design/draft/2026-04-08_action_time_button_proposal.html`

### UX フロー

1. **通常表示**: Mark カード右上に Violet の ⚡ アイコンボタンを常時表示
2. **状態バッジ**: Mark カードに現在の ActionState（「移動中」「滞留中」「作業中」「休憩中」）を小さく常時表示
3. **ボトムシート展開**: ⚡ ボタンタップ → 既存の `ActionTimeView` をボトムシートとして表示
4. **記録**: ボトムシート内でアクションボタンをタップ → `ActionTimeLogRecorded` イベントを dispatch → DB 保存
5. **閉じる**: ボトムシートをスワイプで閉じる / 記録完了後に自動で閉じる

---

## 要件一覧

| ID | 要件 | 優先度 |
|---|---|---|
| REQ-MAB-001 | Mark カード右上に Violet（`#7C3AED`）の ⚡ アイコンボタンを常時表示する | Must |
| REQ-MAB-002 | ⚡ ボタンタップで `ActionTimeView` をボトムシートとして表示する | Must |
| REQ-MAB-003 | Mark カードに現在の ActionState を示す状態バッジを常時表示する | Must |
| REQ-MAB-004 | 状態バッジは `currentStateLabel`（移動中 / 滞留中 / 作業中 / 休憩中）を表示する | Must |
| REQ-MAB-005 | ボトムシートは既存の `ActionTimeView` を流用する（新規 View を作らない） | Must |
| REQ-MAB-006 | ボトムシート内で記録完了後、ボトムシートを閉じる | Must |
| REQ-MAB-007 | ボトムシートを開く際に `ActionTimeStarted` イベントを発火し最新状態を読み込む | Must |
| REQ-MAB-008 | Link カードには ⚡ ボタン・状態バッジを表示しない（Mark のみ対象） | Must |

---

## カラー定義

| 用途 | カラー | 備考 |
|---|---|---|
| ⚡ アイコンボタン背景 | `#7C3AED`（Violet） | 第4色。Teal / Emerald / Amber と区別 |
| ⚡ アイコン | `#FFFFFF`（白） | コントラスト比 約6.2:1（WCAG AA クリア） |
| 状態バッジ背景 | Violet 10% alpha | カードを圧迫しない薄い表示 |
| 状態バッジテキスト | `#7C3AED` | バッジ背景と同色系 |

---

## 状態バッジ表示仕様

- バッジは Mark カード内の左下または右下（デザイン詳細は architect / flutter-dev に委ねる）
- `ActionTimeProjection.currentStateLabel` の値を表示
- 初回（ログなし）は「滞留中」を表示
- ボトムシートで記録後、バッジがリアルタイムに更新される

---

## 対象外（スコープ外）

- Link カードへの ActionTime 記録
- ActionTimeLog 一覧の MichiInfo インライン表示（ボトムシート内のログ表示で代替）
- ActionTime の自動記録（GPS連携など）

---

## 参照

- デザイン提案: `docs/Design/draft/2026-04-08_action_time_button_proposal.html`
- ActionTime 要件書: `docs/Requirements/ActionTime_Requirements.md`
- タスクボード: T-094〜T-098
