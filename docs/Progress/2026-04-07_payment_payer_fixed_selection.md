# 2026-04-07 割り勘支払者 固定チェック実装

## 完了した作業

### Task 5: 割り勘メンバー選択で支払者を常にON固定

- `SelectionItemProjection` に `isFixed: bool` フィールド追加（デフォルト false）
- `SelectionArgs` に `fixedSelectedIds: Set<String>` フィールド追加（デフォルト const {}）
- `SelectionBloc`
  - コンストラクタに `fixedSelectedIds` パラメータ追加・フィールド保持
  - `_onItemToggled`: 固定IDが来た場合は early return（トグル不可）
  - `_buildResult` の `splitMembers` ケース: `_fixedSelectedIds` を `draft.selectedIds` にマージして確実に含める
- `SelectionAdapter.fromMembers`: `fixedSelectedIds` パラメータ追加、固定IDのアイテムに `isFixed: true, isSelected: true` を付与
- `SelectionAdapter.rebuild`: `isFixed` を保持、固定アイテムは `isSelected: true` を維持
- `selection_page.dart` の `_SelectionItem`: 固定アイテムをグレーアウト・`onTap: null` で非活性
- `payment_detail_page.dart`: 割り勘メンバー選択を開く際に `fixedSelectedIds: {paymentMember.id}` を渡す
- `router.dart`: `SelectionBloc` 生成時に `args.fixedSelectedIds` を渡す

## 変更ファイル

- `flutter/lib/features/selection/projection/selection_projection.dart`
- `flutter/lib/features/selection/selection_args.dart`
- `flutter/lib/features/selection/bloc/selection_bloc.dart`
- `flutter/lib/features/selection/view/selection_page.dart`
- `flutter/lib/adapter/selection_adapter.dart`
- `flutter/lib/features/payment_detail/view/payment_detail_page.dart`
- `flutter/lib/app/router.dart`

## 未完了・次回やること

- なし（Task 5 完了）
