import Foundation
import SwiftData
import Combine

protocol PomodoroRepositoryProtocol: Sendable {
    func fetchGoals() async throws -> [PomodoroGoal]
    func addGoal(_ goal: PomodoroGoal) async throws
    func deleteGoal(_ goal: PomodoroGoal) async throws
    
    func fetchSessions() async throws -> [PomodoroSession]
    func addSession(_ session: PomodoroSession) async throws
    
    func fetchSettings() async throws -> PomodoroSettings
    func updateSettings(_ settings: PomodoroSettings) async throws
}

@ModelActor
actor PomodoroRepository: PomodoroRepositoryProtocol {
    
    func fetchGoals() async throws -> [PomodoroGoal] {
        let descriptor = FetchDescriptor<PomodoroGoal>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func addGoal(_ goal: PomodoroGoal) async throws {
        modelContext.insert(goal)
        try modelContext.save()
    }
    
    func deleteGoal(_ goal: PomodoroGoal) async throws {
        modelContext.delete(goal)
        try modelContext.save()
    }
    
    func fetchSessions() async throws -> [PomodoroSession] {
        let descriptor = FetchDescriptor<PomodoroSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func addSession(_ session: PomodoroSession) async throws {
        modelContext.insert(session)
        try modelContext.save()
    }
    
    func fetchSettings() async throws -> PomodoroSettings {
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
    
    func updateSettings(_ settings: PomodoroSettings) async throws {
        try modelContext.save()
    }
}
