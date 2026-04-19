# Feature Spec: UI-16 スプラッシュ画面改善

- **Spec ID**: FS-splash_screen_improvement
- **要件書**: REQ-splash_screen_improvement
- **作成日**: 2026-04-20
- **担当**: architect
- **ステータス**: Draft

---

## 1. Feature Overview

### Feature Name

SplashScreen

### Purpose

アプリ起動時の体験を改善する。ネイティブスプラッシュ（OS起動直後）とFlutterスプラッシュ（Dartエンジン起動後）を統一したTealカラー（`#2B7A9E`）で構成し、DI初期化完了までユーザーに視覚的フィードバックを提供した後、Dashboardへシームレスに遷移する。

### Scope

含むもの
- flutter_native_splash によるネイティブスプラッシュ設定（iOS/Android）
- Dart層スプラッシュ画面ウィジェットの新設（`/splash` ルート）
- ロゴフェードイン + スケールアニメーション
- DI初期化（GetIt）完了待機ロジック
- 最低表示時間（1秒）の保証
- Dashboard（`/dashboard`）へのフェードアウト遷移
- Integration Test用スプラッシュスキップの維持（`router.go('/')` パターン）
- 白抜きロゴアセットの新規追加（flutter-dev または designer が用意する）

含まないもの
- ダークモード対応
- ローディング進捗バーの表示
- 初回起動時オンボーディング連携
- Lottie等の外部アニメーションライブラリ使用

---

## 2. Feature Responsibility

SplashScreen Feature の責務

- DI初期化完了の待機（`setupDi()` 完了後のタスク実行）
- 最低表示時間（1秒）の計測・保証
- Dashboard遷移の Delegate 発火

RootはこのFeatureの内部状態を変更しない。

### アーキテクチャ上の注意

スプラッシュ画面は「表示専用の一時画面」であり、編集可能なデータを持たない。そのため通常の Draft / Projection / Adapter の三層は不要とし、BlocのStateはシンプルな sealed class（enum相当）で表現する。この Feature に限り Draft・Projection・Adapter を省略することを明示的に許可する。

---

## 3. State Structure

```
SplashState（sealed）
  - SplashInitial         : 初期状態
  - SplashAnimating       : アニメーション再生中
  - SplashCompleted       : 初期化完了・遷移準備完了
    - delegate: SplashDelegate?
```

Delegate が非 null になったタイミングで BlocListener が `context.go('/dashboard')` を実行する。

---

## 4. Draft Model

不要（スプラッシュ画面は編集状態を持たない）。

---

## 5. Domain Model

不要（スプラッシュ画面はドメインデータを扱わない）。

---

## 6. Projection Model

不要（表示内容はアニメーション状態のみ。Widget内で `AnimationController` 値を直接参照する）。

---

## 7. Adapter

不要。

---

## 8. Events

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `SplashStarted` | スプラッシュ画面が `initState` で呼ぶ | アニメーション開始・初期化完了待機を開始する |
| `SplashInitializationCompleted` | DI初期化完了 AND 最低表示時間経過の両方が揃ったとき | Bloc内部で発火。Dashboard遷移の Delegate をセットする |

`SplashStarted` を受け取ったBlocは以下を並列実行する。
- 最低1秒のタイマー（`Future.delayed`）
- DI初期化完了の確認（`setupDi()` が同期完了している場合は即時OK、非同期の場合は完了を待つ）

両方が揃ったタイミングで `SplashInitializationCompleted` を発火する。

---

## 9. Delegate Contract

| Delegate名 | 遷移先 | 説明 |
|---|---|---|
| `SplashNavigateToDashboardDelegate` | `/dashboard` | 初期化完了後にDashboardへ遷移する |

BlocListener が Delegate を受け取り `context.go('/dashboard')` を実行する。Bloc内での直接遷移は禁止。

---

## 10. Bloc Responsibility

Bloc は以下のみ行う。

- アニメーション開始の State 発火（`SplashAnimating`）
- タイマーとDI完了の待機
- 完了時の Delegate 発火（`SplashCompleted(delegate: SplashNavigateToDashboardDelegate())`）

禁止事項

- `context.go()` / `Navigator.push()` 等の直接ナビゲーション操作
- Repository への直接アクセス

---

## 11. Navigation

### ルーター変更方針

| 変更内容 | 詳細 |
|---|---|
| `initialLocation` 変更 | `'/dashboard'` → `'/splash'` |
| `/splash` ルート追加 | `SplashPage` をレンダリング（ShellRoute の外に置く） |
| `/` ルートの維持 | Integration Test の `router.go('/')` パターンが引き続き動作すること |

### テスト互換スキップ

`main.dart` の `isTest`（`FLUTTER_TEST` 環境変数）判定と同じパターンで、テスト実行時は `/splash` を初期ルートとしない仕組みを設ける。具体的には `router.go('/')` を `app.main()` より先に呼ぶことで `/splash` をスキップできる。これは既存の Integration Test ヘルパーパターンと完全に互換性を保つ。

---

## 12. Data Flow

```
app.main()
  ↓
setupDi()（同期: GetIt登録）
  ↓
runApp()
  ↓
GoRouter initialLocation = '/splash'
  ↓
SplashPage（BlocProvider<SplashBloc> 生成）
  ↓
SplashBloc receives SplashStarted
  ↓
[並列] タイマー1秒 AND DI完了確認
  ↓
SplashInitializationCompleted（両条件充足）
  ↓
State: SplashCompleted(delegate: SplashNavigateToDashboardDelegate())
  ↓
BlocListener → context.go('/dashboard')
```

アニメーション側の流れ

```
SplashStarted
  ↓
AnimationController.forward()（フェードイン + スケール: 1〜2秒）
  ↓
SplashPage Widget でアニメーション値を FadeTransition + ScaleTransition に反映
```

---

## 13. Persistence

なし（スプラッシュ画面は永続化データを扱わない）。

---

## 14. Validation

なし。

---

## 15. Assets（新規追加）

| アセット | 内容 | 担当 |
|---|---|---|
| `assets/images/logo_white.png` | Teal背景用の白抜きロゴ（新規作成） | flutter-dev または designer が用意する |

白抜きロゴが用意できない場合の暫定対応として、既存アイコン（`Icon-App-1024x1024`）を使用することも可とする。

### pubspec.yaml 追加内容

`flutter_native_splash` を `dev_dependencies` に追加し、`flutter_native_splash` セクションを `pubspec.yaml` に記述してネイティブスプラッシュを一元管理する。

```
flutter_native_splash:
  color: "#2B7A9E"
  image: assets/images/logo_white.png
  android: true
  ios: true
```

---

## 16. SwiftUI版との対応

| Flutter Feature | 対応SwiftUI |
|---|---|
| splash_screen | なし（Flutter新設） |

SwiftUI版にはDart層のスプラッシュ画面は存在しない。Flutter版で新規に設計する。

---

## 17. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- `FLUTTER_TEST` 環境変数が設定されていないこと（本スプラッシュテストはアプリを通常起動する専用テストファイルで実行）
- Integration Test の既存テストファイルは従来通り `router.go('/')` でスキップするため、本 Feature のテストファイルは独立したファイルで実装する

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 | テスト層 |
|---|---|---|---|
| TC-UI16-I001 | スプラッシュ画面の表示確認 | High | Integration Test |
| TC-UI16-I002 | アニメーション完了後にDashboardへ遷移する | High | Integration Test |
| TC-UI16-I003 | router.go('/') でスプラッシュをスキップできる | High | Integration Test |

### シナリオ詳細

---

#### TC-UI16-I001: スプラッシュ画面の表示確認

**テスト層**: Integration Test（`flutter/integration_test/splash_screen_test.dart`）

**前提**:
- アプリを通常起動する（`router.go('/')` スキップなし）
- スプラッシュ画面はアニメーション中に確認する

**操作手順**:
1. `GetIt.I.reset()` 後、`app.main()` をそのまま呼ぶ（`router.go('/')` を先行させない）
2. `pump` を数回実行してスプラッシュ画面が描画されるのを待つ

**期待結果**:
- `Key('splash_image_logo')` を持つウィジェットが表示される
- 背景色がTeal（`#2B7A9E`）であること（`Key('splash_container_background')` で確認）

**実装ノート**:
- Widgetキー一覧:
  - `Key('splash_container_background')` — 背景コンテナ
  - `Key('splash_image_logo')` — ロゴ画像
- シードデータ依存: なし

---

#### TC-UI16-I002: アニメーション完了後にDashboardへ遷移する

**テスト層**: Integration Test（`flutter/integration_test/splash_screen_test.dart`）

**前提**:
- アプリを通常起動する（`router.go('/')` スキップなし）

**操作手順**:
1. `GetIt.I.reset()` 後、`app.main()` を呼ぶ
2. 最低表示時間（1秒）＋アニメーション時間（最大2秒）を考慮し、`pump(Duration(milliseconds: 500))` を最大10回繰り返す
3. Dashboard画面の表示を待つ

**期待結果**:
- スプラッシュ画面が消え、`Key('dashboard_tab')` が存在するDashboard画面が表示される
- タイムアウト（5秒）以内に遷移が完了する

**実装ノート**:
- Widgetキー一覧:
  - `Key('dashboard_tab')` — Dashboard画面のボトムナビゲーションタブ（既存キー）
- シードデータ依存: なし

---

#### TC-UI16-I003: router.go('/') でスプラッシュをスキップできる

**テスト層**: Integration Test（`flutter/integration_test/splash_screen_test.dart`）

**前提**:
- 既存の Integration Test ヘルパーパターン（`router.go('/')` を `app.main()` より先に呼ぶ）が維持されていること

**操作手順**:
1. `GetIt.I.reset()` を呼ぶ
2. `router.go('/')` を呼ぶ
3. `app.main()` を呼ぶ
4. `pump(Duration(milliseconds: 500))` を最大20回繰り返す

**期待結果**:
- スプラッシュ画面を経由せず、`find.text('イベント一覧')` が表示される（既存動作の維持確認）

**実装ノート**:
- Widgetキー一覧: 特になし（`find.text('イベント一覧')` で確認）
- シードデータ依存: なし

---

## 18. 備考

- `flutter_native_splash` の生成コマンド: `flutter pub run flutter_native_splash:create`
- ネイティブスプラッシュ → Flutterスプラッシュ間の「チラつき」防止のため、両者の背景色を `#2B7A9E` で完全に一致させること
- `AnimationController` は `TickerProviderStateMixin` を使用し、`dispose()` での解放を忘れないこと（設計憲章準拠）
- 白抜きロゴアセットの準備が実装着手前に完了していない場合、暫定として既存アイコン画像を使用し、後から差し替える運用を許容する

---

*End of Feature Spec: FS-splash_screen_improvement*
