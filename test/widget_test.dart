// Smoke test for LabTrack.
//
// Pumps the Login screen (which has no Firebase or timer dependencies) and
// verifies the core controls render. This keeps `flutter test` green without
// needing a live Firebase connection.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cea_lab_app/screens/auth/login_screen.dart';
import 'package:cea_lab_app/screens/staff/request_card.dart';
import 'package:cea_lab_app/screens/staff/return_flow.dart';
import 'package:cea_lab_app/screens/student/how_it_works_screen.dart';
import 'package:cea_lab_app/services/session.dart';

void main() {
  // 2026-10-06: the four steps open by themselves once per student, then
  // only from Profile.
  testWidgets('How Borrowing Works opens once per student', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(children: [
            TextButton(
                onPressed: () => HowItWorksScreen.showOnce(context, 's1'),
                child: const Text('open s1')),
            TextButton(
                onPressed: () => HowItWorksScreen.showOnce(context, 's2'),
                child: const Text('open s2')),
          ]),
        ),
      ),
    ));

    await tester.tap(find.text('open s1'));
    await tester.pumpAndSettle();
    expect(find.text('How Borrowing Works'), findsOneWidget);
    for (final step in ['Choose and send', 'Wait for approval',
        'Pick up at the lab', 'Return on time']) {
      expect(find.text(step), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Got it'), 200);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('How Borrowing Works'), findsNothing);

    // Seen: not again for s1, but a second student on this phone gets it.
    await tester.tap(find.text('open s1'));
    await tester.pumpAndSettle();
    expect(find.text('How Borrowing Works'), findsNothing);
    await tester.tap(find.text('open s2'));
    await tester.pumpAndSettle();
    expect(find.text('How Borrowing Works'), findsOneWidget);
  });

  // QA 2026-10-06: approving a request of several units takes seconds, and a
  // second tap meanwhile started a second run.
  testWidgets('A request card runs Approve once and shows it is busy',
      (WidgetTester tester) async {
    Session.set({'role': 'admin'}, 'staff');
    addTearDown(Session.clear);
    final done = Completer<void>();
    var approvals = 0;
    Map<String, dynamic> unit(int n) => {
          'student_id': 's1',
          'borrow_date': '2026-10-06T14:18:00.000',
          'borrower_name': 'Test Student',
          'equipment_name': 'Beaker 1000 mL #$n',
          'qr_code': 'OTH-$n',
          'status': 'Pending',
        };
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PendingRequestCard(
            request: [unit(1), unit(2)],
            onApprove: () {
              approvals++;
              return done.future;
            },
            onReject: () async {},
          ),
        ),
      ),
    ));

    expect(find.text('Approve all 2'), findsOneWidget);
    await tester.tap(find.text('Approve all 2'));
    await tester.pump();
    // Busy: a spinner, and neither button acts until it finishes.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Approve all 2'));
    await tester.tap(find.text('Deny'));
    await tester.pump();
    expect(approvals, 1);

    done.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // Live test 2026-10-07 (U2): on Requests → Approved a returned loan's card
  // leaves the list while the return is saved, and the return step used to
  // stop there: no confirmation, and a damaged return never asked
  // "Log Damage & Hold?".
  group('A return whose card leaves the screen meanwhile', () {
    // Opens the return sheet from a "card" that the list drops as soon as the
    // return starts; the save answers only when the test completes [saved].
    Future<void> openSheet(
        WidgetTester tester, Completer<Map<String, dynamic>> saved) async {
      var showCard = true;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setOuter) => showCard
                ? Builder(
                    builder: (cardContext) => TextButton(
                      onPressed: () => showReturnSheet(
                        cardContext,
                        equipment: const {
                          'equipment_id': 'b1',
                          'equipment_name': 'Beaker 1000 mL #1',
                          'qr_code': 'OTH-1',
                          'status': 'Borrowed',
                        },
                        closeLabel: 'Cancel',
                        doReturn: (condition) {
                          setOuter(() => showCard = false); // the list drops it
                          return saved.future;
                        },
                      ),
                      child: const Text('Mark as Returned'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ));
      await tester.tap(find.text('Mark as Returned'));
      await tester.pumpAndSettle();
    }

    Future<void> returnAs(WidgetTester tester, String button,
        Completer<Map<String, dynamic>> saved) async {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      expect(find.text('Mark as Returned'), findsNothing); // the card is gone
      saved.complete({'success': true, 'borrower_name': 'Test Student'});
      await tester.pumpAndSettle();
    }

    testWidgets('still confirms a good return', (WidgetTester tester) async {
      final saved = Completer<Map<String, dynamic>>();
      await openSheet(tester, saved);
      await returnAs(tester, 'Return — Good Condition', saved);
      expect(find.text('"Beaker 1000 mL #1" marked as returned.'), findsOneWidget);
    });

    testWidgets('still offers Log Damage & Hold for a damaged one',
        (WidgetTester tester) async {
      final saved = Completer<Map<String, dynamic>>();
      await openSheet(tester, saved);
      await returnAs(tester, 'Return — Report Damage', saved);
      expect(find.text('"Beaker 1000 mL #1" returned and marked Under Repair.'),
          findsOneWidget);
      expect(find.text('Log Damage & Hold?'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Log Damage & Hold?'), findsNothing);
    });
  });

  testWidgets('Login screen renders core controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    // Sign In button and the (now functional) Forgot password link are present.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });
}
