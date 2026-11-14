import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class DeleteAccountModal extends StatefulWidget {
  final VoidCallback onConfirmDelete;

  const DeleteAccountModal({super.key, required this.onConfirmDelete});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirmDelete,
  }) {
    HapticService.light();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteAccountModal(onConfirmDelete: onConfirmDelete),
    );
  }

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isDeleteConfirmed =>
      _confirmController.text.trim().toUpperCase() == 'DELETE';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF171717),
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 14, 24, bottomInset + 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete your account?',
                      style: AppTypography.title().copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "This cannot be undone.",
                      style: AppTypography.caption(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: const [
                _DeleteItem(text: 'Your stats, streaks and XP'),
                _DeleteItem(text: 'Brainy and every form you unlocked'),
                _DeleteItem(text: 'Friends, battles and challenges'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: AppTypography.caption(color: AppColors.secondaryText),
              children: [
                const TextSpan(text: 'Type '),
                TextSpan(
                  text: 'DELETE',
                  style: AppTypography.caption(color: AppColors.error)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' to confirm'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isDeleteConfirmed
                    ? AppColors.error
                    : const Color(0xFF333333),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _confirmController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.title().copyWith(
                fontSize: 16,
                letterSpacing: 2,
                color: AppColors.error,
              ),
              cursorColor: AppColors.error,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'DELETE',
                hintStyle: TextStyle(
                  color: Color(0xFF555555),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ScrolaPrimaryButton(
            label: 'Keep my account',
            onTap: () {
              HapticService.subtle();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isDeleteConfirmed
                ? () {
                    HapticService.medium();
                    Navigator.of(context).pop();
                    widget.onConfirmDelete();
                  }
                : null,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _isDeleteConfirmed
                    ? AppColors.error.withValues(alpha: 0.15)
                    : const Color(0xFF242424),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isDeleteConfirmed
                      ? AppColors.error
                      : const Color(0xFF2F2F2F),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Delete my account',
                style: AppTypography.caption(
                  color: _isDeleteConfirmed
                      ? AppColors.error
                      : const Color(0xFF707070),
                ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                HapticService.light();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your account data archive is being prepared.'),
                  ),
                );
              },
              child: Text(
                'Export my data first',
                style: AppTypography.caption(color: AppColors.primaryAccent)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;
  const _DeleteItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(color: const Color(0xFFC8C8C8))
                  .copyWith(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
