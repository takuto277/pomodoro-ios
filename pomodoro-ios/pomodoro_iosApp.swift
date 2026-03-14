//
//  pomodoro_iosApp.swift
//  pomodoro-ios
//
//  Created by 小野拓人 on 2026/02/11.
//

import SwiftUI
import SwiftData

@main
struct pomodoro_iosApp: App {
    @StateObject private var container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            HomeScreenView(viewModel: container.makeHomeViewModel())
                .environmentObject(container)
        }
        .modelContainer(container.modelContainer)
    }
}
