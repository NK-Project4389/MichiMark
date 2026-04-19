import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:michi_mark/domain/master/member/member_domain.dart';
import 'package:michi_mark/domain/master/tag/tag_domain.dart';
import 'package:michi_mark/domain/master/trans/trans_domain.dart';
import 'package:michi_mark/domain/topic/topic_domain.dart';
import 'package:michi_mark/domain/topic/topic_config.dart';
import 'package:michi_mark/features/basic_info/bloc/basic_info_bloc.dart';
import 'package:michi_mark/features/basic_info/bloc/basic_info_event.dart';
import 'package:michi_mark/features/basic_info/bloc/basic_info_state.dart';
import 'package:michi_mark/features/basic_info/draft/basic_info_draft.dart';
import 'package:michi_mark/repository/event_repository.dart';
import 'package:michi_mark/repository/member_repository.dart';
import 'package:michi_mark/repository/tag_repository.dart';
import 'package:michi_mark/repository/topic_repository.dart';
import 'package:michi_mark/repository/trans_repository.dart';

// Mock classes
class MockEventRepository extends Mock implements EventRepository {}

class MockTopicRepository extends Mock implements TopicRepository {}

class MockTagRepository extends Mock implements TagRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

class MockTransRepository extends Mock implements TransRepository {}

void main() {
  group('BasicInfoBloc', () {
    late MockEventRepository mockEventRepository;
    late MockTopicRepository mockTopicRepository;
    late MockTagRepository mockTagRepository;
    late MockMemberRepository mockMemberRepository;
    late MockTransRepository mockTransRepository;
    late BasicInfoBloc basicInfoBloc;

    final now = DateTime.now();

    // テスト用データ
    late MemberDomain member1;
    late MemberDomain member2;
    late MemberDomain member3;
    late TransDomain trans1;
    late TransDomain trans2;
    late TagDomain tag1;
    late TopicDomain topicMovingCost;
    late TopicDomain topicOther;
    late TopicConfig topicConfigMovingCost;
    late TopicConfig topicConfigOther;

    setUp(() {
      mockEventRepository = MockEventRepository();
      mockTopicRepository = MockTopicRepository();
      mockTagRepository = MockTagRepository();
      mockMemberRepository = MockMemberRepository();
      mockTransRepository = MockTransRepository();

      // テスト用マスターデータ生成
      member1 = MemberDomain(
        id: 'member_1',
        memberName: 'テスト太郎',
        createdAt: now,
        updatedAt: now,
      );
      member2 = MemberDomain(
        id: 'member_2',
        memberName: 'テスト花子',
        createdAt: now,
        updatedAt: now,
      );
      member3 = MemberDomain(
        id: 'member_3',
        memberName: 'テスト次郎',
        createdAt: now,
        updatedAt: now,
      );

      trans1 = TransDomain(
        id: 'trans_1',
        transName: 'マイカー',
        kmPerGas: 150, // 15.0 km/L
        createdAt: now,
        updatedAt: now,
      );
      trans2 = TransDomain(
        id: 'trans_2',
        transName: 'レンタカー',
        kmPerGas: 120, // 12.0 km/L
        createdAt: now,
        updatedAt: now,
      );

      tag1 = TagDomain(
        id: 'tag_1',
        tagName: 'テストタグ',
        createdAt: now,
        updatedAt: now,
      );

      // TopicTypeから対応するTopicConfigを生成
      topicConfigMovingCost = TopicConfig.fromTopicType(TopicType.movingCostEstimated);
      topicConfigOther = TopicConfig.fromTopicType(TopicType.visitWork);

      topicMovingCost = TopicDomain(
        id: 'topic_1',
        topicName: '移動コスト（燃費で推定）',
        topicType: TopicType.movingCostEstimated,
        createdAt: now,
        updatedAt: now,
      );
      topicOther = TopicDomain(
        id: 'topic_2',
        topicName: '訪問作業',
        topicType: TopicType.visitWork,
        createdAt: now,
        updatedAt: now,
      );

      basicInfoBloc = BasicInfoBloc(
        eventRepository: mockEventRepository,
        topicRepository: mockTopicRepository,
        tagRepository: mockTagRepository,
        memberRepository: mockMemberRepository,
        transRepository: mockTransRepository,
      );
    });

    tearDown(() {
      basicInfoBloc.close();
    });

    // TC-001: BasicInfoTransChipToggled - 別TransをタップするとselectedTransが変わる（単一選択）
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-001: 別TransをタップするとselectedTransが変わる',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedTrans: trans1,
          selectedMembers: [member1],
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1, trans2],
        allMembers: [member1, member2],
        memberSuggestions: [member2],
        allTags: [tag1],
      ),
      act: (bloc) => bloc.add(BasicInfoTransChipToggled(trans2)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedTrans?.id, 'selectedTrans.id', 'trans_2')
            .having((state) => state.draft.selectedTrans?.transName, 'selectedTrans.transName', 'レンタカー'),
      ],
    );

    // TC-002: BasicInfoTransChipToggled - 同一TransをタップするとselectedTransがnullになる（トグルOFF）
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-002: 同一TransをタップするとselectedTransがnullになる',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedTrans: trans1,
          selectedMembers: [member1],
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1, trans2],
        allMembers: [member1, member2],
        memberSuggestions: [member2],
        allTags: [tag1],
      ),
      act: (bloc) => bloc.add(BasicInfoTransChipToggled(trans1)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedTrans, 'selectedTrans', null),
      ],
    );

    // TC-003: BasicInfoTransChipToggled - movingCostEstimatedモードでTrans変更時にkmPerGasInputが自動反映される
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-003: movingCostEstimatedモードでTrans変更時にkmPerGasInputが自動反映される',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedTrans: trans1,
          kmPerGasInput: '',
          selectedMembers: [member1],
          selectedTopic: topicMovingCost,
        ),
        topicConfig: topicConfigMovingCost,
        allTrans: [trans1, trans2],
        allMembers: [member1, member2],
        memberSuggestions: [member2],
        allTags: [tag1],
      ),
      act: (bloc) => bloc.add(BasicInfoTransChipToggled(trans2)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedTrans?.id, 'selectedTrans.id', 'trans_2')
            .having((state) => state.draft.kmPerGasInput, 'kmPerGasInput', '12.0'),
      ],
    );

    // TC-004: BasicInfoTransChipToggled - movingCostEstimated以外のモードではkmPerGasInputが変わらない
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-004: movingCostEstimated以外のモードではkmPerGasInputが変わらない',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedTrans: trans1,
          kmPerGasInput: '10.5',
          selectedMembers: [member1],
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1, trans2],
        allMembers: [member1, member2],
        memberSuggestions: [member2],
        allTags: [tag1],
      ),
      act: (bloc) => bloc.add(BasicInfoTransChipToggled(trans2)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedTrans?.id, 'selectedTrans.id', 'trans_2')
            .having((state) => state.draft.kmPerGasInput, 'kmPerGasInput', '10.5'),
      ],
    );

    // TC-005: BasicInfoMemberRemoved - 削除するメンバーがpayMemberと同一の場合 → payMemberもクリアされる
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-005: 削除するメンバーがpayMemberと同一の場合、payMemberもクリアされる',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedMembers: [member1, member2],
          selectedPayMember: member1,
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1],
        allMembers: [member1, member2],
        memberSuggestions: [],
        allTags: [],
      ),
      act: (bloc) => bloc.add(BasicInfoMemberRemoved(member1)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedMembers.length, 'selectedMembers.length', 1)
            .having((state) => state.draft.selectedMembers[0].id, 'selectedMembers[0].id', 'member_2')
            .having((state) => state.draft.selectedPayMember, 'selectedPayMember', null),
      ],
    );

    // TC-006: BasicInfoMemberRemoved - 削除するメンバーがpayMemberと別の場合 → payMemberは変わらない
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-006: 削除するメンバーがpayMemberと別の場合、payMemberは変わらない',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedMembers: [member1, member2, member3],
          selectedPayMember: member1,
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1],
        allMembers: [member1, member2, member3],
        memberSuggestions: [],
        allTags: [],
      ),
      act: (bloc) => bloc.add(BasicInfoMemberRemoved(member2)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedMembers.length, 'selectedMembers.length', 2)
            .having((state) => state.draft.selectedPayMember?.id, 'selectedPayMember.id', 'member_1'),
      ],
    );

    // TC-007: BasicInfoPayMemberChipToggled - 別MemberをタップするとpayMemberが変わる（単一選択）
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-007: 別MemberをタップするとpayMemberが変わる',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedMembers: [member1, member2],
          selectedPayMember: member1,
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1],
        allMembers: [member1, member2],
        memberSuggestions: [],
        allTags: [],
      ),
      act: (bloc) => bloc.add(BasicInfoPayMemberChipToggled(member2)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedPayMember?.id, 'selectedPayMember.id', 'member_2'),
      ],
    );

    // TC-008: BasicInfoPayMemberChipToggled - 同一MemberをタップするとpayMemberがnullになる（トグルOFF）
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-008: 同一MemberをタップするとpayMemberがnullになる',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          selectedMembers: [member1, member2],
          selectedPayMember: member1,
          selectedTopic: topicOther,
        ),
        topicConfig: topicConfigOther,
        allTrans: [trans1],
        allMembers: [member1, member2],
        memberSuggestions: [],
        allTags: [],
      ),
      act: (bloc) => bloc.add(BasicInfoPayMemberChipToggled(member1)),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.selectedPayMember, 'selectedPayMember', null),
      ],
    );

    // TC-009: BasicInfoEditCancelled - originalDraftがある場合 → draftがoriginalDraftに戻る
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-009: originalDraftがある場合、editCancelledでdraftがoriginalDraftに戻る',
      build: () => basicInfoBloc,
      seed: () {
        final originalDraft = BasicInfoDraft(
          eventName: 'オリジナルイベント',
          selectedMembers: [member1],
          selectedPayMember: member1,
          selectedTopic: topicOther,
        );
        final editedDraft = BasicInfoDraft(
          eventName: '編集後イベント',
          selectedMembers: [member1, member2],
          selectedPayMember: member2,
          selectedTopic: topicOther,
          isEditing: true,
        );
        return BasicInfoLoaded(
          draft: editedDraft,
          originalDraft: originalDraft,
          topicConfig: topicConfigOther,
          allTrans: [trans1],
          allMembers: [member1, member2],
          memberSuggestions: [],
          allTags: [],
        );
      },
      act: (bloc) => bloc.add(BasicInfoEditCancelled()),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.eventName, 'eventName', 'オリジナルイベント')
            .having((state) => state.draft.selectedMembers.length, 'selectedMembers.length', 1)
            .having((state) => state.draft.selectedMembers[0].id, 'selectedMembers[0].id', 'member_1')
            .having((state) => state.draft.selectedPayMember?.id, 'selectedPayMember.id', 'member_1')
            .having((state) => state.draft.isEditing, 'isEditing', false),
      ],
    );

    // TC-010: BasicInfoEditCancelled - originalDraftがnullの場合
    blocTest<BasicInfoBloc, BasicInfoState>(
      'TC-010: originalDraftがnullの場合、isEditingがfalseになるのみ',
      build: () => basicInfoBloc,
      seed: () => BasicInfoLoaded(
        draft: BasicInfoDraft(
          eventName: '現在のイベント',
          selectedMembers: [member1],
          selectedTopic: topicOther,
          isEditing: true,
        ),
        originalDraft: null,
        topicConfig: topicConfigOther,
        allTrans: [trans1],
        allMembers: [member1],
        memberSuggestions: [],
        allTags: [],
      ),
      act: (bloc) => bloc.add(BasicInfoEditCancelled()),
      expect: () => [
        isA<BasicInfoLoaded>()
            .having((state) => state.draft.eventName, 'eventName', '現在のイベント')
            .having((state) => state.draft.isEditing, 'isEditing', false),
      ],
    );
  });
}
