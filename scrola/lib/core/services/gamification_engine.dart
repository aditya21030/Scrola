enum BrainyMood {
  happy,
  neutral,
  tired,
  sad,
  focused,
  sleepy,
  excited,
  celebrating,
}

enum BrainySkin {
  classic,
  ember,
  golden,
  frost,
  mint,
  midnight,
}

class EvolutionStage {
  final int stageNumber;
  final String name;
  final int minLevel;
  final int maxLevel;
  final String description;

  const EvolutionStage({
    required this.stageNumber,
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.description,
  });

  String get title => name;
}

class LevelInfo {
  final int level;
  final String title;
  final int minXP;
  final int maxXP;
  final int stageNumber;
  final int currentXP;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.minXP,
    required this.maxXP,
    required this.stageNumber,
    this.currentXP = 0,
  });

  int get xpForNextLevel => (maxXP - minXP).clamp(1, 999999);
  int get xpInCurrentLevel => (currentXP - minXP).clamp(0, xpForNextLevel);
  double get progress => (xpInCurrentLevel / xpForNextLevel).clamp(0.0, 1.0);
}

class GamificationEngine {
  static const List<EvolutionStage> evolutionStages = [
    EvolutionStage(
      stageNumber: 1,
      name: 'Sleepy Seed',
      minLevel: 1,
      maxLevel: 2,
      description: 'Just waking up from endless scrolls.',
    ),
    EvolutionStage(
      stageNumber: 2,
      name: 'Curious Cortex',
      minLevel: 3,
      maxLevel: 5,
      description: 'Building mindful awareness of your habits.',
    ),
    EvolutionStage(
      stageNumber: 3,
      name: 'Bright Mind',
      minLevel: 6,
      maxLevel: 9,
      description: 'Consistent control over daily feeds.',
    ),
    EvolutionStage(
      stageNumber: 4,
      name: 'Sharp Genius',
      minLevel: 10,
      maxLevel: 14,
      description: 'Master of focus and intentional screen time.',
    ),
    EvolutionStage(
      stageNumber: 5,
      name: 'Zen Master',
      minLevel: 15,
      maxLevel: 99,
      description: 'Total digital clarity and effortless balance.',
    ),
  ];

  static const List<LevelInfo> levels = [
    LevelInfo(level: 1, title: 'Sleepy Seed', minXP: 0, maxXP: 100, stageNumber: 1),
    LevelInfo(level: 2, title: 'Sleepy Seed', minXP: 100, maxXP: 200, stageNumber: 1),
    LevelInfo(level: 3, title: 'Curious Cortex', minXP: 200, maxXP: 300, stageNumber: 2),
    LevelInfo(level: 4, title: 'Curious Cortex', minXP: 300, maxXP: 500, stageNumber: 2),
    LevelInfo(level: 5, title: 'Curious Cortex', minXP: 500, maxXP: 750, stageNumber: 2),
    LevelInfo(level: 6, title: 'Bright Mind', minXP: 750, maxXP: 1050, stageNumber: 3),
    LevelInfo(level: 7, title: 'Bright Mind', minXP: 1050, maxXP: 1400, stageNumber: 3),
    LevelInfo(level: 8, title: 'Bright Mind', minXP: 1400, maxXP: 1800, stageNumber: 3),
    LevelInfo(level: 9, title: 'Bright Mind', minXP: 1800, maxXP: 2250, stageNumber: 3),
    LevelInfo(level: 10, title: 'Sharp Genius', minXP: 2250, maxXP: 2750, stageNumber: 4),
    LevelInfo(level: 11, title: 'Sharp Genius', minXP: 2750, maxXP: 3300, stageNumber: 4),
    LevelInfo(level: 12, title: 'Sharp Genius', minXP: 3300, maxXP: 3900, stageNumber: 4),
    LevelInfo(level: 13, title: 'Sharp Genius', minXP: 3900, maxXP: 4550, stageNumber: 4),
    LevelInfo(level: 14, title: 'Sharp Genius', minXP: 4550, maxXP: 5250, stageNumber: 4),
    LevelInfo(level: 15, title: 'Zen Master', minXP: 5250, maxXP: 6000, stageNumber: 5),
    LevelInfo(level: 16, title: 'Zen Master', minXP: 6000, maxXP: 6800, stageNumber: 5),
    LevelInfo(level: 17, title: 'Zen Master', minXP: 6800, maxXP: 7650, stageNumber: 5),
    LevelInfo(level: 18, title: 'Zen Master', minXP: 7650, maxXP: 8550, stageNumber: 5),
    LevelInfo(level: 19, title: 'Zen Master', minXP: 8550, maxXP: 9500, stageNumber: 5),
    LevelInfo(level: 20, title: 'Zen Master', minXP: 9500, maxXP: 10500, stageNumber: 5),
  ];

  static int unlockLevelForSkin(BrainySkin skin) {
    switch (skin) {
      case BrainySkin.classic:
        return 1;
      case BrainySkin.ember:
        return 2;
      case BrainySkin.golden:
        return 4;
      case BrainySkin.frost:
        return 8;
      case BrainySkin.mint:
        return 12;
      case BrainySkin.midnight:
        return 20;
    }
  }

  /// Determine Brainy's emotional reaction based on habit metrics (design.md Section 7)
  static BrainyMood evaluateMood({
    required int reelsWatched,
    required int dailyLimit,
    bool isFocusModeActive = false,
    bool isDetoxOrNightBlock = false,
    bool isCelebrating = false,
    bool isMilestone = false,
  }) {
    if (isCelebrating) return BrainyMood.celebrating;
    if (isMilestone) return BrainyMood.excited;
    if (isFocusModeActive) return BrainyMood.focused;
    if (isDetoxOrNightBlock) return BrainyMood.sleepy;

    if (dailyLimit <= 0) return BrainyMood.happy;

    final double ratio = reelsWatched / dailyLimit;

    if (ratio > 1.0) {
      return BrainyMood.sad;
    } else if (ratio >= 0.80) {
      return BrainyMood.tired;
    } else if (ratio >= 0.60) {
      return BrainyMood.neutral;
    } else {
      return BrainyMood.happy;
    }
  }

  static String moodAssetPath(BrainyMood mood) {
    switch (mood) {
      case BrainyMood.happy:
        return 'assets/mascot/brainy-happy.svg';
      case BrainyMood.neutral:
        return 'assets/mascot/brainy-neutral.svg';
      case BrainyMood.tired:
        return 'assets/mascot/brainy-tired.svg';
      case BrainyMood.sad:
        return 'assets/mascot/brainy-sad.svg';
      case BrainyMood.focused:
        return 'assets/mascot/brainy-focused.svg';
      case BrainyMood.sleepy:
        return 'assets/mascot/brainy-sleepy.svg';
      case BrainyMood.excited:
        return 'assets/mascot/brainy-excited.svg';
      case BrainyMood.celebrating:
        return 'assets/mascot/brainy-celebrating.svg';
    }
  }

  static String moodDescription(BrainyMood mood) {
    switch (mood) {
      case BrainyMood.happy:
        return 'Shown when you are under 60% of today\'s limit.';
      case BrainyMood.neutral:
        return 'Shown when you are between 60% and 80% of today\'s limit.';
      case BrainyMood.tired:
        return 'Shown when you are approaching 100% of your limit.';
      case BrainyMood.sad:
        return 'Shown when you have crossed today\'s reel limit.';
      case BrainyMood.focused:
        return 'Shown during active Focus sessions.';
      case BrainyMood.sleepy:
        return 'Shown during Scroll Detox or Night Block.';
      case BrainyMood.excited:
        return 'Shown on level-ups and streak milestones.';
      case BrainyMood.celebrating:
        return 'Shown when unlocking achievements or finishing setup.';
    }
  }

  static LevelInfo getLevelForXP(int totalXP) {
    final int safeXP = totalXP < 0 ? 0 : totalXP;
    for (final level in levels) {
      if (safeXP >= level.minXP && safeXP < level.maxXP) {
        return LevelInfo(
          level: level.level,
          title: level.title,
          minXP: level.minXP,
          maxXP: level.maxXP,
          stageNumber: level.stageNumber,
          currentXP: safeXP,
        );
      }
    }
    const int postCapStep = 1000;
    final last = levels.last;
    final int extraXP = (safeXP - last.maxXP).clamp(0, 1 << 30);
    final int extraLevels = (extraXP ~/ postCapStep) + 1;
    final int computedLevel = last.level + extraLevels;
    final int minXP = last.maxXP + (extraLevels - 1) * postCapStep;
    final int maxXP = minXP + postCapStep;
    final stage = getStageForLevel(computedLevel);
    return LevelInfo(
      level: computedLevel,
      title: stage.title,
      minXP: minXP,
      maxXP: maxXP,
      stageNumber: stage.stageNumber,
      currentXP: safeXP,
    );
  }

  static EvolutionStage getStageForLevel(int level) {
    if (level <= 1) return evolutionStages.first;
    for (final stage in evolutionStages) {
      if (level >= stage.minLevel && level <= stage.maxLevel) {
        return stage;
      }
    }
    return evolutionStages.last;
  }
}
