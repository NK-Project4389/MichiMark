import '../domain/master/member/member_domain.dart';

/// メンバーの永続化インターフェース
///
/// 削除は論理削除（isDeleted フラグ）で行うため、deleteメソッドは持たない。
/// 新規作成・更新は save で一本化する（upsert）。
abstract interface class MemberRepository {
  /// 論理削除されていないメンバーを全件取得
  Future<List<MemberDomain>> fetchAll();

  /// メンバーを保存（新規作成 / 上書き更新）
  Future<void> save(MemberDomain member);
}
