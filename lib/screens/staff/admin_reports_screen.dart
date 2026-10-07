// -----------------------------------------------------------------------------
// LabTrack - staff: admin reports screen
//
// Extracted from firstFile.dart on 2026-08-03 as step 7 of the module split.
//
// 2026-10-07: back to the 1.0.16 page, as the user asked: the 1.0.17 redesign
// (period picker, "At a glance", explained figures, Copy Summary) was more
// than they wanted. Only the download changed: the web portal's "Download
// Excel Report (.xlsx)" saves the workbook from report_xlsx.dart (Summary +
// Borrowing records) instead of the old .csv. Kept from 1.0.17 because they
// are fixes, not looks: no second title bar under the staff header (the
// refresh button sits on the period line instead), Overdue Items counts every
// loan still out as the Dashboard does (not only those sent in the last 90
// days), a message instead of zeros when loading fails, and Most Borrowed by
// item type (ApiService.reportMetrics).
// -----------------------------------------------------------------------------


import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _loading = true;
  bool _failed = false;
  bool _exporting = false;

  // Reporting window. Borrowing figures below cover this many days back, not
  // all time — see the note in _load(). Surfaced in the UI and the exported
  // report so the numbers are never read as lifetime totals.
  static const int _reportPeriodDays = 90;

  // Live stats
  int _totalBorrowings   = 0;
  int _totalReturned     = 0;
  int _totalOverdue      = 0;
  int _totalDamage       = 0;
  int _totalEquipment    = 0;
  double _onTimeRate     = 0;

  // Most borrowed equipment map: name → count
  Map<String, int> _mostBorrowed = {};

  // Recent transactions for export
  List<dynamic> _allTransactions = [];

  // The same period worked out for the Excel report's Summary sheet.
  ReportSummary? _summary;

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
      // Scoped to a reporting period rather than all-time: borrow_transactions
      // grows forever, so an unbounded read here gets more expensive every
      // semester. Equipment and damage totals are counted server-side. All
      // start before any is awaited, so they run concurrently.
      final now     = DateTime.now();
      final cutoff  = now.subtract(const Duration(days: _reportPeriodDays));
      final txF     = ApiService.getRequestsSince(cutoff);
      final openF   = ApiService.getOpenRequests();
      final eqF     = ApiService.getEquipmentStatusCounts();
      final damageF = ApiService.damageReportCount();
      final openDamageF = ApiService.openDamageReportCount();
      final txSnap        = await txF;
      final open          = await openF;
      final equipment     = await eqF;
      final damageReports = await damageF;
      final openDamage    = await openDamageF;

      // Borrowing stats. The counting rules live in ApiService.reportMetrics so
      // they are unit-tested rather than done by hand here — the hand-rolled
      // version counted Pending and Rejected requests as borrowings and worked
      // out "on time" without ever looking at a return date (QA 2026-09-19, M2).
      final m = ApiService.reportMetrics(txSnap, now: now);

      if (!mounted) return;
      setState(() {
        _totalBorrowings  = m['borrowings'] as int;
        _totalReturned    = m['returned'] as int;
        // Every loan still out past its time, whenever it was sent, as on the
        // Dashboard: one sent before the period used to be left out.
        _totalOverdue     = ApiService.overdueLoans(open, now: now).length;
        _totalDamage      = damageReports;
        _totalEquipment   = equipment['Total'] ?? 0;
        _onTimeRate       = m['onTimeRate'] as double;
        _mostBorrowed     = m['mostBorrowed'] as Map<String, int>;
        _allTransactions  = txSnap;
        _summary = ReportSummary.of(txSnap,
            days: _reportPeriodDays, now: now, open: open,
            openDamage: openDamage, equipment: equipment);
        _loading          = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  // ── Generate and share a text report ──────────────────────────────────────
  Future<void> _exportReport() async {
    setState(() => _exporting = true);

    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';

      // Build report text
      final buf = StringBuffer();
      buf.writeln('==============================================');
      buf.writeln('  LABTRACK — CEA LABORATORY REPORT');
      buf.writeln('  New Era University');
      buf.writeln('  Generated: $dateStr at $timeStr');
      buf.writeln('==============================================');
      buf.writeln('');
      buf.writeln('SUMMARY  (last $_reportPeriodDays days)');
      buf.writeln('----------------------------------------------');
      buf.writeln('Borrowing figures below cover the last '
          '$_reportPeriodDays days. Equipment and damage report');
      buf.writeln('totals are current counts.');
      buf.writeln('');
      buf.writeln('Total Borrowings   : $_totalBorrowings');
      buf.writeln('Total Returned     : $_totalReturned');
      buf.writeln('Total Overdue      : $_totalOverdue');
      buf.writeln('Damage Reports     : $_totalDamage');
      buf.writeln('Total Equipment    : $_totalEquipment');
      buf.writeln('On-Time Return Rate: ${_onTimeRate.toStringAsFixed(1)}%');
      buf.writeln('');
      buf.writeln('MOST BORROWED EQUIPMENT');
      buf.writeln('----------------------------------------------');
      int rank = 1;
      _mostBorrowed.forEach((name, cnt) {
        buf.writeln('$rank. $name — ${cnt}x borrowed');
        rank++;
      });

      if (_allTransactions.isNotEmpty) {
        buf.writeln('');
        buf.writeln('TRANSACTION LOG');
        buf.writeln('----------------------------------------------');
        for (final tx in _allTransactions) {
          final status  = tx['status'] ?? '';
          final student = tx['borrower_name'] ?? tx['student_number'] ?? '—';
          final equip   = tx['equipment_name'] ?? '—';
          final bDate   = '${tx['borrow_date'] ?? ''}'.split('T').first;
          buf.writeln('[$status] $student | $equip | $bDate');
        }
      }

      buf.writeln('');
      buf.writeln('==============================================');
      buf.writeln('  END OF REPORT — LabTrack v1.0');
      buf.writeln('==============================================');

      final reportText = buf.toString();

      // Show report in a dialog with copy option
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: const [
            Icon(Icons.assessment_rounded, color: AppTheme.primary),
            SizedBox(width: 10),
            Text('Full Report'),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        reportText,
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 11,
                          color: Color(0xFF00FF88),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap "Copy" to copy the report to your clipboard.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMid),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppTheme.textMid)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Copy to clipboard
                // ignore: deprecated_member_use
                Clipboard.setData(ClipboardData(text: reportText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Report copied to clipboard! Paste it in Notes or Email.'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy Report'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: AppTheme.danger));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Web portal: the period as an Excel workbook ───────────────────────────
  // 2026-10-07: replaces the .csv. Two sheets: Summary (the figures, each
  // explained) and Borrowing records (one row per item asked for, with plain
  // statuses such as "Returned late"); see report_xlsx.dart.
  void _downloadXlsx() {
    final s = _summary;
    if (s == null) return;
    final bytes = ReportXlsx.build(s, _allTransactions, generatedBy: Session.name);
    final ok = downloadBytes(ReportXlsx.fileName(s), bytes,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Downloaded the Excel report: ${_allTransactions.length} '
              '${_allTransactions.length == 1 ? 'record' : 'records'} '
              '(last $_reportPeriodDays days).'
          : 'Downloading is available in the web portal.'),
      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // The period line, with the refresh button that used to sit in this page's
  // own title bar.
  Widget _periodLine() => Row(children: [
        const Icon(Icons.event_note_outlined,
            size: 14, color: AppTheme.textMid),
        const SizedBox(width: 6),
        Expanded(
          child: Text('Borrowing activity — last $_reportPeriodDays days',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMid,
                  fontWeight: FontWeight.w600)),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          onPressed: _load,
          tooltip: 'Refresh',
          visualDensity: VisualDensity.compact,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Two report cards per row on a phone, three on a wide window, all six in
    // one row on a full-size monitor (as on the Dashboard).
    final width = MediaQuery.sizeOf(context).width;
    final cardsPerRow = width >= 1400 ? 6 : width >= 900 ? 3 : 2;
    final cards = [
      _ReportCard(
        label: 'Total\nBorrowings',
        value: '$_totalBorrowings',
        icon: Icons.trending_up_rounded,
        color: AppTheme.accent,
      ),
      _ReportCard(
        label: 'On-Time\nReturns',
        value: '${_onTimeRate.toStringAsFixed(0)}%',
        icon: Icons.check_circle_outline_rounded,
        color: AppTheme.success,
      ),
      _ReportCard(
        label: 'Overdue\nItems',
        value: '$_totalOverdue',
        icon: Icons.warning_amber_rounded,
        color: AppTheme.danger,
      ),
      _ReportCard(
        label: 'Damage\nReports',
        value: '$_totalDamage',
        icon: Icons.report_problem_outlined,
        color: AppTheme.warning,
      ),
      _ReportCard(
        label: 'Total\nEquipment',
        value: '$_totalEquipment',
        icon: Icons.science_rounded,
        color: AppTheme.primary,
      ),
      _ReportCard(
        label: 'Returned\nSuccessfully',
        value: '$_totalReturned',
        icon: Icons.assignment_return_rounded,
        color: AppTheme.success,
      ),
    ];
    final exportButton = ElevatedButton.icon(
      onPressed: _exporting ? null : _exportReport,
      icon: _exporting
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.download_rounded),
      label: Text(_exporting ? 'Generating...' : 'Export Full Report'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14)),
    );
    final xlsxButton = OutlinedButton.icon(
      onPressed: _summary == null ? null : _downloadXlsx,
      icon: const Icon(Icons.table_view_rounded),
      label: const Text('Download Excel Report (.xlsx)'),
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14)),
    );

    // No title bar of its own: the staff header above already says "Reports"
    // (until 2026-10-06 this page showed a second one).
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Borrowing figures are scoped to a period, not all-time.
              _periodLine(),
              const SizedBox(height: 12),

              if (_failed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Text(
                      'Could not load the report. Pull down or tap refresh to try again.',
                      style: TextStyle(color: AppTheme.textMid)),
                )
              else ...[

              // ── Summary Cards ──
              for (var i = 0; i < cards.length; i += cardsPerRow) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(children: [
                  for (var j = i; j < i + cardsPerRow; j++) ...[
                    if (j > i) const SizedBox(width: 12),
                    cards[j],
                  ],
                ]),
              ],
              const SizedBox(height: 24),

              // ── Most Borrowed and Recent Transactions ──
              // Side by side on a full-size monitor.
              if (width >= 1200)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _mostBorrowedSection()),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _recentSection()),
                    ),
                  ],
                )
              else ...[
                ..._mostBorrowedSection(),
                const SizedBox(height: 24),
                ..._recentSection(),
              ],
              const SizedBox(height: 24),

              // ── Export Buttons ── (side by side on a wide window)
              if (kIsWeb && width >= 900)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: exportButton),
                      const SizedBox(width: 12),
                      Expanded(child: xlsxButton),
                    ],
                  ),
                )
              else ...[
                SizedBox(width: double.infinity, child: exportButton),
                if (kIsWeb) ...[
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: xlsxButton),
                ],
              ],
              const SizedBox(height: 8),
              // Full width, so it stays centred when it fits on one line.
              SizedBox(
                width: double.infinity,
                child: Text(
                  kIsWeb
                      ? 'Export Full Report copies a summary to your clipboard. '
                          'Download Excel Report saves the last $_reportPeriodDays '
                          'days as an Excel workbook: a Summary sheet and one row '
                          'per item asked for.'
                      : 'Report will be copied to your clipboard — paste it in Notes, Email, or Google Docs.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
                ),
              ),
              const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Most Borrowed ──
  List<Widget> _mostBorrowedSection() {
    final maxCount = _mostBorrowed.values.isEmpty
        ? 1
        : _mostBorrowed.values.reduce((a, b) => a > b ? a : b);
    return [
      const SectionHeader(title: 'Most Borrowed Equipment'),
      const SizedBox(height: 12),
      if (_mostBorrowed.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14)),
          child: const Center(
            child: Text('No borrowing data yet.',
                style: TextStyle(color: AppTheme.textMid)),
          ),
        )
      else
        ..._mostBorrowed.entries.map((e) {
          final ratio = maxCount > 0 ? e.value / maxCount : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: AppTheme.divider,
                          valueColor: const AlwaysStoppedAnimation(
                              AppTheme.accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text('${e.value}x',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent)),
              ]),
            ),
          );
        }),
    ];
  }

  // ── Recent Transactions ──
  List<Widget> _recentSection() => [
        const SectionHeader(title: 'Recent Transactions'),
        const SizedBox(height: 12),
        if (_allTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: const Center(
              child: Text('No transactions yet.',
                  style: TextStyle(color: AppTheme.textMid)),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: _allTransactions.take(8).map((tx) {
                final status   = tx['status'] ?? '';
                final student  = tx['borrower_name'] ??
                    tx['student_number'] ?? '—';
                final equip    = tx['equipment_name'] ?? '—';
                final bDate    =
                    '${tx['borrow_date'] ?? ''}'.split('T').first.split(' ').first;
                // Cancelled (new in 1.0.17) is grey, as on Requests.
                final sc = status == 'Approved'  ? AppTheme.success
                         : status == 'Pending'   ? AppTheme.accent
                         : status == 'Returned'  ? AppTheme.textMid
                         : status == 'Cancelled' ? AppTheme.textLight
                         : AppTheme.danger;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: sc, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(student, style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: AppTheme.textDark)),
                      Text(equip, style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMid)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      StatusBadge(label: status, color: sc),
                      const SizedBox(height: 2),
                      Text(bDate, style: const TextStyle(
                          fontSize: 10, color: AppTheme.textLight)),
                    ]),
                  ]),
                );
              }).toList(),
            ),
          ),
      ];
}

class _ReportCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ReportCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withAlpha(31),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMid)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

