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
    private var lastRemaining: Int? = nil
    private var overrideMinutes: Int? = nil
    private var hasStarted: Bool = false
    
    init(timerUseCase: TimerUseCaseProtocol, settingsUseCase: SettingsUseCaseProtocol, goal: PomodoroGoal?, sessionType: SessionType, overrideMinutes: Int? = nil) {
        self.timerUseCase = timerUseCase
        self.settingsUseCase = settingsUseCase
        self.goal = goal
        self.sessionType = sessionType
        self.output.currentType = sessionType
        self.overrideMinutes = overrideMinutes
        
        start()
        setupBindings()
    }
    
    private func setupBindings() {
        timerUseCase.timerValue
            .receive(on: RunLoop.main)
            .sink { [weak self] remainingSeconds in
                guard let self = self else { return }
                // Ignore timer events before we actually started
                guard self.hasStarted else { return }

                self.updateUI(remaining: remainingSeconds)
                // Only trigger finish when we observe a transition to 0 from >0
                if remainingSeconds == 0 && (self.lastRemaining ?? -1) > 0 {
                    self.finish()
                }
                self.lastRemaining = remainingSeconds
            }
            .store(in: &cancellables)
    }
    
    private func start() {
        do {
            let settings = try settingsUseCase.getSettings()
            let minutes: Int
            if let override = overrideMinutes {
                minutes = override
            } else {
                minutes = (sessionType == .work) ? settings.workDuration : settings.breakDuration
            }
            totalSeconds = minutes * 60
            lastRemaining = totalSeconds
            output.isRunning = true
            // mark started before subscription will process values
            hasStarted = true
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
        // Treat user stop as session finish
        finish()
    }
    
    private func finish() {
        // Prevent double finish
        if output.isFinished { return }
        output.isRunning = false
        output.isFinished = true
        timerUseCase.completeSession(type: sessionType, goal: goal)
        
        // Notification logic would go here
    }
}
