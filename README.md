# Math Champs iOS App

A SwiftUI-based educational app for practicing mental math calculations through interactive exercises and timed challenges.

## Project Overview

The main application code is located in the `/Math Champs/Math Champs/` directory. Here are the key files:

### Core Features
- `PracticePage.swift` - Main practice interface where users solve math problems
- `PracticePageViewModel.swift` - Business logic for the practice interface
- `AppSettingsManager.swift` - Settings and configuration management

### UI Components
- `ProblemDisplayView.swift` - Displays the current math problem
- `NumberPadView.swift` - Custom numeric keypad for input
- `AnimatedButton.swift` - Reusable animated button component
- `TimerSummaryBanner.swift` - Shows results after timed sessions

### Views
- `ContentView.swift` - Root view and navigation setup
- `SettingsView.swift` - User preferences and difficulty settings
- `StatsView.swift` - Progress tracking and statistics

## Technology Stack
- SwiftUI
- Combine
- SwiftUI Shimmer for animations
- Native iOS haptics
- UserDefaults for persistence

## Getting Started

1. Clone the repository
2. Open `Math Champs.xcodeproj` in Xcode
3. Build and run the project (requires Xcode 14+ and iOS 16.6+)

## Contact

If you have any questions about the implementation or architecture decisions, please feel free to reach out.