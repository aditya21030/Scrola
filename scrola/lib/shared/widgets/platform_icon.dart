import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';

enum SocialPlatform {
  instagram,
  youtube,
  tiktok,
  snapchat,
  facebook,
  x,
  reddit,
  moj,
}

extension SocialPlatformMeta on SocialPlatform {
  String get id => switch (this) {
        SocialPlatform.instagram => 'instagram',
        SocialPlatform.youtube => 'youtube',
        SocialPlatform.tiktok => 'tiktok',
        SocialPlatform.snapchat => 'snapchat',
        SocialPlatform.facebook => 'facebook',
        SocialPlatform.x => 'x',
        SocialPlatform.reddit => 'reddit',
        SocialPlatform.moj => 'moj',
      };

  String get shortName => switch (this) {
        SocialPlatform.instagram => 'Instagram',
        SocialPlatform.youtube => 'YouTube',
        SocialPlatform.tiktok => 'TikTok',
        SocialPlatform.snapchat => 'Snapchat',
        SocialPlatform.facebook => 'Facebook',
        SocialPlatform.x => 'X',
        SocialPlatform.reddit => 'Reddit',
        SocialPlatform.moj => 'Moj',
      };

  String get reelsName => switch (this) {
        SocialPlatform.instagram => 'Instagram Reels',
        SocialPlatform.youtube => 'YouTube Shorts',
        SocialPlatform.tiktok => 'TikTok',
        SocialPlatform.snapchat => 'Snapchat Spotlight',
        SocialPlatform.facebook => 'Facebook Reels',
        SocialPlatform.x => 'X Videos',
        SocialPlatform.reddit => 'Reddit Watch',
        SocialPlatform.moj => 'Moj Reels',
      };

  String get shortBadge => switch (this) {
        SocialPlatform.instagram => 'IG',
        SocialPlatform.youtube => 'YT',
        SocialPlatform.tiktok => 'TT',
        SocialPlatform.snapchat => 'SC',
        SocialPlatform.facebook => 'FB',
        SocialPlatform.x => 'X',
        SocialPlatform.reddit => 'RD',
        SocialPlatform.moj => 'MJ',
      };

  Color get brandColor => switch (this) {
        SocialPlatform.instagram => AppColors.instagram,
        SocialPlatform.youtube => AppColors.youtube,
        SocialPlatform.tiktok => AppColors.tiktok,
        SocialPlatform.snapchat => AppColors.snapchat,
        SocialPlatform.facebook => AppColors.facebook,
        SocialPlatform.x => AppColors.xPlatform,
        SocialPlatform.reddit => AppColors.reddit,
        SocialPlatform.moj => AppColors.moj,
      };

  int get defaultLimit => switch (this) {
        SocialPlatform.instagram => 20,
        SocialPlatform.youtube => 15,
        SocialPlatform.tiktok => 15,
        SocialPlatform.snapchat => 5,
        SocialPlatform.facebook => 10,
        SocialPlatform.x => 10,
        SocialPlatform.reddit => 10,
        SocialPlatform.moj => 10,
      };

  static SocialPlatform? tryParse(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final platform in SocialPlatform.values) {
      if (platform.id == normalized) return platform;
    }
    return null;
  }
}

/// Real brand app icon tile for supported short-video / reels platforms.
class PlatformIcon extends StatelessWidget {
  final SocialPlatform platform;
  final double size;

  const PlatformIcon({
    super.key,
    required this.platform,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    final isDarkTile =
        platform == SocialPlatform.tiktok || platform == SocialPlatform.x;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _baseColor(platform),
        gradient: _tileGradient(platform),
        borderRadius: radius,
        border: isDarkTile
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDarkTile ? Colors.black : platform.brandColor)
                .withValues(alpha: 0.34),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Center(
          child: SizedBox(
            width: platform == SocialPlatform.facebook ? size : size * 0.68,
            height: platform == SocialPlatform.facebook ? size : size * 0.68,
            child: SvgPicture.string(
              _svgForPlatform(platform),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Color? _baseColor(SocialPlatform platform) => switch (platform) {
        SocialPlatform.youtube => const Color(0xFFFF0000),
        SocialPlatform.facebook => const Color(0xFF1877F2),
        SocialPlatform.snapchat => const Color(0xFFFFFC00),
        SocialPlatform.tiktok => const Color(0xFF0C0C10),
        SocialPlatform.x => const Color(0xFF0C0C10),
        SocialPlatform.reddit => const Color(0xFFFF4500),
        _ => null,
      };

  Gradient? _tileGradient(SocialPlatform platform) => switch (platform) {
        SocialPlatform.instagram => const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFFFEDA75),
              Color(0xFFFA7E1E),
              Color(0xFFD62976),
              Color(0xFF962FBF),
              Color(0xFF4F5BD5),
            ],
            stops: [0.0, 0.24, 0.54, 0.78, 1.0],
          ),
        SocialPlatform.moj => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD100),
              Color(0xFFFF7A00),
              Color(0xFFFF2E63),
            ],
          ),
        _ => null,
      };

  String _svgForPlatform(SocialPlatform platform) => switch (platform) {
        SocialPlatform.instagram => _instagramSvg,
        SocialPlatform.youtube => _youtubeSvg,
        SocialPlatform.facebook => _facebookSvg,
        SocialPlatform.snapchat => _snapchatSvg,
        SocialPlatform.tiktok => _tiktokSvg,
        SocialPlatform.x => _xSvg,
        SocialPlatform.reddit => _redditSvg,
        SocialPlatform.moj => _mojSvg,
      };
}

const String _instagramSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <rect x="2.8" y="2.8" width="18.4" height="18.4" rx="5.4" fill="none" stroke="#FFFFFF" stroke-width="2.1"/>
  <circle cx="12" cy="12" r="4.15" fill="none" stroke="#FFFFFF" stroke-width="2.1"/>
  <circle cx="17.3" cy="6.7" r="1.35" fill="#FFFFFF"/>
</svg>
''';

const String _youtubeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#FFFFFF" fill-rule="evenodd" d="M21.58 7.19a2.75 2.75 0 0 0-1.94-1.95C17.93 4.78 12 4.78 12 4.78s-5.93 0-7.64.46A2.75 2.75 0 0 0 2.42 7.19 28.8 28.8 0 0 0 2 12c0 1.63.14 3.25.42 4.81a2.75 2.75 0 0 0 1.94 1.95c1.71.46 7.64.46 7.64.46s5.93 0 7.64-.46a2.75 2.75 0 0 0 1.94-1.95c.28-1.56.42-3.18.42-4.81 0-1.63-.14-3.25-.42-4.81zM10 15.1V8.9L15.4 12 10 15.1z"/>
</svg>
''';

const String _facebookSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#FFFFFF" d="M15.85 24v-8.85h2.98l.45-3.46h-3.43V9.48c0-1 .28-1.68 1.71-1.68h1.83V4.71c-.32-.04-1.41-.14-2.67-.14-2.65 0-4.46 1.62-4.46 4.58v2.54H9.26v3.46h3V24h3.59z"/>
</svg>
''';

const String _snapchatSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#FFFFFF" stroke="#111111" stroke-width="1.35" stroke-linejoin="round" stroke-linecap="round" d="M12 3.1c2.95 0 5.1 2.05 5.1 5.05 0 .7-.1 1.4-.2 1.8.6-.2 1.2-.1 1.5.3.3.4.2 1-.3 1.3-.5.3-1 .5-1.1.7.1.7.7 2.25 2.45 3.25.5.3.8.7.6 1.2-.2.5-.9.7-1.95.8-.4.1-.6.4-.8.8-.2.4-.5.6-1.1.5-.6-.1-1.3-.3-2.2-.1-.9.2-1.45.8-2.05.8s-1.15-.6-2.05-.8c-.9-.2-1.6 0-2.2.1-.6.1-.9-.1-1.1-.5-.2-.4-.4-.7-.8-.8-1.05-.1-1.75-.3-1.95-.8-.2-.5.1-.9.6-1.2 1.75-1 2.35-2.55 2.45-3.25-.1-.2-.6-.4-1.1-.7-.5-.3-.6-.9-.3-1.3.3-.4.9-.5 1.5-.3-.1-.4-.2-1.1-.2-1.8 0-3 2.15-5.05 5.1-5.05z"/>
</svg>
''';

const String _tiktokSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <g transform="translate(-0.85, -0.7)">
    <path fill="#25F4EE" d="M16.6 5.82A4.28 4.28 0 0 1 15.54 3h-3.09v12.4a2.59 2.59 0 0 1-2.59 2.5c-1.42 0-2.6-1.16-2.6-2.6 0-1.47 1.24-2.66 2.75-2.6.2 0 .41.03.62.08V9.66c-3.45-.46-6.47 2.22-6.47 5.64 0 3.33 2.76 5.7 5.69 5.7 3.14 0 5.69-2.55 5.69-5.7V9.01a7.35 7.35 0 0 0 4.3 1.38V7.3s-1.88.09-3.24-1.48z"/>
  </g>
  <g transform="translate(0.85, 0.7)">
    <path fill="#FE2C55" d="M16.6 5.82A4.28 4.28 0 0 1 15.54 3h-3.09v12.4a2.59 2.59 0 0 1-2.59 2.5c-1.42 0-2.6-1.16-2.6-2.6 0-1.47 1.24-2.66 2.75-2.6.2 0 .41.03.62.08V9.66c-3.45-.46-6.47 2.22-6.47 5.64 0 3.33 2.76 5.7 5.69 5.7 3.14 0 5.69-2.55 5.69-5.7V9.01a7.35 7.35 0 0 0 4.3 1.38V7.3s-1.88.09-3.24-1.48z"/>
  </g>
  <path fill="#FFFFFF" d="M16.6 5.82A4.28 4.28 0 0 1 15.54 3h-3.09v12.4a2.59 2.59 0 0 1-2.59 2.5c-1.42 0-2.6-1.16-2.6-2.6 0-1.47 1.24-2.66 2.75-2.6.2 0 .41.03.62.08V9.66c-3.45-.46-6.47 2.22-6.47 5.64 0 3.33 2.76 5.7 5.69 5.7 3.14 0 5.69-2.55 5.69-5.7V9.01a7.35 7.35 0 0 0 4.3 1.38V7.3s-1.88.09-3.24-1.48z"/>
</svg>
''';

const String _xSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#FFFFFF" d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231L18.244 2.25zm-1.161 17.52h1.833L7.084 4.126H5.117L17.083 19.77z"/>
</svg>
''';

const String _redditSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="none" stroke="#FFFFFF" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round" d="M12 8.2L13.5 4.4l3.15.8"/>
  <circle cx="17.9" cy="5.5" r="1.45" fill="#FFFFFF"/>
  <circle cx="4.8" cy="12.2" r="2.05" fill="#FFFFFF"/>
  <circle cx="19.2" cy="12.2" r="2.05" fill="#FFFFFF"/>
  <ellipse cx="12" cy="13.8" rx="7.2" ry="5.5" fill="#FFFFFF"/>
  <circle cx="9.25" cy="13.15" r="1.35" fill="#FF4500"/>
  <circle cx="14.75" cy="13.15" r="1.35" fill="#FF4500"/>
  <path fill="none" stroke="#FF4500" stroke-width="1.35" stroke-linecap="round" d="M9.05 16.15c.82.82 1.82 1.22 2.95 1.22s2.13-.4 2.95-1.22"/>
</svg>
''';

const String _mojSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#FFFFFF" d="M4.3 18.2V6.8c0-.95 1.15-1.4 1.8-.72L12 11.95l5.9-5.87c.65-.68 1.8-.23 1.8.72v11.4a1.35 1.35 0 0 1-2.7 0v-7.4l-4.05 3.95a1.35 1.35 0 0 1-1.9 0L7 10.8v7.4a1.35 1.35 0 0 1-2.7 0z"/>
</svg>
''';
