# 2026-03-29 link_detail Feature 実装

## 完了した作業

### link_detail Feature 新規実装

- `flutter/lib/features/link_detail/draft/link_detail_draft.dart`
  - LinkDetailDraft（markLinkName, markLinkDate, distanceValueInput, selectedMembers, selectedActions, memo）
  - markLinkDate は保持用（仕様上編集なし）
  - distanceValueInput はテキスト入力用String

- `flutter/lib/features/link_detail/bloc/link_detail_event.dart`
  - sealed Events: Started, DismissPressed, NameChanged, DistanceChanged, EditMembersPressed, MembersSelected, EditActionsPressed, ActionsSelected, MemoChanged

- `flutter/lib/features/link_detail/bloc/link_detail_state.dart`
  - sealed Delegate: DismissDelegate, OpenMembersSelectionDelegate, OpenActionsSelectionDelegate
  - sealed State: Loading, Loaded(draft, delegate?), Error

- `flutter/lib/features/link_detail/bloc/link_detail_bloc.dart`
  - EventRepository から EventDomain を取得し markLinkId でフィルタ（type=link）
  - 各Event ハンドラで Draft copyWith による状態更新

- `flutter/lib/features/link_detail/view/link_detail_page.dart`
  - StatefulWidget（await context.push + mounted チェック）
  - メンバー・アクション選択（linkMembers / linkActions 使用）
  - 名称・走行距離・メモ入力フィールド

### router.dart 更新

- `/event/link/:linkId` ルート追加
- LinkDetailBloc を BlocProvider で提供

## 未完了の作業 / 次回やること

- fuel_detail Feature（mark_detail のサブ機能）
- payment_detail Feature
- payment_info タブ（EventDetail）
- マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
- EventDetail 全タブ一括保存（§17）
- InMemory スタブへのテストデータ投入（seed data）
- drift Repository 実装（永続化）
- get_it DI セットアップ
- 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）
