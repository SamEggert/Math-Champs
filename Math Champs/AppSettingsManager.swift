import SwiftUI

class AppSettingsManager: ObservableObject {
    @AppStorage("additionMinNumber1") var additionMinNumber1 = 2
    @AppStorage("additionMaxNumber1") var additionMaxNumber1 = 100
    @AppStorage("additionMinNumber2") var additionMinNumber2 = 2
    @AppStorage("additionMaxNumber2") var additionMaxNumber2 = 100
    
    @AppStorage("subtractionMinNumber1") var subtractionMinNumber1 = 2
    @AppStorage("subtractionMaxNumber1") var subtractionMaxNumber1 = 100
    @AppStorage("subtractionMinNumber2") var subtractionMinNumber2 = 2
    @AppStorage("subtractionMaxNumber2") var subtractionMaxNumber2 = 100
    
    @AppStorage("multiplicationMinNumber1") var multiplicationMinNumber1 = 2
    @AppStorage("multiplicationMaxNumber1") var multiplicationMaxNumber1 = 12
    @AppStorage("multiplicationMinNumber2") var multiplicationMinNumber2 = 2
    @AppStorage("multiplicationMaxNumber2") var multiplicationMaxNumber2 = 12
    
    @AppStorage("divisionMinNumber1") var divisionMinNumber1 = 2
    @AppStorage("divisionMaxNumber1") var divisionMaxNumber1 = 100
    @AppStorage("divisionMinNumber2") var divisionMinNumber2 = 2
    @AppStorage("divisionMaxNumber2") var divisionMaxNumber2 = 12
    
    @AppStorage("generateNewOnIncorrect") var generateNewOnIncorrect = false
    @AppStorage("automaticCorrect") var automaticCorrect = false
    @AppStorage("preserveProblems") var preserveProblems = true
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
        subtractionMinNumber1 = 2
        subtractionMaxNumber1 = 100
        subtractionMinNumber2 = 2
        subtractionMaxNumber2 = 100
        multiplicationMinNumber1 = 2
        multiplicationMaxNumber1 = 12
        multiplicationMinNumber2 = 2
        multiplicationMaxNumber2 = 12
        divisionMinNumber1 = 2
        divisionMaxNumber1 = 100
        divisionMinNumber2 = 2
        divisionMaxNumber2 = 12
        generateNewOnIncorrect = false
        preserveProblems = true
        operationTypes = ["addition", "subtraction", "multiplication", "division"]
        timerDuration = 60 // Reset to 1 minute
        saveOperationTypes()
    }
}
