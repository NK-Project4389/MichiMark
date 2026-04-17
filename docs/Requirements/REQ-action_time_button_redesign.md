# 要件書: UI-24 ActionTime アクションボタン大型化

作成日: 2026-04-17
作成者: product-manager
バージョン: 1.0
参照デザイン叩き: `docs/Design/draft/action_time_button_redesign.html`

---

## 概要

ActionTimeボトムシート内のアクションボタンを、現行の `ElevatedButton + Wrap` レイアウトから、4ボタン横一列・等幅スクエア角丸の大型グリッドボタンへリデザインする。
各ボタンに「アクション名（上部）＋ 直近の押下時刻（下部・大きめ表示）」を表示し、モバイル操作性と状況把握の即時化を両立する。
また、アクションボタン押下時にボトムアップ画面を閉じない（現在は閉じている）よう動作を変更する。

---

## ユーザーストーリー

- ユーザーとして、作業現場でアクションボタンを素早く確実にタップしたい
  → 4等分均等配置の大型ボタンによりタップ面積が最大化され、誤タップが減る
- ユーザーとして、「いつ作業開始したか」をボタンを見るだけで確認したい
  → ボタン内に直近の押下時刻を大きく表示することで、ログセクションまでスクロール不要
- ユーザーとして、アクションを連続して記録したい
  → ボタン押下時にボトムシートが閉じなくなるため、複数アクションを続けて操作できる

---

## 機能要件

### REQ-ATB-01: ボタンレイアウト変更

- 現行の `Wrap + ElevatedButton` を `Row + Expanded * 4`（または等幅GridView）に置き換える
- 4ボタンが横一列に等幅で並ぶ配置にする
- ボタン数がアクション数によって変わる場合：4ボタン以下は等幅グリッド、5ボタン以上はWrapフォールバックとする（architectがSpec作成時に判断する）

### REQ-ATB-02: ボタンビジュアル（スクエア角丸大型ボタン）

**通常状態（未アクティブ）:**
- 背景色: `#FFFFFF`（白）
- ボーダー色: `#E9ECEF` / ボーダー幅: 1.5px
- 角丸: borderRadius 14px
- ボタン高さ: 88px
- ボタン間隔: gap 8px

**アクティブ状態（最後に押したアクション）:**
- 背景色: `#F5F3FF`（Violet 50）
- ボーダー色: `#7C3AED`（Violet 600）
- ボーダー幅: 1.5px

**ボタン内レイアウト（上→下）:**
1. アクション名テキスト（上部中央）: fontSize 12 / fontWeight Bold (w700) / color `#1A1A2E`（最大2行折り返し可）
2. 区切り線: height 1px / color `#E9ECEF`（アクティブ時は `#C4B5FD`）/ margin 4px 8px
3. 直近の押下時刻（下部中央）: fontSize 18 / fontWeight Bold (w700) / color `#7C3AED` / HH:mm形式 / tabular-nums
4. 「直近の記録」ラベル: fontSize 9 / fontWeight Regular / color `#ADB5BD`
   - 押下履歴なし時は「未記録」テキスト: fontSize 11 / italic / color `#ADB5BD`

**ボタン内パディング:** top 12px / horizontal 4px / bottom 10px

### REQ-ATB-03: Projection拡張（lastLoggedAt）

- 各アクションに「直近の押下時刻（lastLoggedAt: DateTime?）」を保持するProjectionの拡張が必要
- 新規 `ActionButtonProjection`（`actionId`, `actionName`, `lastLoggedTimeLabel: String?`）を追加し、`ActionTimeProjection` に `List<ActionButtonProjection> buttonItems` を追加する（既存の `availableActions` とは別）
- `ActionTimeLogProjection` のログ一覧からアクションIDごとに最新タイムスタンプを逆引きする
- 具体的な実装方針はarchitectがSpec作成時に確定する

### REQ-ATB-04: ボタン押下時のボトムシート動作変更

- **現行**: アクションボタン押下 → `ActionTimeLogRecorded` dispatch → ボトムシートが閉じる
- **変更後**: アクションボタン押下 → `ActionTimeLogRecorded` dispatch → ボトムシートを閉じない
- ボトムシートを閉じる操作は、ユーザーが明示的に閉じる操作（スワイプ・閉じるボタン）でのみ行う

---

## 非機能要件

- `ActionTimeLogRecorded` のdispatchロジック自体は変更しない（View層のみ変更）
- `dart analyze` エラー・警告 0 を維持する
- 既存の状態遷移ロジック・ログ記録ロジックは変更しない

---

## スコープ外

- ボタン数が5以上になる場合のデザイン対応（architectがSpec時に検討）
- 長押しによる確認ダイアログ
- アクションボタンのドラッグ並び替え
- ダークテーマ対応

---

## 受け入れ条件

- [ ] 4ボタンが横一列・等幅で並んで表示される
- [ ] ボタン高さが88px程度で表示される
- [ ] ボタン内上部にアクション名（fontSize 12 / Bold）が表示される
- [ ] ボタン内下部に直近の押下時刻（fontSize 18 / Bold / Violet色）が大きく表示される
- [ ] 押下履歴がない場合に「未記録」テキストが表示される
- [ ] 最後に押したアクションのボタンがアクティブ状態（Violet背景・ボーダー）で表示される
- [ ] アクションボタンを押してもボトムシートが閉じない
- [ ] アクションを押すと従来通りActionTimeLogが記録される
- [ ] 既存の状態遷移ロジックが正常に動作する
- [ ] `dart analyze` エラー・警告 0

---

## 備考

- 既存の `_violetColor`（#7C3AED）を継承し、ActionTimeブランドカラーとの一貫性を保つ
- `DraggableScrollableSheet`（initialChildSize: 0.6）の縦スペースを活かした設計
- デザイン叩き（`docs/Design/draft/action_time_button_redesign.html`）を実装の視覚参照とする
- Projection拡張の詳細設計はarchitectに委ねる
