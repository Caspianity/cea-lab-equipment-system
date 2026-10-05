// -----------------------------------------------------------------------------
// LabTrack - CSV export of borrowing requests
//
// Added 2026-10-05 for the staff web portal: Reports → "Download for Excel"
// saves the requests of the reporting period as a .csv file. Pure Dart apart
// from the Timestamp type, so the layout and the escaping are unit-tested
// (test/logic_test.dart).
// -----------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class ReportCsv {
  static const List<String> transactionColumns = [
    'Requested', 'Student', 'Student No.', 'Equipment', 'Item Code', 'Status',
    'Return By', 'Returned', 'Condition on Return', 'Subject', 'Purpose',
    'Approved By', 'Received By', 'Reject Reason',
  ];

  // One row per unit record, in the order the list already has (newest first).
  static String transactions(List<dynamic> txs) => build([
        transactionColumns,
        for (final t in txs)
          [
            dateTime(t['borrow_date']),
            t['borrower_name'],
            t['student_number'],
            t['equipment_name'],
            t['qr_code'],
            t['status'],
            dateTime(t['due_date']),
            dateTime(t['return_date']),
            t['condition_returned'],
            t['subject'],
            t['purpose'],
            t['approved_by_name'],
            t['returned_by_name'],
            t['reject_reason'],
          ],
      ]);

  // The whole file: a byte-order mark so Excel reads a name like "Peña" as
  // UTF-8, then CRLF-terminated rows (RFC 4180).
  static String build(List<List<Object?>> rows) =>
      '﻿${rows.map((r) => r.map(field).join(',')).join('\r\n')}\r\n';

  // One cell. Students type the subject and purpose themselves, so a value
  // that starts like a formula (=, +, -, @) gets a leading apostrophe and
  // Excel shows it as text instead of running it (OWASP "CSV injection").
  static String field(Object? v) {
    var s = v == null ? '' : '$v';
    if (s.isNotEmpty && '=+-@\t\r'.contains(s[0])) s = "'$s";
    if (s.contains(RegExp('[",\r\n]'))) s = '"${s.replaceAll('"', '""')}"';
    return s;
  }

  // "2026-10-05 14:30" in local time, which Excel reads as a date and time.
  // Accepts the ISO strings the transaction lists carry, or a raw Timestamp
  // (return_date is not converted by the lists).
  static String dateTime(dynamic v) {
    final d = v is Timestamp ? v.toDate() : DateTime.tryParse('${v ?? ''}');
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}
