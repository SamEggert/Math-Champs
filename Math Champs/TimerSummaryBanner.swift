import SwiftUI

struct TimerSummaryBannerView: View {
    @ObservedObject var viewModel: PracticePageViewModel

    var body: some View {
        TimerSummaryBanner(
            problemsSolved: viewModel.problemsSolvedDuringTimer,
            totalTime: viewModel.settingsManager.timerDuration,
            isExpanded: $viewModel.isSummaryExpanded,
            onDismiss: viewModel.dismissSummaryBanner,
            onToggleExpansion: viewModel.toggleSummaryExpansion
        )
    }
}

struct TimerSummaryBanner: View {
    let problemsSolved: Int
    let totalTime: Int
    @Binding var isExpanded: Bool
    var onDismiss: () -> Void
    var onToggleExpansion: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Time's up!")
                    .font(.headline)
                Spacer()
                Text("\(problemsSolved) problems solved")
                    .font(.subheadline)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(hex: "686060"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .onTapGesture {
                withAnimation {
                    onToggleExpansion()
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total time: \(totalTime) seconds")
                    Text("Average time per problem: \(String(format: "%.2f", Double(totalTime) / Double(problemsSolved))) seconds")
                    // Add more detailed stats here
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(hex: "242329"))
        .cornerRadius(15)
    }
}