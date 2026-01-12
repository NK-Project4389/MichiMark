import Foundation

protocol TransRepository: Sendable {
    /// 論理削除されていない Action を全件取得
    func fetchAll() async throws -> [TransDomain]

    /// 新規作成 or 上書き保存
    func save(_ trans: TransDomain) async throws

    /// 既存 Action の更新
    func update(_ trans: TransDomain) async throws
}
