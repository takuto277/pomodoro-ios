import SwiftUI
import Charts

struct StatisticsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: StatisticsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Summary Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatCard(title: "Today", value: viewModel.output.dailyTime, icon: "calendar")
                        StatCard(title: "This Week", value: viewModel.output.weeklyTime, icon: "calendar.badge.clock")
                        StatCard(title: "This Month", value: viewModel.output.monthlyTime, icon: "calendar.badge.exclamationmark")
                        StatCard(title: "All Time", value: viewModel.output.totalTime, icon: "infinity")
                    }
                    .padding()
                    
                    // Chart Section
                    VStack(alignment: .leading) {
                        Text("目標ごとの時間分布")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.output.goalStats.isEmpty {
                            Text("まだデータがありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            Chart(viewModel.output.goalStats) { stat in
                                BarMark(
                                    x: .value("Goal", stat.title),
                                    y: .value("Hours", stat.totalSeconds / 3600)
                                )
                                .foregroundStyle(by: .value("Goal", stat.title))
                            }
                            .frame(height: 250)
                            .padding()
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Lifetime Chart (Simplified)
                    VStack(alignment: .leading) {
                        Text("生産性の推移")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            BarMark(x: .value("Period", "日"), y: .value("Seconds", viewModel.output.dailySeconds))
                                .foregroundStyle(.blue)
                            BarMark(x: .value("Period", "週"), y: .value("Seconds", viewModel.output.weeklySeconds / 7))
                                .foregroundStyle(.green)
                            BarMark(x: .value("Period", "月"), y: .value("Seconds", viewModel.output.monthlySeconds / 30))
                                .foregroundStyle(.orange)
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadStats()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
