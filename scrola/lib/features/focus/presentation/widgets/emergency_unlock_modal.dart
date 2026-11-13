import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class EmergencyUnlockModal extends StatefulWidget {
  const EmergencyUnlockModal({super.key});

  static Future<bool?> show(BuildContext context) {
    HapticService.warning();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmergencyUnlockModal(),
    );
  }

  @override
  State<EmergencyUnlockModal> createState() => _EmergencyUnlockModalState();
}

class _EmergencyUnlockModalState extends State<EmergencyUnlockModal> {
  final TrackingService _tracking = TrackingService();
  int _secondsLeft = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        setState(() => _secondsLeft = 0);
        timer.cancel();
        HapticService.subtle();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleUnlockAnyway() async {
    if (_secondsLeft > 0) return;
    final success = await _tracking.useEmergencyUnlock();
    if (!mounted) return;
    if (success) {
      await HapticService.medium();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unlocked for 5 minutes. Use your time wisely!'),
        ),
      );
    } else {
      await HapticService.error();
      if (!mounted) return;
      Navigator.of(context).pop(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No emergency unlocks remaining today.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocksLeft = _tracking.emergencyUnlocksLeft;
    final streak = _tracking.streakDays;
    final progress = (15 - _secondsLeft) / 15.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Row: Countdown ring + title
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.elevatedSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAccent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_secondsLeft',
                          style: AppTypography.title().copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'sec',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock for 5 minutes?',
                      style: AppTypography.title().copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a breath first. The button wakes up when the timer ends.',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Consequences warning list
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This ends your $streak day streak',
                        style: AppTypography.caption(
                          color: AppColors.warning,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Uses 1 of 3 emergency unlocks today ($unlocksLeft left)',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Primary: Keep it locked
          ScrolaPrimaryButton(
            label: 'Keep it locked',
            useMediumHaptic: true,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          const SizedBox(height: 10),

          // Secondary: Unlock anyway
          ScrolaSecondaryButton(
            label: _secondsLeft > 0
                ? 'Wait $_secondsLeft seconds...'
                : 'Unlock anyway',
            onPressed: _secondsLeft > 0 || unlocksLeft <= 0
                ? null
                : _handleUnlockAnyway,
          ),
        ],
      ),
    );
  }
}
