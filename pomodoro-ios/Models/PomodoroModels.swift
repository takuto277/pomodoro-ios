import Foundation
import SwiftData

@Model
final class PomodoroGoal {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \PomodoroSession.goal)
    var sessions: [PomodoroSession] = []
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
    }
}

@Model
final class PomodoroSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval // in seconds
    var type: SessionType
    var goal: PomodoroGoal?
    
    init(startTime: Date, endTime: Date, duration: TimeInterval, type: SessionType, goal: PomodoroGoal? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.type = type
        self.goal = goal
    }
}

enum SessionType: String, Codable {
    case work
    case breakTime
}

@Model
final class PomodoroSettings {
    var workDuration: Int // minutes
    var breakDuration: Int // minutes
    var isSoundEnabled: Bool
    var isNotificationEnabled: Bool
    
    init(workDuration: Int = 25, breakDuration: Int = 5, isSoundEnabled: Bool = true, isNotificationEnabled: Bool = true) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.isSoundEnabled = isSoundEnabled
        self.isNotificationEnabled = isNotificationEnabled
    }
}
