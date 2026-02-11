import SwiftUI

struct SettingsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タイマーの長さ")) {
                    Stepper(value: Binding(
                        get: { viewModel.output.workDuration },
                        set: { viewModel.updateWorkDuration($0) }
                    ), in: 1...60) {
                        HStack {
                            Text("作業時間")
                            Spacer()
                            Text("\(viewModel.output.workDuration) 分")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper(value: Binding(
                        get: { viewModel.output.breakDuration },
                        set: { viewModel.updateBreakDuration($0) }
                    ), in: 1...30) {
                        HStack {
                            Text("休憩時間")
                            Spacer()
                            Text("\(viewModel.output.breakDuration) 分")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("通知・音")) {
                    Toggle("サウンド", isOn: Binding(
                        get: { viewModel.output.isSoundEnabled },
                        set: { _ in viewModel.toggleSound() }
                    ))
                    
                    Toggle("通知", isOn: Binding(
                        get: { viewModel.output.isNotificationEnabled },
                        set: { _ in viewModel.toggleNotifications() }
                    ))
                }
                
                Section {
                    Button(role: .destructive, action: {
                        // Reset all logic
                    }) {
                        Text("全データをリセット")
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}
