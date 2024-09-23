import SwiftUI
import Shimmer

struct PracticePage: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var settingsManager: AppSettingsManager
    @Binding var selectedTab: Int

    @StateObject private var viewModel: PracticePageViewModel

    init(gameState: GameState, settingsManager: AppSettingsManager, selectedTab: Binding<Int>) {
        self._gameState = ObservedObject(wrappedValue: gameState)
        self._settingsManager = ObservedObject(wrappedValue: settingsManager)
        self._selectedTab = selectedTab
        self._viewModel = StateObject(wrappedValue: PracticePageViewModel(gameState: gameState, settingsManager: settingsManager))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()

                VStack(spacing: 0) {
                    ProgressBarNavigationView(
                        settingsManager: settingsManager,
                        selectedTab: $selectedTab,
                        isTimerActive: $viewModel.isTimerActive,
                        displayedTime: $viewModel.displayedTime,
                        progressToNextLevel: .constant(viewModel.progressToNextLevel),
                        problemsSolvedDuringTimer: $viewModel.problemsSolvedDuringTimer,
                        remainingTime: $viewModel.remainingTime
                    )
                    .padding(.top, topSafeAreaInset)

                    Spacer()

                    ProblemView(viewModel: viewModel, settingsManager: settingsManager)

                    Spacer()

                    ControlButtons(viewModel: viewModel)

                    NumberPadView(
                        appendNumber: viewModel.appendNumber,
                        clearAction: viewModel.clearAnswer,
                        submitAction: { viewModel.checkAnswer(autoSubmit: false) },
                        geometry: geometry
                    )
                }
                .padding(.bottom, optimizedBottomPadding(for: geometry))

                VStack {
                    if viewModel.showSummaryBanner {
                        TimerSummaryBannerView(viewModel: viewModel)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                            .padding(.top, topSafeAreaInset + 60) // Adjust this value as needed
                    }
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.showSummaryBanner)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: viewModel.setupOnAppear)
        .onChange(of: settingsManager.operationTypes) { _ in viewModel.generateNewProblem() }
        // Add other .onChange modifiers here
    }

    private func optimizedBottomPadding(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        let curveBeginRatio: CGFloat = 0.87
        let optimalPosition = screenHeight * curveBeginRatio
        let currentPosition = screenHeight - safeAreaBottom
        let additionalPadding = currentPosition - optimalPosition
        return max(safeAreaBottom, min(additionalPadding, 40))
    }

    private var topSafeAreaInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.top ?? 0
    }
}

// Define these as separate views
struct BackgroundView: View {
    var body: some View {
        Color(hex: "242329").edgesIgnoringSafeArea(.all)
    }
}

struct ProblemView: View {
    @ObservedObject var viewModel: PracticePageViewModel
    let settingsManager: AppSettingsManager

    var body: some View {
        ProblemDisplayView(
            currentProblem: $viewModel.currentProblem,
            userAnswer: $viewModel.userAnswer,
            isShimmering: $viewModel.isShimmering,
            settingsManager: settingsManager,
            feedbackColor: feedbackColor
        )
        .frame(width: 300)
        .padding(.top, 20)
    }

    private var feedbackColor: Color {
        if viewModel.showingColorFeedback {
            return viewModel.isCorrect ?? false ? .green : .red
        } else {
            return .white
        }
    }
}

struct ControlButtons: View {
    @ObservedObject var viewModel: PracticePageViewModel

    var body: some View {
        HStack {
            Button(action: viewModel.generateNewProblem) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }

            Spacer()

            Button(action: viewModel.toggleTimer) {
                Image(systemName: viewModel.isTimerActive ? "timer.circle.fill" : "timer")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}
