import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_entry_app/main.dart';

void main() {
  testWidgets('Task adding test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(TaskEntryApp());

    // Verify that our app has a TextField and an ElevatedButton.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter a task in the TextField.
    await tester.enterText(find.byType(TextField), 'New Task');
    
    // Tap the ElevatedButton to add the task.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Rebuild the widget after the state has changed.

    // Verify that the task is displayed in the ListView.
    expect(find.text('New Task'), findsOneWidget);
  });
}
