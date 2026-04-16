import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/master/trans/trans_domain.dart';
import '../../auth_repository.dart';
import '../../trans_repository.dart';

/// TransRepository の Firestore 実装
class FirestoreTransRepository implements TransRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreTransRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> _collection() {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreTransRepository: currentUid is null');
    }
    return _firestore.collection('organizations/$uid/trans');
  }

  @override
  Future<List<TransDomain>> fetchAll() async {
    final snapshot =
        await _collection().where('isDeleted', isEqualTo: false).get();
    return snapshot.docs.map((doc) => _fromFirestore(doc.data())).toList();
  }

  @override
  Future<void> save(TransDomain trans) async {
    await _collection().doc(trans.id).set(_toFirestore(trans));
  }

  static TransDomain _fromFirestore(Map<String, Object?> data) {
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

  static Map<String, Object?> _toFirestore(TransDomain trans) {
    return {
      'id': trans.id,
      'transName': trans.transName,
      'kmPerGas': trans.kmPerGas,
      'meterValue': trans.meterValue,
      'isVisible': trans.isVisible,
      'isDeleted': trans.isDeleted,
      'createdAt': Timestamp.fromDate(trans.createdAt),
      'updatedAt': Timestamp.fromDate(trans.updatedAt),
    };
  }
}
