# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shiot** is an iOS Belot game score counter app, built entirely in Swift with SwiftUI. The app helps players track scores from tabletop Belot card games across 2, 3, and 4-player formats. It implements all official Belot scoring rules and combination detection, automatically calculating bile (game points) to determine winners.

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
# Run all tests
xcodebuild -project shiot.xcodeproj -scheme shiot test

# Run tests on a specific simulator
xcodebuild -project shiot.xcodeproj -scheme shiot test -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture & Code Organization

### Core Score Tracking (`Models/`)

#### ScoreKeeperModels.swift
**Data structures for score management:**

- **RoundScoreEntry**: Represents a single round's scores and combinations
  - `playerScores`: Points from tricks for each player
  - `combinations`: Combinations claimed in the round
  - `totalScores`: Calculated total including combinations

- **Combination**: Represents a detected combination
  - `name`: Combination name (e.g., "Bela", "Tărcă")
  - `points`: Points value (20, 50, 100, 150, 200, etc.)

- **ScorekeeperPlayer**: Game participant tracking
  - `roundScores`: Array of scores for each completed round
  - `roundCombinations`: Array of combinations per round
  - `totalBile`: Cumulative bile (game points)
  - Calculated properties: `totalPoints`, `roundDetails`

- **GameSession**: Main score tracking engine
  - Score management (add/remove scores and combinations)
  - Bile calculation for all game formats (2, 3, 4 player)
  - Win condition checking with automatic escalation (51→101→151)
  - Round management and game reset

### UI Layer (`PlayersView/`)

**Score Counter Views (specific to player count):**
- `TwoPlayerScoreView.swift`: 2-player (1v1) score counter
- `ThreePlayerScoreView.swift`: 3-player score counter with special algorithm
- `FourPlayerScoreView.swift`: 4-player (2v2 teams) score counter

**Shared Components (in views):**
- `PlayerScoreInputCard`: Input field for trick points + combination management
- `CombinationPickerView`: Selection interface for all Belot combinations
- `ScoreSummaryView`: Leaderboard display with running totals
- `gamemodeSelect.swift`: Player setup (names, game mode selection)
- `ContentView.swift`: Main menu with player count selection

### Design System (`Utils/`)

**NotebookTheme.swift:**
- `NotebookBackgroundView`: Paper-textured background with ruled lines and margin
- `NotebookCardView`: Consistent card styling
- `HandwrittenButton`: Hand-drawn style buttons with rotation
- `NotebookCardDisplay`: Enhanced card presentation
- `NotebookTitle`: Styled title component
- `NotebookDivider`: Decorative separators
- Custom animations (CardFlip, SlideIn, Pulse)

**ViewUtilities.swift:**
- Helper extensions for views
- Custom button styling

## Game Rules Implementation

### Card Values (Points)
| Card | Base Points |
|------|-------------|
| 7, 8, 9 | 0 |
| 10 | 10 |
| Jack | 2 |
| Queen | 3 |
| King | 4 |
| Ace | 11 |

*Note: Trump point values are input by users (J of trump = 20, 9 of trump = 14)*

### Supported Combinations

**Sequences (by suit):**
- Tărcă (2-card sequence): 20 points
- Sută (3-card sequence): 50 points  
- Jumătate (4-card sequence): 100 points
- Două sute (5-card sequence): 200 points

**Special Combinations:**
- Bela (Q+K of trump): 20 points
- Four Sevens: 0 points (cancels round)
- Four Eights: 100 points (cancels opponent combinations)
- Four Nines: 150 points
- Four Jacks: 200 points
- Four Tens/Queens/Kings/Aces: 100 points

### Bile Calculation

**2-Player (1v1):** 
- Each player: (total points) / 10 = bile

**4-Player (2v2 Teams):**
- Each team: (team total points) / 10 = bile
- Bile distributed to both team members

**3-Player (Special Algorithm):**
- Non-leading players: (their points) / 10 = bile
- Leading player: total bile - (other two players' bile) = bile
- Handles special cases for equal bile counts

### Win Condition
- First player/team to 51+ bile wins
- If multiple players exceed threshold, escalates to 101, 151, etc.

## Key Features

✅ **Complete Rule Set**
- All official Belot combinations
- Proper point calculations
- Special rules (4-of-a-kind handling)
- Score escalation for ties

✅ **Multiple Game Formats**
- 2-player (1v1) 
- 3-player (with special bile algorithm)
- 4-player (2v2 teams)

✅ **Beautiful UI**
- Notebook-themed design
- Smooth animations
- Clear score displays
- Leaderboard tracking

✅ **Score Management**
- Add/remove round scores
- Track combinations per round
- Automatic bile calculation
- Game history

## File Structure

```
shiot/
├── shiotApp.swift              # Entry point
├── Models/
│   └── ScoreKeeperModels.swift # All game models and logic
├── PlayersView/
│   ├── ContentView.swift       # Main menu
│   ├── gamemodeSelect.swift    # Player setup
│   ├── TwoPlayerScoreView.swift    # 2-player counter
│   ├── ThreePlayerScoreView.swift  # 3-player counter
│   ├── FourPlayerScoreView.swift   # 4-player counter
│   └── SettingsView.swift      # Settings
├── Utils/
│   ├── NotebookTheme.swift     # UI design system
│   └── ViewUtilities.swift     # Helper extensions
└── Assets.xcassets/            # Images and resources
```

## Dependencies

- **iOS Deployment Target**: iOS 15+
- **Swift Version**: 5.9+
- **SwiftUI**: Latest (NavigationStack, Canvas for custom drawing)
- **No external dependencies** - pure native Swift/SwiftUI

## Important Notes

- **Language**: Game/score messages in English, with support for Romanian terminology
- **State Management**: Uses `@StateObject` and `@ObservedObject` with MVVM pattern
- **Score Input**: Players manually enter points from their physical Belot game
- **Combination Selection**: UI provides all official combinations for quick selection
- **Automatic Calculations**: Bile calculated automatically per official rules
- **Game Persistence**: Currently resets when app closes (can be enhanced with UserDefaults/CoreData)