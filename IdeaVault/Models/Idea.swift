import Foundation
import SwiftData

@Model
final class Idea {
    var uuid: UUID = UUID()
    var title: String = ""
    var details: String = ""
    var problem: String = ""
    var nextStep: String = ""
    var category: String = ""
    var tags: [String] = []
    var statusRaw: String = "idea"
    var priorityRaw: Int = 0
    var isPinned: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(title: String, details: String = "") {
        self.uuid = UUID()
        self.title = title
        self.details = details
        self.problem = ""
        self.nextStep = ""
        self.category = ""
        self.tags = []
        self.statusRaw = IdeaStatus.idea.rawValue
        self.priorityRaw = 0
        self.isPinned = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var status: IdeaStatus {
        get { IdeaStatus(rawValue: statusRaw) ?? .idea }
        set { statusRaw = newValue.rawValue }
    }

    var priority: IdeaPriority {
        get { IdeaPriority(rawValue: priorityRaw) ?? .none }
        set { priorityRaw = newValue.rawValue }
    }

    var displayTitle: String {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Untitled idea" : t
    }

    var searchText: String {
        [title, details, problem, nextStep, category, tags.joined(separator: " ")]
            .joined(separator: " ")
            .lowercased()
    }

    func touch() {
        updatedAt = Date()
    }
}
