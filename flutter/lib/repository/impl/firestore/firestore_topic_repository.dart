import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/topic/topic_domain.dart';
import '../../auth_repository.dart';
import '../../topic_repository.dart';

/// TopicRepository の Firestore 実装
class FirestoreTopicRepository implements TopicRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreTopicRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> _collection() {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreTopicRepository: currentUid is null');
    }
    return _firestore.collection('organizations/$uid/topics');
  }

  @override
  Future<List<TopicDomain>> fetchAll() async {
    final snapshot =
        await _collection().where('isDeleted', isEqualTo: false).get();
    return snapshot.docs
        .map((doc) => _fromFirestore(doc.data()))
        .where((t) => t.isVisible)
        .toList();
  }

  @override
  Future<TopicDomain?> fetchByType(TopicType type) async {
    final snapshot = await _collection()
        .where('isDeleted', isEqualTo: false)
        .where('topicType', isEqualTo: type.name)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _fromFirestore(snapshot.docs.first.data());
  }

  @override
  Future<void> save(TopicDomain topic) async {
    await _collection().doc(topic.id).set(_toFirestore(topic));
  }

  static TopicDomain _fromFirestore(Map<String, Object?> data) {
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

  static Map<String, Object?> _toFirestore(TopicDomain topic) {
    return {
      'id': topic.id,
      'topicName': topic.topicName,
      'topicType': topic.topicType.name,
      'isVisible': topic.isVisible,
      'isDeleted': topic.isDeleted,
      'color': topic.color,
      'createdAt': Timestamp.fromDate(topic.createdAt),
      'updatedAt': Timestamp.fromDate(topic.updatedAt),
    };
  }
}
