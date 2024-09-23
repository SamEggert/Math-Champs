import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: AppSettingsManager
    @State private var isDifficultiesExpanded = false
    @State private var isExtrasExpanded = false

    let presetDurations = [15, 30, 60, 120, 300] // in seconds

    var body: some View {
        Form {
            Section(header: Text("Operations").foregroundColor(.white)) {
                Toggle("Addition", isOn: binding(for: "addition"))
                Toggle("Subtraction", isOn: binding(for: "subtraction"))
                Toggle("Multiplication", isOn: binding(for: "multiplication"))
                Toggle("Division", isOn: binding(for: "division"))
            }

            Section(header: Text("Addition Range").foregroundColor(.white)) {
                StepperRow(title: "Min 1:", value: $settingsManager.additionMinNumber1, range: 1...99998)
                StepperRow(title: "Max 1:", value: $settingsManager.additionMaxNumber1, range: (settingsManager.additionMinNumber1 + 1)...99999)
                StepperRow(title: "Min 2:", value: $settingsManager.additionMinNumber2, range: 1...99998)
                StepperRow(title: "Max 2:", value: $settingsManager.additionMaxNumber2, range: (settingsManager.additionMinNumber2 + 1)...99999)
            }

            Section(header: Text("Multiplication Range").foregroundColor(.white)) {
                StepperRow(title: "Min 1:", value: $settingsManager.multiplicationMinNumber1, range: 2...998)
                StepperRow(title: "Max 1:", value: $settingsManager.multiplicationMaxNumber1, range: (settingsManager.multiplicationMinNumber1 + 1)...999)
                StepperRow(title: "Min 2:", value: $settingsManager.multiplicationMinNumber2, range: 2...998)
                StepperRow(title: "Max 2:", value: $settingsManager.multiplicationMaxNumber2, range: (settingsManager.multiplicationMinNumber2 + 1)...999)
            }

            Section(header: Text("Timer Duration").foregroundColor(.white)) {
                Picker("Duration", selection: $settingsManager.timerDuration) {
                    ForEach(presetDurations, id: \.self) { duration in
                        Text(formatDuration(duration))
                            .tag(duration)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section(header: Text("Presets").foregroundColor(.white)) {
                DisclosureGroup(
                    isExpanded: $isDifficultiesExpanded,
                    content: {
                        Button("Easy") {
                            applyEasyPreset()
                        }
                        .padding(.vertical, 5)

                        Button("Medium") {
                            applyMediumPreset()
                        }
                        .padding(.vertical, 5)

                        Button("Hard") {
                            applyHardPreset()
                        }
                        .padding(.vertical, 5)

                        Button("Expert") {
                            applyExpertPreset()
                        }
                        .padding(.vertical, 5)
                    },
                    label: {
                        Text("Difficulties")
                            .foregroundColor(.white)
                    }
                )

                DisclosureGroup(
                    isExpanded: $isExtrasExpanded,
                    content: {
                        Button("Zetamac") {
                            applyZetamacPreset()
                        }
                        .padding(.vertical, 5)

                        Button("2 Digit Multiplication") {
                            applyTwoDigitMultiplicationPreset()
                        }
                        .padding(.vertical, 5)

                        Button("Long Addition") {
                            applyLongAdditionPreset()
                        }
                        .padding(.vertical, 5)

                        Button("Max") {
                            applyMaxPreset()
                        }
                        .padding(.vertical, 5)
                    },
                    label: {
                        Text("Extras")
                            .foregroundColor(.white)
                    }
                )
            }

            Section(header: Text("Problem Behavior").foregroundColor(.white)) {
                Toggle("Generate new problems on incorrect answers", isOn: $settingsManager.generateNewOnIncorrect)
                Toggle("Automatically Detect Correct Answers", isOn: $settingsManager.automaticCorrect)
                Toggle("Preserve problems between sessions", isOn: $settingsManager.preserveProblems)
                Toggle("Perfect Animation Effect", isOn: $settingsManager.perfectAnimationEnabled)
            }

            Section {
                Button(action: {
                    settingsManager.resetToDefaults()
                }) {
                    Text("Reset to Default Settings")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
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

    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) seconds"
        } else {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
    }


    private func applyEasyPreset() {
        settingsManager.additionMinNumber1 = 1
        settingsManager.additionMaxNumber1 = 12
        settingsManager.additionMinNumber2 = 1
        settingsManager.additionMaxNumber2 = 12
        settingsManager.operationTypes = ["addition", "subtraction"]
    }

    private func applyMediumPreset() {
        settingsManager.additionMinNumber1 = 1
        settingsManager.additionMaxNumber1 = 9
        settingsManager.additionMinNumber2 = 10
        settingsManager.additionMaxNumber2 = 99
        settingsManager.multiplicationMinNumber1 = 2
        settingsManager.multiplicationMaxNumber1 = 9
        settingsManager.multiplicationMinNumber2 = 2
        settingsManager.multiplicationMaxNumber2 = 9
        settingsManager.operationTypes = ["addition", "subtraction", "multiplication", "division"]
    }

    private func applyHardPreset() {
        settingsManager.additionMinNumber1 = 10
        settingsManager.additionMaxNumber1 = 99
        settingsManager.additionMinNumber2 = 10
        settingsManager.additionMaxNumber2 = 99
        settingsManager.multiplicationMinNumber1 = 2
        settingsManager.multiplicationMaxNumber1 = 9
        settingsManager.multiplicationMinNumber2 = 10
        settingsManager.multiplicationMaxNumber2 = 99
        settingsManager.operationTypes = ["addition", "subtraction", "multiplication", "division"]
    }

    private func applyExpertPreset() {
        settingsManager.additionMinNumber1 = 100
        settingsManager.additionMaxNumber1 = 999
        settingsManager.additionMinNumber2 = 100
        settingsManager.additionMaxNumber2 = 999
        settingsManager.multiplicationMinNumber1 = 10
        settingsManager.multiplicationMaxNumber1 = 99
        settingsManager.multiplicationMinNumber2 = 10
        settingsManager.multiplicationMaxNumber2 = 99
        settingsManager.operationTypes = ["addition", "subtraction", "multiplication", "division"]
    }

    private func applyZetamacPreset() {
        settingsManager.timerDuration = 120
        settingsManager.additionMinNumber1 = 1
        settingsManager.additionMaxNumber1 = 99
        settingsManager.additionMinNumber2 = 1
        settingsManager.additionMaxNumber2 = 99
        settingsManager.multiplicationMinNumber1 = 2
        settingsManager.multiplicationMaxNumber1 = 12
        settingsManager.multiplicationMinNumber2 = 2
        settingsManager.multiplicationMaxNumber2 = 12
        settingsManager.operationTypes = ["addition", "subtraction", "multiplication", "division"]
    }

    private func applyTwoDigitMultiplicationPreset() {
        settingsManager.multiplicationMinNumber1 = 11
        settingsManager.multiplicationMaxNumber1 = 99
        settingsManager.multiplicationMinNumber2 = 11
        settingsManager.multiplicationMaxNumber2 = 99
        settingsManager.operationTypes = ["multiplication"]
    }

    private func applyLongAdditionPreset() {
        settingsManager.additionMinNumber1 = 1000
        settingsManager.additionMaxNumber1 = 9999
        settingsManager.additionMinNumber2 = 1000
        settingsManager.additionMaxNumber2 = 9999
        settingsManager.operationTypes = ["addition"]
    }

    private func applyMaxPreset() {
        settingsManager.additionMinNumber1 = 2
        settingsManager.additionMaxNumber1 = 99999
        settingsManager.additionMinNumber2 = 2
        settingsManager.additionMaxNumber2 = 99999
        settingsManager.multiplicationMinNumber1 = 2
        settingsManager.multiplicationMaxNumber1 = 999
        settingsManager.multiplicationMinNumber2 = 2
        settingsManager.multiplicationMaxNumber2 = 999
        settingsManager.operationTypes = ["addition", "subtraction", "multiplication", "division"]
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
