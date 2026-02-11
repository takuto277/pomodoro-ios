import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    struct Output {
        var dailyTime: String = "0h 0m"
        var weeklyTime: String = "0h 0m"
        var monthlyTime: String = "0h 0m"
        var totalTime: String = "0h 0m"
        var dailySeconds: Double = 0
        var weeklySeconds: Double = 0
        var monthlySeconds: Double = 0
        var totalSeconds: Double = 0
        var goalStats: [GoalStat] = []
    }
    
    @Published var output = Output()
    private let statisticsUseCase: StatisticsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(statisticsUseCase: StatisticsUseCaseProtocol) {
        self.statisticsUseCase = statisticsUseCase
        loadStats()
    }
    
    func loadStats() {
        do {
            let stats = try statisticsUseCase.getStatistics()
            output.dailySeconds = stats.dailySeconds
            output.weeklySeconds = stats.weeklySeconds
            output.monthlySeconds = stats.monthlySeconds
            output.totalSeconds = stats.totalSeconds
            
            output.dailyTime = formatTime(stats.dailySeconds)
            output.weeklyTime = formatTime(stats.weeklySeconds)
            output.monthlyTime = formatTime(stats.monthlySeconds)
            output.totalTime = formatTime(stats.totalSeconds)
            
            output.goalStats = stats.goalStats
        } catch {
            print("Error loading stats: \(error)")
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return "\(h)h \(m)m"
    }
}
