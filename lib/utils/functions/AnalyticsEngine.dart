import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/firebase_options.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AnalyticsEngine {
  Mixpanel? _mixpanel;

  // Log a custom event
  void logEvent(String eventName) async {
     _mixpanel?.track(
      eventName,
    );
  }
  
}
