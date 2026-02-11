import Foundation
import SwiftData
import Combine

protocol PomodoroRepositoryProtocol {
    func fetchGoals() throws -> [PomodoroGoal]
    func addGoal(_ goal: PomodoroGoal) throws
    func deleteGoal(_ goal: PomodoroGoal) throws
    
    func fetchSessions() throws -> [PomodoroSession]
    func addSession(_ session: PomodoroSession) throws
    
    func fetchSettings() throws -> PomodoroSettings
    func updateSettings(_ settings: PomodoroSettings) throws
}

final class PomodoroRepository: PomodoroRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchGoals() throws -> [PomodoroGoal] {
        let descriptor = FetchDescriptor<PomodoroGoal>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func addGoal(_ goal: PomodoroGoal) throws {
        modelContext.insert(goal)
        try modelContext.save()
    }
    
    func deleteGoal(_ goal: PomodoroGoal) throws {
        modelContext.delete(goal)
        try modelContext.save()
    }
    
    func fetchSessions() throws -> [PomodoroSession] {
        let descriptor = FetchDescriptor<PomodoroSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func addSession(_ session: PomodoroSession) throws {
        modelContext.insert(session)
        try modelContext.save()
    }
    
    func fetchSettings() throws -> PomodoroSettings {
        let descriptor = FetchDescriptor<PomodoroSettings>()
        let settings = try modelContext.fetch(descriptor)
        if let first = settings.first {
            return first
        } else {
            let defaultSettings = PomodoroSettings()
            modelContext.insert(defaultSettings)
            try modelContext.save()
            return defaultSettings
        }
    }
    
    func updateSettings(_ settings: PomodoroSettings) throws {
        // SwiftData tracks changes, but we ensure it's saved
        try modelContext.save()
    }
}
