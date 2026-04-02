import '../../../../domain/master/member/member_domain.dart';
import '../../../member_repository.dart';
import '../../../repository_error.dart';
import '../dao/master_dao.dart';

class DriftMemberRepository implements MemberRepository {
  final MasterDao _dao;

  DriftMemberRepository(this._dao);

  @override
  Future<List<MemberDomain>> fetchAll() async => _dao.fetchAllMembers();

  @override
  Future<void> save(MemberDomain member) async {
    try {
      await _dao.saveMember(member);
    } on Exception catch (e) {
      throw SaveFailedError(e);
    }
  }
}
