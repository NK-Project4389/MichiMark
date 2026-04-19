import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di.dart';
import '../../../domain/invitation/invitation_role.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/topic/topic_theme_color.dart';
import '../../../repository/action_repository.dart';
import '../../../repository/auth_repository.dart';
import '../../../repository/event_repository.dart';
import '../../../repository/member_repository.dart';
import '../../../repository/tag_repository.dart';
import '../../../repository/topic_repository.dart';
import '../../../repository/trans_repository.dart';
import '../../basic_info/bloc/basic_info_bloc.dart';
import '../../basic_info/bloc/basic_info_event.dart';
import '../../basic_info/bloc/basic_info_state.dart';
import '../../basic_info/view/basic_info_view.dart';
import '../../invite_code_input/repository/invitation_repository.dart';
import '../../invite_link_share/bloc/invite_link_share_bloc.dart';
import '../../invite_link_share/bloc/invite_link_share_event.dart';
import '../../invite_link_share/view/invite_link_share_sheet.dart';
import '../../michi_info/bloc/michi_info_bloc.dart';
import '../../michi_info/bloc/michi_info_event.dart';
import '../../michi_info/bloc/michi_info_state.dart';
import '../../michi_info/view/michi_info_view.dart';
import '../../overview/bloc/overview_bloc.dart';
import '../../overview/bloc/overview_event.dart';
import '../../overview/view/event_detail_overview_page.dart';
import '../../payment_info/bloc/payment_info_bloc.dart';
import '../../payment_info/bloc/payment_info_event.dart';
import '../../payment_info/bloc/payment_info_state.dart';
import '../../payment_info/view/payment_info_view.dart';
import '../bloc/event_detail_bloc.dart';
import '../bloc/event_detail_event.dart';
import '../bloc/event_detail_state.dart';
import '../draft/event_detail_draft.dart';
import '../projection/event_detail_projection.dart';

class EventDetailPage extends StatelessWidget {
  final TopicType? initialTopicType;

  const EventDetailPage({super.key, this.initialTopicType});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailLoaded) {
          final delegate = state.delegate;
          if (delegate != null) {
            _handleDelegate(context, delegate, state);
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          EventDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          EventDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          EventDetailLoaded(
            :final projection,
            :final draft,
            :final topicThemeColor,
            :final topicDisplayName,
          ) =>
            _EventDetailScaffold(
              projection: projection,
              draft: draft,
              topicThemeColor: topicThemeColor,
              topicDisplayName: topicDisplayName,
              initialTopicType: initialTopicType,
            ),
        };
      },
    );
  }

  void _handleDelegate(
    BuildContext context,
    EventDetailDelegate delegate,
    EventDetailLoaded state,
  ) {
    switch (delegate) {
      case EventDetailDismissDelegate():
        context.pop();
      case EventDetailDeletedDelegate():
        context.pop();
      case EventDetailOpenMarkDelegate(:final markLinkId):
        context.go('/event/mark/$markLinkId');
      case EventDetailOpenLinkDelegate(:final markLinkId):
        context.go('/event/link/$markLinkId');
      case EventDetailOpenPaymentDelegate(:final paymentId):
        context.go('/event/payment/$paymentId');
      case EventDetailAddMarkLinkDelegate():
        context.go('/event/mark-link/add');
      case EventDetailOpenInviteLinkDelegate():
        _showInviteLinkShareSheet(context, state);
      case EventDetailOpenInviteCodeInputDelegate():
        context.push('/invite-code');
      case EventDetailTopicConfigPropagateDelegate():
        // 子BlocへTopicConfigを伝播する。
        // 子BlocはEventDetailScaffoldのMultiBlocProvider内にある。
        // EventDetailScaffoldのBlocListenerで処理する。
        break;
    }
  }

  void _showInviteLinkShareSheet(
    BuildContext context,
    EventDetailLoaded state,
  ) {
    final eventId = state.projection.eventId;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => InviteLinkShareBloc(
            invitationRepository: getIt<InvitationRepository>(),
            authRepository: getIt<AuthRepository>(),
            eventId: eventId,
          )..add(const InviteLinkShareStarted()),
          child: const InviteLinkShareSheet(),
        );
      },
    );
  }
}

class _EventDetailScaffold extends StatelessWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;
  final TopicType? initialTopicType;

  const _EventDetailScaffold({
    required this.projection,
    required this.draft,
    this.topicThemeColor,
    this.topicDisplayName,
    this.initialTopicType,
  });

  @override
  Widget build(BuildContext context) {
    final eventId = projection.basicInfo.eventId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BasicInfoBloc(
            eventRepository: getIt<EventRepository>(),
            topicRepository: getIt<TopicRepository>(),
            tagRepository: getIt<TagRepository>(),
            memberRepository: getIt<MemberRepository>(),
            transRepository: getIt<TransRepository>(),
          )..add(BasicInfoStarted(eventId, initialTopicType: initialTopicType)),
        ),
        BlocProvider(
          create: (_) => MichiInfoBloc(
            eventRepository: getIt<EventRepository>(),
            actionRepository: getIt<ActionRepository>(),
            memberRepository: getIt<MemberRepository>(),
          )..add(MichiInfoStarted(eventId)),
        ),
        BlocProvider(
          create: (_) => PaymentInfoBloc(
            eventRepository: getIt<EventRepository>(),
          )..add(PaymentInfoStarted(
              eventId: projection.eventId,
              projection: projection.paymentInfo,
            )),
        ),
        BlocProvider(
          create: (_) => EventDetailOverviewBloc(
            aggregationService: getIt(),
          ),
        ),
      ],
      child: _EventDetailScaffoldInner(
        projection: projection,
        draft: draft,
        topicThemeColor: topicThemeColor,
        topicDisplayName: topicDisplayName,
      ),
    );
  }
}

/// 子Blocが利用可能になったスコープ内でEventDetailBlocのDelegateを処理する。
class _EventDetailScaffoldInner extends StatefulWidget {
  final EventDetailProjection projection;
  final EventDetailDraft draft;
  final TopicThemeColor? topicThemeColor;
  final String? topicDisplayName;

  const _EventDetailScaffoldInner({
    required this.projection,
    required this.draft,
    this.topicThemeColor,
    this.topicDisplayName,
  });

  @override
  State<_EventDetailScaffoldInner> createState() =>
      _EventDetailScaffoldInnerState();
}

class _EventDetailScaffoldInnerState extends State<_EventDetailScaffoldInner> {
  @override
  void initState() {
    super.initState();
    // 初回ロード時に概要タブが選択済みの場合、BlocListenerは
    // Loading→Loaded の遷移をキャッチできないため postFrameCallback で発火する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final eventDetailState = context.read<EventDetailBloc>().state;
      if (eventDetailState is! EventDetailLoaded) return;
      if (eventDetailState.draft.selectedTab != EventDetailTab.overview) return;
      final cachedEvent = eventDetailState.cachedEvent;
      if (cachedEvent == null) return;
      context.read<EventDetailOverviewBloc>().add(OverviewStarted(
            event: cachedEvent,
            topicConfig: eventDetailState.topicConfig,
          ));
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    final themeColor = widget.topicThemeColor;
    final displayName = widget.topicDisplayName;
    final eventName = widget.projection.basicInfo.eventName.isEmpty
        ? 'イベント詳細'
        : widget.projection.basicInfo.eventName;

    final deleteButton = IconButton(
      key: const Key('eventDetail_button_delete'),
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline),
          Text(
            'イベント削除',
            style: TextStyle(
              fontSize: 9,
              color: themeColor != null ? Colors.white : null,
            ),
          ),
        ],
      ),
      onPressed: () => context
          .read<EventDetailBloc>()
          .add(const EventDetailDeleteButtonPressed()),
    );

    if (themeColor == null) {
      // Topic未設定: デフォルトのAppBar表示
      return AppBar(
        leading: IconButton(
          key: const Key('eventDetail_button_back'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _onBackPressed(context),
        ),
        title: Text(eventName),
        centerTitle: true,
        actions: [deleteButton],
      );
    }

    // Topic設定済み: グラデーション AppBar
    return AppBar(
      leading: IconButton(
        key: const Key('eventDetail_button_back'),
        icon: const Icon(Icons.chevron_left),
        onPressed: () => _onBackPressed(context),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventName,
            style: const TextStyle(color: Colors.white),
          ),
          if (displayName != null && displayName.isNotEmpty)
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      centerTitle: true,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.darkColor, themeColor.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [deleteButton],
    );
  }

  void _onBackPressed(BuildContext context) {
    final basicInfoState = context.read<BasicInfoBloc>().state;
    final isEditing =
        basicInfoState is BasicInfoLoaded && basicInfoState.draft.isEditing;
    if (isEditing) {
      _showUnsavedChangesForBack(context);
    } else {
      context.read<EventDetailBloc>().add(const EventDetailDismissPressed());
    }
  }

  void _showUnsavedChangesForBack(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('保存していません'),
          content: const Text('編集内容を保存しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('編集に戻る'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<BasicInfoBloc>().add(const BasicInfoEditCancelled());
                context
                    .read<EventDetailBloc>()
                    .add(const EventDetailDismissPressed());
              },
              child: const Text('破棄して戻る'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoSavePressed(withDismiss: true));
              },
              child: const Text('保存して戻る'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('eventDetail_dialog_deleteConfirm'),
          title: const Text('イベントを削除しますか？'),
          content: const Text('このイベントに関連するすべての情報が削除されます。'),
          actions: [
            TextButton(
              key: const Key('eventDetail_button_deleteCancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<EventDetailBloc>()
                    .add(const EventDetailDeleteDialogDismissed());
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              key: const Key('eventDetail_button_deleteConfirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<EventDetailBloc>()
                    .add(const EventDetailDeleteConfirmed());
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // EventDetailBlocのDelegateを監視し、子BlocへTopicConfig伝播を行う
    return MultiBlocListener(
      listeners: [
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) =>
              curr is EventDetailLoaded && curr.delegate != null,
          listener: (context, state) {
            if (state is! EventDetailLoaded) return;
            final delegate = state.delegate;
            if (delegate == null) return;

            switch (delegate) {
              case EventDetailTopicConfigPropagateDelegate(:final topicConfig):
                if (!context.mounted) return;
                context
                    .read<MichiInfoBloc>()
                    .add(MichiInfoTopicConfigUpdated(topicConfig));
                // OverviewBlocへもTopicConfig変更を伝播する
                final cachedEvent = state.cachedEvent;
                if (cachedEvent != null) {
                  context.read<EventDetailOverviewBloc>().add(
                        OverviewTopicConfigUpdated(
                          config: topicConfig,
                          event: cachedEvent,
                        ),
                      );
                }
                // delegateをnullにリセット
                context
                    .read<EventDetailBloc>()
                    .add(const EventDetailDelegateConsumed());

              case EventDetailDismissDelegate():
              case EventDetailDeletedDelegate():
              case EventDetailOpenMarkDelegate():
              case EventDetailOpenLinkDelegate():
              case EventDetailOpenPaymentDelegate():
              case EventDetailAddMarkLinkDelegate():
              case EventDetailOpenInviteLinkDelegate():
              case EventDetailOpenInviteCodeInputDelegate():
                // これらのDelegateはEventDetailPageの_handleDelegateで処理する
                break;
            }
          },
        ),
        // 削除確認ダイアログ表示フラグを監視する
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return !prev.showDeleteConfirmDialog && curr.showDeleteConfirmDialog;
          },
          listener: (context, state) {
            if (!context.mounted) return;
            _showDeleteConfirmDialog(context);
          },
        ),
        // Overviewタブ選択時にOverviewStartedを発火する
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return prev.draft.selectedTab != EventDetailTab.overview &&
                curr.draft.selectedTab == EventDetailTab.overview;
          },
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is! EventDetailLoaded) return;
            final cachedEvent = state.cachedEvent;
            if (cachedEvent == null) return;
            context.read<EventDetailOverviewBloc>().add(OverviewStarted(
                  event: cachedEvent,
                  topicConfig: state.topicConfig,
                ));
          },
        ),
        // PaymentInfoタブ選択時にPaymentInfoReloadRequestedを発火する
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return prev.draft.selectedTab != EventDetailTab.paymentInfo &&
                curr.draft.selectedTab == EventDetailTab.paymentInfo;
          },
          listener: (context, state) {
            if (!context.mounted) return;
            context.read<PaymentInfoBloc>().add(const PaymentInfoReloadRequested());
          },
        ),
        // BasicInfoSavedDelegate受信後にcachedEventを更新する + isSavedAtLeastOnce を true にする
        BlocListener<BasicInfoBloc, BasicInfoState>(
          listenWhen: (prev, curr) =>
              curr is BasicInfoLoaded && curr.delegate is BasicInfoSavedDelegate,
          listener: (context, state) {
            context
                .read<EventDetailBloc>()
                .add(const EventDetailChildSaved());
            context
                .read<EventDetailBloc>()
                .add(const EventDetailCachedEventUpdateRequested());
          },
        ),
        // BasicInfoSavedAndDismissDelegate受信後にcachedEvent更新 + 画面を閉じる + isSavedAtLeastOnce を true にする
        BlocListener<BasicInfoBloc, BasicInfoState>(
          listenWhen: (prev, curr) =>
              curr is BasicInfoLoaded &&
              curr.delegate is BasicInfoSavedAndDismissDelegate,
          listener: (context, state) {
            context
                .read<EventDetailBloc>()
                .add(const EventDetailChildSaved());
            context
                .read<EventDetailBloc>()
                .add(const EventDetailCachedEventUpdateRequested());
            context
                .read<EventDetailBloc>()
                .add(const EventDetailDismissPressed());
          },
        ),
        // ミチタブが非アクティブになったとき追加モードをリセットする
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return prev.draft.selectedTab == EventDetailTab.michiInfo &&
                curr.draft.selectedTab != EventDetailTab.michiInfo;
          },
          listener: (context, state) {
            if (!context.mounted) return;
            context
                .read<MichiInfoBloc>()
                .add(const MichiInfoTabDeactivated());
          },
        ),
        // MichiInfoReloadedDelegate受信後にcachedEventを更新する（給油情報など集計反映のため）+ isSavedAtLeastOnce を true にする
        BlocListener<MichiInfoBloc, MichiInfoState>(
          listenWhen: (prev, curr) =>
              curr is MichiInfoLoaded &&
              curr.delegate is MichiInfoReloadedDelegate,
          listener: (context, state) {
            context
                .read<EventDetailBloc>()
                .add(const EventDetailChildSaved());
            context
                .read<EventDetailBloc>()
                .add(const EventDetailCachedEventUpdateRequested());
          },
        ),
        // PaymentInfoReloadedDelegate受信後にcachedEventを更新する（概要タブ集計反映のため）+ isSavedAtLeastOnce を true にする
        BlocListener<PaymentInfoBloc, PaymentInfoState>(
          listenWhen: (prev, curr) =>
              curr is PaymentInfoLoaded &&
              curr.delegate is PaymentInfoReloadedDelegate,
          listener: (context, state) {
            context
                .read<EventDetailBloc>()
                .add(const EventDetailChildSaved());
            context
                .read<EventDetailBloc>()
                .add(const EventDetailCachedEventUpdateRequested());
          },
        ),
        // cachedEvent更新時に概要タブを再集計する
        BlocListener<EventDetailBloc, EventDetailState>(
          listenWhen: (prev, curr) {
            if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
              return false;
            }
            return !identical(prev.cachedEvent, curr.cachedEvent) &&
                curr.draft.selectedTab == EventDetailTab.overview;
          },
          listener: (context, state) {
            if (state is! EventDetailLoaded) return;
            final cachedEvent = state.cachedEvent;
            if (cachedEvent == null) return;
            context.read<EventDetailOverviewBloc>().add(OverviewStarted(
                  event: cachedEvent,
                  topicConfig: state.topicConfig,
                ));
          },
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _tabContent(context, widget.draft, widget.projection)),
            const Divider(height: 1),
            _TabBar(selectedTab: widget.draft.selectedTab),
          ],
        ),
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    EventDetailDraft draft,
    EventDetailProjection projection,
  ) {
    return switch (draft.selectedTab) {
      EventDetailTab.overview => _OverviewTabContent(
          eventId: projection.basicInfo.eventId,
        ),
      EventDetailTab.michiInfo => const MichiInfoView(),
      EventDetailTab.paymentInfo =>
        PaymentInfoView(topicThemeColor: widget.topicThemeColor),
    };
  }
}

/// 概要タブのコンテンツ（BasicInfoView + EventDetailOverviewPage の縦並び）
class _OverviewTabContent extends StatelessWidget {
  final String eventId;

  const _OverviewTabContent({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(key: const Key('overview_sectionLabel_basicInfo'), label: '基本情報'),
          const BasicInfoView(),
          const Divider(height: 1),
          _SectionLabel(key: const Key('overview_sectionLabel_overview'), label: '集計'),
          const EventDetailOverviewPage(),
          const Divider(height: 1),
          const _InvitationSection(),
        ],
      ),
    );
  }
}

/// 招待ボタンセクション。userRoleに応じてボタンを切り替える。
class _InvitationSection extends StatelessWidget {
  const _InvitationSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      buildWhen: (prev, curr) {
        if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
          return true;
        }
        return prev.userRole != curr.userRole;
      },
      builder: (context, state) {
        if (state is! EventDetailLoaded) {
          return const SizedBox.shrink();
        }
        final userRole = state.userRole;
        final isOwner = userRole == InvitationRole.owner;
        return Padding(
          key: const Key('overview_section_invitation'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isOwner
              ? OutlinedButton.icon(
                  key: const Key('overview_button_inviteLink'),
                  onPressed: () => context
                      .read<EventDetailBloc>()
                      .add(const EventDetailInviteLinkButtonPressed()),
                  icon: const Icon(Icons.person_add),
                  label: const Text('メンバーを招待'),
                )
              : OutlinedButton.icon(
                  key: const Key('overview_button_inviteCodeInput'),
                  onPressed: () => context
                      .read<EventDetailBloc>()
                      .add(const EventDetailInviteCodeButtonPressed()),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('招待コードを入力'),
                ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final EventDetailTab selectedTab;

  const _TabBar({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: EventDetailTab.values.map((tab) {
          return Expanded(
            child: _TabButton(tab: tab, selectedTab: selectedTab),
          );
        }).toList(),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final EventDetailTab tab;
  final EventDetailTab selectedTab;

  const _TabButton({required this.tab, required this.selectedTab});

  String _label(bool isVisitWork) => switch (tab) {
        EventDetailTab.overview => '概要',
        EventDetailTab.michiInfo => 'ミチ',
        EventDetailTab.paymentInfo => isVisitWork ? '収支' : '支払',
      };

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    // EventDetailBlocのtopicConfigとBasicInfoBlocのisEditingを購読する
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      buildWhen: (prev, curr) {
        if (prev is! EventDetailLoaded || curr is! EventDetailLoaded) {
          return true;
        }
        return prev.topicConfig != curr.topicConfig;
      },
      builder: (context, eventDetailState) {
        final isVisitWork = eventDetailState is EventDetailLoaded &&
            eventDetailState.topicConfig.markActions
                .contains('visit_work_arrive');
        return BlocBuilder<BasicInfoBloc, BasicInfoState>(
          buildWhen: (prev, curr) {
            final prevEditing =
                prev is BasicInfoLoaded ? prev.draft.isEditing : false;
            final currEditing =
                curr is BasicInfoLoaded ? curr.draft.isEditing : false;
            return prevEditing != currEditing;
          },
          builder: (context, basicInfoState) {
            final isEditing = basicInfoState is BasicInfoLoaded &&
                basicInfoState.draft.isEditing;
            return TextButton(
              key: Key('eventDetail_tab_${tab.name}'),
              onPressed: () => _onTabPressed(context, isEditing),
              child: Text(
                _label(isVisitWork),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  void _onTabPressed(BuildContext context, bool isEditing) {
    // 編集中チェック
    if (isEditing) {
      _showUnsavedChangesDialog(context);
      return;
    }
    context.read<EventDetailBloc>().add(EventDetailTabSelected(tab));
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    final targetTab = tab;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('保存していません'),
          content: const Text('編集内容を保存しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('編集に戻る'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoEditCancelled());
                context
                    .read<EventDetailBloc>()
                    .add(EventDetailTabSelected(targetTab));
              },
              child: const Text('破棄して移動'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // 保存後にタブ切り替えを行うため、BasicInfoSavedDelegateを
                // BasicInfoBlocListenerで受け取ってタブ切り替えを実行する
                // ここでは保存のみ発火し、タブ切り替えはEventDetailBlocListenerで行う
                context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoSavePressed());
                // 保存完了後にタブ切り替え（BlocListenerで処理）
                // EventDetailBlocにタブ遷移先を伝えるため、直接切り替えを予約する
                // BasicInfoSavedDelegateがemitされた後にlistenerが動くため
                // ここではタブ切り替えをBlocListenerに委譲
                // 実装上、保存成功後は自動でisEditing=falseになるため
                // 次のフレームでタブ切り替えを行う
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context
                      .read<EventDetailBloc>()
                      .add(EventDetailTabSelected(targetTab));
                });
              },
              child: const Text('保存して移動'),
            ),
          ],
        );
      },
    );
  }
}
