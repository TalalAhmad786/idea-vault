import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Plain, Codable copy of an idea used for JSON backups.
struct IdeaRecord: Codable {
    var uuid: UUID
    var title: String
    var details: String
    var problem: String
    var nextStep: String
    var category: String
    var tags: [String]
    var status: String
    var priority: Int
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct IdeaBackupFile: Codable {
    var app: String
    var version: Int
    var exportedAt: Date
    var ideas: [IdeaRecord]
}

extension Idea {
    var record: IdeaRecord {
        IdeaRecord(
            uuid: uuid, title: title, details: details, problem: problem,
            nextStep: nextStep, category: category, tags: tags,
            status: statusRaw, priority: priorityRaw, isPinned: isPinned,
            createdAt: createdAt, updatedAt: updatedAt
        )
    }

    func apply(_ r: IdeaRecord) {
        uuid = r.uuid
        title = r.title
        details = r.details
        problem = r.problem
        nextStep = r.nextStep
        category = r.category
        tags = r.tags
        statusRaw = (IdeaStatus(rawValue: r.status) ?? .idea).rawValue
        priorityRaw = (IdeaPriority(rawValue: r.priority) ?? .none).rawValue
        isPinned = r.isPinned
        createdAt = r.createdAt
        updatedAt = r.updatedAt
    }
}

enum Backup {
    static func encode(_ ideas: [Idea]) throws -> Data {
        let file = IdeaBackupFile(
            app: "IdeaVault",
            version: 1,
            exportedAt: Date(),
            ideas: ideas.map { $0.record }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(file)
    }

    /// Merges a backup into the store. Ideas are matched by their UUID;
    /// an existing idea is only overwritten when the backup copy is newer.
    static func merge(_ data: Data, into context: ModelContext, existing: [Idea]) throws -> (added: Int, updated: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let file = try decoder.decode(IdeaBackupFile.self, from: data)

        var byID: [UUID: Idea] = [:]
        for idea in existing { byID[idea.uuid] = idea }

        var added = 0
        var updated = 0
        for r in file.ideas {
            if let current = byID[r.uuid] {
                if r.updatedAt > current.updatedAt {
                    current.apply(r)
                    updated += 1
                }
            } else {
                let idea = Idea(title: r.title)
                idea.apply(r)
                context.insert(idea)
                byID[r.uuid] = idea
                added += 1
            }
        }
        try context.save()
        return (added, updated)
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        data = contents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
