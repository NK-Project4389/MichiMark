import Foundation

protocol MemberRepository: Sendable {
    /// 論理削除されていない Action を全件取得
    func fetchAll() async throws -> [MemberDomain]

    /// 新規作成 or 上書き保存
    func save(_ member: MemberDomain) async throws

    /// 既存 Action の更新
    func update(_ member: MemberDomain) async throws
}
