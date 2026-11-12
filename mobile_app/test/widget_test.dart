import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_auto_care_new/main.dart';

void main() {
  testWidgets('Smart Auto Care welcome screen loads', (
    WidgetTester tester,
  ) async {
    // Simulate a desktop-sized display.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartAutoCareApp());

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Smart Auto Care'), findsOneWidget);
    expect(find.text('Vehicle Care'), findsOneWidget);
    expect(find.text('Find Workshops'), findsOneWidget);
  });
}
