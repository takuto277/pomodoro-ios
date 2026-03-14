import Foundation

protocol SettingsUseCaseProtocol: Sendable {
    func getSettings() async throws -> PomodoroSettings
    func updateSettings(_ settings: PomodoroSettings) async throws
}

final class SettingsUseCase: SettingsUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func getSettings() async throws -> PomodoroSettings {
        try await repository.fetchSettings()
    }
    
    func updateSettings(_ settings: PomodoroSettings) async throws {
        try await repository.updateSettings(settings)
    }
}
