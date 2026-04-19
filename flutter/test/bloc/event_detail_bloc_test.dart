import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:michi_mark/domain/topic/topic_domain.dart';
import 'package:michi_mark/domain/topic/topic_config.dart';
import 'package:michi_mark/domain/transaction/event/event_domain.dart';
import 'package:michi_mark/features/event_detail/bloc/event_detail_bloc.dart';
import 'package:michi_mark/features/event_detail/bloc/event_detail_event.dart';
import 'package:michi_mark/features/event_detail/bloc/event_detail_state.dart';
import 'package:michi_mark/features/event_detail/draft/event_detail_draft.dart';
import 'package:michi_mark/features/event_detail/projection/event_detail_projection.dart';
import 'package:michi_mark/features/event_detail/projection/basic_info_projection.dart';
import 'package:michi_mark/features/event_detail/projection/michi_info_list_projection.dart';
import 'package:michi_mark/features/event_detail/projection/payment_info_projection.dart';
import 'package:michi_mark/repository/event_repository.dart';
import 'package:michi_mark/repository/topic_repository.dart';
import 'package:michi_mark/features/invite_code_input/repository/invitation_repository.dart';

// Mock classes
class MockEventRepository extends Mock implements EventRepository {}

class MockTopicRepository extends Mock implements TopicRepository {}

class MockInvitationRepository extends Mock implements InvitationRepository {}

void main() {
  group('EventDetailBloc - State変換テスト', () {
    late MockEventRepository mockEventRepository;
    late MockTopicRepository mockTopicRepository;
    late MockInvitationRepository mockInvitationRepository;
    late EventDetailBloc bloc;

    final now = DateTime.now();

    // テスト用Projection
    late EventDetailProjection testProjection;
    late EventDomain testEventDomain;

    setUp(() {
      mockEventRepository = MockEventRepository();
      mockTopicRepository = MockTopicRepository();
      mockInvitationRepository = MockInvitationRepository();

      testProjection = EventDetailProjection(
        eventId: 'event_1',
        basicInfo: BasicInfoProjection.empty('event_1'),
        michiInfo: MichiInfoListProjection.empty,
        paymentInfo: PaymentInfoProjection.empty,
      );

      testEventDomain = EventDomain(
        id: 'event_1',
        eventName: 'テストイベント',
        createdAt: now,
        updatedAt: now,
      );

      bloc = EventDetailBloc(
        eventRepository: mockEventRepository,
        topicRepository: mockTopicRepository,
        invitationRepository: mockInvitationRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    // TC-001: EventDetailTabSelected - michiInfoタブをタップするとselectedTabが変わる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-001: michiInfoタブをタップするとselectedTabがmichiInfoに変わる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(selectedTab: EventDetailTab.overview),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailTabSelected(EventDetailTab.michiInfo)),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.draft.selectedTab, 'selectedTab', EventDetailTab.michiInfo),
      ],
    );

    // TC-002: EventDetailTabSelected - overviewタブをタップするとselectedTabがoverviewに変わる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-002: overviewタブをタップするとselectedTabがoverviewに変わる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(selectedTab: EventDetailTab.michiInfo),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailTabSelected(EventDetailTab.overview)),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.draft.selectedTab, 'selectedTab', EventDetailTab.overview),
      ],
    );

    // TC-003: EventDetailTabSelected - paymentInfoタブをタップするとselectedTabがpaymentInfoに変わる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-003: paymentInfoタブをタップするとselectedTabがpaymentInfoに変わる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(selectedTab: EventDetailTab.overview),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailTabSelected(EventDetailTab.paymentInfo)),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.draft.selectedTab, 'selectedTab', EventDetailTab.paymentInfo),
      ],
    );

    // TC-004: EventDetailDeleteButtonPressed - showDeleteConfirmDialogがtrueになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-004: 削除ボタンを押すとshowDeleteConfirmDialogがtrueになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
        showDeleteConfirmDialog: false,
      ),
      act: (bloc) => bloc.add(const EventDetailDeleteButtonPressed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.showDeleteConfirmDialog, 'showDeleteConfirmDialog', true),
      ],
    );

    // TC-005: EventDetailDeleteDialogDismissed - showDeleteConfirmDialogがfalseに戻る
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-005: 削除ダイアログを閉じるとshowDeleteConfirmDialogがfalseに戻る',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
        showDeleteConfirmDialog: true,
      ),
      act: (bloc) => bloc.add(const EventDetailDeleteDialogDismissed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.showDeleteConfirmDialog, 'showDeleteConfirmDialog', false),
      ],
    );

    // TC-006: EventDetailChildSaved - isSavedAtLeastOnceがtrueになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-006: 子Bloc保存時、isSavedAtLeastOnceがtrueになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: false,
      ),
      act: (bloc) => bloc.add(const EventDetailChildSaved()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.isSavedAtLeastOnce, 'isSavedAtLeastOnce', true),
      ],
    );

    // TC-007: EventDetailDelegateConsumed - delegateがnullになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-007: delegateを消費するとdelegateがnullになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        delegate: const EventDetailDismissDelegate(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailDelegateConsumed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', null),
      ],
    );

    // TC-008: EventDetailDismissPressed（isNewEvent=false） - delegateが発行される削除は呼ばれない
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-008: 既存イベントで戻る場合、EventDetailDismissDelegateが発行・delete呼ばれない',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false, // 既存イベント
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailDismissPressed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailDismissDelegate>()),
      ],
      verify: (bloc) {
        // deleteが呼ばれていないことを確認
        verifyNever(() => mockEventRepository.delete(any()));
      },
    );

    // TC-009: EventDetailDismissPressed（isNewEvent=true && isSavedAtLeastOnce=false） - deleteが呼ばれ、delegateが発行される
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-009: 新規イベント・未保存で戻る場合、deleteが呼ばれてEventDetailDismissDelegateが発行',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: true, // 新規イベント
        isSavedAtLeastOnce: false, // 未保存
      ),
      act: (bloc) async {
        when(() => mockEventRepository.delete('event_1')).thenAnswer((_) async => {});
        bloc.add(const EventDetailDismissPressed());
      },
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailDismissDelegate>()),
      ],
      verify: (bloc) {
        // deleteが呼ばれることを確認
        verify(() => mockEventRepository.delete('event_1')).called(1);
      },
    );

    // TC-010: EventDetailDismissPressed（isNewEvent=true && isSavedAtLeastOnce=true） - delegateが発行される・deleteは呼ばれない
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-010: 新規イベント・1件以上保存で戻る場合、delete呼ばれない',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: true, // 新規イベント
        isSavedAtLeastOnce: true, // 1件以上保存済み
      ),
      act: (bloc) => bloc.add(const EventDetailDismissPressed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailDismissDelegate>()),
      ],
      verify: (bloc) {
        // deleteが呼ばれていないことを確認
        verifyNever(() => mockEventRepository.delete(any()));
      },
    );

    // TC-011: EventDetailPaymentSaved - isSavedAtLeastOnceがtrueになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-011: 支払保存時、isSavedAtLeastOnceがtrueになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: true,
        isSavedAtLeastOnce: false,
      ),
      act: (bloc) async {
        when(() => mockEventRepository.fetch('event_1')).thenAnswer((_) async => testEventDomain);
        bloc.add(const EventDetailPaymentSaved());
      },
      expect: () => [
        // EventDetailPaymentSavedはisSavedAtLeastOnceをtrueにし、その後CachedEventUpdateを発火する
        isA<EventDetailLoaded>()
            .having((state) => state.isSavedAtLeastOnce, 'isSavedAtLeastOnce', true),
        // CachedEventUpdate後の状態（キャッシュが更新される）
        isA<EventDetailLoaded>()
            .having((state) => state.isSavedAtLeastOnce, 'isSavedAtLeastOnce', true),
      ],
    );

    // TC-012: EventDetailOpenMarkRequested - delegateがEventDetailOpenMarkDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-012: マーク詳細を開く要求時、delegateがEventDetailOpenMarkDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailOpenMarkRequested('mark_1')),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailOpenMarkDelegate>()),
      ],
    );

    // TC-013: EventDetailOpenLinkRequested - delegateがEventDetailOpenLinkDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-013: リンク詳細を開く要求時、delegateがEventDetailOpenLinkDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailOpenLinkRequested('link_1')),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailOpenLinkDelegate>()),
      ],
    );

    // TC-014: EventDetailOpenPaymentRequested - delegateがEventDetailOpenPaymentDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-014: 支払詳細を開く要求時、delegateがEventDetailOpenPaymentDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailOpenPaymentRequested('payment_1')),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailOpenPaymentDelegate>()),
      ],
    );

    // TC-015: EventDetailAddMarkLinkRequested - delegateがEventDetailAddMarkLinkDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-015: マーク/リンク追加要求時、delegateがEventDetailAddMarkLinkDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailAddMarkLinkRequested()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailAddMarkLinkDelegate>()),
      ],
    );

    // TC-016: EventDetailInviteLinkButtonPressed - delegateがEventDetailOpenInviteLinkDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-016: メンバー招待ボタン押下時、delegateがEventDetailOpenInviteLinkDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailInviteLinkButtonPressed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailOpenInviteLinkDelegate>()),
      ],
    );

    // TC-017: EventDetailInviteCodeButtonPressed - delegateがEventDetailOpenInviteCodeInputDelegateになる
    blocTest<EventDetailBloc, EventDetailState>(
      'TC-017: 招待コード入力ボタン押下時、delegateがEventDetailOpenInviteCodeInputDelegateになる',
      build: () => bloc,
      seed: () => EventDetailLoaded(
        projection: testProjection,
        draft: const EventDetailDraft(),
        topicConfig: const TopicConfig(
          showMeterValue: true,
          showFuelDetail: true,
          addMenuItems: [AddMenuItemType.mark, AddMenuItemType.link],
          showLinkDistance: true,
          showKmPerGas: true,
          showPricePerGas: true,
          showPayMember: true,
          showPaymentInfoTab: true,
        ),
        cachedEvent: testEventDomain,
        isNewEvent: false,
        isSavedAtLeastOnce: true,
      ),
      act: (bloc) => bloc.add(const EventDetailInviteCodeButtonPressed()),
      expect: () => [
        isA<EventDetailLoaded>()
            .having((state) => state.delegate, 'delegate', isA<EventDetailOpenInviteCodeInputDelegate>()),
      ],
    );
  });
}
