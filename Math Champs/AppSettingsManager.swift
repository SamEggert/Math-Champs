import SwiftUI

class AppSettingsManager: ObservableObject {
    @AppStorage("additionMinNumber1") var additionMinNumber1 = 2
    @AppStorage("additionMaxNumber1") var additionMaxNumber1 = 100
    @AppStorage("additionMinNumber2") var additionMinNumber2 = 2
    @AppStorage("additionMaxNumber2") var additionMaxNumber2 = 100
    @AppStorage("multiplicationMinNumber1") var multiplicationMinNumber1 = 2
    @AppStorage("multiplicationMaxNumber1") var multiplicationMaxNumber1 = 12
    @AppStorage("multiplicationMinNumber2") var multiplicationMinNumber2 = 2
    @AppStorage("multiplicationMaxNumber2") var multiplicationMaxNumber2 = 100
    @Published var operationTypes: Set<String> = ["addition", "subtraction", "multiplication", "division"]
    
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
}
