import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'friend_profile_screen.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final SocialService _social = SocialService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<FriendUser> _suggestions = const [
    FriendUser(
      id: 's1',
      name: 'Rohan Sharma',
      username: 'rohan.s',
      skin: BrainySkin.cherry,
      level: 16,
      streak: 11,
      reelsToday: 19,
      dailyLimit: 25,
      isOnline: true,
      battleWins: 7,
    ),
    FriendUser(
      id: 's2',
      name: 'Ananya Verma',
      username: 'ananya_v',
      skin: BrainySkin.aqua,
      level: 24,
      streak: 30,
      reelsToday: 14,
      dailyLimit: 20,
      isOnline: false,
      battleWins: 18,
    ),
    FriendUser(
      id: 's3',
      name: 'Dev Patel',
      username: 'dev.scrollfree',
      skin: BrainySkin.honey,
      level: 8,
      streak: 4,
      reelsToday: 26,
      dailyLimit: 30,
      isOnline: true,
      battleWins: 2,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _suggestions
        .where((f) =>
            f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.username.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Find friends'),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTypography.body(weight: FontWeight.w600),
                        cursorColor: AppColors.primaryAccent,
                        decoration: const InputDecoration(
                          hintText: 'Search by username or name...',
                          hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close_rounded, color: AppColors.secondaryText, size: 18),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Share invite link card
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                radius: 20,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.link_rounded, color: AppColors.primaryAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invite Friends to Scrola', style: AppTypography.body(weight: FontWeight.w700)),
                          Text(
                            'scrola.app/join/@alex.scrolls',
                            style: AppTypography.caption(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                          const ClipboardData(text: 'https://scrola.app/join/@alex.scrolls'),
                        );
                        await HapticService.medium();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invite link copied to clipboard!')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Share',
                          style: AppTypography.caption(
                            color: AppColors.textOnAccent,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'SUGGESTIONS FOR YOU',
                style: AppTypography.label(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final friend = filtered[index];
                    final isAlreadyFriend = _social.friends.any((f) => f.id == friend.id);

                    return GestureDetector(
                      onTap: () {
                        HapticService.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FriendProfileScreen(friend: friend),
                          ),
                        );
                      },
                      child: ScrolaCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        radius: 18,
                        child: Row(
                          children: [
                            BrainyMascot(
                              mood: BrainyMood.happy,
                              skin: friend.skin,
                              size: 40,
                              animate: false,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(friend.name, style: AppTypography.body(weight: FontWeight.w700)),
                                  Text(
                                    '@${friend.username} · Lv ${friend.level}',
                                    style: AppTypography.caption(color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: isAlreadyFriend
                                  ? null
                                  : () async {
                                      await _social.addFriend(friend);
                                      setState(() {});
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isAlreadyFriend
                                      ? AppColors.elevatedSurface
                                      : AppColors.primaryAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isAlreadyFriend
                                        ? AppColors.border
                                        : AppColors.primaryAccent.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  isAlreadyFriend ? 'Added' : 'Add',
                                  style: AppTypography.caption(
                                    color: isAlreadyFriend
                                        ? AppColors.secondaryText
                                        : AppColors.primaryAccent,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
