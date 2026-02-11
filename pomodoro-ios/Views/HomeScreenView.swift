import SwiftUI

struct HomeScreenView: View {
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
                    
                    // Timer Circle Preview
                    ZStack {
                        Circle()
                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        VStack {
                            Text("\(viewModel.output.workDuration)")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                            Text("min")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        showingTimer = true
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Goal")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.output.goals.isEmpty {
                            Button(action: { showingGoals = true }) {
                                Text("Set a goal to start")
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
                                    Text(viewModel.output.selectedGoal?.title ?? "Select Goal")
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
                        Text("Start Focusing")
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
                        TabButton(icon: "chart.bar.fill", title: "Stats") { showingStats = true }
                        TabButton(icon: "target", title: "Goals") { showingGoals = true }
                        TabButton(icon: "gearshape.fill", title: "Settings") { showingSettings = true }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Pomodoro")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTimer) {
                TimerScreenView(viewModel: DependencyContainer.shared.makeTimerViewModel(
                    goal: viewModel.output.selectedGoal,
                    type: .work
                ))
            }
            .sheet(isPresented: $showingStats) {
                StatisticsScreenView(viewModel: DependencyContainer.shared.makeStatisticsViewModel())
            }
            .sheet(isPresented: $showingGoals) {
                GoalSettingScreenView(viewModel: DependencyContainer.shared.makeGoalViewModel())
            }
            .sheet(isPresented: $showingSettings) {
                SettingsScreenView(viewModel: DependencyContainer.shared.makeSettingsViewModel())
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
