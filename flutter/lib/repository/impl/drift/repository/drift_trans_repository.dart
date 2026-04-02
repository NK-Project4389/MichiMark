import '../../../../domain/master/trans/trans_domain.dart';
import '../../../repository_error.dart';
import '../../../trans_repository.dart';
import '../dao/master_dao.dart';

class DriftTransRepository implements TransRepository {
  final MasterDao _dao;

  DriftTransRepository(this._dao);

  @override
  Future<List<TransDomain>> fetchAll() async => _dao.fetchAllTrans();

  @override
  Future<void> save(TransDomain trans) async {
    try {
      await _dao.saveTrans(trans);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }
}
