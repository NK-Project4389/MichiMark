# REQ-action_log_time_edit

## 概要

ActionTimeLogに「変更後の時間（adjustedAt）」フィールドをDomainレベルで追加し、ユーザーがUI上で記録時間を事後変更できるようにする。ActionTime画面では変更後の時間を優先してソート・表示し、変更後の時間が登録時間と一致した場合はNULLに戻す。

作成日: 2026-04-18
作成者: product-manager
バージョン: 1.1

---

## ユーザーストーリー

- ユーザーとして、記録した作業時間を後から修正したい
  - 理由: ボタンを押し忘れた・タイミングがずれた場合に、実際の時刻に合わせて修正する必要がある
- ユーザーとして、修正後の時間で正しい時系列順にログを確認したい
  - 理由: 時系列が正しくないと作業の流れが把握しにくい
- ユーザーとして、修正を取り消して元の登録時間に戻したい
  - 理由: 誤って修正した場合に簡単に元に戻せる安心感がほしい

---

## 要件項目

### REQ-ALTE-01: Domain拡張（adjustedAtフィールド追加）

- ActionTimeLogに `adjustedAt: DateTime?` フィールドを追加する
- `adjustedAt` はNULL許容とし、未変更時は `null` とする
- `adjustedAt` が `null` の場合は従来通り登録時間（`timestamp` / `createdAt`）を使用する
- `adjustedAt` が登録時間と同一値になった場合は `null` に戻す（正規化ルール）

### REQ-ALTE-02: ソート順の変更

- ActionTime画面のログ一覧は「有効時間」でソートする
- 有効時間 = `adjustedAt ?? timestamp`（変更後の時間が優先、なければ登録時間）
- ソート方向は現行の仕様を維持する（既存のソート方向に従う）

### REQ-ALTE-03: 時間変更UI

- ActionTime画面のログ一覧において、時間表示部分をタップすると時間を変更できる
- UI形式: **CupertinoDatePicker（時刻モード）のボトムシート表示** — 確定
  - 理由: iOSネイティブに馴染みのあるスクロール式ピッカーで、時・分の選択が直感的
  - 日付変更が不要（同日内の時刻変更のみ想定）のため、DatePickerのfullモードではなくtimeモードが適切
  - 日付をまたぐ変更はPhase 1ではスコープ外とする（将来検討）
- 変更確定後、`adjustedAt` にユーザーが選択した時刻を設定する
- 変更後の時刻が登録時間と同一の場合は `adjustedAt` を `null` に戻す（REQ-ALTE-01の正規化ルール適用）

### REQ-ALTE-04: 変更後の時間の表示

- ログ一覧の時間表示は「有効時間」（`adjustedAt ?? timestamp`）を表示する
- `adjustedAt` が設定されている場合、時間表示に視覚的な区別を付ける（例: アイコン・色の変更など）
  - 具体的なビジュアル仕様はarchitectがSpec作成時に決定する
- ボタン内の「直近の押下時刻」（UI-24で追加済み）も有効時間を反映する

### REQ-ALTE-05: DBスキーマ変更（マイグレーション）

- ActionTimeLogの永続化テーブルに `adjusted_at` カラム（DateTime?、NULL許容）を追加する
- 既存データのマイグレーション: 既存レコードの `adjusted_at` は `NULL` とする（変更なしの扱い）
- driftのスキーマバージョンを上げてマイグレーション処理を実装する

---

## 受け入れ条件

- [ ] ActionTimeLogのDomainに `adjustedAt: DateTime?` フィールドが追加されている
- [ ] `adjustedAt` が登録時間と同一値の場合に `null` に正規化される
- [ ] ActionTime画面のログ一覧が有効時間（`adjustedAt ?? timestamp`）でソートされる
- [ ] ログ一覧の時間表示をタップすると時刻変更UIが表示される
- [ ] 時刻を変更すると `adjustedAt` が更新され、ログ一覧に反映される
- [ ] 変更後の時刻を登録時間と同じ値に戻すと `adjustedAt` が `null` になる
- [ ] `adjustedAt` が設定されているログに視覚的な区別がある
- [ ] ボタン内の「直近の押下時刻」が有効時間を反映する
- [ ] DBマイグレーションにより既存データが正常に動作する
- [ ] 既存のActionTimeLog記録機能が正常に動作する（デグレなし）
- [ ] `dart analyze` エラー・警告 0

---

## 非機能要件

- `ActionTimeLogRecorded` のdispatchロジック（ログ記録処理）は変更しない
- 既存の状態遷移ロジックは変更しない
- 設計憲章のレイヤー構造を遵守する（Domain拡張 → Repository → Adapter → Projection → View）

---

## スコープ外

- 日付をまたぐ時刻変更（Phase 2以降で検討）
- 複数ログの一括時刻変更
- 時刻変更の履歴管理（Undo/Redo）
- ダークテーマ対応

---

## 未決定事項

| 項目 | 現状 | 決定タイミング |
|---|---|---|
| `adjustedAt` 設定時の視覚的区別の具体仕様 | 未定（アイコン・色変更など） | architect Spec作成時に確定 |
| 日付をまたぐ変更の要否 | Phase 1ではスコープ外 | ユーザーフィードバック後に判断 |

---

## 備考

- UI-24（ActionTimeアクションボタン大型化）で追加された `ActionButtonProjection.lastLoggedTimeLabel` は、本要件により「有効時間」を参照するよう変更が必要になる
- ActionTimeAdapterの `buttonItems` 算出ロジック（アクションIDごとの最新タイムスタンプ逆引き）も有効時間ベースに変更する
- DBマイグレーションの実装方針はarchitectがSpec作成時にdriftのバージョン管理と合わせて設計する
- 正規化ルール（`adjustedAt == timestamp` のとき `null` に戻す）により、不要なデータ保持を防ぎストレージ効率を維持する
