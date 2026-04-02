import '../../../../domain/master/action/action_domain.dart';
import '../../../action_repository.dart';
import '../../../repository_error.dart';
import '../dao/master_dao.dart';

class DriftActionRepository implements ActionRepository {
  final MasterDao _dao;

  DriftActionRepository(this._dao);

  @override
  Future<List<ActionDomain>> fetchAll() async => _dao.fetchAllActions();

  @override
  Future<void> save(ActionDomain action) async {
    try {
      await _dao.saveAction(action);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }
}
