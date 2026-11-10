import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScrolaApp());
}

class ScrolaApp extends StatelessWidget {
  const ScrolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrola',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        primaryColor: AppColors.primaryAccent,
        canvasColor: AppColors.primaryBackground,
        cardColor: AppColors.cardSurface,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryAccent,
          secondary: AppColors.accentHighlight,
          surface: AppColors.cardSurface,
          error: AppColors.error,
          onPrimary: AppColors.textOnAccent,
          onSurface: AppColors.primaryText,
          onError: AppColors.primaryText,
        ),
        textTheme: TextTheme(
          bodyLarge: AppTypography.body(),
          bodyMedium: AppTypography.body(),
          labelLarge: AppTypography.label(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
