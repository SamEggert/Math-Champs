import SwiftUI

struct CustomTicker: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    @State private var isDecrementing = false
    @State private var isIncrementing = false
    @State private var timer: Timer?
    @State private var showKeyboard = false
    
    private let buttonWidth: CGFloat = 60
    private let buttonHeight: CGFloat = 60
    private let cornerRadius: CGFloat = 15
    private let shadowHeight: CGFloat = 4
    
    var body: some View {
        HStack(spacing: 1) {
            tickerButton("-") {
                decrement()
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isDecrementing {
                            isDecrementing = true
                            startDecrementTimer()
                        }
                    }
                    .onEnded { _ in
                        isDecrementing = false
                        timer?.invalidate()
                    }
            )
            
            numberDisplay
            
            tickerButton("+") {
                increment()
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isIncrementing {
                            isIncrementing = true
                            startIncrementTimer()
                        }
                    }
                    .onEnded { _ in
                        isIncrementing = false
                        timer?.invalidate()
                    }
            )
        }
        .background(Color.black.opacity(0.1))
        .cornerRadius(cornerRadius)
        .sheet(isPresented: $showKeyboard) {
            NumberKeyboard(value: $value, range: range)
        }
    }
    
    private var numberDisplay: some View {
        Button(action: {
            showKeyboard = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: buttonWidth, height: buttonHeight)
                    .offset(y: shadowHeight)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .frame(width: buttonWidth, height: buttonHeight)
                
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .frame(width: buttonWidth, height: buttonHeight + shadowHeight)
    }
    
    private func tickerButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: buttonWidth, height: buttonHeight)
                    .offset(y: shadowHeight)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .offset(y: (title == "-" && isDecrementing) || (title == "+" && isIncrementing) ? shadowHeight : 0)
                
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .offset(y: (title == "-" && isDecrementing) || (title == "+" && isIncrementing) ? shadowHeight : 0)
            }
        }
        .frame(width: buttonWidth, height: buttonHeight + shadowHeight)
    }
    
    private func increment() {
        value = min(value + step, range.upperBound)
    }
    
    private func decrement() {
        value = max(value - step, range.lowerBound)
    }
    
    private func startIncrementTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            increment()
        }
    }
    
    private func startDecrementTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            decrement()
        }
    }
}

struct NumberKeyboard: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    @State private var input = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Enter a number")
                .font(.headline)
            
            TextField("", text: $input)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Done") {
                if let newValue = Int(input), range.contains(newValue) {
                    value = newValue
                }
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .onAppear {
            input = "\(value)"
        }
    }
}

struct CustomTicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomTicker(value: .constant(50), range: 0...100, step: 1)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
