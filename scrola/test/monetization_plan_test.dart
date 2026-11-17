import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/ad_service.dart';
import 'package:scrola/core/services/monetization_analytics_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/profile/presentation/screens/subscription_pro_screen.dart';
import 'package:scrola/features/profile/presentation/widgets/notch_pro_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MonetizationAnalyticsService().clearHistoryForTesting();
  });

  test('MonetizationAnalyticsService logs events accurately', () {
    final analytics = MonetizationAnalyticsService();

    analytics.logPaywallViewed(
      featureId: 'subscription_pro_screen',
      planId: 'yearly',
    );
    analytics.logProFeatureTapped(featureId: 'skin_golden');
    analytics.logPurchaseStarted(planId: 'lifetime');
    analytics.logPurchaseCompleted(planId: 'lifetime');
    analytics.logPurchaseRestored();
    analytics.logAdImpression(
      placementId: 'notchSession',
      adUnitId: 'ca-app-pub-test',
    );

    final events = analytics.eventHistory;
    expect(events.length, 6);
    expect(events[0]['event'], 'paywall_viewed');
    expect(events[0]['feature_id'], 'subscription_pro_screen');
    expect(events[0]['plan_id'], 'yearly');

    expect(events[1]['event'], 'pro_feature_tapped');
    expect(events[1]['feature_id'], 'skin_golden');

    expect(events[2]['event'], 'purchase_started');
    expect(events[2]['plan_id'], 'lifetime');

    expect(events[3]['event'], 'purchase_completed');
    expect(events[3]['plan_id'], 'lifetime');

    expect(events[4]['event'], 'purchase_restored');

    expect(events[5]['event'], 'ad_impression');
    expect(events[5]['placement_id'], 'notchSession');
    expect(events[5]['ad_unit_id'], 'ca-app-pub-test');
  });

  test('ProPlanTier defines ₹999 launch offer for Lifetime tier', () {
    expect(ProPlanTier.lifetime.price, '₹999');
    expect(ProPlanTier.lifetime.badge, contains('LAUNCH OFFER'));
    expect(ProPlanTier.lifetime.subtitle, contains('Regular ₹1,499'));
    expect(ProPlanTier.monthly.price, '₹49');
    expect(ProPlanTier.yearly.price, '₹499');
  });

  testWidgets('SubscriptionProScreen logs paywall_viewed on appearance',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SubscriptionProScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final analytics = MonetizationAnalyticsService();
    final paywallEvents = analytics.eventHistory
        .where((e) => e['event'] == 'paywall_viewed')
        .toList();
    expect(paywallEvents, isNotEmpty);
    expect(paywallEvents.first['feature_id'], 'subscription_pro_screen');
  });

  testWidgets('NotchProModal renders ₹999 LAUNCH OFFER for Lifetime preview',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotchProModal(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('LAUNCH OFFER'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
  });
}
