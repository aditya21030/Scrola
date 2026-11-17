import 'package:flutter/foundation.dart';

/// Lightweight monetization analytics service tracking paywalls, feature gates,
/// purchase funnels, and ad impressions per Section 8 of the Monetization Strategy.
class MonetizationAnalyticsService {
  MonetizationAnalyticsService._();
  static final MonetizationAnalyticsService _instance =
      MonetizationAnalyticsService._();
  factory MonetizationAnalyticsService() => _instance;

  final List<Map<String, dynamic>> _eventHistory = [];

  List<Map<String, dynamic>> get eventHistory =>
      List.unmodifiable(_eventHistory);

  void logPaywallViewed({
    required String featureId,
    String? planId,
  }) {
    final params = <String, dynamic>{
      'feature_id': featureId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (planId != null) {
      params['plan_id'] = planId;
    }
    _recordEvent('paywall_viewed', params);
  }

  void logProFeatureTapped({required String featureId}) {
    _recordEvent('pro_feature_tapped', {
      'feature_id': featureId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logPurchaseStarted({required String planId}) {
    _recordEvent('purchase_started', {
      'plan_id': planId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logPurchaseCompleted({required String planId}) {
    _recordEvent('purchase_completed', {
      'plan_id': planId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logPurchaseRestored() {
    _recordEvent('purchase_restored', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logAdImpression({required String placementId, String? adUnitId}) {
    final params = <String, dynamic>{
      'placement_id': placementId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (adUnitId != null) {
      params['ad_unit_id'] = adUnitId;
    }
    _recordEvent('ad_impression', params);
  }

  void _recordEvent(String eventName, Map<String, dynamic> params) {
    final entry = {
      'event': eventName,
      ...params,
    };
    _eventHistory.add(entry);
    debugPrint('[MonetizationAnalytics] $eventName: $params');
  }

  @visibleForTesting
  void clearHistoryForTesting() {
    _eventHistory.clear();
  }
}
