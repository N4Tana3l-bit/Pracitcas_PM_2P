import 'package:flutter_test/flutter_test.dart';
import 'package:pracitcas_pm_2p/main.dart';

void main() {
  testWidgets('Smoke test de BitacoraPage', (WidgetTester tester) async {
    await tester.pumpWidget(const BitacoraPage());
  });
}