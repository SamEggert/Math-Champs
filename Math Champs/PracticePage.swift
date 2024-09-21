import SwiftUI

struct PracticePage: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var settingsManager: AppSettingsManager
    @Binding var selectedTab: Int
    
    @State private var firstNumber = 0
    @State private var secondNumber = 0
    @State private var operationSymbol = "+"
    @State private var userAnswer = ""
    @State private var isCorrect: Bool? = nil
    @State private var showingColorFeedback = false
    @State private var showingIncorrectFeedback = false
    @State private var colorFeedbackDuration: Double = 0.25
    @State private var showTimer = false
    @State private var isTimerActive = false
    @State private var displayedTime: Double = 0
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var problemsSolvedDuringTimer = 0
    @State private var showSummaryBanner = false
    @State private var isSummaryExpanded = false
    @State private var currentProblem: Problem? = nil
    @State private var isPerfectAnswer: Bool = false
    @State private var isFirstAttempt: Bool = true
    @State private var hasCleared: Bool = false
    @State private var hasSubmittedIncorrectly: Bool = false
    @State private var isAnswerChecked = false
    @State private var lastCheckedAnswer = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "242329").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Progress Bar and Navigation Buttons
                    VStack(spacing: 0) {
                        // Progress Bar
                        ProgressBar(
                            progress: isTimerActive ? (displayedTime / Double(settingsManager.timerDuration)) : progressToNextLevel,
                            color: isTimerActive ? .green : .white
                        )
                        .frame(height: 8)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .animation(.linear(duration: 0.1), value: displayedTime) // Animate only the bar
                                                
                        
                        // Navigation and Level
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
                    .modifier(BelowNotchViewModifier())
                    .animation(.linear(duration: 0.1), value: displayedTime)
                    
                    Spacer()
                    
                    // Problem display
                    VStack(alignment: .trailing, spacing: 10) {
                        Text("\(currentProblem?.firstNumber ?? 0)")
                            .font(.system(size: 60, weight: .bold))
                        HStack(spacing: 20) {
                            Text(currentProblem?.operation ?? "+")
                                .font(.system(size: 60, weight: .bold))
                            Text("\(currentProblem?.secondNumber ?? 0)")
                                .font(.system(size: 60, weight: .bold))
                        }
                        ZStack(alignment: .trailing) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 4)
                            
                            if showingColorFeedback {
                                Rectangle()
                                    .fill(colorForAnswer())
                                    .frame(height: 4)
                            }
                        }
                        Text(showingIncorrectFeedback ? userAnswer : (userAnswer.isEmpty ? "?" : userAnswer))
                            .font(.system(size: 60, weight: .bold))
                            .frame(height: 70)
                    }
                    .foregroundColor(showingColorFeedback ? colorForAnswer() : .white)
                    .frame(width: min(geometry.size.width * 0.8, 300))
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Small row with timer button and new problem button
                    HStack {
                        Button(action: {
                            generateNewProblem()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 20))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if isTimerActive {
                                // Stop the timer
                                isTimerActive = false
                                remainingTime = settingsManager.timerDuration
                                displayedTime = Double(settingsManager.timerDuration)
                                // Cancel the timer
                                timer?.invalidate()
                                timer = nil
                            } else {
                                // Start the timer
                                isTimerActive = true
                                remainingTime = settingsManager.timerDuration // Reset to full duration
                                generateNewProblem()
                                displayedTime = Double(settingsManager.timerDuration)
                                startTimer()
                            }
                        }) {
                            Image(systemName: isTimerActive ? "timer.circle.fill" : "timer")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    
                    // Number pad
                    VStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(1...3, id: \.self) { column in
                                    AnimatedButton(
                                        title: "\((row - 1) * 3 + column)",
                                        action: {
                                            self.appendNumber((row - 1) * 3 + column)
                                        },
                                        width: (geometry.size.width - 32) / 3,
                                        height: 55,
                                        fontSize: 30
                                    )
                                }
                            }
                        }
                        HStack(spacing: 4) {
                            AnimatedButton(
                                title: "Clear",
                                action: {
                                    self.userAnswer = ""
                                    self.isCorrect = nil
                                    self.hasCleared = true
                                    self.isAnswerChecked = false
                                    self.lastCheckedAnswer = ""
                                    self.impactFeedback(.medium)
                                },
                                width: (UIScreen.main.bounds.width - 32) / 3,
                                height: 55,
                                topColor: Color(hex: "686060"),
                                bottomColor: Color(hex: "484040"),
                                textColor: .white,
                                fontSize: 24
                            )
                            AnimatedButton(
                                title: "0",
                                action: {
                                    self.appendNumber(0)
                                },
                                width: (geometry.size.width - 32) / 3,
                                height: 55,
                                fontSize: 30
                            )
                            AnimatedButton(
                                title: "Submit",
                                action: {
                                    self.checkAnswer(autoSubmit: false)
                                    self.impactFeedback(.medium)
                                },
                                width: (geometry.size.width - 32) / 3,
                                height: 55,
                                topColor: Color(hex: "FF9944"),
                                bottomColor: Color(hex: "BB6622"),
                                textColor: .white,
                                fontSize: 24
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.bottom, optimizedBottomPadding(for: geometry))
                
                // Overlay the TimerSummaryBanner
                if showSummaryBanner {
                    GeometryReader { geo in
                        VStack {
                            TimerSummaryBanner(
                                problemsSolved: problemsSolvedDuringTimer,
                                totalTime: settingsManager.timerDuration,  // Use the setting here
                                isExpanded: $isSummaryExpanded,
                                onDismiss: {
                                    withAnimation {
                                        self.showSummaryBanner = false
                                        self.isSummaryExpanded = false
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 120)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            
                            Spacer()
                        }
                    }
                    .zIndex(1) // Ensure it's above other content
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
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
        
        .onChange(of: settingsManager.operationTypes) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.additionMinNumber1) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.additionMaxNumber1) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.additionMinNumber2) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.additionMaxNumber2) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.multiplicationMinNumber1) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.multiplicationMaxNumber1) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.multiplicationMinNumber2) { _, _ in generateNewProblem() }
        .onChange(of: settingsManager.multiplicationMaxNumber2) { _, _ in generateNewProblem() }
    }
    
    private func optimizedBottomPadding(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        
        // Approximate position where the iPhone's curve begins
        let curveBeginRatio: CGFloat = 0.87
        
        let optimalPosition = screenHeight * curveBeginRatio
        let currentPosition = screenHeight - safeAreaBottom
        
        let additionalPadding = currentPosition - optimalPosition
        
        // Ensure we don't push the buttons too high
        return max(safeAreaBottom, min(additionalPadding, 40))
    }
    
    func generateNewProblem() {
        guard !settingsManager.operationTypes.isEmpty else {
            settingsManager.operationTypes = ["addition"]
            return
        }
        
        let operation = settingsManager.operationTypes.randomElement()!
        
        switch operation {
        case "addition":
            operationSymbol = "+"
            firstNumber = Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1)
            secondNumber = Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2)
            currentProblem = Problem(firstNumber: firstNumber, secondNumber: secondNumber, operation: operationSymbol)

        case "subtraction":
            operationSymbol = "-"
            let n1 = Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1)
            let n2 = Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2)
            firstNumber = n1 + n2
            secondNumber = n1
            currentProblem = Problem(firstNumber: firstNumber, secondNumber: secondNumber, operation: operationSymbol)

        case "multiplication":
            operationSymbol = "×"
            firstNumber = Int.random(in: settingsManager.multiplicationMinNumber1...settingsManager.multiplicationMaxNumber1)
            secondNumber = Int.random(in: settingsManager.multiplicationMinNumber2...settingsManager.multiplicationMaxNumber2)
            currentProblem = Problem(firstNumber: firstNumber, secondNumber: secondNumber, operation: operationSymbol)

        case "division":
            operationSymbol = "÷"
            let n1 = Int.random(in: settingsManager.multiplicationMinNumber1...settingsManager.multiplicationMaxNumber1)
            let n2 = Int.random(in: settingsManager.multiplicationMinNumber2...settingsManager.multiplicationMaxNumber2)
            firstNumber = n1 * n2
            secondNumber = n1
            currentProblem = Problem(firstNumber: firstNumber, secondNumber: secondNumber, operation: operationSymbol)

        default:
            operationSymbol = "+"
            firstNumber = Int.random(in: settingsManager.additionMinNumber1...settingsManager.additionMaxNumber1)
            secondNumber = Int.random(in: settingsManager.additionMinNumber2...settingsManager.additionMaxNumber2)
            currentProblem = Problem(firstNumber: firstNumber, secondNumber: secondNumber, operation: operationSymbol)
        }
        
        if settingsManager.preserveProblems {
            settingsManager.saveLastProblem(currentProblem)
        }
        
        resetProblemState()
    }
    
    func resetProblemState() {
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

    
    private func colorForAnswer() -> Color {
        guard let isCorrect = isCorrect else {
            return .white  // Default color when isCorrect is nil
        }
        if isCorrect && isPerfectAnswer {
            return .yellow  // Gold color for perfect answers
        }
        return isCorrect ? .green : .red
    }
    
    
    func checkAnswer(autoSubmit: Bool) {
        guard let problem = currentProblem else { return }
        
        if let answer = Int(userAnswer) {
            let correctAnswer = problem.correctAnswer
           
            isCorrect = (answer == correctAnswer)
           
            if isCorrect == true && userAnswer != lastCheckedAnswer {
                gameState.totalProblems += 1
                gameState.correctAnswers += 1
                if isTimerActive {
                    problemsSolvedDuringTimer += 1
                }
               
                // Check if it's a perfect answer
                isPerfectAnswer = !hasCleared && !hasSubmittedIncorrectly
               
                notificationFeedback(isPerfectAnswer ? .success : .warning)
               
                // Always generate a new problem on correct answer
                showColorFeedback(generateNewProblem: true)
                lastCheckedAnswer = userAnswer
            } else if isCorrect == false && (!settingsManager.automaticCorrect || !autoSubmit) {
                gameState.totalProblems += 1
                notificationFeedback(.error)
                hasSubmittedIncorrectly = true
               
                if settingsManager.generateNewOnIncorrect {
                    showingIncorrectFeedback = true
                    showColorFeedback(generateNewProblem: true)
                } else {
                    // Clear the input but keep the same problem
                    showColorFeedback(generateNewProblem: false)
                }
                lastCheckedAnswer = userAnswer
            }
            
            isAnswerChecked = isCorrect == true
        }
    }
    
    func showColorFeedback(generateNewProblem: Bool) {
        showingColorFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + colorFeedbackDuration) {
            self.showingColorFeedback = false
            self.showingIncorrectFeedback = false
            if generateNewProblem {
                self.generateNewProblem()
            } else {
                self.userAnswer = "" // Clear the input if the answer was incorrect
            }
            self.isAnswerChecked = false
            self.lastCheckedAnswer = ""
        }
    }
    
    
    func appendNumber(_ number: Int) {
        userAnswer += "\(number)"
        if settingsManager.automaticCorrect {
            self.checkAnswer(autoSubmit: true)
        }
    }
    
    func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
    }
    
    func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(type)
    }
    
    private var currentLevel: Int {
        level(for: gameState.correctAnswers)
    }
    
    private var progressToNextLevel: Double {
        let correctAnswers = gameState.correctAnswers
        let currentLevel = self.currentLevel
        let pointsForCurrentLevel = pointsForLevel(currentLevel)
        let pointsForNextLevel = pointsForLevel(currentLevel + 1)
        let currentProgress = correctAnswers - pointsForCurrentLevel
        let totalForNextLevel = pointsForNextLevel - pointsForCurrentLevel
        return Double(currentProgress) / Double(totalForNextLevel)
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
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    func startTimer() {
        timer?.invalidate() // Invalidate any existing timer
        displayedTime = Double(settingsManager.timerDuration)
        remainingTime = settingsManager.timerDuration
        problemsSolvedDuringTimer = 0 // Reset the counter
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.displayedTime -= 0.1
                self.remainingTime = Int(self.displayedTime)
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.isTimerActive = false
                self.remainingTime = self.settingsManager.timerDuration
                self.displayedTime = Double(self.settingsManager.timerDuration)
                
                // Show the summary banner
                withAnimation {
                    self.showSummaryBanner = true
                }
                
                // Hide the banner after 5 seconds if it's not expanded
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if !self.isSummaryExpanded {
                        withAnimation {
                            self.showSummaryBanner = false
                        }
                    }
                }
            }
        }
    }
}

struct BelowNotchViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding(.top, topInset)
        } else {
            content
                .padding(.top, topInset)
        }
    }
    
    private var topInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.top ?? 0
    }
}

struct ProgressBar: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: max(0, CGFloat(progress) * geometry.size.width), height: 8)
                    .foregroundColor(color)
            }
        }
    }
}

struct Problem: Codable {
    let firstNumber: Int
    let secondNumber: Int
    let operation: String
    
    var correctAnswer: Int {
        switch operation {
        case "+":
            return firstNumber + secondNumber
        case "-":
            return firstNumber - secondNumber
        case "×":
            return firstNumber * secondNumber
        case "÷":
            return firstNumber / secondNumber
        default:
            return 0
        }
    }
}

struct PracticePage_Previews: PreviewProvider {
    static var previews: some View {
        PracticePage(gameState: GameState(), settingsManager: AppSettingsManager(), selectedTab: .constant(1))
    }
}
