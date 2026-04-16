# Feature Spec: FS-dashboard_tab_position

- **Spec ID**: FS-dashboard_tab_position
- **要件書**: REQ-dashboard_tab_position
- **作成日**: 2026-04-16
- **担当**: architect
- **ステータス**: 確定
- **種別**: UI改善（UI-17）
- **関連Spec**: FS-dashboard

---

# 1. Feature Overview

## Feature Name

DashboardTabPosition（ダッシュボードタブ左側配置・初期タブ化）

## Purpose

ダッシュボードタブをボトムナビゲーションの先頭（左側）に移動し、アプリ起動時の初期表示タブにする。ユーザーが毎回手動でタブを切り替えなくても、起動直後にサマリーを確認できる導線を実現する。

## Scope

含むもの
- ボトムナビゲーション上のタブ順序変更（ダッシュボードを1番目・イベント一覧を2番目）
- アプリ起動時の初期ルート変更（`/` → `/dashboard` または go_router の初期パス変更）
- 既存の Integration Test のうちタブ順序に依存するものの修正

含まないもの
- ダッシュボードの表示内容・ロジック（FS-dashboard の実装範囲を変更しない）
- タブのアイコン・ラベル文字列（変更なし、ラベル文字列は UI-18 で別途変更）
- イベント一覧画面の内部実装（変更なし）
- タブ数の増加・3タブ以上への拡張

---

# 2. Feature Responsibility

変更対象はルーター設定とボトムナビゲーションの構造のみ。

- Draft / Projection / Bloc / Domain の変更なし
- Root（AppRouter / `_ScaffoldWithBottomNav`）のタブ定義順序と `initialLocation` のみ変更する

---

# 3. 変更内容

## 3-1. タブ順序

| 位置 | 変更前 | 変更後 |
|---|---|---|
| 1番目（左） | イベント一覧（`/`） | ダッシュボード（`/dashboard`） |
| 2番目（右） | ダッシュボード（`/dashboard`） | イベント一覧（`/`） |

## 3-2. 初期ルート

- go_router の `initialLocation` を `/dashboard` に変更する
- アプリ起動時に最初に表示されるタブがダッシュボードになること

## 3-3. Widget Key

タブに付与するキーは変更しない（FS-dashboard で定義済みのキーを維持する）。

| Widget | Key |
|---|---|
| ダッシュボードタブ | `Key('dashboard_tab')` |
| イベント一覧タブ | `Key('event_list_tab')` |

> `Key('event_list_tab')` が未付与の場合は本変更時に付与する。

---

# 4. Data Flow

変更なし（タブ順序・初期ルートのみ変更のため）

---

# 5. Router変更方針

- `flutter/lib/app/router.dart` の `GoRouter` の `initialLocation` を `'/dashboard'` に変更する
- `ShellRoute` 内の `GoRoute` 定義順序をダッシュボードを先頭に変更する
- `_ScaffoldWithBottomNav` 内のナビゲーションアイテム定義順序も合わせて変更する

---

# 6. Test Scenarios

## 前提条件

- iOSシミュレーター起動済み
- アプリが初期状態（クリーンインストール相当）で起動できること

## テストシナリオ一覧

| ID | シナリオ名 | 種別 | 優先度 |
|---|---|---|---|
| TC-TAB-001 | アプリ起動時にダッシュボードが最初に表示される | Integration | High |
| TC-TAB-002 | ダッシュボードタブがナビゲーションバーの左側（先頭）に表示される | Integration | High |
| TC-TAB-003 | イベント一覧タブをタップすると一覧画面に切り替わる | Integration | High |
| TC-TAB-004 | ダッシュボードタブをタップするとダッシュボード画面に戻る | Integration | High |

## シナリオ詳細

### TC-TAB-001: アプリ起動時にダッシュボードが最初に表示される

**前提:**
- アプリを起動する（初期ルートを使用）

**操作手順:**
1. アプリを起動する

**期待結果:**
- `Key('dashboard_tab')` がナビゲーションバーに表示される
- ダッシュボード画面（`Key('dashboard_tab')` が選択状態）が表示されること
- イベント一覧画面は表示されていないこと

**実装ノート（ウィジェットキー一覧）:**
- `Key('dashboard_tab')`: ダッシュボードタブ（ナビゲーションバー）

---

### TC-TAB-002: ダッシュボードタブがナビゲーションバーの左側（先頭）に表示される

**前提:**
- アプリを起動した状態

**操作手順:**
1. アプリを起動する
2. ナビゲーションバーのタブ配置を確認する

**期待結果:**
- `Key('dashboard_tab')` が `Key('event_list_tab')` より左側（インデックス0側）に配置されている
- 具体的には `find.byKey(const Key('dashboard_tab'))` が `find.byKey(const Key('event_list_tab'))` より画面左側に存在すること

**実装ノート（ウィジェットキー一覧）:**
- `Key('dashboard_tab')`: ダッシュボードタブ（ナビゲーションバー）
- `Key('event_list_tab')`: イベント一覧タブ（ナビゲーションバー）

---

### TC-TAB-003: イベント一覧タブをタップすると一覧画面に切り替わる

**前提:**
- アプリ起動後、ダッシュボードが表示されている状態

**操作手順:**
1. アプリを起動する（ダッシュボードが表示される）
2. `Key('event_list_tab')` をタップする

**期待結果:**
- イベント一覧画面が表示される
- `Key('event_list_tab')` が選択状態になる

**実装ノート（ウィジェットキー一覧）:**
- `Key('event_list_tab')`: イベント一覧タブ（ナビゲーションバー）
- イベント一覧画面のルートウィジェット（既存のキーを参照）

---

### TC-TAB-004: ダッシュボードタブをタップするとダッシュボード画面に戻る

**前提:**
- アプリ起動後、イベント一覧タブを選択している状態

**操作手順:**
1. アプリを起動する（ダッシュボードが表示される）
2. `Key('event_list_tab')` をタップする（イベント一覧へ移動）
3. `Key('dashboard_tab')` をタップする

**期待結果:**
- ダッシュボード画面が再度表示される
- `Key('dashboard_tab')` が選択状態になる

**実装ノート（ウィジェットキー一覧）:**
- `Key('dashboard_tab')`: ダッシュボードタブ（ナビゲーションバー）
- `Key('event_list_tab')`: イベント一覧タブ（ナビゲーションバー）

---

# End of Feature Spec
