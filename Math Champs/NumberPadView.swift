import SwiftUI

struct NumberPadView: View {
    let appendNumber: (Int) -> Void
    let clearAction: () -> Void
    let submitAction: () -> Void
    let geometry: GeometryProxy

    var body: some View {
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
                    action: clearAction,
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
                    action: submitAction,
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
}