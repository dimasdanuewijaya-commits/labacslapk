import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack_pro/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LabTrackProApp());
    expect(find.text('ACSL'), findsOneWidget);
  });
}
