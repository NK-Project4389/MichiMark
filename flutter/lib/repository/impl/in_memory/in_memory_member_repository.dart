import '../../../domain/master/member/member_domain.dart';
import '../../member_repository.dart';

/// MemberRepository の InMemory 実装（drift 実装前の仮実装）
class InMemoryMemberRepository implements MemberRepository {
  final List<MemberDomain> _items;

  InMemoryMemberRepository({List<MemberDomain> initialItems = const []})
      : _items = List.of(initialItems);

  @override
  Future<List<MemberDomain>> fetchAll() async =>
      _items.where((m) => !m.isDeleted).toList();

  @override
  Future<void> save(MemberDomain member) async {
    final index = _items.indexWhere((m) => m.id == member.id);
    if (index >= 0) {
      _items[index] = member;
    } else {
      _items.add(member);
    }
  }
}
