import SwiftUI

struct SettingsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations")) {
                    Stepper(value: Binding(
                        get: { viewModel.output.workDuration },
                        set: { viewModel.updateWorkDuration($0) }
                    ), in: 1...60) {
                        HStack {
                            Text("Work Duration")
                            Spacer()
                            Text("\(viewModel.output.workDuration) min")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper(value: Binding(
                        get: { viewModel.output.breakDuration },
                        set: { viewModel.updateBreakDuration($0) }
                    ), in: 1...30) {
                        HStack {
                            Text("Break Duration")
                            Spacer()
                            Text("\(viewModel.output.breakDuration) min")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Alerts")) {
                    Toggle("Sound", isOn: Binding(
                        get: { viewModel.output.isSoundEnabled },
                        set: { _ in viewModel.toggleSound() }
                    ))
                    
                    Toggle("Notifications", isOn: Binding(
                        get: { viewModel.output.isNotificationEnabled },
                        set: { _ in viewModel.toggleNotifications() }
                    ))
                }
                
                Section {
                    Button(role: .destructive, action: {
                        // Reset all logic
                    }) {
                        Text("Reset All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
