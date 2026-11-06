import 'package:flutter_test/flutter_test.dart';
import 'package:pracitcas_pm_2p/main.dart';

void main() {
  testWidgets('Smoke test de SensoresPage', (WidgetTester tester) async {
    await tester.pumpWidget(const SensoresPage());
  });
}