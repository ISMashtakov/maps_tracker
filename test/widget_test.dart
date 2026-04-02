import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maps_tracker/main.dart';

void main() {
  testWidgets('App displays map view with center button', (WidgetTester tester) async {
    await tester.pumpWidget(const MapsTrackerApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
