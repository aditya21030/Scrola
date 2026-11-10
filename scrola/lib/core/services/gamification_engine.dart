enum BrainyMascotState {
  happy,
  focused,
  tired,
  celebrating,
}

class LevelInfo {
  final int level;
  final String title;
  final int minXP;
  final int maxXP;
  final bool isEvolutionStage;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.minXP,
    required this.maxXP,
    this.isEvolutionStage = false,
  });
}

class GamificationEngine {
  static const List<LevelInfo> levels = [
    LevelInfo(level: 1, title: 'Curious Spark', minXP: 0, maxXP: 100),
    LevelInfo(level: 2, title: 'Awakened Mind', minXP: 100, maxXP: 200),
    LevelInfo(level: 3, title: 'Mindful Synapse', minXP: 200, maxXP: 300),
    LevelInfo(level: 4, title: 'Curious Cortex', minXP: 300, maxXP: 500),
    LevelInfo(level: 5, title: 'Analytical Mind', minXP: 500, maxXP: 800, isEvolutionStage: true),
    LevelInfo(level: 6, title: 'Zen Master', minXP: 800, maxXP: 1200),
  ];

  /// Determine Brainy's emotional reaction based on habit metrics
  static BrainyMascotState evaluateMascotState({
    required int reelsWatched,
    required int dailyLimit,
    required bool isFocusModeActive,
    bool isDailyGoalCompleted = false,
  }) {
    if (isFocusModeActive) {
      return BrainyMascotState.focused;
    }

    if (isDailyGoalCompleted) {
      return BrainyMascotState.celebrating;
    }

    if (dailyLimit <= 0) return BrainyMascotState.happy;

    final double ratio = reelsWatched / dailyLimit;

    if (ratio >= 0.85) {
      return BrainyMascotState.tired;
    } else {
      return BrainyMascotState.happy;
    }
  }

  /// Get Level details from total XP
  static LevelInfo getLevelForXP(int totalXP) {
    for (final level in levels) {
      if (totalXP >= level.minXP && totalXP < level.maxXP) {
        return level;
      }
    }
    return levels.last;
  }

  /// Check if an XP gain will trigger a Level-up
  static bool willLevelUp(int currentXP, int addedXP) {
    final currentLevel = getLevelForXP(currentXP);
    final newLevel = getLevelForXP(currentXP + addedXP);
    return newLevel.level > currentLevel.level;
  }
}
