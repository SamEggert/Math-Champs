import SwiftUI
import Shimmer

struct ProblemDisplayView: View {
    @Binding var currentProblem: Problem?
    @Binding var userAnswer: String
    @Binding var isShimmering: Bool
    let settingsManager: AppSettingsManager
    let feedbackColor: Color

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("\(currentProblem?.firstNumber ?? 0)")
                .font(.system(size: 60, weight: .bold))
                .shimmering(
                    active: settingsManager.perfectAnimationEnabled && isShimmering,
                    animation: Animation.linear(duration: 0.3).repeatForever(autoreverses: true),
                    gradient: Gradient(stops: [
                        .init(color: .green, location: 0),
                        .init(color: Color(hex: "D4AF37"), location: 0.4),
                        .init(color: Color(hex: "FFD700"), location: 0.5),
                        .init(color: Color(hex: "D4AF37"), location: 0.6),
                        .init(color: .yellow.opacity(0.6), location: 1)
                    ])
                )
            HStack(spacing: 20) {
                Text(currentProblem?.operation ?? "+")
                    .font(.system(size: 60, weight: .bold))
                Text("\(currentProblem?.secondNumber ?? 0)")
                    .font(.system(size: 60, weight: .bold))
                    .shimmering(
                        active: settingsManager.perfectAnimationEnabled && isShimmering,
                        animation: Animation.linear(duration: 0.3).repeatForever(autoreverses: true),
                        gradient: Gradient(stops: [
                            .init(color: .green, location: 0),
                            .init(color: Color(hex: "D4AF37"), location: 0.4),
                            .init(color: Color(hex: "FFD700"), location: 0.5),
                            .init(color: Color(hex: "D4AF37"), location: 0.6),
                            .init(color: .yellow.opacity(0.6), location: 1)
                        ])
                    )
            }
            ZStack(alignment: .trailing) {
                Rectangle()
                    .fill(feedbackColor)
                    .frame(height: 4)
            }
            Text(userAnswer.isEmpty ? "?" : userAnswer)
                .font(.system(size: fontSize(for: userAnswer.count), weight: .bold))
                .frame(height: 70)
                .shimmering(
                    active: settingsManager.perfectAnimationEnabled && isShimmering,
                    animation: Animation.linear(duration: 0.3).repeatForever(autoreverses: true),
                    gradient: Gradient(stops: [
                        .init(color: .green, location: 0),
                        .init(color: Color(hex: "D4AF37"), location: 0.4),
                        .init(color: Color(hex: "FFD700"), location: 0.5),
                        .init(color: Color(hex: "D4AF37"), location: 0.6),
                        .init(color: .yellow.opacity(0.6), location: 1)
                    ])
                )
        }
        .foregroundColor(feedbackColor)
    }

    private func fontSize(for count: Int) -> CGFloat {
        let defaultFontSize: CGFloat = 60
        let minFontSize: CGFloat = 20

        if count <= 7 {
            return defaultFontSize
        } else {
            let fontSize = defaultFontSize - (CGFloat(count - 7) / CGFloat(8)) * (defaultFontSize - minFontSize)
            return max(fontSize, minFontSize)
        }
    }
}