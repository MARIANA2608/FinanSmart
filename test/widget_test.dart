import 'package:flutter_test/flutter_test.dart';
import 'package:finansmart/main.dart';

void main() {
  testWidgets(
    'FinanSmart inicia correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const FinanSmartApp(
          sesionActiva: false,
        ),
      );

      await tester.pump();

      expect(
        find.text('FinanSmart'),
        findsOneWidget,
      );
    },
  );
}