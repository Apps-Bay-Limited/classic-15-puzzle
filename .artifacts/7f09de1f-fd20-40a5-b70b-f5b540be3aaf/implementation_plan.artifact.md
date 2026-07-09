# Implementation Plan: Hall of Fame & Hint System

Implement a local progress tracking system ("Hall of Fame") and an A*-based hint system to assist players.

## User Review Required

> [!IMPORTANT]
> - **Storage Limit**: I will limit the history log to the last 100 games to prevent `SharedPreferences` from growing indefinitely. Personal bests (Time & Moves) will always be preserved for each grid size.
> - **Solver Performance**: A* search on a 5x5 grid can be computationally expensive. I will implement a depth-limited search or a heuristic-heavy optimization to ensure the UI doesn't hang.
> - **Hint UI**: I propose adding a "bulb" icon next to the "Moves" counter. Tapping it will automatically perform the next best move for the user.

## Proposed Changes

### 1. Data & Persistence

#### [MODIFY] [result.dart](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/data/result.dart)
- Implement `Serializable` to allow saving results to local storage.
- Add `timestamp` field to track when the game was completed.

#### [NEW] [history.dart](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/data/history.dart)
- Model `GameHistory` containing:
    - `List<Result> log`: Chronological list of completions.
    - `Map<int, Result> bestTime`: Fastest completions per grid size.
    - `Map<int, Result> bestMoves`: Fewest moves per grid size.

#### [MODIFY] [main.dart (Presenter)](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/widgets/game/presenter/main.dart)
- Add `GameHistory history` to the state.
- Load history on `initState` (encrypted, similar to game state).
- Save history when a game is solved in the `tap` method's `onSolve` hook.

### 2. UI Components

#### [NEW] [hall_of_fame.dart](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/widgets/game/hall_of_fame.dart)
- New full-screen or large dialog UI showing:
    - Tabbed view for different grid sizes (3x3, 4x4, 5x5).
    - "Personal Bests" cards (Gold for Time, Silver for Moves).
    - Scrollable list of "Recent Games".
- Apply "Liquid Glass" theme for iOS.

#### [MODIFY] [page.dart](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/widgets/game/material/page.dart)
- Add `Icons.emoji_events_rounded` to the `AppBar` actions to open the Hall of Fame.
- Add a "Hint" button (`Icons.lightbulb_outline_rounded`) next to the refresh button.

### 3. Hint System (A* Algorithm)

#### [NEW] [solver.dart](file:///Users/banghuazhao/Development/FlutterApps/classic_15_puzzle/lib/domain/solver.dart)
- Implement A* search algorithm:
    - **State**: Representation of the board.
    - **Heuristic**: Manhattan Distance + Linear Conflict (for faster convergence).
    - **Open Set**: Priority Queue based on `f(n) = g(n) + h(n)`.
- Method `findNextMove(Board board)`: Returns the `Point` to tap to reach the next state on the optimal path.

## Verification Plan

### Automated Tests
- Unit tests for `PuzzleSolver` to ensure it can solve a scrambled 3x3 board in a reasonable number of steps.
- Serialization tests for `Result` and `GameHistory`.

### Manual Verification
- Scramble a 3x3 board and repeatedly use the "Hint" button until the board is solved.
- Complete a game and verify it appears in the Hall of Fame.
- Verify that a new "Best Time" correctly updates the Gold record card.
