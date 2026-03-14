import Foundation

protocol GoalUseCaseProtocol: Sendable {
    func getGoals() async throws -> [PomodoroGoal]
    func createGoal(title: String) async throws
    func removeGoal(_ goal: PomodoroGoal) async throws
}

final class GoalUseCase: GoalUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func getGoals() async throws -> [PomodoroGoal] {
        try await repository.fetchGoals()
    }
    
    func createGoal(title: String) async throws {
        let goal = PomodoroGoal(title: title)
        try await repository.addGoal(goal)
    }
    
    func removeGoal(_ goal: PomodoroGoal) async throws {
        try await repository.deleteGoal(goal)
    }
}
