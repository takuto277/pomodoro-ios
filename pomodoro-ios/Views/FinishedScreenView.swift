import SwiftUI

struct FinishedScreenView: View {
    let onTakeBreak: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.accentColor, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("お疲れさまでした！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("セッションが完了しました。休憩しますか？")
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: onTakeBreak) {
                        Text("5分休憩する")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onClose) {
                        Text("閉じる")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FinishedScreenView_Previews: PreviewProvider {
    static var previews: some View {
        FinishedScreenView(onTakeBreak: {}, onClose: {})
    }
}
