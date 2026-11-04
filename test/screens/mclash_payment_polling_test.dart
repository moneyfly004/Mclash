import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));
  tearDown(() => debugOrderStatusOverride = null);

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showMclashPaymentSheet(
                  context,
                  orderNo: 'poll-test',
                  amount: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('slow polls coalesce timer, resume and manual checks', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>?>();
    var calls = 0;
    debugOrderStatusOverride = (_) {
      calls++;
      return pending.future;
    };
    await open(tester);
    await tester.pump(const Duration(seconds: 12));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.text(t.payment.paidAlready));
    await tester.pump();
    expect(calls, 1);
    pending.complete({'status': 'paid'});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('open'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'failed check releases guard; timeout permits only manual check',
    (tester) async {
      var calls = 0;
      debugOrderStatusOverride = (_) async {
        calls++;
        if (calls == 1) throw StateError('transient');
        return {'status': 'pending'};
      };
      await open(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(calls, 2);
      await tester.pump(const Duration(minutes: 15));
      final atTimeout = calls;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 6));
      expect(calls, atTimeout);
      await tester.tap(find.text(t.payment.paidAlready));
      await tester.pump();
      expect(calls, atTimeout + 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('completion after disposal cannot navigate or restart polling', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>?>();
    var calls = 0;
    debugOrderStatusOverride = (_) {
      calls++;
      return pending.future;
    };
    await open(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete({'status': 'completed'});
    await tester.pump(const Duration(seconds: 10));
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
