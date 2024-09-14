import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var settingsManager = AppSettingsManager()
    @State private var selectedTab = 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "242329").edgesIgnoringSafeArea(.all)
                
                TabView(selection: $selectedTab) {
                    SettingsView(settingsManager: settingsManager)
                        .tag(0)
                    
                    PracticePage(gameState: gameState, settingsManager: settingsManager, selectedTab: $selectedTab)
                        .tag(1)
                    
                    StatsView(gameState: gameState)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            AppDelegate.orientationLock = .portrait
        }
        .environment(\.colorScheme, .dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
