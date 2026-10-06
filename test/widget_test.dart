// Smoke test for LabTrack.
//
// Pumps the Login screen (which has no Firebase or timer dependencies) and
// verifies the core controls render. This keeps `flutter test` green without
// needing a live Firebase connection.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cea_lab_app/screens/auth/login_screen.dart';
import 'package:cea_lab_app/screens/staff/request_card.dart';
import 'package:cea_lab_app/services/session.dart';

void main() {
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

  testWidgets('Login screen renders core controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    // Sign In button and the (now functional) Forgot password link are present.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });
}
