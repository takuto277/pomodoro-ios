import Foundation
import SwiftData

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    let modelContainer: ModelContainer
    let repository: PomodoroRepositoryProtocol
    
    private init() {
        do {
            modelContainer = try ModelContainer(for: PomodoroGoal.self, PomodoroSession.self, PomodoroSettings.self)
            repository = PomodoroRepository(modelContext: ModelContext(modelContainer))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            goalUseCase: GoalUseCase(repository: repository),
            settingsUseCase: SettingsUseCase(repository: repository)
        )
    }
    
    func makeTimerViewModel(goal: PomodoroGoal?, type: SessionType) -> TimerViewModel {
        TimerViewModel(
            timerUseCase: TimerUseCase(repository: repository),
            settingsUseCase: SettingsUseCase(repository: repository),
            goal: goal,
            sessionType: type
        )
    }
    
    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(statisticsUseCase: StatisticsUseCase(repository: repository))
    }
    
    func makeGoalViewModel() -> GoalViewModel {
        GoalViewModel(goalUseCase: GoalUseCase(repository: repository))
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsUseCase: SettingsUseCase(repository: repository))
    }
}
