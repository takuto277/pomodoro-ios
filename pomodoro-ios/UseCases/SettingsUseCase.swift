import Foundation

protocol SettingsUseCaseProtocol {
    func getSettings() throws -> PomodoroSettings
    func updateSettings(_ settings: PomodoroSettings) throws
}

final class SettingsUseCase: SettingsUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func getSettings() throws -> PomodoroSettings {
        try repository.fetchSettings()
    }
    
    func updateSettings(_ settings: PomodoroSettings) throws {
        try repository.updateSettings(settings)
    }
}
