# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shiot** is an iOS score-counting app for the card game Belot, built entirely in Swift with SwiftUI. The app supports 2, 3, and 4-player game modes with automatic score calculation and validation.

## Development Commands

### Build and Run
```bash
# Build the app
xcodebuild -project shiot.xcodeproj -scheme shiot -configuration Debug

# Build and run on simulator
xcodebuild -project shiot.xcodeproj -scheme shiot -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'

# Open in Xcode
open shiot.xcodeproj
```

### Testing
```bash
# Run all tests (if any exist)
xcodebuild -project shiot.xcodeproj -scheme shiot test

# Run tests on a specific simulator
xcodebuild -project shiot.xcodeproj -scheme shiot test -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Quality
- No formal linting setup currently exists
- SwiftUI Preview is available for component testing—use `#Preview` blocks in views
- Consider using `swift-format` for code formatting if added to the project

## Architecture & Code Organization

### High-Level Flow
1. **Entry Point** (`shiotApp.swift`): SwiftUI `@main` app with NavigationStack wrapping ContentView
2. **Game Mode Selection** (`ContentView.swift`): Main menu with buttons for 2, 3, 4-player modes and settings
3. **Game Setup** (`gamemodeSelect.swift`): Collects player names and game options (Bochika/Tiomka toggles)
4. **Game Views** (`PlayersView/`):
   - `TwoPlayerView.swift`: Two-player game interface
   - `ThreePlayerView.swift`: Three-player game interface
   - `FourPlayerView.swift`: Four-player game interface with notebook-style UI

### State Management & Models
- **FourPlayerLogic**: `ObservableObject` class managing game state for score tracking
  - `@Published` properties: `scores`, `currentTeam1ScoreInput`, `currentTeam2ScoreInput`, `currentRoundTotalInput`
  - Key methods: `saveCurrentRound()` (validates and persists scores), `resetInputs()`, `hideKeyboard()`
  - Calculated properties: `totalTeam1`, `totalTeam2` (reduce over scores array)
- **RoundScore**: `Identifiable` struct representing a single round with `team1Score`, `team2Score`, `roundTotal`
- Error handling uses alerts via `showingInputAlert` and `alertMessage` published properties

### UI Components & Organization
- **Notebook Aesthetic**: `NotebookBackground` (in FourPlayerView) provides paper-textured interface with hand-drawn lines and red margin line
- **Custom Views**:
  - `HandDrawnLine`: Canvas-based wavy line for notebook effect
  - `SettingsView`: User preferences
  - `InfoHelpView`: Game instructions
  - `TermsOfServiceView`: Legal information
- All views use `NavigationLink` for navigation within the NavigationStack

### Key Design Patterns
- **MVVM**: Views bind to `@StateObject` for observable logic classes
- **Validation**: Score input validation in `FourPlayerLogic.saveCurrentRound()` handles three input scenarios:
  1. Both team scores + round total (validates sum equals total)
  2. One team score + round total (calculates missing score)
  3. Full validation with Romanian language error messages
- **Assets**: Images stored in `Assets.xcassets` (paper backgrounds, scribble buttons)

## Important Implementation Notes

- Error messages are in **Romanian** (game is localized for Romanian speakers)
- Score calculation supports partial input (can provide one team's score and total, app calculates the other)
- SwiftUI previews use `NavigationStack` wrapper for testing views
- The 4-player button currently passes `numberOfPlayers: 2` (likely a bug to fix)

## Dependencies

- **iOS Deployment Target**: Check in project settings (likely iOS 15+)
- **Swift Version**: 5.9+ (uses latest SwiftUI features like NavigationStack)
- No external package dependencies (native SwiftUI only)
