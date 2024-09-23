import SwiftUI

struct ProgressBarNavigationView: View {
    @ObservedObject var settingsManager: AppSettingsManager
    @Binding var selectedTab: Int
    @Binding var isTimerActive: Bool
    @Binding var displayedTime: Double
    @Binding var progressToNextLevel: Double
    @Binding var problemsSolvedDuringTimer: Int
    @Binding var remainingTime: Int

    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressBar(
                progress: isTimerActive ? (displayedTime / Double(settingsManager.timerDuration)) : progressToNextLevel,
                color: isTimerActive ? .green : .white
            )
            .frame(height: 8)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .animation(.linear(duration: 0.1), value: displayedTime)

            // Navigation and Level/Timer info
            HStack {
                Button(action: { withAnimation { self.selectedTab = 0 } }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 20))
                }
                Spacer()

                if isTimerActive {
                    Text("\(problemsSolvedDuringTimer) | \(timeString(from: remainingTime))")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                } else {
                    Text("Level \(currentLevel)")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }

                Spacer()
                Button(action: { withAnimation { self.selectedTab = 2 } }) {
                    Image(systemName: "chart.bar")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    private var currentLevel: Int {
        // You may need to adjust this calculation based on your game logic
        Int(progressToNextLevel * 10) + 1
    }
}

struct ProgressBar: View {
    var progress: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                Rectangle()
                    .fill(color)
                    .frame(width: max(0, CGFloat(progress) * geometry.size.width), height: 8)
                    .cornerRadius(4)
            }
        }
    }
}