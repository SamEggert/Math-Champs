import SwiftUI

struct AnimatedButton: View {
    let title: String
    let action: () -> Void

    var width: CGFloat = 120
    var height: CGFloat = 60
    var cornerRadius: CGFloat = 8
    var topColor: Color = .white
    var bottomColor: Color = Color(hex: "AAA0A0")
    var textColor: Color = .black
    var fontSize: CGFloat = 40
    var shadowHeight: CGFloat = 6
    var pressedDuration: Double = 0.07

    @GestureState private var isPressed = false
    @State private var buttonPressed = false

    var body: some View {
        ZStack {
            // Bottom rectangle (shadow)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(bottomColor)
                .frame(width: width, height: height)
                .offset(y: shadowHeight)

            // Top rectangle
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(topColor)
                .frame(width: width, height: height)
                .offset(y: isPressed ? shadowHeight : 0)

            // Button text
            Text(title)
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .offset(y: isPressed ? shadowHeight : 0)
        }
        .frame(width: width, height: height + shadowHeight)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
                .onChanged { _ in
                    if !buttonPressed {
                        buttonPressed = true
                        hapticFeedback()
                    }
                }
                .onEnded { value in
                    buttonPressed = false
                    if value.translation.height > -height && value.translation.height < shadowHeight &&
                       value.translation.width > -width/2 && value.translation.width < width/2 {
                        action()
                    }
                }
        )
        .animation(.easeInOut(duration: pressedDuration), value: isPressed)
    }

    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// Add this extension to enable Color initialization from hex strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AnimatedButton_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedButton(title: "7") {
            print("Button pressed")
        }
    }
}
