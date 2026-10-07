// -----------------------------------------------------------------------------
// LabTrack - staff: admin reports screen
//
// Extracted from firstFile.dart on 2026-08-03 as step 7 of the module split.
//
// 2026-10-06 (usability update: staff found Reports hard to understand):
//   • a period picker (7 / 30 / 90 days) instead of a fixed 90 days;
//   • "At a glance": the period in a few plain sentences;
//   • every figure says what it counts, in one line;
//   • the equipment right now, by status (Reserved included);
//   • Most Borrowed by item ("Beaker 1000 mL"), not by single unit;
//   • recent activity with plain statuses ("Returned late", "Not picked up");
//   • the Excel download is an .xlsx workbook built on a template (Summary +
//     Borrowing records, see report_xlsx.dart) instead of a raw .csv, and
//     Copy Summary replaces the old text-dump dialog.
// The figures themselves are worked out in report_summary.dart (unit-tested).
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/file_download.dart';
import '../../services/report_summary.dart';
import '../../services/report_xlsx.dart';
import '../../services/session.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

// ─── Admin Reports Screen ──────────────────────────────────────────────────────

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  // Borrowing figures cover this many days back, not all time:
  // borrow_transactions grows forever, so the read is scoped to a period.
  static const _periods = [7, 30, 90];
  int _days = 30;

  bool _loading = true;
  bool _failed = false;
  ReportSummary? _summary;
  List<dynamic> _txns = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final now = DateTime.now();
      // All four start before any is awaited, so they run concurrently. The
      // open requests feed the "right now" figures, so a loan from before the
      // period that is still out counts as overdue, as on the Dashboard.
      final txF = ApiService.getRequestsSince(now.subtract(Duration(days: _days)));
      final openF = ApiService.getOpenRequests();
      final eqF = ApiService.getEquipmentStatusCounts();
      final damageF = ApiService.openDamageReportCount();
      final txns = await txF;
      final open = await openF;
      final equipment = await eqF;
      final damage = await damageF;
      if (!mounted) return;
      setState(() {
        _txns = txns;
        _summary = ReportSummary.of(txns,
            days: _days, now: now, open: open, openDamage: damage, equipment: equipment);
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _say(String text, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _copySummary(ReportSummary s) async {
    await Clipboard.setData(ClipboardData(text: s.asText(generatedBy: Session.name)));
    if (mounted) _say('Summary copied. Paste it into an email or a document.');
  }

  void _downloadXlsx(ReportSummary s) {
    final bytes = ReportXlsx.build(s, _txns, generatedBy: Session.name);
    final ok = downloadBytes(ReportXlsx.fileName(s), bytes,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    _say(
        ok
            ? 'Downloaded the Excel report: ${_txns.length} '
                '${_txns.length == 1 ? 'record' : 'records'} from the last ${s.days} days.'
            : 'The Excel report downloads from the web portal.',
        ok: ok);
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _periodRow(),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_failed || s == null)
              _box(const Text('Could not load the report. Pull down to try again.',
                  style: TextStyle(color: AppTheme.textMid)))
            else
              ..._report(s),
          ],
        ),
      ),
    );
  }

  Widget _periodRow() => Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Period',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          SegmentedButton<int>(
            segments: [
              for (final d in _periods) ButtonSegment(value: d, label: Text('$d days')),
            ],
            selected: {_days},
            showSelectedIcon: false,
            onSelectionChanged: _loading
                ? null
                : (sel) {
                    setState(() => _days = sel.first);
                    _load();
                  },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          ),
        ],
      );

  Widget _box(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      );

  List<Widget> _report(ReportSummary s) {
    final width = MediaQuery.sizeOf(context).width;
    final perRow = width >= 1400 ? 4 : width >= 900 ? 3 : 2;
    final notBorrowed = s.notPickedUp + s.cancelledByStudents + s.rejected;
    final cards = [
      _FigureCard(
          label: 'Requests sent', value: '${s.requests}',
          meaning: '${s.itemsAsked} ${s.itemsAsked == 1 ? 'item' : 'items'} asked for',
          icon: Icons.assignment_outlined, color: AppTheme.primary),
      _FigureCard(
          label: 'Items handed over', value: '${s.borrowed}',
          meaning: 'Received by students: still out, or back',
          icon: Icons.trending_up_rounded, color: AppTheme.accent),
      _FigureCard(
          label: 'Returned on time',
          value: s.returned == 0 ? '—' : '${(s.onTimeRate * 100).round()}%',
          meaning: s.returned == 0
              ? 'Nothing has come back yet'
              : '${s.onTime} of ${s.returned} returns; ${s.late} late',
          icon: Icons.check_circle_outline_rounded, color: AppTheme.success),
      _FigureCard(
          label: 'Overdue now', value: '${s.overdueNow}',
          meaning: 'Still out after their return time',
          icon: Icons.warning_amber_rounded, color: AppTheme.danger),
      _FigureCard(
          label: 'Waiting for pick-up', value: '${s.readyItems}',
          meaning: 'Approved, set aside at the lab',
          icon: Icons.storefront_outlined, color: AppTheme.primary),
      _FigureCard(
          label: 'Waiting for approval', value: '${s.waitingItems}',
          meaning: 'Sent, not decided yet',
          icon: Icons.hourglass_top_rounded, color: AppTheme.accent),
      _FigureCard(
          label: 'Not borrowed after all', value: '$notBorrowed',
          meaning: 'Requests: ${s.notPickedUp} not picked up, '
              '${s.cancelledByStudents} cancelled, ${s.rejected} rejected',
          icon: Icons.do_not_disturb_on_outlined, color: AppTheme.textMid),
      _FigureCard(
          label: 'Open damage reports', value: '${s.openDamage}',
          meaning: 'Not resolved yet (all time)',
          icon: Icons.report_problem_outlined, color: AppTheme.warning),
    ];

    final copy = OutlinedButton.icon(
      onPressed: () => _copySummary(s),
      icon: const Icon(Icons.copy_rounded),
      label: const Text('Copy Summary'),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
    );
    final xlsx = ElevatedButton.icon(
      onPressed: () => _downloadXlsx(s),
      icon: const Icon(Icons.table_view_rounded),
      label: const Text('Download Excel Report (.xlsx)'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
    );

    return [
      Text('${formatDate(s.from)} to ${formatDate(s.to)}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
      const SizedBox(height: 10),

      // ── At a glance ──
      const SectionHeader(title: 'At a Glance'),
      const SizedBox(height: 10),
      _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final line in s.glance)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 6, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(line,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4))),
            ]),
          ),
      ])),
      const SizedBox(height: 24),

      // ── The figures, each with what it counts ──
      const SectionHeader(title: 'Borrowing'),
      const SizedBox(height: 10),
      for (var i = 0; i < cards.length; i += perRow) ...[
        if (i > 0) const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var j = i; j < i + perRow; j++) ...[
              if (j > i) const SizedBox(width: 12),
              Expanded(child: j < cards.length ? cards[j] : const SizedBox()),
            ],
          ]),
        ),
      ],
      const SizedBox(height: 24),

      // ── Equipment right now ──
      const SectionHeader(title: 'Equipment Right Now'),
      const SizedBox(height: 10),
      _box(Wrap(spacing: 8, runSpacing: 8, children: [
        for (final e in s.equipment.entries)
          StatusBadge(label: '${e.key}: ${e.value}', color: _statusColor(e.key)),
      ])),
      const SizedBox(height: 24),

      // ── Most borrowed, and recent activity ── (side by side when wide)
      if (width >= 1200)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: _mostBorrowed(s))),
          const SizedBox(width: 20),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: _recent())),
        ])
      else ...[
        ..._mostBorrowed(s),
        const SizedBox(height: 24),
        ..._recent(),
      ],
      const SizedBox(height: 24),

      // ── Export ──
      if (kIsWeb && width >= 900)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: xlsx),
            const SizedBox(width: 12),
            Expanded(child: copy),
          ]),
        )
      else ...[
        if (kIsWeb) ...[
          SizedBox(width: double.infinity, child: xlsx),
          const SizedBox(height: 10),
        ],
        SizedBox(width: double.infinity, child: copy),
      ],
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: Text(
          kIsWeb
              ? 'The Excel report has two sheets: Summary (these figures, each '
                  'explained) and Borrowing records (one row per item, with plain '
                  'statuses such as "Returned late" or "Not picked up"). Copy '
                  'Summary puts the figures on your clipboard.'
              : 'Copy Summary puts these figures on your clipboard. The Excel '
                  'report downloads from the web portal.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  Color _statusColor(String status) => switch (status) {
        'Available' => AppTheme.success,
        'Reserved' => AppTheme.accent,
        'Borrowed' => AppTheme.warning,
        'Under Repair' || 'For Disposal' => AppTheme.danger,
        _ => AppTheme.primary,
      };

  Color _outcomeColor(String outcome) => switch (outcome) {
        'Overdue' || 'Returned late' || 'Rejected' => AppTheme.danger,
        'On loan' || 'Returned on time' => AppTheme.success,
        'Ready for pick-up' => AppTheme.primary,
        'Waiting for approval' => AppTheme.accent,
        _ => AppTheme.textMid,
      };

  // ── Most Borrowed ──
  List<Widget> _mostBorrowed(ReportSummary s) {
    final top = s.mostBorrowed;
    final maxCount = top.values.isEmpty ? 1 : top.values.reduce((a, b) => a > b ? a : b);
    return [
      const SectionHeader(title: 'Most Borrowed Items'),
      const SizedBox(height: 10),
      if (top.isEmpty)
        _box(const Center(
          child: Text('Nothing was handed over in this period.',
              style: TextStyle(color: AppTheme.textMid)),
        ))
      else
        for (final e in top.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _box(Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.key,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxCount > 0 ? e.value / maxCount : 0.0,
                      minHeight: 6,
                      backgroundColor: AppTheme.divider,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 16),
              Text('${e.value}×',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent)),
            ])),
          ),
    ];
  }

  // ── Recent activity ──
  List<Widget> _recent() => [
        const SectionHeader(title: 'Recent Activity'),
        const SizedBox(height: 10),
        if (_txns.isEmpty)
          _box(const Center(
            child: Text('Nothing in this period.', style: TextStyle(color: AppTheme.textMid)),
          ))
        else
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              for (final tx in _txns.take(8))
                Builder(builder: (_) {
                  final outcome = ApiService.loanOutcome(tx);
                  final sc = _outcomeColor(outcome);
                  final asked = ApiService.asDate(tx['borrow_date']);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.divider)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: sc, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${tx['borrower_name'] ?? tx['student_number'] ?? '—'}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          Text('${tx['equipment_name'] ?? '—'}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMid)),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        StatusBadge(label: outcome, color: sc),
                        if (asked != null) ...[
                          const SizedBox(height: 2),
                          Text(formatDate(asked),
                              style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                        ],
                      ]),
                    ]),
                  );
                }),
            ]),
          ),
      ];
}

// One figure: its value, its name, and one line on what it counts.
class _FigureCard extends StatelessWidget {
  final String label, value, meaning;
  final IconData icon;
  final Color color;
  const _FigureCard(
      {required this.label,
      required this.value,
      required this.meaning,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withAlpha(31), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(meaning, style: const TextStyle(fontSize: 11, color: AppTheme.textMid)),
          ]),
        ),
      ]),
    );
  }
}
