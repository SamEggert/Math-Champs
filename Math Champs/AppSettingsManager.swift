import SwiftUI

class AppSettingsManager: ObservableObject {
    @AppStorage("additionMinNumber1") var additionMinNumber1 = 2
    @AppStorage("additionMaxNumber1") var additionMaxNumber1 = 100
    @AppStorage("additionMinNumber2") var additionMinNumber2 = 2
    @AppStorage("additionMaxNumber2") var additionMaxNumber2 = 100

    @AppStorage("multiplicationMinNumber1") var multiplicationMinNumber1 = 2
    @AppStorage("multiplicationMaxNumber1") var multiplicationMaxNumber1 = 12
    @AppStorage("multiplicationMinNumber2") var multiplicationMinNumber2 = 2
    @AppStorage("multiplicationMaxNumber2") var multiplicationMaxNumber2 = 12

    @AppStorage("generateNewOnIncorrect") var generateNewOnIncorrect = false
    @AppStorage("automaticCorrect") var automaticCorrect = false
    @AppStorage("preserveProblems") var preserveProblems = true
    @AppStorage("perfectAnimationEnabled") var perfectAnimationEnabled = true
    @AppStorage("lastProblem") private var lastProblemData: Data?
    @Published var operationTypes: Set<String> = ["addition", "subtraction", "multiplication", "division"]
    @AppStorage("timerDuration") var timerDuration: Int = 60 // Default 1 minute

    init() {
        if let savedOperations = UserDefaults.standard.array(forKey: "operationTypes") as? [String] {
            operationTypes = Set(savedOperations)
        } else {
            // If no saved operations, set all operations as active
            operationTypes = ["addition", "subtraction", "multiplication", "division"]
            saveOperationTypes()
        }
    }

    func toggleOperation(_ operation: String) {
        if operationTypes.contains(operation) {
            if operationTypes.count > 1 {
                operationTypes.remove(operation)
            }
        } else {
            operationTypes.insert(operation)
        }
        saveOperationTypes()
    }

    private func saveOperationTypes() {
        UserDefaults.standard.set(Array(operationTypes), forKey: "operationTypes")
    }

    func getLastProblem() -> Problem? {
        guard let data = lastProblemData else { return nil }
        return try? JSONDecoder().decode(Problem.self, from: data)
    }

    func saveLastProblem(_ problem: Problem?) {
        if let problem = problem,
           let encoded = try? JSONEncoder().encode(problem) {
            lastProblemData = encoded
        } else {
            lastProblemData = nil
        }
    }

    func setTimerDuration(_ seconds: Int) {
        timerDuration = max(1, seconds)
    }

    func resetToDefaults() {
        additionMinNumber1 = 2
        additionMaxNumber1 = 100
        additionMinNumber2 = 2
        additionMaxNumber2 = 100
        multiplicationMinNumber1 = 2
        multiplicationMaxNumber1 = 12
        multiplicationMinNumber2 = 2
        multiplicationMaxNumber2 = 12
        generateNewOnIncorrect = false
        automaticCorrect = false
        preserveProblems = true
        perfectAnimationEnabled = true
        operationTypes = ["addition", "subtraction", "multiplication", "division"]
        timerDuration = 60 // Reset to 1 minute
        saveOperationTypes()
    }
}

struct Problem: Codable, Equatable {
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