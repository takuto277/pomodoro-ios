import SwiftUI

struct TimerScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: TimerViewModel
    @State private var showingFinishedScreen = false
    @State private var showBreakFullScreen = false
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text(viewModel.output.currentType == .work ? "Work Time" : "Break Time")
                        .font(.headline)
                    Spacer()
                    // Spacer for centering
                    Image(systemName: "xmark").opacity(0)
                }
                .padding()
                
                Spacer()
                
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 15)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.output.progress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.output.progress)
                    
                    VStack(spacing: 10) {
                        Text(viewModel.output.timeString)
                            .font(.system(size: 70, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        Text(viewModel.output.currentType == .work ? "Focusing" : "Resting")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 300, height: 300)
                .padding()
                
                Spacer()
                
                HStack(spacing: 50) {
                    Button(action: { viewModel.togglePause() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: viewModel.output.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        viewModel.stop()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "stop.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            .foregroundColor(.white)
        }
        .onChange(of: viewModel.output.isFinished) { finished in
            if finished {
                // 表示は常に終了画面へ
                showingFinishedScreen = true
            }
        }
        .fullScreenCover(isPresented: $showingFinishedScreen) {
            FinishedScreenView(
                onTakeBreak: {
                    // 5分の休憩をフルスクリーンで開始
                    viewModel.stop()
                    showingFinishedScreen = false
                    showBreakFullScreen = true
                },
                onClose: {
                    showingFinishedScreen = false
                    dismiss()
                }
            )
        }
        .fullScreenCover(isPresented: $showBreakFullScreen) {
            TimerScreenView(viewModel: DependencyContainer.shared.makeTimerViewModel(goal: nil, type: .breakTime, overrideMinutes: 5))
        }
    }
    
    var backgroundColor: Color {
        viewModel.output.currentType == .work ? Color.accentColor : Color.green
    }
}
