# 2026-03-29 payment_info Feature実装

## 完了した作業

### PaymentInfo Feature実装（flutter-dev）

| ファイル | 内容 |
|---|---|
| `payment_info/bloc/payment_info_event.dart` | Event: Started(eventId, projection注入) / PaymentTapped / PlusButtonTapped |
| `payment_info/bloc/payment_info_state.dart` | State + Delegate: OpenNewPayment / OpenPaymentById |
| `payment_info/bloc/payment_info_bloc.dart` | Bloc: Repository不使用・Projectionを親から受け取る |
| `payment_info/view/payment_info_view.dart` | View: 一覧表示・合計金額・FAB・context.push連携 |

### EventDetailPage更新（flutter-dev）

- `_PaymentInfoTabView` プレースホルダーを `PaymentInfoView` に置き換え
- `MultiBlocProvider` に `PaymentInfoBloc` 追加（Projectionは親から注入）

---

## 設計メモ

- **PaymentInfoBloc はRepository不使用**（Spec定義通り）
  - Projectionは `PaymentInfoStarted.projection` で親（EventDetailPage）から注入
- **ナビゲーションはPaymentInfoView内で処理**（MichiInfoViewと同パターン）
  - `context.push('/event/payment', extra: PaymentDetailArgs(eventId, paymentId?))`
  - `paymentId == null` → 新規作成
  - `paymentId != null` → 既存編集
- **保存結果の反映は未実装**（EventDetail 全タブ一括保存フェーズで対応予定）

---

## 未完了の作業

なし（payment_info Feature完結）

---

## 次回やること

### 優先タスク
1. マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
2. EventDetail 全タブ一括保存（§17）
3. InMemory スタブへのテストデータ投入（seed data）
4. drift Repository 実装（永続化）
5. get_it DI セットアップ
6. 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）
