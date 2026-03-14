import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject var viewModel: HomeViewModel
    @State private var showingTimer = false
    @State private var showingStats = false
    @State private var showingGoals = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                        // タイマーサマリ
                    ZStack {
                        Circle()
                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        VStack {
                                Text("\(viewModel.output.workDuration)")
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                Text("分")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        showingTimer = true
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("現在の目標")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.output.goals.isEmpty {
                            Button(action: { showingGoals = true }) {
                                Text("目標を設定して開始しましょう")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        } else {
                            Menu {
                                ForEach(viewModel.output.goals) { goal in
                                    Button(goal.title) {
                                        viewModel.selectGoal(goal)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.output.selectedGoal?.title ?? "目標を選択")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.up.down")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Button(action: { showingTimer = true }) {
                        Text("集中を開始")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Tab Bar Simulation
                    HStack(spacing: 40) {
                        TabButton(icon: "chart.bar.fill", title: "統計") { showingStats = true }
                        TabButton(icon: "target", title: "目標") { showingGoals = true }
                        TabButton(icon: "gearshape.fill", title: "設定") { showingSettings = true }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Pomodoro")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTimer) {
                TimerScreenView(viewModel: container.makeTimerViewModel(
                    goal: viewModel.output.selectedGoal,
                    type: .work
                ))
            }
            .sheet(isPresented: $showingStats) {
                StatisticsScreenView(viewModel: container.makeStatisticsViewModel())
            }
            .sheet(isPresented: $showingGoals) {
                GoalSettingScreenView(viewModel: container.makeGoalViewModel())
            }
            .sheet(isPresented: $showingSettings) {
                SettingsScreenView(viewModel: container.makeSettingsViewModel())
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
        }
        .foregroundColor(.secondary)
    }
}
