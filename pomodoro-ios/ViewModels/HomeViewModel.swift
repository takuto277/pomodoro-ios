import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    struct Output {
        var selectedGoal: PomodoroGoal? = nil
        var goals: [PomodoroGoal] = []
        var workDuration: Int = 25
    }
    
    @Published var output = Output()
    
    private let goalUseCase: GoalUseCaseProtocol
    private let settingsUseCase: SettingsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(goalUseCase: GoalUseCaseProtocol, settingsUseCase: SettingsUseCaseProtocol) {
        self.goalUseCase = goalUseCase
        self.settingsUseCase = settingsUseCase
        loadData()
    }
    
    func loadData() {
        Task {
            do {
                output.goals = try await goalUseCase.getGoals()
                if output.selectedGoal == nil {
                    output.selectedGoal = output.goals.first
                }
                let settings = try await settingsUseCase.getSettings()
                output.workDuration = settings.workDuration
            } catch {
                print("Error loading home data: \(error)")
            }
        }
    }
    
    func selectGoal(_ goal: PomodoroGoal) {
        output.selectedGoal = goal
    }
}
