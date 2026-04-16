import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/master/tag/tag_domain.dart';
import '../../auth_repository.dart';
import '../../tag_repository.dart';

/// TagRepository の Firestore 実装
class FirestoreTagRepository implements TagRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreTagRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> _collection() {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreTagRepository: currentUid is null');
    }
    return _firestore.collection('organizations/$uid/tags');
  }

  @override
  Future<List<TagDomain>> fetchAll() async {
    final snapshot =
        await _collection().where('isDeleted', isEqualTo: false).get();
    return snapshot.docs.map((doc) => _fromFirestore(doc.data())).toList();
  }

  @override
  Future<void> save(TagDomain tag) async {
    await _collection().doc(tag.id).set(_toFirestore(tag));
  }

  static TagDomain _fromFirestore(Map<String, Object?> data) {
    return TagDomain(
      id: data['id'] as String,
      tagName: data['tagName'] as String,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, Object?> _toFirestore(TagDomain tag) {
    return {
      'id': tag.id,
      'tagName': tag.tagName,
      'isVisible': tag.isVisible,
      'isDeleted': tag.isDeleted,
      'createdAt': Timestamp.fromDate(tag.createdAt),
      'updatedAt': Timestamp.fromDate(tag.updatedAt),
    };
  }
}
