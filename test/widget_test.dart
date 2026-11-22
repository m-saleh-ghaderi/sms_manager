import 'package:flutter_test/flutter_test.dart';
import 'package:sms_manager/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmsManagerApp());
  });
}
