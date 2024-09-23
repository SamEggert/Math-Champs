import SwiftUI

struct NumberPadHeaderView: View {
    @Binding var isTimerActive: Bool
    @Binding var problemsSolvedDuringTimer: Int
    @Binding var remainingTime: Int
    let currentLevel: Int

    var body: some View {
        HStack {
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

            Button(action: {
                // Add action for new problem generation
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }

            Spacer()

            Button(action: {
                // Add action for timer toggle
            }) {
                Image(systemName: isTimerActive ? "timer.circle.fill" : "timer")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}