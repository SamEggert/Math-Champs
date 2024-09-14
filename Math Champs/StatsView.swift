import SwiftUI

struct StatsView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 10) {
                StatRow(label: "Total Problems", value: "\(gameState.totalProblems)")
                StatRow(label: "Correct Answers", value: "\(gameState.correctAnswers)")
                StatRow(label: "Accuracy", value: "\(accuracy)%")
                StatRow(label: "Level", value: "\(currentLevel)")
                StatRow(label: "Points for Next Level", value: "\(pointsForLevel(currentLevel + 1) - gameState.totalProblems)")
            }
            .font(.title2)
            
            Button("Reset Stats") {
                gameState.resetStats()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .environment(\.colorScheme, .dark)
    }
    
    private var accuracy: Int {
        guard gameState.totalProblems > 0 else { return 0 }
        return Int((Double(gameState.correctAnswers) / Double(gameState.totalProblems)) * 100)
    }
    
    private var currentLevel: Int {
        var level = 1
        while gameState.totalProblems >= pointsForLevel(level + 1) {
            level += 1
        }
        return level
    }
    
    private func pointsForLevel(_ level: Int) -> Int {
        return level * level * 5
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(gameState: GameState())
            .preferredColorScheme(.dark)
    }
}
