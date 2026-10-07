// -----------------------------------------------------------------------------
// LabTrack - the Reports figures, in plain words
//
// Added 2026-10-06 (usability update): staff found Reports hard to read. Every
// figure the Reports tab, its copied summary and its .xlsx workbook show is
// worked out here, once, from the period's records, together with the
// sentence that explains it. Pure Dart, so it is unit-tested.
// -----------------------------------------------------------------------------

import '../constants.dart';
import 'api_service.dart';

class ReportSummary {
  final int days;
  final DateTime from, to;
  final int requests;            // requests sent in the period
  final int itemsAsked;          // items in those requests
  final int borrowed;            // items handed over: out now or returned
  final int returned, onTime, late;
  final int overdueNow;          // items out past their return time
  final int readyItems, readyRequests;      // approved, at the lab
  final int waitingItems, waitingRequests;  // not decided yet
  final int notPickedUp;         // requests never collected
  final int cancelledByStudents; // requests taken back before approval
  final int rejected;            // requests refused
  final Map<String, int> mostBorrowed;      // item type → times handed over
  final int openDamage;          // damage reports not resolved (all time)
  final Map<String, int> equipment;         // status → items, and 'Total'

  const ReportSummary({
    required this.days, required this.from, required this.to,
    required this.requests, required this.itemsAsked, required this.borrowed,
    required this.returned, required this.onTime, required this.late,
    required this.overdueNow, required this.readyItems, required this.readyRequests,
    required this.waitingItems, required this.waitingRequests,
    required this.notPickedUp, required this.cancelledByStudents, required this.rejected,
    required this.mostBorrowed, required this.openDamage, required this.equipment,
  });

  // Returned on time, out of all returns (0 to 1).
  double get onTimeRate => returned == 0 ? 0 : onTime / returned;

  // [txns]: the records sent in the period. [open]: every record still
  // Pending or Approved, whenever it was sent; the "right now" figures
  // (overdue, waiting for pick-up, waiting for approval) come from these,
  // so a loan from before the period that is still out counts as overdue,
  // as on the Dashboard. Without [open], the period's records are used.
  factory ReportSummary.of(List<dynamic> txns,
      {required int days,
      DateTime? now,
      List<dynamic>? open,
      int openDamage = 0,
      Map<String, int> equipment = const {}}) {
    final at = now ?? DateTime.now();
    final m = ApiService.reportMetrics(txns, now: at);
    List<dynamic> withOutcome(String o, [List<dynamic>? from]) =>
        (from ?? txns).where((t) => ApiService.loanOutcome(t, now: at) == o).toList();
    int requestsOf(List<dynamic> records) => ApiService.groupRequests(records).length;
    final current = open ?? txns;
    final ready = withOutcome('Ready for pick-up', current);
    final waiting = withOutcome('Waiting for approval', current);
    final returned = m['returned'] as int;
    final onTime = m['onTime'] as int;
    return ReportSummary(
      days: days,
      from: at.subtract(Duration(days: days)),
      to: at,
      requests: requestsOf(txns),
      itemsAsked: txns.length,
      borrowed: m['borrowings'] as int,
      returned: returned,
      onTime: onTime,
      late: returned - onTime,
      overdueNow: ApiService.overdueLoans(current, now: at).length,
      readyItems: ready.length,
      readyRequests: requestsOf(ready),
      waitingItems: waiting.length,
      waitingRequests: requestsOf(waiting),
      notPickedUp: requestsOf(withOutcome('Not picked up')),
      cancelledByStudents: requestsOf(withOutcome('Cancelled by student')),
      rejected: requestsOf(withOutcome('Rejected')),
      mostBorrowed: m['mostBorrowed'] as Map<String, int>,
      openDamage: openDamage,
      equipment: equipment,
    );
  }

  static String _n(int n, String one, [String? many]) =>
      '$n ${n == 1 ? one : (many ?? '${one}s')}';

  // "At a glance": the period in a few plain sentences.
  List<String> get glance {
    final pct = (onTimeRate * 100).round();
    final lines = <String>[
      if (requests == 0)
        'No requests were sent in the last $days days.'
      else
        'Students sent ${_n(requests, 'request')} for ${_n(itemsAsked, 'item')}, '
            'and ${_n(borrowed, 'item was', 'items were')} handed over to them.',
      if (returned > 0)
        '${_n(returned, 'item')} came back: $onTime on time and $late late '
            '($pct% on time).'
      else if (borrowed > 0)
        'Nothing has come back yet.',
      overdueNow == 0
          ? 'Nothing is overdue right now.'
          : '${_n(overdueNow, 'item is', 'items are')} overdue right now. '
              'Penalties & Holds lists who has them.',
      if (readyRequests > 0)
        '${_n(readyRequests, 'approved request is', 'approved requests are')} '
            'waiting at the lab to be picked up.',
      if (waitingRequests > 0)
        '${_n(waitingRequests, 'request is', 'requests are')} waiting for approval.',
      if (notPickedUp + cancelledByStudents + rejected > 0)
        'Not borrowed after all: ${[
          if (notPickedUp > 0) '$notPickedUp not picked up',
          if (cancelledByStudents > 0) '$cancelledByStudents cancelled by students',
          if (rejected > 0) '$rejected rejected',
        ].join(', ')} (requests).',
      if (openDamage > 0)
        '${_n(openDamage, 'damage report is', 'damage reports are')} still open.',
    ];
    return lines;
  }

  // The figures with what each one means, in the order Reports and the
  // workbook's Summary sheet list them: (label, value, meaning). A percent
  // is a double from 0 to 1; everything else is a count.
  List<(String, num, String)> get figures => [
        ('Requests sent', requests,
            'Requests students sent. One request can hold several items.'),
        ('Items asked for', itemsAsked, 'Every item in those requests.'),
        ('Items handed over', borrowed,
            'Items students received: still out, or already back.'),
        ('Returned on time', onTime, 'Back by their return time.'),
        ('Returned late', late, 'Back after their return time.'),
        ('On-time rate', onTimeRate, 'Returned on time, out of all returns.'),
        ('Overdue now', overdueNow,
            'Still out after their return time, right now (from any period).'),
        ('Waiting for pick-up', readyItems,
            'Approved and set aside at the lab right now; not counted as borrowed yet.'),
        ('Waiting for approval', waitingItems,
            'Sent, and not approved or rejected yet (right now).'),
        ('Not picked up', notPickedUp, 'Approved requests the student never collected.'),
        ('Cancelled by students', cancelledByStudents,
            'Requests the student took back before approval.'),
        ('Rejected', rejected, 'Requests staff refused.'),
        ('Open damage reports', openDamage,
            'Damage reported and not resolved yet (all time, not just this period).'),
      ];

  // The summary as plain text, for "Copy Summary".
  String asText({String generatedBy = ''}) {
    final b = StringBuffer()
      ..writeln('LabTrack: CEA Laboratory borrowing report')
      ..writeln('New Era University')
      ..writeln('Period: ${formatDate(from)} to ${formatDate(to)} (last $days days)')
      ..writeln('Generated: ${formatDate(to)}'
          '${generatedBy.isEmpty ? '' : ' by $generatedBy'}')
      ..writeln()
      ..writeln('AT A GLANCE');
    for (final l in glance) {
      b.writeln('- $l');
    }
    b
      ..writeln()
      ..writeln('FIGURES');
    for (final (label, value, _) in figures) {
      b.writeln('$label: ${value is double ? '${(value * 100).round()}%' : value}');
    }
    if (mostBorrowed.isNotEmpty) {
      b
        ..writeln()
        ..writeln('MOST BORROWED ITEMS');
      var rank = 1;
      mostBorrowed.forEach((name, n) => b.writeln('${rank++}. $name: $n'));
    }
    if (equipment.isNotEmpty) {
      b
        ..writeln()
        ..writeln('EQUIPMENT RIGHT NOW');
      equipment.forEach((status, n) => b.writeln('$status: $n'));
    }
    return b.toString();
  }
}
