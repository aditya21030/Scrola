import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'haptic_service.dart';
import 'tracking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ScrolaAdPlacement {
  notchSession(
    title: 'Free Notch Session',
    badge: '+1 Session',
    description: 'Watch a short video to unlock 1 free floating counter session.',
  ),
  emergencyUnlock(
    title: '5-Min Reel Unlock',
    badge: '5 Min Unlock',
    description: 'Watch a short video for an instant emergency reel unlock.',
  ),
  streakRepair(
    title: 'Streak Freeze & Repair',
    badge: 'Streak Shield',
    description: 'Watch a short video to repair or shield your active streak.',
  ),
  bonusXp(
    title: '+50 Brainy Bonus XP',
    badge: '+50 XP',
    description: 'Watch a short video to give Brainy an instant +50 XP evolution boost.',
  );

  final String title;
  final String badge;
  final String description;
  const ScrolaAdPlacement({
    required this.title,
    required this.badge,
    required this.description,
  });
}

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isLoadingAd = false;
  bool _isLoadingInterstitial = false;
  bool _isInitialized = false;
  @visibleForTesting
  static bool isTesting = false;

  /// Production Google AdMob Unit IDs
  static const String _prodRewardedAdUnitId =
      'ca-app-pub-8510502760785545/9023978234';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-8510502760785545/6074381264';

  /// Official Google Sample Test Unit IDs (used during debug & testing to safeguard AdMob account)
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get rewardedAdUnitId =>
      kReleaseMode ? _prodRewardedAdUnitId : _testRewardedAdUnitId;

  static String get interstitialAdUnitId =>
      kReleaseMode ? _prodInterstitialAdUnitId : _testInterstitialAdUnitId;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _preloadRewardedAd();
      _preloadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: MobileAds.initialize failed or test env: $e');
    }
  }

  void _preloadRewardedAd() {
    if (isTesting ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    if (_rewardedAd != null || _isLoadingAd) return;
    _isLoadingAd = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingAd = false;
          debugPrint('AdService: RewardedAd ($rewardedAdUnitId) preloaded successfully.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _preloadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _preloadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingAd = false;
          debugPrint('AdService: RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void _preloadInterstitialAd() {
    if (isTesting ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    if (_interstitialAd != null || _isLoadingInterstitial) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
          debugPrint('AdService: InterstitialAd ($interstitialAdUnitId) preloaded successfully.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          debugPrint('AdService: InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show Interstitial Ad (Pro users get 0 ads / instant bypass)
  Future<bool> showInterstitialAd({required BuildContext context}) async {
    final tracking = TrackingService();
    if (tracking.isProSubscribed) return true;

    if (_interstitialAd == null) {
      _preloadInterstitialAd();
      return true;
    }

    final completer = Completer<bool>();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitialAd();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitialAd();
        completer.complete(true);
      },
    );

    _interstitialAd!.show();
    return completer.future;
  }

  /// Show Rewarded Ad.
  /// If the user is a PRO SUBSCRIBER, this completes IMMEDIATELY with NO ADS.
  Future<bool> showRewardedAd({
    required BuildContext context,
    required ScrolaAdPlacement placement,
  }) async {
    final tracking = TrackingService();

    // 🔒 PRO USER RULE: Pro members get 100% ad-free instant rewards!
    if (tracking.isProSubscribed) {
      HapticService.light();
      await _grantReward(placement);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceSolid,
            content: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: AppColors.primaryAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pro Member: ${placement.title} granted without ads!',
                    style: AppTypography.caption(color: AppColors.primaryText)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return true;
    }

    final completer = Completer<bool>();
    var rewardEarned = false;

    if (_rewardedAd == null) {
      final isTestEnv =
          isTesting || WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!isTestEnv) {
        if (context.mounted) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.cardSurface,
              content: Row(
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Loading short sponsor video...',
                      style: AppTypography.caption(color: AppColors.primaryText),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        await Future.delayed(const Duration(milliseconds: 1400));
        if (context.mounted) Navigator.of(context).pop();
      }

      // Grant reward gracefully
      await _grantReward(placement);
      if (context.mounted && !isTestEnv) {
        _showRewardSuccessSnackBar(context, placement);
      }
      _preloadRewardedAd();
      return true;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewardedAd();

        if (rewardEarned) {
          await _grantReward(placement);
          if (context.mounted) {
            _showRewardSuccessSnackBar(context, placement);
          }
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewardedAd();
        // Fallback: grant reward gracefully
        await _grantReward(placement);
        if (context.mounted) {
          _showRewardSuccessSnackBar(context, placement);
        }
        completer.complete(true);
      },
    );

    return completer.future;
  }

  Future<void> _grantReward(ScrolaAdPlacement placement) async {
    final tracking = TrackingService();
    HapticService.medium();

    switch (placement) {
      case ScrolaAdPlacement.notchSession:
        await tracking.grantBonusNotchSession();
        break;
      case ScrolaAdPlacement.emergencyUnlock:
        await tracking.grantBonusEmergencyUnlock(5);
        break;
      case ScrolaAdPlacement.streakRepair:
        await tracking.restoreBrokenStreak(defaultDays: 1);
        break;
      case ScrolaAdPlacement.bonusXp:
        await tracking.recordFocusCompleted(0, bonusXP: 50);
        break;
    }
  }

  void _showRewardSuccessSnackBar(
    BuildContext context,
    ScrolaAdPlacement placement,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceSolid,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reward Unlocked: ${placement.title}!',
                style: AppTypography.caption(color: AppColors.primaryText)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
