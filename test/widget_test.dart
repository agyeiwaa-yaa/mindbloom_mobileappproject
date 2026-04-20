import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mindbloom/app/app.dart';

void main() {
  testWidgets('MindBloom app bootstraps', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MindBloomApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
