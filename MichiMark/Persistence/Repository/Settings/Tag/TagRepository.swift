import Foundation

protocol TagRepository: Sendable {
    /// 論理削除されていない Action を全件取得
    func fetchAll() async throws -> [TagDomain]

    /// 新規作成 or 上書き保存
    func save(_ tag: TagDomain) async throws

    /// 既存 Action の更新
    func update(_ tag: TagDomain) async throws
}
