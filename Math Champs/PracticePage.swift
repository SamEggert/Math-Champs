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
    @State private var colorFeedbackDuration: Double = 0.25
    @State private var showTimer = false
    @State private var isTimerActive = false
    @State private var displayedTime: Double = 120
    @State private var timerDuration: Int = 120
    @State private var remainingTime: Int = 120
    @State private var timer: Timer?
    @State private var problemsSolvedDuringTimer = 0


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "242329").edgesIgnoringSafeArea(.all)
               
                VStack(spacing: 0) {
                    // Progress Bar and Navigation Buttons
                    VStack(spacing: 0) {
                        // Progress Bar
                        ProgressBar(
                            progress: isTimerActive ? (displayedTime / Double(timerDuration)) : progressToNextLevel,
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
                        Text("\(firstNumber)")
                            .font(.system(size: 60, weight: .bold))
                        HStack(spacing: 20) {
                            Text(operationSymbol)
                                .font(.system(size: 60, weight: .bold))
                            Text("\(secondNumber)")
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
                        Text(userAnswer.isEmpty ? "?" : userAnswer)
                            .font(.system(size: 60, weight: .bold))
                            .frame(height: 70)
                    }
                    .foregroundColor(showingColorFeedback ? colorForAnswer() : .white)
                    .frame(width: min(geometry.size.width * 0.8, 300))
                    .padding(.top, 20)
                    
                    
                    Spacer()
                
                    // Small row with timer button
                    HStack {
                        Button(action: {
                            // Action for problem counter (to be implemented)
                        }) {
                            Image(systemName: "123.rectangle")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 20))
                        }
                        Spacer()
                        Button(action: {
                            if isTimerActive {
                                // Stop the timer
                                isTimerActive = false
                                remainingTime = timerDuration
                                displayedTime = Double(timerDuration)
                                // Cancel the timer
                                timer?.invalidate()
                                timer = nil
                            } else {
                                // Start the timer
                                isTimerActive = true
                                remainingTime = timerDuration // Reset to full duration
                                displayedTime = Double(timerDuration)
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
                                        action: { self.appendNumber((row - 1) * 3 + column) },
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
                                    self.impactFeedback(.medium)
                                },
                                width: (geometry.size.width - 32) / 3,
                                height: 55,
                                topColor: Color(hex: "686060"),
                                bottomColor: Color(hex: "484040"),
                                textColor: .white,
                                fontSize: 24
                            )
                            AnimatedButton(
                                title: "0",
                                action: { self.appendNumber(0) },
                                width: (geometry.size.width - 32) / 3,
                                height: 55,
                                fontSize: 30
                            )
                            AnimatedButton(
                                title: "Submit",
                                action: {
                                    self.checkAnswer()
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
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: generateNewProblem)
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
        
        // Ensure min values are always less than or equal to max values
        let additionMin1 = min(settingsManager.additionMinNumber1, settingsManager.additionMaxNumber1)
        let additionMax1 = max(settingsManager.additionMinNumber1, settingsManager.additionMaxNumber1)
        let additionMin2 = min(settingsManager.additionMinNumber2, settingsManager.additionMaxNumber2)
        let additionMax2 = max(settingsManager.additionMinNumber2, settingsManager.additionMaxNumber2)
        let multiplicationMin1 = min(settingsManager.multiplicationMinNumber1, settingsManager.multiplicationMaxNumber1)
        let multiplicationMax1 = max(settingsManager.multiplicationMinNumber1, settingsManager.multiplicationMaxNumber1)
        let multiplicationMin2 = min(settingsManager.multiplicationMinNumber2, settingsManager.multiplicationMaxNumber2)
        let multiplicationMax2 = max(settingsManager.multiplicationMinNumber2, settingsManager.multiplicationMaxNumber2)
        
        switch operation {
        case "addition":
            operationSymbol = "+"
            firstNumber = Int.random(in: additionMin1...additionMax1)
            secondNumber = Int.random(in: additionMin2...additionMax2)
        case "subtraction":
            operationSymbol = "-"
            secondNumber = Int.random(in: additionMin1...additionMax1)
            let answer = Int.random(in: additionMin2...additionMax2)
            firstNumber = secondNumber + answer
            
        case "multiplication":
            operationSymbol = "×"
            firstNumber = Int.random(in: multiplicationMin1...multiplicationMax1)
            secondNumber = Int.random(in: multiplicationMin2...multiplicationMax2)
        case "division":
            operationSymbol = "÷"
            secondNumber = Int.random(in: max(1, multiplicationMin1)...multiplicationMax1)
            let answer = Int.random(in: max(1, multiplicationMin2)...multiplicationMax2)
            firstNumber = secondNumber * answer
        default:
            operationSymbol = "+"
            firstNumber = Int.random(in: additionMin1...additionMax1)
            secondNumber = Int.random(in: additionMin2...additionMax2)
        }
        
        userAnswer = ""
        isCorrect = nil
    }
    
    private func colorForAnswer() -> Color {
        guard let isCorrect = isCorrect else {
            return .white  // Default color when isCorrect is nil
        }
        return isCorrect ? .green : .red
    }
    
    func checkAnswer() {
        if let answer = Int(userAnswer) {
            let correctAnswer: Int
            switch operationSymbol {
            case "+":
                correctAnswer = firstNumber + secondNumber
            case "-":
                correctAnswer = firstNumber - secondNumber
            case "×":
                correctAnswer = firstNumber * secondNumber
            case "÷":
                correctAnswer = firstNumber / secondNumber
            default:
                correctAnswer = 0
            }
            
            isCorrect = (answer == correctAnswer)
                    gameState.totalProblems += 1
                    if isCorrect == true {
                        gameState.correctAnswers += 1
                        if isTimerActive {
                            problemsSolvedDuringTimer += 1
                        }
                        notificationFeedback(.success)
                    } else {
                        notificationFeedback(.error)
                    }
            
            showColorFeedback()
        }
    }
        
    func showColorFeedback() {
        showingColorFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + colorFeedbackDuration) {
            self.showingColorFeedback = false
            if self.isCorrect == true {
                self.generateNewProblem()
            } else {
                self.userAnswer = "" // Clear the input if the answer was incorrect
            }
        }
    }
    
    func appendNumber(_ number: Int) {
        userAnswer += "\(number)"
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
        displayedTime = Double(timerDuration)
        remainingTime = timerDuration
        problemsSolvedDuringTimer = 0 // Reset the counter
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.displayedTime -= 0.1
                self.remainingTime = Int(self.displayedTime)
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.isTimerActive = false
                self.remainingTime = self.timerDuration
                self.displayedTime = Double(self.timerDuration)
                // Show summary or handle timer completion
                print("Time's up! Problems solved: \(self.problemsSolvedDuringTimer)")
                self.problemsSolvedDuringTimer = 0 // Reset the counter
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

struct PracticePage_Previews: PreviewProvider {
    static var previews: some View {
        PracticePage(gameState: GameState(), settingsManager: AppSettingsManager(), selectedTab: .constant(1))
    }
}
