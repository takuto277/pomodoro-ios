import Foundation
import Combine

protocol TimerUseCaseProtocol: Sendable {
    var timerValue: AnyPublisher<Int, Never> { get }
    func startTimer(minutes: Int)
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
    func completeSession(type: SessionType, goal: PomodoroGoal?) async
}

final class TimerUseCase: TimerUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    private var timer: AnyCancellable?
    private let _timerValue = CurrentValueSubject<Int, Never>(0)
    var timerValue: AnyPublisher<Int, Never> { _timerValue.eraseToAnyPublisher() }
    
    private var targetEndTime: Date?
    private var remainingSeconds: Int = 0
    private var initialDuration: Int = 0
    private var startTime: Date?
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func startTimer(minutes: Int) {
        initialDuration = minutes * 60
        remainingSeconds = initialDuration
        _timerValue.send(remainingSeconds)
        startTime = Date()
        
        targetEndTime = Date().addingTimeInterval(TimeInterval(initialDuration))
        startTimerTicking()
    }
    
    func pauseTimer() {
        timer?.cancel()
        timer = nil
        targetEndTime = nil
    }
    
    func resumeTimer() {
        if remainingSeconds > 0 {
            targetEndTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            startTimerTicking()
        }
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
        targetEndTime = nil
    }
    
    private func startTimerTicking() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let end = self.targetEndTime else { return }
                let now = Date()
                let timeRemaining = Int(end.timeIntervalSince(now))
                
                if timeRemaining > 0 {
                    self.remainingSeconds = timeRemaining
                    self._timerValue.send(timeRemaining)
                } else {
                    self.remainingSeconds = 0
                    self._timerValue.send(0)
                    self.stopTimer()
                }
            }
    }
    
    func completeSession(type: SessionType, goal: PomodoroGoal?) async {
        let endTime = Date()
        let start = startTime ?? endTime.addingTimeInterval(-Double(initialDuration - remainingSeconds))
        let session = PomodoroSession(
            startTime: start,
            endTime: endTime,
            duration: Double(initialDuration - remainingSeconds),
            type: type,
            goal: goal
        )
        do {
            try await repository.addSession(session)
            await MainActor.run {
                NotificationCenter.default.post(name: .pomodoroSessionDidComplete, object: session)
            }
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}

extension Notification.Name {
    static let pomodoroSessionDidComplete = Notification.Name("pomodoroSessionDidComplete")
}
