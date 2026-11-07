import SwiftUI

struct StatusPill: View {
    let status: IdeaStatus

    var body: some View {
        Label(status.title, systemImage: status.symbol)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.color.opacity(0.16), in: Capsule())
            .foregroundStyle(status.color)
    }
}

struct PriorityBadge: View {
    let priority: IdeaPriority

    var body: some View {
        if priority != .none {
            HStack(spacing: 1) {
                ForEach(0..<priority.rawValue, id: \.self) { _ in
                    Image(systemName: "flame.fill")
                }
            }
            .font(.caption2)
            .foregroundStyle(Color.red)
            .accessibilityLabel("\(priority.title) priority")
        }
    }
}

struct IdeaRow: View {
    let idea: Idea

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if idea.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(Color.orange)
                }
                Text(idea.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                Spacer(minLength: 8)
                PriorityBadge(priority: idea.priority)
            }

            if !idea.details.isEmpty {
                Text(idea.details)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                StatusPill(status: idea.status)
                if !idea.category.isEmpty {
                    Label(idea.category, systemImage: "folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                Text(idea.updatedAt, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusFilterBar: View {
    @Binding var selection: IdeaStatus?
    let counts: [IdeaStatus: Int]
    let total: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", symbol: "square.stack.fill", color: .orange,
                     count: total, isOn: selection == nil) {
                    selection = nil
                }
                ForEach(IdeaStatus.allCases) { status in
                    chip(title: status.title, symbol: status.symbol, color: status.color,
                         count: counts[status, default: 0], isOn: selection == status) {
                        selection = (selection == status) ? nil : status
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private func chip(title: String, symbol: String, color: Color, count: Int,
                      isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                Text(title)
                Text("\(count)")
                    .foregroundStyle(isOn ? Color.white.opacity(0.85) : Color.secondary)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isOn ? color : Color(.secondarySystemGroupedBackground), in: Capsule())
            .foregroundStyle(isOn ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

func parseTags(_ text: String) -> [String] {
    var seen = Set<String>()
    var result: [String] = []
    for part in text.split(separator: ",") {
        var tag = String(part).trimmed
        if tag.hasPrefix("#") { tag.removeFirst() }
        tag = tag.trimmed
        let key = tag.lowercased()
        if !tag.isEmpty && !seen.contains(key) {
            seen.insert(key)
            result.append(tag)
        }
    }
    return result
}
