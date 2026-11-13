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
  sunset,
  peach,
  coral,
  lava,
  copper,
  bronze,
  silver,
  steel,
  obsidian,
  ruby,
  rose,
  candy,
  sakura,
  sky,
  ocean,
  teal,
  lagoon,
  lime,
  forest,
  jade,
  moss,
  olive,
  sand,
  cream,
  snow,
  charcoal,
  ink,
  aqua,
  cherry,
  wine,
  mango,
  lemon,
  honey,
  rust,
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
      description: 'Pale and small, with a sprout.',
    ),
    EvolutionStage(
      stageNumber: 2,
      name: 'Curious Cortex',
      minLevel: 3,
      maxLevel: 5,
      description: 'The base form waking up to mindfulness.',
    ),
    EvolutionStage(
      stageNumber: 3,
      name: 'Bright Mind',
      minLevel: 6,
      maxLevel: 8,
      description: 'A floating idea bulb powering consistent habits.',
    ),
    EvolutionStage(
      stageNumber: 4,
      name: 'Sharp Genius',
      minLevel: 9,
      maxLevel: 11,
      description: 'Round glasses and sparks of daily discipline.',
    ),
    EvolutionStage(
      stageNumber: 5,
      name: 'Explorer',
      minLevel: 12,
      maxLevel: 14,
      description: 'Goggles and a scarf exploring digital balance.',
    ),
    EvolutionStage(
      stageNumber: 6,
      name: 'Ninja Focus',
      minLevel: 15,
      maxLevel: 17,
      description: 'Headband tied, ready to focus and defeat distractions.',
    ),
    EvolutionStage(
      stageNumber: 7,
      name: 'Zen Master',
      minLevel: 18,
      maxLevel: 20,
      description: 'Halo and golden calm over screen urges.',
    ),
    EvolutionStage(
      stageNumber: 8,
      name: 'Wizard',
      minLevel: 21,
      maxLevel: 23,
      description: 'Starry hat and wand casting deep work spells.',
    ),
    EvolutionStage(
      stageNumber: 9,
      name: 'Astronaut',
      minLevel: 24,
      maxLevel: 26,
      description: 'Helmet and antenna venturing beyond feeds.',
    ),
    EvolutionStage(
      stageNumber: 10,
      name: 'Storm Brain',
      minLevel: 27,
      maxLevel: 29,
      description: 'Electrifying focus and unstoppable momentum.',
    ),
    EvolutionStage(
      stageNumber: 11,
      name: 'Cosmic Mind',
      minLevel: 30,
      maxLevel: 34,
      description: 'Starry body with orbiting planet of clarity.',
    ),
    EvolutionStage(
      stageNumber: 12,
      name: 'Royal Legend',
      minLevel: 35,
      maxLevel: 39,
      description: 'Golden crown and cape of pure self-mastery.',
    ),
    EvolutionStage(
      stageNumber: 13,
      name: 'Chef',
      minLevel: 40,
      maxLevel: 42,
      description: 'Tall white toque cooking up mindful days.',
    ),
    EvolutionStage(
      stageNumber: 14,
      name: 'Pirate',
      minLevel: 43,
      maxLevel: 45,
      description: 'Bandana and eyepatch sailing clear of rabbit holes.',
    ),
    EvolutionStage(
      stageNumber: 15,
      name: 'Knight',
      minLevel: 46,
      maxLevel: 48,
      description: 'Steel helmet defending your attention.',
    ),
    EvolutionStage(
      stageNumber: 16,
      name: 'Viking',
      minLevel: 49,
      maxLevel: 51,
      description: 'Horned helmet conquering screen addiction.',
    ),
    EvolutionStage(
      stageNumber: 17,
      name: 'Cowboy',
      minLevel: 52,
      maxLevel: 54,
      description: 'Wide brim hat wrangling wild scroll impulses.',
    ),
    EvolutionStage(
      stageNumber: 18,
      name: 'Detective',
      minLevel: 55,
      maxLevel: 57,
      description: 'Fedora and magnifier uncovering true priorities.',
    ),
    EvolutionStage(
      stageNumber: 19,
      name: 'DJ',
      minLevel: 58,
      maxLevel: 60,
      description: 'Big headphones tuning into flow state.',
    ),
    EvolutionStage(
      stageNumber: 20,
      name: 'Scientist',
      minLevel: 61,
      maxLevel: 63,
      description: 'Goggles and a flask experimenting with productivity.',
    ),
    EvolutionStage(
      stageNumber: 21,
      name: 'Robot',
      minLevel: 64,
      maxLevel: 66,
      description: 'Steel body running flawless daily routines.',
    ),
    EvolutionStage(
      stageNumber: 22,
      name: 'Alien',
      minLevel: 67,
      maxLevel: 69,
      description: 'Glowing antennae transmitting otherworldly calm.',
    ),
    EvolutionStage(
      stageNumber: 23,
      name: 'Frost Monarch',
      minLevel: 70,
      maxLevel: 72,
      description: 'Ice crown freezing digital distractions in their tracks.',
    ),
    EvolutionStage(
      stageNumber: 24,
      name: 'Fire Spirit',
      minLevel: 73,
      maxLevel: 75,
      description: 'Flame crest burning bright with creative drive.',
    ),
    EvolutionStage(
      stageNumber: 25,
      name: 'Pharaoh',
      minLevel: 76,
      maxLevel: 79,
      description: 'Striped headdress ruling over timeless habits.',
    ),
    EvolutionStage(
      stageNumber: 26,
      name: 'Angel',
      minLevel: 80,
      maxLevel: 84,
      description: 'Wings and halo ascending into effortless peace.',
    ),
    EvolutionStage(
      stageNumber: 27,
      name: 'Dragon',
      minLevel: 85,
      maxLevel: 89,
      description: 'Horns and wings commanding supreme focus power.',
    ),
    EvolutionStage(
      stageNumber: 28,
      name: 'Time Traveler',
      minLevel: 90,
      maxLevel: 94,
      description: 'Gear ring and clock reclaiming lost hours.',
    ),
    EvolutionStage(
      stageNumber: 29,
      name: 'Galaxy Emperor',
      minLevel: 95,
      maxLevel: 99,
      description: 'Star crown presiding over limitless digital clarity.',
    ),
    EvolutionStage(
      stageNumber: 30,
      name: 'Infinity',
      minLevel: 100,
      maxLevel: 999,
      description: 'Triple halo and orbiting gems of ultimate enlightenment.',
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
    LevelInfo(level: 9, title: 'Sharp Genius', minXP: 1800, maxXP: 2250, stageNumber: 4),
    LevelInfo(level: 10, title: 'Sharp Genius', minXP: 2250, maxXP: 2750, stageNumber: 4),
    LevelInfo(level: 11, title: 'Sharp Genius', minXP: 2750, maxXP: 3300, stageNumber: 4),
    LevelInfo(level: 12, title: 'Explorer', minXP: 3300, maxXP: 3900, stageNumber: 5),
    LevelInfo(level: 13, title: 'Explorer', minXP: 3900, maxXP: 4550, stageNumber: 5),
    LevelInfo(level: 14, title: 'Explorer', minXP: 4550, maxXP: 5250, stageNumber: 5),
    LevelInfo(level: 15, title: 'Ninja Focus', minXP: 5250, maxXP: 6000, stageNumber: 6),
    LevelInfo(level: 16, title: 'Ninja Focus', minXP: 6000, maxXP: 6800, stageNumber: 6),
    LevelInfo(level: 17, title: 'Ninja Focus', minXP: 6800, maxXP: 7650, stageNumber: 6),
    LevelInfo(level: 18, title: 'Zen Master', minXP: 7650, maxXP: 8550, stageNumber: 7),
    LevelInfo(level: 19, title: 'Zen Master', minXP: 8550, maxXP: 9500, stageNumber: 7),
    LevelInfo(level: 20, title: 'Zen Master', minXP: 9500, maxXP: 10500, stageNumber: 7),
  ];

  static const Map<int, String> _stageSlugs = {
    1: 'sleepy-seed',
    2: 'curious-cortex',
    3: 'bright-mind',
    4: 'sharp-genius',
    5: 'explorer',
    6: 'ninja-focus',
    7: 'zen-master',
    8: 'wizard',
    9: 'astronaut',
    10: 'storm-brain',
    11: 'cosmic-mind',
    12: 'royal-legend',
    13: 'chef',
    14: 'pirate',
    15: 'knight',
    16: 'viking',
    17: 'cowboy',
    18: 'detective',
    19: 'dj',
    20: 'scientist',
    21: 'robot',
    22: 'alien',
    23: 'frost-monarch',
    24: 'fire-spirit',
    25: 'pharaoh',
    26: 'angel',
    27: 'dragon',
    28: 'time-traveler',
    29: 'galaxy-emperor',
    30: 'infinity',
  };

  static String stageAssetPath(int stageNumber) {
    final clamped = stageNumber.clamp(1, 30);
    final slug = _stageSlugs[clamped] ?? 'curious-cortex';
    return 'assets/mascot/stages/brainy-stage$clamped-$slug.svg';
  }

  static String skinAssetPath(BrainySkin skin) {
    return 'assets/mascot/skins/brainy-skin-${skin.name}.svg';
  }

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
      case BrainySkin.sunset:
        return 22;
      case BrainySkin.peach:
        return 24;
      case BrainySkin.coral:
        return 26;
      case BrainySkin.lava:
        return 28;
      case BrainySkin.copper:
        return 30;
      case BrainySkin.bronze:
        return 32;
      case BrainySkin.silver:
        return 34;
      case BrainySkin.steel:
        return 36;
      case BrainySkin.obsidian:
        return 38;
      case BrainySkin.ruby:
        return 40;
      case BrainySkin.rose:
        return 42;
      case BrainySkin.candy:
        return 44;
      case BrainySkin.sakura:
        return 46;
      case BrainySkin.sky:
        return 48;
      case BrainySkin.ocean:
        return 50;
      case BrainySkin.teal:
        return 52;
      case BrainySkin.lagoon:
        return 54;
      case BrainySkin.lime:
        return 56;
      case BrainySkin.forest:
        return 58;
      case BrainySkin.jade:
        return 60;
      case BrainySkin.moss:
        return 62;
      case BrainySkin.olive:
        return 64;
      case BrainySkin.sand:
        return 66;
      case BrainySkin.cream:
        return 68;
      case BrainySkin.snow:
        return 70;
      case BrainySkin.charcoal:
        return 72;
      case BrainySkin.ink:
        return 74;
      case BrainySkin.aqua:
        return 76;
      case BrainySkin.cherry:
        return 78;
      case BrainySkin.wine:
        return 80;
      case BrainySkin.mango:
        return 82;
      case BrainySkin.lemon:
        return 84;
      case BrainySkin.honey:
        return 86;
      case BrainySkin.rust:
        return 88;
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

  /// Progress within the current evolution stage (`0.0`..`1.0`), spanning
  /// multiple levels so evolution progress does not reset mid-stage.
  static double getStageProgress(int totalXP) {
    final safeXP = totalXP < 0 ? 0 : totalXP;
    final info = getLevelForXP(safeXP);
    final currentStage = getStageForLevel(info.level);
    final stageIdx = evolutionStages.indexWhere(
      (s) => s.stageNumber == currentStage.stageNumber,
    );
    if (stageIdx < 0 || stageIdx >= evolutionStages.length - 1) {
      return 1.0;
    }
    final nextStage = evolutionStages[stageIdx + 1];
    final stageStartXP = levels
        .firstWhere(
          (l) => l.level == currentStage.minLevel,
          orElse: () => levels.first,
        )
        .minXP;
    final nextStageStartXP = levels
        .firstWhere(
          (l) => l.level == nextStage.minLevel,
          orElse: () => levels.last,
        )
        .minXP;
    final span = (nextStageStartXP - stageStartXP).clamp(1, 1 << 30);
    return ((safeXP - stageStartXP) / span).clamp(0.0, 1.0);
  }

  /// Counts how many Brainy skins are unlocked at [level].
  static int unlockedSkinCount(int level) {
    return BrainySkin.values
        .where((skin) => level >= unlockLevelForSkin(skin))
        .length;
  }

  /// Evaluates real badge unlock status from current user metrics.
  static List<AchievementBadge> evaluateBadges({
    required int streakDays,
    required int totalReelsToday,
    required int totalLimit,
    required bool isTrackingEnabled,
    required int focusMinutesToday,
    required int focusSessionsToday,
    required bool nightBlockEnabled,
    required bool isDetoxActive,
    required bool isDetoxCompleted,
    required int currentLevel,
  }) {
    final underLimit = totalLimit > 0 && totalReelsToday <= totalLimit;
    return [
      AchievementBadge(
        id: 'streak_7',
        title: '7 Day Streak',
        category: 'Streaks',
        xpLabel: '+50 XP',
        description: 'Stay under your daily limit for 7 days.',
        unlocked: streakDays >= 7,
      ),
      AchievementBadge(
        id: 'under_limit',
        title: 'Under Limit',
        category: 'Limits',
        xpLabel: '+25 XP',
        description: 'Keep tracking active while under today\'s limit.',
        unlocked: isTrackingEnabled && underLimit,
      ),
      AchievementBadge(
        id: 'first_count',
        title: 'First Count',
        category: 'Limits',
        xpLabel: '+15 XP',
        description: 'Log your first counted short-form video.',
        unlocked: totalReelsToday > 0 || streakDays > 0,
      ),
      AchievementBadge(
        id: 'focus_starter',
        title: 'Focus Starter',
        category: 'Focus',
        xpLabel: '+30 XP',
        description: 'Complete at least one Focus session.',
        unlocked: focusSessionsToday >= 1 || focusMinutesToday >= 5,
      ),
      AchievementBadge(
        id: 'deep_focus_60',
        title: 'Deep Focus',
        category: 'Focus',
        xpLabel: '+40 XP',
        description: 'Reach 60 minutes of Focus time in a day.',
        unlocked: focusMinutesToday >= 60,
      ),
      AchievementBadge(
        id: 'streak_14',
        title: '14 Day Streak',
        category: 'Streaks',
        xpLabel: '+100 XP',
        description: 'Maintain an under-limit streak for two weeks.',
        unlocked: streakDays >= 14,
      ),
      AchievementBadge(
        id: 'night_owl',
        title: 'Night Owl',
        category: 'Limits',
        xpLabel: '+40 XP',
        description: 'Enable Night Block while tracking is active.',
        unlocked: isTrackingEnabled && nightBlockEnabled,
      ),
      AchievementBadge(
        id: 'detox_day',
        title: 'Detox Day',
        category: 'Focus',
        xpLabel: '+75 XP',
        description: 'Start or complete a Scroll Detox pause.',
        unlocked: isDetoxActive || isDetoxCompleted,
      ),
      AchievementBadge(
        id: 'level_5',
        title: 'Bright Brain',
        category: 'Streaks',
        xpLabel: '+50 XP',
        description: 'Reach Level 5 with Brainy.',
        unlocked: currentLevel >= 5,
      ),
    ];
  }
}

class AchievementBadge {
  final String id;
  final String title;
  final String category;
  final String xpLabel;
  final String description;
  final bool unlocked;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.category,
    required this.xpLabel,
    required this.description,
    required this.unlocked,
  });
}
