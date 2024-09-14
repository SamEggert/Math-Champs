import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: AppSettingsManager
    
    var body: some View {
        Form {
            Section(header: Text("Operations").foregroundColor(.white)) {
                Toggle("Addition", isOn: binding(for: "addition"))
                Toggle("Subtraction", isOn: binding(for: "subtraction"))
                Toggle("Multiplication", isOn: binding(for: "multiplication"))
                Toggle("Division", isOn: binding(for: "division"))
            }
            
            Section(header: Text("Addition Range").foregroundColor(.white)) {
                StepperRow(title: "Min 1:", value: $settingsManager.additionMinNumber1, range: 1...998)
                StepperRow(title: "Max 1:", value: $settingsManager.additionMaxNumber1, range: (settingsManager.additionMinNumber1 + 1)...999)
                StepperRow(title: "Min 2:", value: $settingsManager.additionMinNumber2, range: 1...998)
                StepperRow(title: "Max 2:", value: $settingsManager.additionMaxNumber2, range: (settingsManager.additionMinNumber2 + 1)...999)
            }
            
            Section(header: Text("Multiplication Range").foregroundColor(.white)) {
                StepperRow(title: "Min 1:", value: $settingsManager.multiplicationMinNumber1, range: 2...999)
                StepperRow(title: "Max 1:", value: $settingsManager.multiplicationMaxNumber1, range: (settingsManager.multiplicationMinNumber1 + 1)...999)
                StepperRow(title: "Min 2:", value: $settingsManager.multiplicationMinNumber2, range: 2...999)
                StepperRow(title: "Max 2:", value: $settingsManager.multiplicationMaxNumber2, range: (settingsManager.multiplicationMinNumber2 + 1)...999)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: "242329"))
    }
    
    private func binding(for operation: String) -> Binding<Bool> {
        Binding(
            get: { self.settingsManager.operationTypes.contains(operation) },
            set: { _ in self.settingsManager.toggleOperation(operation) }
        )
    }
}

struct StepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text("\(value)")
                .foregroundColor(.white)
            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsManager: AppSettingsManager())
            .preferredColorScheme(.dark)
            .background(Color(hex: "242329"))
    }
}
