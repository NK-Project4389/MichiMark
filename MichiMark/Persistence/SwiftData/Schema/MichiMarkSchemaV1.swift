import SwiftData

/// MichiMark SwiftData Schema v1
///
/// - Purpose:
///   MichiMark アプリにおける永続モデル定義（初期バージョン）
///
/// - Includes:
///   Event / MarkLink / Payment / Trans / Member / Tag / Action
///
/// - Notes:
///   この Schema は将来 VersionedSchema として拡張される前提
///
enum MichiMarkSchemaV1: VersionedSchema {

    /// スキーマバージョン
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }

    /// このスキーマに含まれる SwiftData Model 群
    static var models: [any PersistentModel.Type] {
        [
            EventModel.self,
            MarkLinkModel.self,
            PaymentModel.self,
            TransModel.self,
            MemberModel.self,
            TagModel.self,
            ActionModel.self
        ]
    }
}
