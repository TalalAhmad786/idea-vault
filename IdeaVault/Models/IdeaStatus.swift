import SwiftUI

enum IdeaStatus: String, CaseIterable, Identifiable, Codable {
    case idea
    case exploring
    case building
    case shipped
    case parked

    var id: String { rawValue }

    var title: String {
        switch self {
        case .idea: return "Idea"
        case .exploring: return "Exploring"
        case .building: return "Building"
        case .shipped: return "Shipped"
        case .parked: return "Parked"
        }
    }

    var symbol: String {
        switch self {
        case .idea: return "lightbulb.fill"
        case .exploring: return "magnifyingglass"
        case .building: return "hammer.fill"
        case .shipped: return "paperplane.fill"
        case .parked: return "pause.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .idea: return .indigo
        case .exploring: return .blue
        case .building: return .orange
        case .shipped: return .green
        case .parked: return .gray
        }
    }

    /// The natural next step in an idea's life.
    var next: IdeaStatus {
        switch self {
        case .idea: return .exploring
        case .exploring: return .building
        case .building: return .shipped
        case .shipped: return .shipped
        case .parked: return .idea
        }
    }
}

enum IdeaPriority: Int, CaseIterable, Identifiable, Codable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case updated
    case created
    case priority
    case title

    var id: String { rawValue }

    var title: String {
        switch self {
        case .updated: return "Recently Updated"
        case .created: return "Newest First"
        case .priority: return "Priority"
        case .title: return "Name"
        }
    }

    var symbol: String {
        switch self {
        case .updated: return "clock"
        case .created: return "calendar"
        case .priority: return "flame"
        case .title: return "textformat"
        }
    }
}
