import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_entry_app/src/app/app.dart';

void main() {
  testWidgets('App shows splash then dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskEntryAppShell()));

    expect(find.text('TaskEntry'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
