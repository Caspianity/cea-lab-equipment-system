// -----------------------------------------------------------------------------
// LabTrack - the Reports workbook (.xlsx)
//
// Added 2026-10-06; replaces the .csv download (2026-10-05), which staff found
// confusing: one flat sheet of raw values with stored statuses like
// "Approved" that did not say whether an item was late or ever collected.
// The workbook is a template with two sheets:
//   • Summary: title, period, the figures with what each one means, the most
//     borrowed items, and the equipment right now;
//   • Borrowing records: one row per item asked for, newest first, with bold
//     headers, set widths, real dates, plain statuses ("Returned late", "Not
//     picked up") and a frozen header row with filters.
// Pure Dart apart from the shared helpers: unit-tested.
// -----------------------------------------------------------------------------

import 'dart:typed_data';

import '../constants.dart';
import 'api_service.dart';
import 'report_summary.dart';
import 'xlsx.dart';

class ReportXlsx {
  static const recordColumns = [
    'Requested', 'Student', 'Student No.', 'Item', 'Item code', 'Status',
    'Return by', 'Picked up', 'Returned', 'Condition', 'Subject', 'Purpose',
    'Approved by', 'Handed over by', 'Received by', 'Notes',
  ];
  static const _recordWidths = <double>[
    22, 26, 15, 30, 13, 20, 22, 22, 22, 12, 18, 34, 18, 18, 18, 36,
  ];

  // "labtrack-report-2026-10-06-last-30-days.xlsx"
  static String fileName(ReportSummary s) {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = s.to;
    return 'labtrack-report-${d.year}-${two(d.month)}-${two(d.day)}-last-${s.days}-days.xlsx';
  }

  static Uint8List build(ReportSummary s, List<dynamic> txns,
          {String generatedBy = '', DateTime? now}) =>
      Xlsx.build([
        summarySheet(s, generatedBy: generatedBy),
        recordsSheet(txns, now: now ?? s.to),
      ]);

  static XSheet summarySheet(ReportSummary s, {String generatedBy = ''}) {
    XCell t(Object? v, [int style = Xlsx.normal]) => XCell(v, style);
    final rows = <List<XCell?>>[
      [t('LabTrack: CEA Laboratory Borrowing Report', Xlsx.title)],
      [t('New Era University, College of Engineering and Architecture')],
      [t('Period'), t('${formatDate(s.from)} to ${formatDate(s.to)} (last ${s.days} days)')],
      [t('Generated'), t(s.to, Xlsx.dateTime), if (generatedBy.isNotEmpty) t('by $generatedBy')],
      [],
      [t('At a glance', Xlsx.bold)],
      for (final line in s.glance) [t(line)],
      [],
      [t('Figure', Xlsx.header), t('Value', Xlsx.header), t('What it means', Xlsx.header)],
      for (final (label, value, meaning) in s.figures)
        [t(label), t(value, value is double ? Xlsx.percent : Xlsx.normal), t(meaning, Xlsx.note)],
      [],
      [t('Most borrowed items', Xlsx.header), t('Times handed over', Xlsx.header)],
      if (s.mostBorrowed.isEmpty) [t('No items were handed over in this period.', Xlsx.note)],
      for (final e in s.mostBorrowed.entries) [t(e.key), t(e.value)],
      if (s.equipment.isNotEmpty) ...[
        [],
        [t('Equipment right now', Xlsx.header), t('Items', Xlsx.header)],
        for (final e in s.equipment.entries)
          [t(e.key, e.key == 'Total' ? Xlsx.bold : Xlsx.normal),
           t(e.value, e.key == 'Total' ? Xlsx.bold : Xlsx.normal)],
      ],
      [],
      [t('The "Borrowing records" sheet has one row for every item asked for in '
          'this period, newest first.', Xlsx.note)],
    ];
    return XSheet('Summary', rows, widths: const [30, 26, 64]);
  }

  static XSheet recordsSheet(List<dynamic> txns, {DateTime? now}) {
    XCell? date(dynamic v) {
      final d = ApiService.asDate(v);
      return d == null ? null : XCell(d, Xlsx.dateTime);
    }
    XCell? text(dynamic v, [int style = Xlsx.normal]) {
      final s = '${v ?? ''}'.trim();
      return s.isEmpty ? null : XCell(s, style);
    }
    String notes(dynamic t) => [
          if ('${t['reject_reason'] ?? ''}'.trim().isNotEmpty) 'Reason: ${t['reject_reason']}',
          if ('${t['cancel_reason'] ?? ''}'.trim().isNotEmpty &&
              t['cancel_reason'] != 'Not picked up')
            'Reason: ${t['cancel_reason']}',
          if ('${t['cancelled_by_name'] ?? ''}'.trim().isNotEmpty)
            'Cancelled by ${t['cancelled_by_name']}',
          if ('${t['due_set_by_name'] ?? ''}'.trim().isNotEmpty)
            'Return time set by ${t['due_set_by_name']}',
        ].join('; ');

    return XSheet(
      'Borrowing records',
      [
        [for (final c in recordColumns) XCell(c, Xlsx.header)],
        for (final t in txns)
          [
            date(t['borrow_date']),
            text(t['borrower_name']),
            text(t['student_number']),
            text(t['equipment_name']),
            text(t['qr_code']),
            XCell(ApiService.loanOutcome(t, now: now), Xlsx.bold),
            date(t['due_date']),
            date(t['picked_up_at']),
            date(t['return_date']),
            text(t['condition_returned']),
            text(t['subject']),
            text(t['purpose']),
            text(t['approved_by_name']),
            text(t['picked_up_by_name']),
            text(t['returned_by_name']),
            text(notes(t)),
          ],
      ],
      widths: _recordWidths,
      tableHeader: true,
    );
  }
}
