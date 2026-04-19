import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/action_time/action_state.dart';
import '../../../domain/action_time/action_time_log.dart';
import '../../../domain/aggregation/aggregation_filter.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../domain/transaction/payment/payment_domain.dart';
import '../../auth_repository.dart';
import '../../event_repository.dart';
import '../../repository_error.dart';

/// EventRepository の Firestore 実装
///
/// EventDomainはFirestore上ではフラット化して保存し、
/// 読み込み時にマスターデータからDomainオブジェクトを組み立てる。
class FirestoreEventRepository implements EventRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreEventRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String get _orgId {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreEventRepository: currentUid is null');
    }
    return uid;
  }

  String get _orgPath => 'organizations/$_orgId';

  CollectionReference<Map<String, Object?>> _eventsCollection() =>
      _firestore.collection('$_orgPath/events');

  CollectionReference<Map<String, Object?>> _markLinksCollection(
          String eventId) =>
      _firestore.collection('$_orgPath/events/$eventId/markLinks');

  CollectionReference<Map<String, Object?>> _paymentsCollection(
          String eventId) =>
      _firestore.collection('$_orgPath/events/$eventId/payments');

  CollectionReference<Map<String, Object?>> _actionTimeLogsCollection(
          String eventId) =>
      _firestore.collection('$_orgPath/events/$eventId/actionTimeLogs');

  // ---------------------------------------------------------------------------
  // マスターデータ読み込み（参照解決用）
  // ---------------------------------------------------------------------------

  Future<Map<String, MemberDomain>> _fetchMembersMap() async {
    final snapshot = await _firestore
        .collection('$_orgPath/members')
        .get();
    final map = <String, MemberDomain>{};
    for (final doc in snapshot.docs) {
      final member = _memberFromFirestore(doc.data());
      map[member.id] = member;
    }
    return map;
  }

  Future<Map<String, TransDomain>> _fetchTransMap() async {
    final snapshot = await _firestore
        .collection('$_orgPath/trans')
        .get();
    final map = <String, TransDomain>{};
    for (final doc in snapshot.docs) {
      final trans = _transFromFirestore(doc.data());
      map[trans.id] = trans;
    }
    return map;
  }

  Future<Map<String, TagDomain>> _fetchTagsMap() async {
    final snapshot = await _firestore
        .collection('$_orgPath/tags')
        .get();
    final map = <String, TagDomain>{};
    for (final doc in snapshot.docs) {
      final tag = _tagFromFirestore(doc.data());
      map[tag.id] = tag;
    }
    return map;
  }

  Future<Map<String, ActionDomain>> _fetchActionsMap() async {
    final snapshot = await _firestore
        .collection('$_orgPath/actions')
        .get();
    final map = <String, ActionDomain>{};
    for (final doc in snapshot.docs) {
      final action = _actionFromFirestore(doc.data());
      map[action.id] = action;
    }
    return map;
  }

  Future<Map<String, TopicDomain>> _fetchTopicsMap() async {
    final snapshot = await _firestore
        .collection('$_orgPath/topics')
        .get();
    final map = <String, TopicDomain>{};
    for (final doc in snapshot.docs) {
      final topic = _topicFromFirestore(doc.data());
      map[topic.id] = topic;
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // EventRepository interface
  // ---------------------------------------------------------------------------

  @override
  Future<List<EventDomain>> fetchAll() async {
    final snapshot = await _eventsCollection()
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return [];

    final membersMap = await _fetchMembersMap();
    final transMap = await _fetchTransMap();
    final tagsMap = await _fetchTagsMap();
    final actionsMap = await _fetchActionsMap();
    final topicsMap = await _fetchTopicsMap();

    final events = <EventDomain>[];
    for (final doc in snapshot.docs) {
      final event = await _buildEventDomain(
        doc.data(),
        membersMap: membersMap,
        transMap: transMap,
        tagsMap: tagsMap,
        actionsMap: actionsMap,
        topicsMap: topicsMap,
      );
      events.add(event);
    }
    return events;
  }

  @override
  Future<EventDomain> fetch(String id) async {
    final doc = await _eventsCollection().doc(id).get();
    if (!doc.exists) throw NotFoundError(id);

    final data = doc.data();
    if (data == null) throw NotFoundError(id);

    final membersMap = await _fetchMembersMap();
    final transMap = await _fetchTransMap();
    final tagsMap = await _fetchTagsMap();
    final actionsMap = await _fetchActionsMap();
    final topicsMap = await _fetchTopicsMap();

    return _buildEventDomain(
      data,
      membersMap: membersMap,
      transMap: transMap,
      tagsMap: tagsMap,
      actionsMap: actionsMap,
      topicsMap: topicsMap,
    );
  }

  @override
  Future<void> save(EventDomain event) async {
    final batch = _firestore.batch();

    // イベント本体
    batch.set(
      _eventsCollection().doc(event.id),
      _eventToFirestore(event),
    );

    // markLinks サブコレクション
    for (final ml in event.markLinks) {
      batch.set(
        _markLinksCollection(event.id).doc(ml.id),
        _markLinkToFirestore(ml, event.id),
      );
    }

    // payments サブコレクション
    for (final p in event.payments) {
      batch.set(
        _paymentsCollection(event.id).doc(p.id),
        _paymentToFirestore(p),
      );
    }

    // actionTimeLogs サブコレクション
    for (final log in event.actionTimeLogs) {
      batch.set(
        _actionTimeLogsCollection(event.id).doc(log.id),
        _actionTimeLogToFirestore(log),
      );
    }

    await batch.commit();
  }

  @override
  Future<void> delete(String id) async {
    await _eventsCollection().doc(id).update({
      'isDeleted': true,
      'updatedAt': Timestamp.now(),
    });
  }

  // ---------------------------------------------------------------------------
  // ActionTimeLog CRUD
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveActionTimeLog(ActionTimeLog log) async {
    await _actionTimeLogsCollection(log.eventId)
        .doc(log.id)
        .set(_actionTimeLogToFirestore(log));
  }

  @override
  Future<void> deleteActionTimeLog(String id) async {
    // actionTimeLogsはイベントIDが不明なのでコレクショングループで検索
    final snapshot = await _firestore
        .collectionGroup('actionTimeLogs')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<List<ActionTimeLog>> fetchActionTimeLogs(String eventId) async {
    final snapshot = await _actionTimeLogsCollection(eventId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp')
        .get();
    return snapshot.docs
        .map((doc) => _actionTimeLogFromFirestore(doc.data()))
        .toList();
  }

  @override
  Future<void> updateActionTimeLogAdjustedAt(
      String logId, DateTime? adjustedAt) async {
    // logIdのみでコレクショングループから検索して更新する
    final snapshot = await _firestore
        .collectionGroup('actionTimeLogs')
        .where('id', isEqualTo: logId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'adjustedAt':
            adjustedAt != null ? Timestamp.fromDate(adjustedAt) : null,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Aggregation用クエリ
  // ---------------------------------------------------------------------------

  @override
  Future<List<EventDomain>> fetchByDateRange(
      DateTime start, DateTime end) async {
    final snapshot = await _eventsCollection()
        .where('isDeleted', isEqualTo: false)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    if (snapshot.docs.isEmpty) return [];

    final membersMap = await _fetchMembersMap();
    final transMap = await _fetchTransMap();
    final tagsMap = await _fetchTagsMap();
    final actionsMap = await _fetchActionsMap();
    final topicsMap = await _fetchTopicsMap();

    final events = <EventDomain>[];
    for (final doc in snapshot.docs) {
      final event = await _buildEventDomain(
        doc.data(),
        membersMap: membersMap,
        transMap: transMap,
        tagsMap: tagsMap,
        actionsMap: actionsMap,
        topicsMap: topicsMap,
      );
      events.add(event);
    }
    return events;
  }

  @override
  Future<List<EventDomain>> fetchByFilter(AggregationFilter filter) async {
    final (start, end) = _resolveDateRange(filter.dateRange);
    var results = await fetchByDateRange(start, end);

    if (filter.tagIds.isNotEmpty) {
      results = results
          .where((e) => e.tags.any((t) => filter.tagIds.contains(t.id)))
          .toList();
    }

    if (filter.memberIds.isNotEmpty) {
      results = results
          .where((e) => e.members.any((m) => filter.memberIds.contains(m.id)))
          .toList();
    }

    final transId = filter.transId;
    if (transId != null) {
      results = results.where((e) => e.trans?.id == transId).toList();
    }

    final topicId = filter.topicId;
    if (topicId != null) {
      results = results.where((e) => e.topic?.id == topicId).toList();
    }

    return results;
  }

  @override
  Future<void> deleteMarkLink(String markLinkId) async {
    // markLinksはイベントIDが不明なのでコレクショングループで検索
    final snapshot = await _firestore
        .collectionGroup('markLinks')
        .where('id', isEqualTo: markLinkId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    // paymentsはイベントIDが不明なのでコレクショングループで検索
    final snapshot = await _firestore
        .collectionGroup('payments')
        .where('id', isEqualTo: paymentId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // EventDomain組み立て
  // ---------------------------------------------------------------------------

  Future<EventDomain> _buildEventDomain(
    Map<String, Object?> data, {
    required Map<String, MemberDomain> membersMap,
    required Map<String, TransDomain> transMap,
    required Map<String, TagDomain> tagsMap,
    required Map<String, ActionDomain> actionsMap,
    required Map<String, TopicDomain> topicsMap,
  }) async {
    final eventId = data['id'] as String;

    // 参照解決
    final transId = data['transId'] as String?;
    final trans = transId != null ? transMap[transId] : null;

    final memberIds = _stringList(data['memberIds']);
    final members = memberIds
        .map((id) => membersMap[id])
        .whereType<MemberDomain>()
        .toList();

    final tagIds = _stringList(data['tagIds']);
    final tags =
        tagIds.map((id) => tagsMap[id]).whereType<TagDomain>().toList();

    final topicId = data['topicId'] as String?;
    final topic = topicId != null ? topicsMap[topicId] : null;

    final payMemberId = data['payMemberId'] as String?;
    final payMember = payMemberId != null ? membersMap[payMemberId] : null;

    // サブコレクション読み込み
    final markLinks = await _fetchMarkLinks(eventId, membersMap, actionsMap);
    final payments = await _fetchPayments(eventId, membersMap);
    final actionTimeLogs = await fetchActionTimeLogs(eventId);

    return EventDomain(
      id: eventId,
      eventName: data['eventName'] as String,
      trans: trans,
      members: members,
      tags: tags,
      kmPerGas: data['kmPerGas'] as int?,
      pricePerGas: data['pricePerGas'] as int?,
      payMember: payMember,
      markLinks: markLinks,
      payments: payments,
      topic: topic,
      actionTimeLogs: actionTimeLogs,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Future<List<MarkLinkDomain>> _fetchMarkLinks(
    String eventId,
    Map<String, MemberDomain> membersMap,
    Map<String, ActionDomain> actionsMap,
  ) async {
    final snapshot = await _markLinksCollection(eventId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('markLinkSeq')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final mlMemberIds = _stringList(data['memberIds']);
      final mlMembers = mlMemberIds
          .map((id) => membersMap[id])
          .whereType<MemberDomain>()
          .toList();

      final actionIds = _stringList(data['actionIds']);
      final actions = actionIds
          .map((id) => actionsMap[id])
          .whereType<ActionDomain>()
          .toList();

      final gasPayerId = data['gasPayerId'] as String?;
      final gasPayer = gasPayerId != null ? membersMap[gasPayerId] : null;

      final markLinkTypeStr = data['markLinkType'] as String;
      final markLinkType =
          markLinkTypeStr == 'link' ? MarkOrLink.link : MarkOrLink.mark;

      return MarkLinkDomain(
        id: data['id'] as String,
        markLinkSeq: data['markLinkSeq'] as int,
        markLinkType: markLinkType,
        markLinkDate: (data['markLinkDate'] as Timestamp).toDate(),
        markLinkName: data['markLinkName'] as String?,
        members: mlMembers,
        meterValue: data['meterValue'] as int?,
        distanceValue: data['distanceValue'] as int?,
        actions: actions,
        memo: data['memo'] as String?,
        isFuel: data['isFuel'] as bool,
        pricePerGas: data['pricePerGas'] as int?,
        gasQuantity: data['gasQuantity'] as int?,
        gasPrice: data['gasPrice'] as int?,
        gasPayer: gasPayer,
        isDeleted: data['isDeleted'] as bool,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<List<PaymentDomain>> _fetchPayments(
    String eventId,
    Map<String, MemberDomain> membersMap,
  ) async {
    final snapshot = await _paymentsCollection(eventId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('paymentSeq')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final paymentMemberId = data['paymentMemberId'] as String;
      final paymentMember = membersMap[paymentMemberId];
      if (paymentMember == null) {
        // paymentMemberが見つからない場合はスキップせずダミーで組み立て
        // （データ整合性を維持するためNotFoundにはしない）
        throw NotFoundError(paymentMemberId);
      }

      final splitMemberIds = _stringList(data['splitMemberIds']);
      final splitMembers = splitMemberIds
          .map((id) => membersMap[id])
          .whereType<MemberDomain>()
          .toList();

      return PaymentDomain(
        id: data['id'] as String,
        paymentSeq: data['paymentSeq'] as int,
        paymentAmount: data['paymentAmount'] as int,
        paymentMember: paymentMember,
        splitMembers: splitMembers,
        paymentMemo: data['paymentMemo'] as String?,
        isDeleted: data['isDeleted'] as bool,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        markLinkID: data['markLinkID'] as String?,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Firestore変換ヘルパー
  // ---------------------------------------------------------------------------

  Map<String, Object?> _eventToFirestore(EventDomain event) {
    return {
      'id': event.id,
      'eventName': event.eventName,
      'transId': event.trans?.id,
      'kmPerGas': event.kmPerGas,
      'pricePerGas': event.pricePerGas,
      'payMemberId': event.payMember?.id,
      'ownerUid': _orgId,
      'memberIds': event.members.map((m) => m.id).toList(),
      'tagIds': event.tags.map((t) => t.id).toList(),
      'topicId': event.topic?.id,
      'isDeleted': event.isDeleted,
      'createdAt': Timestamp.fromDate(event.createdAt),
      'updatedAt': Timestamp.fromDate(event.updatedAt),
    };
  }

  Map<String, Object?> _markLinkToFirestore(
      MarkLinkDomain ml, String eventId) {
    return {
      'id': ml.id,
      'markLinkSeq': ml.markLinkSeq,
      'markLinkType': ml.markLinkType.name,
      'markLinkDate': Timestamp.fromDate(ml.markLinkDate),
      'markLinkName': ml.markLinkName,
      'ownerUid': _orgId,
      'memberIds': ml.members.map((m) => m.id).toList(),
      'meterValue': ml.meterValue,
      'distanceValue': ml.distanceValue,
      'actionIds': ml.actions.map((a) => a.id).toList(),
      'memo': ml.memo,
      'isFuel': ml.isFuel,
      'pricePerGas': ml.pricePerGas,
      'gasQuantity': ml.gasQuantity,
      'gasPrice': ml.gasPrice,
      'gasPayerId': ml.gasPayer?.id,
      'isDeleted': ml.isDeleted,
      'createdAt': Timestamp.fromDate(ml.createdAt),
      'updatedAt': Timestamp.fromDate(ml.updatedAt),
    };
  }

  Map<String, Object?> _paymentToFirestore(PaymentDomain p) {
    return {
      'id': p.id,
      'paymentSeq': p.paymentSeq,
      'paymentAmount': p.paymentAmount,
      'paymentMemberId': p.paymentMember.id,
      'splitMemberIds': p.splitMembers.map((m) => m.id).toList(),
      'paymentMemo': p.paymentMemo,
      'isDeleted': p.isDeleted,
      'createdAt': Timestamp.fromDate(p.createdAt),
      'updatedAt': Timestamp.fromDate(p.updatedAt),
      'markLinkID': p.markLinkID,
    };
  }

  static Map<String, Object?> _actionTimeLogToFirestore(ActionTimeLog log) {
    return {
      'id': log.id,
      'eventId': log.eventId,
      'actionId': log.actionId,
      'timestamp': Timestamp.fromDate(log.timestamp),
      'isDeleted': log.isDeleted,
      'createdAt': Timestamp.fromDate(log.createdAt),
      'updatedAt': Timestamp.fromDate(log.updatedAt),
    };
  }

  // ---------------------------------------------------------------------------
  // マスターデータ個別変換（_fetchXxxMap用）
  // ---------------------------------------------------------------------------

  static MemberDomain _memberFromFirestore(Map<String, Object?> data) {
    return MemberDomain(
      id: data['id'] as String,
      memberName: data['memberName'] as String,
      mailAddress: data['mailAddress'] as String?,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static TransDomain _transFromFirestore(Map<String, Object?> data) {
    return TransDomain(
      id: data['id'] as String,
      transName: data['transName'] as String,
      kmPerGas: data['kmPerGas'] as int?,
      meterValue: data['meterValue'] as int?,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static TagDomain _tagFromFirestore(Map<String, Object?> data) {
    return TagDomain(
      id: data['id'] as String,
      tagName: data['tagName'] as String,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static ActionDomain _actionFromFirestore(Map<String, Object?> data) {
    final toStateStr = data['toState'] as String?;
    ActionState? toState;
    if (toStateStr != null) {
      toState = ActionState.values.firstWhere(
        (s) => s.name == toStateStr,
        orElse: () => ActionState.waiting,
      );
    }
    return ActionDomain(
      id: data['id'] as String,
      actionName: data['actionName'] as String,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      toState: toState,
      isToggle: data['isToggle'] as bool,
      togglePairId: data['togglePairId'] as String?,
      needsTransition: data['needsTransition'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static TopicDomain _topicFromFirestore(Map<String, Object?> data) {
    final topicTypeStr = data['topicType'] as String;
    final topicType = TopicType.values.firstWhere(
      (t) => t.name == topicTypeStr,
      orElse: () => TopicType.movingCost,
    );
    return TopicDomain(
      id: data['id'] as String,
      topicName: data['topicName'] as String,
      topicType: topicType,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      color: data['color'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static ActionTimeLog _actionTimeLogFromFirestore(Map<String, Object?> data) {
    return ActionTimeLog(
      id: data['id'] as String,
      eventId: data['eventId'] as String,
      actionId: data['actionId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // ---------------------------------------------------------------------------
  // ユーティリティ
  // ---------------------------------------------------------------------------

  static List<String> _stringList(Object? value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }

  (DateTime, DateTime) _resolveDateRange(AggregationDateRange range) {
    final now = DateTime.now();
    return switch (range) {
      ThisMonth() => (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1)
              .subtract(const Duration(milliseconds: 1)),
        ),
      LastMonth() => (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1)
              .subtract(const Duration(milliseconds: 1)),
        ),
      CustomRange(:final startDate, :final endDate) => (startDate, endDate),
    };
  }
}
