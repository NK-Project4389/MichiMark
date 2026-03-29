# 2026-03-29 fuel_detail Feature実装・product-managerロール追加

## 完了した作業

### プロセス整備
- `product-manager` ロールをCLAUDE.mdに追加
  - 追加要件発生時に要件書を作成する役割
  - フロー: product-manager → architect → flutter-dev → reviewer
  - Flutter移行タスクは都度判断
- `docs/Requirements/` ディレクトリ作成

### FuelDetail 要件書・Spec作成
- `docs/Requirements/FuelDetail_Requirements.md` 作成（product-manager）
  - 計算仕様：単価必須・2方向計算（単価は計算しない）
  - インライン埋め込み・Domain不持ち確定
- `docs/Spec/Features/EventDetail/FuelDetail/FuelDetailFeature_Spec.md` 作成（architect）
  - Draft: pricePerGas / gasQuantity / gasPrice（全String）
  - Delegate: FuelDraftChanged（全変更後に発火）
  - Domain/Projection/Adapter: なし（計算専用Feature）

### 既存Spec更新（architect）
- **MarkDetail Spec**: `FuelChanged` → `IsFuelToggled` + `FuelFieldsChanged` に分離、FuelDetail連携ノート追加
- **LinkDetail Spec**: Fuel fields追加（Domain参照・Draft・Projection・Events）、FuelDetail連携ノート追加

### FuelDetail Feature実装（flutter-dev）
- `flutter/lib/features/fuel_detail/draft/fuel_detail_draft.dart`
- `flutter/lib/features/fuel_detail/bloc/fuel_detail_event.dart`
- `flutter/lib/features/fuel_detail/bloc/fuel_detail_state.dart`
- `flutter/lib/features/fuel_detail/bloc/fuel_detail_bloc.dart`
- `flutter/lib/features/fuel_detail/view/fuel_detail_widget.dart`

### MarkDetail・LinkDetail更新（flutter-dev）
- `MarkDetailDraft`: pricePerGasInput / gasQuantityInput / gasPriceInput 追加
- `MarkDetailEvent`: MarkDetailFuelFieldsChanged 追加
- `MarkDetailBloc`: FuelFieldsChanged handler追加、Started で fuel fields 初期化
- `LinkDetailDraft`: isFuel / pricePerGasInput / gasQuantityInput / gasPriceInput 追加
- `LinkDetailEvent`: LinkDetailIsFuelToggled / LinkDetailFuelFieldsChanged 追加
- `LinkDetailBloc`: 新イベントhandler追加、Started で fuel fields 初期化

### ページ組み込み（flutter-dev）
- `MarkDetailPage._FuelRow`: プレースホルダー → FuelDetailWidget 組み込み
- `LinkDetailPage._FuelRow`: 新規追加・FuelDetailWidget 組み込み
- 両ページ: BlocProvider + BlocListener でFuelDetailBloc↔親Bloc連携

---

## 未完了の作業

なし（fuel_detail Feature完結）

---

## 次回やること

### 優先タスク
1. **payment_detail** Feature 実装（Spec既存あり）
2. **payment_info** タブ（EventDetail）実装
3. マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
4. EventDetail 全タブ一括保存（§17）
5. InMemory スタブへのテストデータ投入（seed data）
6. drift Repository 実装（永続化）
7. get_it DI セットアップ
8. 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）

### 設計メモ
- gasQuantity の型変換: Draft=String（"30.0"）/ Domain=int（×10）
- FuelDetail は計算専用Feature・Domain不持ち
- FuelDetailBloc は BlocProvider でページ側が提供、BlocListener で親Blocへ同期
