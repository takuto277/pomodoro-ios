import Foundation

protocol GoalUseCaseProtocol {
    func getGoals() throws -> [PomodoroGoal]
    func createGoal(title: String) throws
    func removeGoal(_ goal: PomodoroGoal) throws
}

final class GoalUseCase: GoalUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func getGoals() throws -> [PomodoroGoal] {
        try repository.fetchGoals()
    }
    
    func createGoal(title: String) throws {
        let goal = PomodoroGoal(title: title)
        try repository.addGoal(goal)
    }
    
    func removeGoal(_ goal: PomodoroGoal) throws {
        try repository.deleteGoal(goal)
    }
}
