import '../../../../domain/master/tag/tag_domain.dart';
import '../../../repository_error.dart';
import '../../../tag_repository.dart';
import '../dao/master_dao.dart';

class DriftTagRepository implements TagRepository {
  final MasterDao _dao;

  DriftTagRepository(this._dao);

  @override
  Future<List<TagDomain>> fetchAll() async => _dao.fetchAllTags();

  @override
  Future<void> save(TagDomain tag) async {
    try {
      await _dao.saveTag(tag);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }
}
