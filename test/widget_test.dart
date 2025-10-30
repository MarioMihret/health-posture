import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_health_assistant/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const PostureHealthApp(hasCompletedOnboarding: false));
    
    // Verify that the onboarding screen is shown
    expect(find.text('Welcome to Posture Health'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
  
  testWidgets('Onboarding navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const PostureHealthApp(hasCompletedOnboarding: false));
    
    // Find and tap the Next button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    
    // Verify that we moved to the next onboarding page
    expect(find.text('AI Posture Detection'), findsOneWidget);
  });
  
  testWidgets('Home screen loads for returning users', (WidgetTester tester) async {
    // Simulate a returning user who has completed onboarding
    await tester.pumpWidget(const PostureHealthApp(hasCompletedOnboarding: true));
    await tester.pumpAndSettle();
    
    // Verify that the home screen is shown
    expect(find.text('Let\'s improve your posture'), findsOneWidget);
  });
}
