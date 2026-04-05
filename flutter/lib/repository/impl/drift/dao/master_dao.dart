import 'package:drift/drift.dart';

import '../../../../domain/action_time/action_state.dart';
import '../../../../domain/master/action/action_domain.dart';
import '../../../../domain/master/member/member_domain.dart';
import '../../../../domain/master/tag/tag_domain.dart';
import '../../../../domain/master/trans/trans_domain.dart';
import '../database.dart';
import '../tables/master_tables.dart';

part 'master_dao.g.dart';

@DriftAccessor(tables: [Actions, Members, Tags, Transports])
class MasterDao extends DatabaseAccessor<AppDatabase> with _$MasterDaoMixin {
  MasterDao(super.db);

  // ---------------------------------------------------------------------------
  // Action
  // ---------------------------------------------------------------------------

  Future<List<ActionDomain>> fetchAllActions() async {
    final rows =
        await (select(actions)..where((t) => t.isDeleted.equals(false))).get();
    return rows.map(_toActionDomain).toList();
  }

  Future<void> saveAction(ActionDomain domain) async {
    await into(actions).insertOnConflictUpdate(_toActionCompanion(domain));
  }

  // ---------------------------------------------------------------------------
  // Member
  // ---------------------------------------------------------------------------

  Future<List<MemberDomain>> fetchAllMembers() async {
    final rows =
        await (select(members)..where((t) => t.isDeleted.equals(false))).get();
    return rows.map(_toMemberDomain).toList();
  }

  Future<void> saveMember(MemberDomain domain) async {
    await into(members).insertOnConflictUpdate(_toMemberCompanion(domain));
  }

  // ---------------------------------------------------------------------------
  // Tag
  // ---------------------------------------------------------------------------

  Future<List<TagDomain>> fetchAllTags() async {
    final rows =
        await (select(tags)..where((t) => t.isDeleted.equals(false))).get();
    return rows.map(_toTagDomain).toList();
  }

  Future<void> saveTag(TagDomain domain) async {
    await into(tags).insertOnConflictUpdate(_toTagCompanion(domain));
  }

  // ---------------------------------------------------------------------------
  // Trans
  // ---------------------------------------------------------------------------

  Future<List<TransDomain>> fetchAllTrans() async {
    final rows = await (select(transports)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map(_toTransDomain).toList();
  }

  Future<void> saveTrans(TransDomain domain) async {
    await into(transports).insertOnConflictUpdate(_toTransCompanion(domain));
  }

  // ---------------------------------------------------------------------------
  // Domain → Companion 変換
  // ---------------------------------------------------------------------------

  ActionsCompanion _toActionCompanion(ActionDomain d) => ActionsCompanion(
        id: Value(d.id),
        actionName: Value(d.actionName),
        isVisible: Value(d.isVisible),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
        // from_state カラムは REQ-004 により廃止。NULLABLEのままDBカラムは残す
        toState: Value(d.toState?.name),
        isToggle: Value(d.isToggle),
        togglePairId: Value(d.togglePairId),
        needsTransition: Value(d.needsTransition),
      );

  MembersCompanion _toMemberCompanion(MemberDomain d) => MembersCompanion(
        id: Value(d.id),
        memberName: Value(d.memberName),
        mailAddress: Value(d.mailAddress),
        isVisible: Value(d.isVisible),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
      );

  TagsCompanion _toTagCompanion(TagDomain d) => TagsCompanion(
        id: Value(d.id),
        tagName: Value(d.tagName),
        isVisible: Value(d.isVisible),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
      );

  TransportsCompanion _toTransCompanion(TransDomain d) => TransportsCompanion(
        id: Value(d.id),
        transName: Value(d.transName),
        kmPerGas: Value(d.kmPerGas),
        meterValue: Value(d.meterValue),
        isVisible: Value(d.isVisible),
        isDeleted: Value(d.isDeleted),
        createdAt: Value(d.createdAt),
        updatedAt: Value(d.updatedAt),
      );

  // ---------------------------------------------------------------------------
  // Row → Domain 変換
  // ---------------------------------------------------------------------------

  ActionDomain _toActionDomain(Action row) {
    // from_state カラムは REQ-004 により廃止。アプリロジックで使用しない
    return ActionDomain(
      id: row.id,
      actionName: row.actionName,
      isVisible: row.isVisible,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      toState: _parseActionState(row.toState),
      isToggle: row.isToggle,
      togglePairId: row.togglePairId,
      needsTransition: row.needsTransition,
    );
  }

  ActionState? _parseActionState(String? value) {
    if (value == null) return null;
    return switch (value) {
      'waiting' => ActionState.waiting,
      'moving' => ActionState.moving,
      'working' => ActionState.working,
      'break_' => ActionState.break_,
      _ => null,
    };
  }

  MemberDomain _toMemberDomain(Member row) => MemberDomain(
        id: row.id,
        memberName: row.memberName,
        mailAddress: row.mailAddress,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  TagDomain _toTagDomain(Tag row) => TagDomain(
        id: row.id,
        tagName: row.tagName,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  TransDomain _toTransDomain(Transport row) => TransDomain(
        id: row.id,
        transName: row.transName,
        kmPerGas: row.kmPerGas,
        meterValue: row.meterValue,
        isVisible: row.isVisible,
        isDeleted: row.isDeleted,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
