import SwiftUI
import Charts

struct StatisticsScreenView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var container: DependencyContainer
    @StateObject var viewModel: StatisticsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Summary Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatCard(title: "今日", value: viewModel.output.dailyTime, icon: "calendar")
                        StatCard(title: "今週", value: viewModel.output.weeklyTime, icon: "calendar.badge.clock")
                        StatCard(title: "今月", value: viewModel.output.monthlyTime, icon: "calendar.badge.exclamationmark")
                        StatCard(title: "累計", value: viewModel.output.totalTime, icon: "infinity")
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
                                    x: .value("目標", stat.title),
                                    y: .value("時間（h）", stat.totalSeconds / 3600)
                                )
                                .foregroundStyle(by: .value("目標", stat.title))
                            }
                            .frame(height: 250)
                            .padding()
                            .chartYAxisLabel("時間（h）")
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
                            BarMark(x: .value("期間", "今日 (合計)"), y: .value("時間（h）", viewModel.output.dailySeconds / 3600))
                                .foregroundStyle(.blue)
                            BarMark(x: .value("期間", "今週 (合計)"), y: .value("時間（h）", viewModel.output.weeklySeconds / 3600))
                                .foregroundStyle(.green)
                            BarMark(x: .value("期間", "今月 (合計)"), y: .value("時間（h）", viewModel.output.monthlySeconds / 3600))
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
            .navigationTitle("進捗")
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
