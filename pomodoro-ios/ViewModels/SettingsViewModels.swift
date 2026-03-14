import Foundation
import Combine

@MainActor
class GoalViewModel: ObservableObject {
    struct Output {
        var goals: [PomodoroGoal] = []
    }
    
    @Published var output = Output()
    private let goalUseCase: GoalUseCaseProtocol
    
    init(goalUseCase: GoalUseCaseProtocol) {
        self.goalUseCase = goalUseCase
        loadGoals()
    }
    
    func loadGoals() {
        Task {
            do {
                output.goals = try await goalUseCase.getGoals()
            } catch {
                print("Error loading goals: \(error)")
            }
        }
    }
    
    func addGoal(title: String) {
        guard !title.isEmpty else { return }
        Task {
            do {
                try await goalUseCase.createGoal(title: title)
                loadGoals()
            } catch {
                print("Error adding goal: \(error)")
            }
        }
    }
    
    func deleteGoal(_ goal: PomodoroGoal) {
        Task {
            do {
                try await goalUseCase.removeGoal(goal)
                loadGoals()
            } catch {
                print("Error deleting goal: \(error)")
            }
        }
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    struct Output {
        var workDuration: Int = 25
        var breakDuration: Int = 5
        var isSoundEnabled: Bool = true
        var isNotificationEnabled: Bool = true
    }
    
    @Published var output = Output()
    private let settingsUseCase: SettingsUseCaseProtocol
    private var settings: PomodoroSettings?
    
    init(settingsUseCase: SettingsUseCaseProtocol) {
        self.settingsUseCase = settingsUseCase
        loadSettings()
    }
    
    func loadSettings() {
        Task {
            do {
                let s = try await settingsUseCase.getSettings()
                self.settings = s
                output.workDuration = s.workDuration
                output.breakDuration = s.breakDuration
                output.isSoundEnabled = s.isSoundEnabled
                output.isNotificationEnabled = s.isNotificationEnabled
            } catch {
                print("Error loading settings: \(error)")
            }
        }
    }
    
    func updateWorkDuration(_ value: Int) {
        output.workDuration = value
        save()
    }
    
    func updateBreakDuration(_ value: Int) {
        output.breakDuration = value
        save()
    }
    
    func toggleSound() {
        output.isSoundEnabled.toggle()
        save()
    }
    
    func toggleNotifications() {
        output.isNotificationEnabled.toggle()
        save()
    }
    
    private func save() {
        guard let s = settings else { return }
        s.workDuration = output.workDuration
        s.breakDuration = output.breakDuration
        s.isSoundEnabled = output.isSoundEnabled
        s.isNotificationEnabled = output.isNotificationEnabled
        Task {
            try? await settingsUseCase.updateSettings(s)
        }
    }
}
