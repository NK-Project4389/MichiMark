import Foundation

struct MarkLinkDraftProjectionAdapter {
    func adapt(_ draft: MarkDetailDraft) -> MarkLinkItemProjection {
        draft.toProjection()
    }

    func adapt(_ draft: LinkDetailDraft) -> MarkLinkItemProjection {
        draft.toProjection()
    }
}
