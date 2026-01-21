import SwiftData
import Foundation

protocol SwiftDataEventRepository {
    func fetch(by id: EventID) -> EventCore?
    func fetchAll() -> [EventCore]
    func save(_ event: EventCore)
    func delete(by id: EventID)
}

final class DefaultEventRepository: SwiftDataEventRepository {

    // MARK: - Dependencies
    private let context: ModelContext
    private let eventMapper: EventMapper

    init(
        context: ModelContext,
        eventMapper: EventMapper
    ) {
        self.context = context
        self.eventMapper = eventMapper
    }

    // MARK: - Fetch

    func fetch(by id: EventID) -> EventCore? {

        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate {
                $0.id == id && $0.isDeleted == false
            }
        )

        guard let model = try? context.fetch(descriptor).first else {
            return nil
        }

        return eventMapper.toDomain(model)
    }

    func fetchAll() -> [EventCore] {

        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate {
                $0.isDeleted == false
            },
            sortBy: [
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )

        guard let models = try? context.fetch(descriptor) else {
            return []
        }

        return models.map { eventMapper.toDomain($0) }
    }

    // MARK: - Save

    func save(_ event: EventCore) {
        _ = eventMapper.toModel(event, context: context)

        do {
            try context.save()
        } catch {
            assertionFailure("Event save failed: \(error)")
        }
    }

    // MARK: - Delete (Logical)

    func delete(by id: EventID) {

        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.id == id }
        )

        guard let model = try? context.fetch(descriptor).first else {
            return
        }

        model.isDeleted = true
        model.updatedAt = .now

        do {
            try context.save()
        } catch {
            assertionFailure("Event delete failed: \(error)")
        }
    }
}
