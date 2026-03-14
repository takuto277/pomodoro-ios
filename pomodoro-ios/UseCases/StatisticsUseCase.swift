import Foundation

struct Statistics {
    let dailySeconds: Double
    let weeklySeconds: Double
    let monthlySeconds: Double
    let totalSeconds: Double
    let goalStats: [GoalStat]
}

struct GoalStat: Identifiable {
    let id = UUID()
    let title: String
    let totalSeconds: Double
}

protocol StatisticsUseCaseProtocol: Sendable {
    func getStatistics() async throws -> Statistics
}

final class StatisticsUseCase: StatisticsUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func getStatistics() async throws -> Statistics {
        let sessions = try await repository.fetchSessions().filter { $0.type == .work }
        let now = Date()
        let calendar = Calendar.current
        
        let daily = sessions.filter { calendar.isDateInToday($0.startTime) }.reduce(0) { $0 + $1.duration }
        
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let weekly = sessions.filter { $0.startTime >= oneWeekAgo }.reduce(0) { $0 + $1.duration }
        
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        let monthly = sessions.filter { $0.startTime >= oneMonthAgo }.reduce(0) { $0 + $1.duration }
        
        let total = sessions.reduce(0) { $0 + $1.duration }
        
        // Group by goal
        let goals = try await repository.fetchGoals()
        let goalStats = goals.map { goal in
            let goalTotal = sessions.filter { $0.goal?.id == goal.id }.reduce(0) { $0 + $1.duration }
            return GoalStat(title: goal.title, totalSeconds: goalTotal)
        }
        
        return Statistics(
            dailySeconds: daily,
            weeklySeconds: weekly,
            monthlySeconds: monthly,
            totalSeconds: total,
            goalStats: goalStats
        )
    }
}
