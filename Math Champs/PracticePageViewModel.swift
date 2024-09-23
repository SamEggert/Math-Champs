import SwiftUI

class PracticePageViewModel: ObservableObject {
    @Published var currentProblem: Problem?
    @Published var userAnswer = ""
    @Published var isCorrect: Bool? = nil
    @Published var showingColorFeedback = false
    @Published var showingIncorrectFeedback = false
    @Published var isTimerActive = false
    @Published var displayedTime: Double = 0
    @Published var remainingTime: Int = 0
    @Published var problemsSolvedDuringTimer = 0
    @Published var showSummaryBanner = false
    @Published var isSummaryExpanded = false
    @Published var isShimmering = false

    private var timer: Timer?
    private var colorFeedbackDuration: Double = 0.25
    private var isPerfectAnswer: Bool = false
    private var isFirstAttempt: Bool = true
    private var hasCleared: Bool = false
    private var hasSubmittedIncorrectly: Bool = false
    private var isAnswerChecked = false
    private var lastCheckedAnswer = ""
    private var bannerDismissTimer: Timer?
    private let bannerDismissDelay: TimeInterval = 5.0

    let gameState: GameState
    let settingsManager: AppSettingsManager

    init(gameState: GameState, settingsManager: AppSettingsManager) {
        self.gameState = gameState
        self.settingsManager = settingsManager
    }

    func setupOnAppear() {
        displayedTime = Double(settingsManager.timerDuration)
        remainingTime = settingsManager.timerDuration
        if settingsManager.preserveProblems,
           let decodedProblem = settingsManager.getLastProblem() {
            currentProblem = decodedProblem
        } else {
            generateNewProblem()
        }
        resetProblemState()
    }

    func generateNewProblem() {
        guard !settingsManager.operationTypes.isEmpty else {
            settingsManager.operationTypes = ["addition"]
            return
        }

        isShimmering = false
        let operation = settingsManager.operationTypes.randomElement()!

        switch operation {
        case "addition":
            currentProblem = Problem(
                firstNumber: Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1),
                secondNumber: Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2),
                operation: "+"
            )
        case "subtraction":
            let n1 = Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1)
            let n2 = Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2)
            currentProblem = Problem(firstNumber: n1 + n2, secondNumber: n1, operation: "-")
        case "multiplication":
            currentProblem = Problem(
                firstNumber: Int.random(in: settingsManager.multiplicationMinNumber1...settingsManager.multiplicationMaxNumber1),
                secondNumber: Int.random(in: settingsManager.multiplicationMinNumber2...settingsManager.multiplicationMaxNumber2),
                operation: "×"
            )
        case "division":
            let n1 = Int.random(in: settingsManager.multiplicationMinNumber1...settingsManager.multiplicationMaxNumber1)
            let n2 = Int.random(in: settingsManager.multiplicationMinNumber2...settingsManager.multiplicationMaxNumber2)
            currentProblem = Problem(firstNumber: n1 * n2, secondNumber: n1, operation: "÷")
        default:
            currentProblem = Problem(
                firstNumber: Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1),
                secondNumber: Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2),
                operation: "+"
            )
        }

        if settingsManager.preserveProblems {
            settingsManager.saveLastProblem(currentProblem)
        }

        resetProblemState()
    }

    func checkAnswer(autoSubmit: Bool) {
        guard let problem = currentProblem, let answer = Int(userAnswer) else { return }

        isCorrect = (answer == problem.correctAnswer)

        if isCorrect == true && userAnswer != lastCheckedAnswer {
            gameState.totalProblems += 1
            gameState.correctAnswers += 1
            if isTimerActive {
                problemsSolvedDuringTimer += 1
            }

            isPerfectAnswer = !hasCleared && !hasSubmittedIncorrectly
            notificationFeedback(isPerfectAnswer ? .success : .warning)
            isShimmering = settingsManager.perfectAnimationEnabled && isPerfectAnswer

            showColorFeedback(generateNewProblem: true)
            lastCheckedAnswer = userAnswer
        } else if isCorrect == false && (!settingsManager.automaticCorrect || !autoSubmit) {
            gameState.totalProblems += 1
            notificationFeedback(.error)
            hasSubmittedIncorrectly = true
            isShimmering = false

            if settingsManager.generateNewOnIncorrect {
                showingIncorrectFeedback = true
                showColorFeedback(generateNewProblem: true)
            } else {
                showColorFeedback(generateNewProblem: false)
            }
            lastCheckedAnswer = userAnswer
        }

        isAnswerChecked = isCorrect == true
    }

    func appendNumber(_ number: Int) {
        if userAnswer.count < 22 {
            userAnswer += "\(number)"
            if settingsManager.automaticCorrect {
                self.checkAnswer(autoSubmit: true)
            }
        }
    }

    func clearAnswer() {
        userAnswer = ""
        isCorrect = nil
        hasCleared = true
        isAnswerChecked = false
        lastCheckedAnswer = ""
        impactFeedback(.medium)
    }

    func toggleTimer() {
        if isTimerActive {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func dismissSummaryBanner() {
        withAnimation {
            showSummaryBanner = false
            isSummaryExpanded = false
        }
        stopBannerDismissTimer()
    }

    private func resetProblemState() {
        userAnswer = ""
        isCorrect = nil
        isPerfectAnswer = false
        isFirstAttempt = true
        showingColorFeedback = false
        showingIncorrectFeedback = false
        hasCleared = false
        hasSubmittedIncorrectly = false
        isAnswerChecked = false
        lastCheckedAnswer = ""
    }

    private func showColorFeedback(generateNewProblem: Bool) {
        showingColorFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + colorFeedbackDuration) {
            self.showingColorFeedback = false
            self.showingIncorrectFeedback = false
            if generateNewProblem {
                self.generateNewProblem()
            } else {
                self.userAnswer = ""
            }
            self.isAnswerChecked = false
            self.lastCheckedAnswer = ""
            self.isShimmering = false
            self.isCorrect = nil // Reset isCorrect after feedback
        }
    }

    private func startTimer() {
        isTimerActive = true
        remainingTime = settingsManager.timerDuration
        displayedTime = Double(settingsManager.timerDuration)
        generateNewProblem()
        problemsSolvedDuringTimer = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.displayedTime -= 0.1
                self.remainingTime = Int(self.displayedTime)
            } else {
                self.stopTimer()
                self.showSummaryBanner = true
            }
        }
    }

    private func stopTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil
        remainingTime = settingsManager.timerDuration
        displayedTime = Double(settingsManager.timerDuration)
        showTimerSummaryBanner()
    }

    private func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(type)
    }

    private func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
    }

    func showTimerSummaryBanner() {
        showSummaryBanner = true
        isSummaryExpanded = false
        startBannerDismissTimer()
    }

    func toggleSummaryExpansion() {
        isSummaryExpanded.toggle()
        if isSummaryExpanded {
            stopBannerDismissTimer()
        } else {
            startBannerDismissTimer()
        }
    }

    private func startBannerDismissTimer() {
        stopBannerDismissTimer()
        bannerDismissTimer = Timer.scheduledTimer(withTimeInterval: bannerDismissDelay, repeats: false) { [weak self] _ in
            self?.dismissSummaryBanner()
        }
    }

    private func stopBannerDismissTimer() {
        bannerDismissTimer?.invalidate()
        bannerDismissTimer = nil
    }
}


extension PracticePageViewModel {
    var progressToNextLevel: Double {
        let correctAnswers = gameState.correctAnswers
        let currentLevel = self.currentLevel
        let pointsForCurrentLevel = pointsForLevel(currentLevel)
        let pointsForNextLevel = pointsForLevel(currentLevel + 1)
        let currentProgress = correctAnswers - pointsForCurrentLevel
        let totalForNextLevel = pointsForNextLevel - pointsForCurrentLevel
        return Double(currentProgress) / Double(totalForNextLevel)
    }

    private var currentLevel: Int {
        level(for: gameState.correctAnswers)
    }

    private func pointsForLevel(_ level: Int) -> Int {
        return (level - 1) * (level - 1) * 5
    }

    private func level(for points: Int) -> Int {
        var level = 1
        while points >= pointsForLevel(level + 1) {
            level += 1
        }
        return level
    }
}
