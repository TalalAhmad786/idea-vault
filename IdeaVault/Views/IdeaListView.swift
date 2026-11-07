import SwiftUI
import SwiftData

struct IdeaListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Idea.updatedAt, order: .reverse) private var ideas: [Idea]

    @AppStorage("sortOption") private var sort: SortOption = .updated
    @State private var search = ""
    @State private var filter: IdeaStatus? = nil
    @State private var showQuickCapture = false
    @State private var showNewIdea = false
    @State private var showSettings = false

    var body: some View {
        let items = visibleIdeas
        let pinned = items.filter { $0.isPinned }
        let others = items.filter { !$0.isPinned }

        NavigationStack {
            List {
                if !ideas.isEmpty {
                    Section {
                        StatusFilterBar(selection: $filter, counts: statusCounts, total: ideas.count)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }

                if !pinned.isEmpty {
                    Section("Pinned") {
                        ForEach(pinned) { idea in row(idea) }
                    }
                }

                if !others.isEmpty {
                    if pinned.isEmpty {
                        Section {
                            ForEach(others) { idea in row(idea) }
                        }
                    } else {
                        Section("Ideas") {
                            ForEach(others) { idea in row(idea) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay { emptyState(itemsEmpty: items.isEmpty) }
            .navigationTitle("Ideas")
            .searchable(text: $search, prompt: "Search ideas, tags, notes")
            .navigationDestination(for: Idea.self) { idea in
                IdeaDetailView(idea: idea)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort by", selection: $sort) {
                            ForEach(SortOption.allCases) { option in
                                Label(option.title, systemImage: option.symbol).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("Sort")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewIdea = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New detailed idea")
                }
            }
            .safeAreaInset(edge: .bottom) {
                quickCaptureButton
            }
            .sheet(isPresented: $showQuickCapture) {
                QuickCaptureView()
            }
            .sheet(isPresented: $showNewIdea) {
                IdeaEditorView(idea: nil)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Pieces

    private var quickCaptureButton: some View {
        Button {
            showQuickCapture = true
        } label: {
            Label("Quick Idea", systemImage: "bolt.fill")
                .font(.headline)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(Color.orange, in: Capsule())
                .foregroundStyle(Color.white)
                .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func emptyState(itemsEmpty: Bool) -> some View {
        if ideas.isEmpty {
            ContentUnavailableView {
                Label("No ideas yet", systemImage: "lightbulb")
            } description: {
                Text("Capture product ideas the moment they hit you, so you never lose one again.")
            } actions: {
                Button("Capture your first idea") {
                    showQuickCapture = true
                }
                .buttonStyle(.borderedProminent)
            }
        } else if itemsEmpty {
            if search.trimmed.isEmpty {
                ContentUnavailableView(
                    "Nothing here",
                    systemImage: filter?.symbol ?? "tray",
                    description: Text("No ideas with status \u{201C}\(filter?.title ?? "")\u{201D} yet.")
                )
            } else {
                ContentUnavailableView.search(text: search)
            }
        }
    }

    private func row(_ idea: Idea) -> some View {
        NavigationLink(value: idea) {
            IdeaRow(idea: idea)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                delete(idea)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                idea.isPinned.toggle()
                save()
            } label: {
                Label(idea.isPinned ? "Unpin" : "Pin",
                      systemImage: idea.isPinned ? "pin.slash" : "pin")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if idea.status.next != idea.status {
                Button {
                    setStatus(idea.status.next, for: idea)
                } label: {
                    Label(idea.status.next.title, systemImage: idea.status.next.symbol)
                }
                .tint(idea.status.next.color)
            }
        }
        .contextMenu {
            Menu("Status") {
                ForEach(IdeaStatus.allCases) { status in
                    Button {
                        setStatus(status, for: idea)
                    } label: {
                        Label(status.title, systemImage: status.symbol)
                    }
                }
            }
            Button {
                idea.isPinned.toggle()
                save()
            } label: {
                Label(idea.isPinned ? "Unpin" : "Pin",
                      systemImage: idea.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive) {
                delete(idea)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Data

    private var statusCounts: [IdeaStatus: Int] {
        var counts: [IdeaStatus: Int] = [:]
        for idea in ideas { counts[idea.status, default: 0] += 1 }
        return counts
    }

    private var visibleIdeas: [Idea] {
        let query = search.trimmed.lowercased()
        let filtered = ideas.filter { idea in
            let statusOK = filter == nil || idea.status == filter
            let searchOK = query.isEmpty || idea.searchText.contains(query)
            return statusOK && searchOK
        }
        switch sort {
        case .updated:
            return filtered.sorted { $0.updatedAt > $1.updatedAt }
        case .created:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .priority:
            return filtered.sorted {
                if $0.priorityRaw != $1.priorityRaw { return $0.priorityRaw > $1.priorityRaw }
                return $0.updatedAt > $1.updatedAt
            }
        case .title:
            return filtered.sorted {
                $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending
            }
        }
    }

    private func setStatus(_ status: IdeaStatus, for idea: Idea) {
        withAnimation {
            idea.status = status
            idea.touch()
            save()
        }
    }

    private func delete(_ idea: Idea) {
        withAnimation {
            context.delete(idea)
            save()
        }
    }

    private func save() {
        try? context.save()
    }
}
