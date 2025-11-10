import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zedmoviedesktop/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ZedMovieApp());

    expect(find.text('ZedMovie'), findsOneWidget);
  });
}
