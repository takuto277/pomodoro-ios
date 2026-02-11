import Foundation
import Combine

protocol TimerUseCaseProtocol {
    var timerValue: AnyPublisher<Int, Never> { get }
    func startTimer(minutes: Int)
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
    func completeSession(type: SessionType, goal: PomodoroGoal?)
}

final class TimerUseCase: TimerUseCaseProtocol {
    private let repository: PomodoroRepositoryProtocol
    private var timer: AnyCancellable?
    private let _timerValue = CurrentValueSubject<Int, Never>(0)
    var timerValue: AnyPublisher<Int, Never> { _timerValue.eraseToAnyPublisher() }
    
    private var remainingSeconds: Int = 0
    private var startTime: Date?
    private var initialDuration: Int = 0
    
    init(repository: PomodoroRepositoryProtocol) {
        self.repository = repository
    }
    
    func startTimer(minutes: Int) {
        initialDuration = minutes * 60
        remainingSeconds = initialDuration
        _timerValue.send(remainingSeconds)
        startTime = Date()
        
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    self._timerValue.send(self.remainingSeconds)
                } else {
                    self.stopTimer()
                }
            }
    }
    
    func pauseTimer() {
        timer?.cancel()
    }
    
    func resumeTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    self._timerValue.send(self.remainingSeconds)
                } else {
                    self.stopTimer()
                }
            }
    }
    
    func stopTimer() {
        timer?.cancel()
    }
    
    func completeSession(type: SessionType, goal: PomodoroGoal?) {
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
            try repository.addSession(session)
            NotificationCenter.default.post(name: .pomodoroSessionDidComplete, object: session)
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}

extension Notification.Name {
    static let pomodoroSessionDidComplete = Notification.Name("pomodoroSessionDidComplete")
}
