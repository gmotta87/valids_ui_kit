import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:valids_ui_kit/valids_ui_kit.dart';

void main() {
  testWidgets('ValidsButton renders its label and responds to taps',
      (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: ValidsTheme.lightTheme,
        home: Scaffold(
          body: ValidsButton(
            label: 'Enviar',
            onPressed: () => pressed++,
          ),
        ),
      ),
    );

    expect(find.text('Enviar'), findsOneWidget);

    await tester.tap(find.byType(ValidsButton));
    await tester.pump();

    expect(pressed, 1);
  });
}
