# 2026-03-27 mark_detail Feature 実装

## 完了した作業

### mark_detail Feature 新規実装
- `flutter/lib/features/mark_detail/draft/mark_detail_draft.dart`
  - MarkDetailDraft（markLinkName, markLinkDate, selectedMembers, meterValueInput, selectedActions, memo, isFuel）
- `flutter/lib/features/mark_detail/bloc/mark_detail_event.dart`
  - sealed Events: Started, DismissPressed, NameChanged, DateChanged, EditMembersPressed, MembersSelected, MeterValueChanged, EditActionsPressed, ActionsSelected, MemoChanged, IsFuelToggled
- `flutter/lib/features/mark_detail/bloc/mark_detail_state.dart`
  - sealed Delegate: DismissDelegate, OpenMembersSelectionDelegate, OpenActionsSelectionDelegate
  - sealed State: Loading, Loaded(draft, delegate?), Error
- `flutter/lib/features/mark_detail/bloc/mark_detail_bloc.dart`
  - EventRepository から EventDomain を取得し markLinkId でフィルタ
- `flutter/lib/features/mark_detail/view/mark_detail_page.dart`
  - StatefulWidget（await context.push + mounted チェック）
  - DatePicker, メンバー/アクション選択, isFuel トグル

### michi_info 更新（eventId パッシング対応）
- `michi_info_state.dart`: delegate に eventId フィールド追加
- `michi_info_bloc.dart`: `_eventId` フィールドを保持して delegate に渡す
- `michi_info_view.dart`: `context.go('/event/mark/$markLinkId', extra: eventId)`

### router.dart 更新
- `/event/mark/:markId` ルート追加
- MarkDetailBloc を BlocProvider で提供

## 未完了の作業 / 次回やること

- link_detail Feature 実装
- payment_detail Feature 実装
- payment_info タブ（EventDetail）実装
- fuel_detail Feature（mark_detail の給油詳細サブ機能）
- EventDetail 全タブ一括保存（§17）
- マーク/リンク新規作成ルート（`/event/mark/new`, `/event/link/new`）
- InMemory スタブへのテストデータ投入（seed data）
- drift Repository 実装（永続化）
- get_it DI セットアップ
- 設定系 Feature（trans_setting, member_setting, tag_setting, action_setting）
