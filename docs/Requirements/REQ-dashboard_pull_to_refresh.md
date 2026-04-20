# REQ-dashboard_pull_to_refresh

## 概要

ダッシュボードタブで上方向へのプルダウン操作（Pull-to-Refresh）によりデータをリロードできるようにする。

- **要件ID**: REQ-dashboard_pull_to_refresh
- **作成日**: 2026-04-20
- **担当**: product-manager
- **ステータス**: Draft（ユーザー確認待ち）
- **種別**: UI改善（UI-26）
- **関連要件書**: REQ-dashboard（F-2）
- **関連Spec**: FS-dashboard

---

## ユーザーストーリー

**誰が**: MichiMarkのユーザーが

**何を**: ダッシュボードタブで画面を上にスクロール（プルダウン）することで、表示データをリロードできるようにしたい

**なぜ**: 他の画面でデータを追加・編集した後、ダッシュボードに戻ったときに最新の集計結果を即座に確認したいから

---

## 要件項目

### Pull-to-Refresh 動作

- [ ] ダッシュボードの各ビュー（MovingCost / TravelExpense / VisitWork）で、上方向へのプルダウン操作によりデータをリロードする
- [ ] FlutterのMaterial Design標準 `RefreshIndicator` ウィジェットを使用する
- [ ] プルダウン操作時にローディングインジケーター（スピナー）を表示する
- [ ] リロード完了後にインジケーターを自動的に非表示にする

### リロード対象

- [ ] 現在選択中のトピックのダッシュボードデータを再取得する
- [ ] DashboardBlocに対して `DashboardInitialized` イベントを再発火し、Repositoryからデータを再取得する
- [ ] リロード後、グラフ・KPIの表示が最新データで更新される

### 適用範囲

- [ ] 3種類のDashboardView全てに適用する
  - MovingCostDashboardView
  - TravelExpenseDashboardView
  - VisitWorkDashboardView
- [ ] トピック選択チップ部分はリフレッシュ対象外（スクロール領域に含めない、またはチップはリフレッシュで再描画しない）

### UI/UX

- [ ] `RefreshIndicator` のインジケーターカラーはアプリのテーマカラーに準拠する
- [ ] リロード中にユーザーが画面操作（トピック切り替え等）を行った場合の挙動をArchitectが設計時に定義する

### テスト対応

- [ ] Pull-to-Refresh操作をIntegration Testで検証可能にする（`tester.drag` によるプルダウン操作）
- [ ] リロード後にデータが再表示されることを確認するテストシナリオを設計する

---

## 受け入れ条件

1. ダッシュボードの各ビュー（MovingCost / TravelExpense / VisitWork）で、上方向へのプルダウン操作によりリロードが発動する
2. プルダウン時にMaterial Design標準のローディングインジケーターが表示される
3. リロード完了後、グラフ・KPIが最新データで更新される
4. リロード完了後にインジケーターが非表示になる
5. 既存のトピック切り替え・ダッシュボード表示機能に影響しない

---

## 設計上の考慮事項（Architect向け）

1. **RefreshIndicatorの配置階層**: `RefreshIndicator` は各DashboardView（MovingCost/TravelExpense/VisitWork）それぞれに配置するか、DashboardPage全体に1つ配置するかを検討する。各Viewが `SingleChildScrollView` を使用している現状を踏まえると、各View単位での配置が自然と想定される
2. **ScrollControllerとの関係**: `SingleChildScrollView` を `RefreshIndicator` の子として配置する場合、`AlwaysScrollableScrollPhysics` の設定が必要（コンテンツがビューポートより短い場合でもプルダウンを有効にするため）
3. **イベント設計**: 既存の `DashboardInitialized` イベントの再発火で十分か、専用の `DashboardRefreshed` イベントを新設するかを検討する
4. **リロード中の状態管理**: リロード中にローディング状態を別途管理するか、`RefreshIndicator` の内部状態に任せるかを検討する

---

## 備考

- 現在のダッシュボードはタブ切り替え時に `DashboardInitialized` イベントで初期データを取得している。Pull-to-Refreshは同様のデータ再取得の仕組みを流用できる可能性が高い
- ダッシュボードは表示専用Feature（Draft保有なし）であるため、リロード操作による編集データの喪失リスクはない
- `RefreshIndicator` は `Scrollable` な子ウィジェットを必要とするため、各Viewの `SingleChildScrollView` との組み合わせで実装する

---

*End of Requirement: REQ-dashboard_pull_to_refresh*
