import SwiftUI

struct GoalSettingScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: GoalViewModel
    @State private var newGoalTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // 新しい目標を追加
                HStack {
                    TextField("New goal title...", text: $newGoalTitle)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.addGoal(title: newGoalTitle)
                        newGoalTitle = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    }
                }
                .padding()
                
                List {
                    Section("フォーカスする分野") {
                        ForEach(viewModel.output.goals) { goal in
                            HStack {
                                Text(goal.title)
                                Spacer()
                                Text("\(goal.sessions.count) 回のセッション")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteGoal)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
    
    private func deleteGoal(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteGoal(viewModel.output.goals[index])
        }
    }
}
