import Foundation
import Combine
import SwiftUI

class TimerViewModel: ObservableObject {
    struct Output {
        var timeString: String = "00:00"
        var progress: Double = 1.0
        var isRunning: Bool = false
        var isFinished: Bool = false
        var currentType: SessionType = .work
    }
    
    @Published var output = Output()
    
    private let timerUseCase: TimerUseCaseProtocol
    private let settingsUseCase: SettingsUseCaseProtocol
    private let goal: PomodoroGoal?
    private let sessionType: SessionType
    private var totalSeconds: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(timerUseCase: TimerUseCaseProtocol, settingsUseCase: SettingsUseCaseProtocol, goal: PomodoroGoal?, sessionType: SessionType) {
        self.timerUseCase = timerUseCase
        self.settingsUseCase = settingsUseCase
        self.goal = goal
        self.sessionType = sessionType
        self.output.currentType = sessionType
        
        setupBindings()
        start()
    }
    
    private func setupBindings() {
        timerUseCase.timerValue
            .receive(on: RunLoop.main)
            .sink { [weak self] remainingSeconds in
                guard let self = self else { return }
                self.updateUI(remaining: remainingSeconds)
                if remainingSeconds == 0 && self.output.isRunning {
                    self.finish()
                }
            }
            .store(in: &cancellables)
    }
    
    private func start() {
        do {
            let settings = try settingsUseCase.getSettings()
            let minutes = (sessionType == .work) ? settings.workDuration : settings.breakDuration
            totalSeconds = minutes * 60
            output.isRunning = true
            timerUseCase.startTimer(minutes: minutes)
        } catch {
            print("Error starting timer: \(error)")
        }
    }
    
    private func updateUI(remaining: Int) {
        let minutes = remaining / 60
        let seconds = remaining % 60
        output.timeString = String(format: "%02d:%02d", minutes, seconds)
        output.progress = totalSeconds > 0 ? Double(remaining) / Double(totalSeconds) : 0
    }
    
    func togglePause() {
        if output.isRunning {
            timerUseCase.pauseTimer()
        } else {
            timerUseCase.resumeTimer()
        }
        output.isRunning.toggle()
    }
    
    func stop() {
        timerUseCase.stopTimer()
        output.isRunning = false
    }
    
    private func finish() {
        output.isRunning = false
        output.isFinished = true
        timerUseCase.completeSession(type: sessionType, goal: goal)
        
        // Notification logic would go here
    }
}
