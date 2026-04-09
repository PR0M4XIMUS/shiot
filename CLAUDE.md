# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Shiot** is a complete iOS implementation of the Belot card game, built entirely in Swift with SwiftUI. The app supports 2, 3, and 4-player game modes with full rule implementation, automatic scoring, combination detection, and the "bile" points system.

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

### Core Game Logic (`Models/`)

#### BelotModels.swift
**Data structures for the complete Belot game:**

- **Card & Suit**: Represents playing cards with point calculations
  - `basePoints()`: Points without trump bonus (7/8 = 0, 9 = 0, 10 = 10, J = 2, Q = 3, K = 4, A = 11)
  - `points(trump:)`: Points with trump bonus (9 of trump = 14, J of trump = 20)
  - Display: `"displayName"` (e.g., "J♥")

- **Rank Enum**: Seven through Ace with comparison support
- **Suit Enum**: Hearts, Diamonds, Clubs, Spades

- **Combination System**: All Belot combinations with detection
  - `CombinationType`: Bela (20 pts), Tărcă (20 pts), Sută (50-100 pts), etc.
  - Four-of-a-kind detection (4 Nines = 150, 4 Jacks = 200, 4 Tens/Dames/Kings/Aces = 100)
  - Special cases: 4 Sevens cancels round, 4 Eights cancels opponent combinations

- **Player Class**: Represents a game participant
  - `hand`: Current cards
  - `roundScore`: Points from tricks this round
  - `totalScore`: Total points (rounds + combinations)
  - `combinations`: Detected combinations with points
  - `totalBile`: Game points (bile) - win condition at 51+

- **BelotGame Class**: Main game engine
  - **Game Phases**: `waitingForPlayers`, `dealing`, `trumpSelection`, `playing`, `roundEnd`, `gameEnd`
  - **Deck Management**: 24 cards (2-3 players, no 7s/8s) or 32 cards (4 players)
  - **Trump Selection**: Automatic Jack rule, first-round pass option, second-round custom selection
  - **Trick Management**: Proper card play validation with four rules:
    1. Must follow suit if possible
    2. Must play trump if no suit cards and have trump
    3. Can play anything if no suit or trump
    4. If trump on table, must beat it if possible
  - **Scoring**: Points from tricks + combinations, with Pasledu (10 pt bonus for last trick)
  - **Bile Calculation**: Different for 2-player (1v1), 3-player (special algorithm), and 4-player (2v2 teams)

#### GameController.swift
**Game flow management and rule enforcement:**

- Manages game lifecycle from start to end
- Validates card plays according to Belot rules
- Detects and applies special rules (8888, 7777, Jack automatic play)
- Calculates final scores and determines winners
- Error handling with user-facing messages

### UI Layer (`PlayersView/`)

**Game Flow Views (shared across player counts):**
- `WaitingForGameView`: Initial setup screen
- `TrumpSelectionView`: First/second trump selection UI
- `GamePlayView` / `ThreePlayerGamePlayView` / `FourPlayerGamePlayView`: Active game play
- `RoundEndView`: Round results and next button
- `GameEndView`: Final game winner
- `ScoreboardView`: Persistent player scores
- `CardView`: Individual card display

**Game Views by Player Count:**
- `TwoPlayersView`: 2-player full implementation with GameController
- `ThreePlayersView`: 3-player with special 3-player bile algorithm
- `FourPlayersView`: 4-player with team-based scoring
- `gamemodeSelect`: Player setup and game options (Bochika/Tiomka toggles)

**Navigation:**
- `ContentView`: Main menu with player count selection
- Proper routing from ContentView → gamemodeSelect → specific game view

### Utilities (`Utils/`)

**ViewUtilities.swift:**
- `hideKeyboard()`: Extension for dismissing keyboard
- `BelotButtonStyle`: Custom button styling
- Helper extensions for view consistency

## Game Rules Implementation

### Card Values (Points)
| Card | Base Points | Trump Points |
|------|-------------|--------------|
| 7, 8 | 0 | 0 |
| 9 | 0 | 14 |
| 10 | 10 | 10 |
| Jack | 2 | 20 |
| Queen, King, Ace | 3, 4, 11 | Same as base |

### Combinations (Belot)
- **Bela**: Queen + King of trump (20 pts) - Always counted
- **Tărcă** (Sequence of 2): Any suit (20 pts)
- **Sută** (Sequence of 3): Any suit (50 pts)
- **Jumătate** (Sequence of 4): Any suit (100 pts)
- **Două sute** (Sequence of 5): Any suit (200 pts)
- **Four-of-a-kind**:
  - 4 Nines: 150 pts
  - 4 Jacks: 200 pts
  - 4 Tens/Dames/Kings/Aces: 100 pts

### Special Rules Implemented
- **Jack Rule**: If first card shown is Jack, next player automatically plays in that trump
- **8888 Rule**: All four Eights cancel opponent combinations (except Bela)
- **7777 Rule**: All four Sevens cancel the round and redistribute cards
- **Pasledu**: Last trick winner gets +10 bonus points

### Bile Calculation
- **2-Player (1v1)**: Each player's (total points / 10) rounded
- **4-Player (2v2)**: Team points combined, then (team total / 10)
- **3-Player (Special)**: Non-trump players get (points / 10), trump player gets remainder = total - non-trump

### Win Condition
- First player to 51+ bile wins
- If multiple players exceed 51, threshold escalates to 101, 151, etc.

## Important Implementation Notes

- **Language**: Game messages are in Romanian (cultural context for Belot players)
- **Card Dealing**: Automatic 5-card initial deal, then 3 more after trump is set
- **State Management**: Uses `@ObservedObject` and `@StateObject` with MVVM pattern
- **Validation**: Card play validation prevents illegal moves at UI level
- **Error Handling**: User-friendly error messages with error alert system

## File Structure
```
shiot/
├── shiotApp.swift              # Entry point
├── Models/
│   ├── BelotModels.swift       # All game data structures and logic
│   └── GameController.swift    # Game flow management
├── PlayersView/
│   ├── ContentView.swift       # Main menu
│   ├── gamemodeSelect.swift    # Player setup
│   ├── TwoPlayerView.swift     # 2-player game
│   ├── ThreePlayerView.swift   # 3-player game
│   ├── FourPlayerView.swift    # 4-player game
│   ├── SettingsView.swift      # Settings
│   └── (other views)
├── Utils/
│   └── ViewUtilities.swift     # Helper extensions
└── Assets.xcassets/            # Images and resources
```

## Dependencies

- **iOS Deployment Target**: iOS 15+
- **Swift Version**: 5.9+
- **SwiftUI**: Latest (NavigationStack, Canvas for custom drawing)
- No external dependencies (pure native Swift/SwiftUI)
