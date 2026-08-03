import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'constants.dart';
import 'services/api_service.dart';
import 'services/session.dart';
import 'widgets/common.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/student/lab_policies_screen.dart';

// ─── Notification preferences ────────────────────────────────────────────────
// Persisted in shared_preferences and honoured by the student dashboard's
// notification cards (previously the settings toggles were cosmetic — they
// were never saved and nothing read them).
class NotifPrefs {
  static bool approved        = true;
  static bool rejected        = true;
  static bool dueSoon         = true;
  static bool overdue         = true;
  static bool returnConfirmed = true;
  static bool damageUpdate    = false;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    approved        = p.getBool('notif_approved')  ?? true;
    rejected        = p.getBool('notif_rejected')  ?? true;
    dueSoon         = p.getBool('notif_due_soon')  ?? true;
    overdue         = p.getBool('notif_overdue')   ?? true;
    returnConfirmed = p.getBool('notif_return')    ?? true;
    damageUpdate    = p.getBool('notif_damage')    ?? false;
  }

  static Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_approved', approved);
    await p.setBool('notif_rejected', rejected);
    await p.setBool('notif_due_soon', dueSoon);
    await p.setBool('notif_overdue', overdue);
    await p.setBool('notif_return', returnConfirmed);
    await p.setBool('notif_damage', damageUpdate);
  }
}

// ─── App Entry ───────────────────────────────────────────────────────────────
// (The real main() lives in lib/main.dart — this library only exports the app.)

class LabBorrowApp extends StatelessWidget {
  const LabBorrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

// ─── My Borrowings Screen ─────────────────────────────────────────────────────

class MyBorrowingsScreen extends StatefulWidget {
  const MyBorrowingsScreen({super.key});
  @override
  State<MyBorrowingsScreen> createState() => _MyBorrowingsScreenState();
}

class _MyBorrowingsScreenState extends State<MyBorrowingsScreen> {
  // Live Firestore stream: the lists update by themselves when staff approve,
  // reject or process a return — no pull-to-refresh needed.
  late final Stream<List<dynamic>> _stream = ApiService.myBorrowingsStream();

  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return AppTheme.success;
      case 'Pending':  return AppTheme.accent;
      case 'Returned': return AppTheme.textMid;
      case 'Rejected': return AppTheme.danger;
      default:         return AppTheme.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Borrowings')),
            body: const Center(
                child: Text('Could not load your borrowings.',
                    style: TextStyle(color: AppTheme.textMid))),
          );
        }
        final all = snap.data ?? const [];
        final active  = all.where((e) => e['status'] == 'Approved').toList();
        final pending = all.where((e) => e['status'] == 'Pending').toList();
        final history = all.where((e) => e['status'] == 'Returned' || e['status'] == 'Rejected').toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('My Borrowings'),
              bottom: const TabBar(
                indicatorColor: AppTheme.accent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textLight,
                tabs: [Tab(text: 'Active'), Tab(text: 'Pending'), Tab(text: 'History')],
              ),
            ),
            body: TabBarView(
              children: [
                _LiveBorrowList(items: active, statusColorFn: _statusColor),
                _LiveBorrowList(items: pending, statusColorFn: _statusColor),
                _LiveBorrowList(items: history, statusColorFn: _statusColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveBorrowList extends StatelessWidget {
  final List<dynamic> items;
  final Color Function(String) statusColorFn;
  const _LiveBorrowList({required this.items, required this.statusColorFn});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox_rounded, size: 48, color: AppTheme.textLight),
        SizedBox(height: 8),
        Text('No items', style: TextStyle(color: AppTheme.textMid)),
        SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sync_rounded, size: 14, color: AppTheme.textLight),
          SizedBox(width: 6),
          Text('Updates automatically', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
        ]),
      ]));
    }
    return Material(
      color: Colors.transparent,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final e = items[i];
          final status = e['status'] ?? 'Pending';
          final dueDate = e['due_date'] ?? '';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    EquipmentThumb(
                      bytes: photoThumbOf(e),
                      category: e['category'] as String? ?? '',
                      color: AppTheme.primary,
                      size: 46,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e['equipment_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                        Text('${e['qr_code'] ?? ''}  •  Due: $dueDate',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
                      ]),
                    ),
                    StatusBadge(label: status, color: statusColorFn(status)),
                  ],
                ),
                if (status == 'Approved') ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const DamageReportScreen())),
                      icon: const Icon(Icons.report_problem_outlined, size: 16),
                      label: const Text('Report Damage'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.warning,
                          side: const BorderSide(color: AppTheme.warning)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(children: [
                    Icon(Icons.qr_code_2_rounded, size: 13, color: AppTheme.textLight),
                    SizedBox(width: 6),
                    Expanded(
                        child: Text(
                      'Returns are processed by lab staff scanning the QR code on the item.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                    )),
                  ]),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}



// ─── Damage Report Screen ─────────────────────────────────────────────────────

class DamageReportScreen extends StatefulWidget {
  const DamageReportScreen({super.key});
  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  String? _severity;
  String? _selectedEquipmentId;
  String? _selectedEquipmentName;
  bool _loading = false;
  bool _loadingEquipment = true;
  final _descCtrl = TextEditingController();

  // Only equipment the student currently has borrowed (Approved status)
  List<Map<String, dynamic>> _borrowedItems = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowedEquipment();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBorrowedEquipment() async {
    setState(() => _loadingEquipment = true);
    try {
      final loans = await ApiService.getMyBorrowings(
        studentId: Session.currentUser?['student_id'],
        studentNumber: Session.studentNumber,
      );
      // Only Approved (currently borrowed) items
      final active = loans
          .where((e) => e['status'] == 'Approved')
          .map<Map<String, dynamic>>((e) => {
                'equipment_id':   '${e['equipment_id'] ?? ''}',
                'equipment_name': '${e['equipment_name'] ?? 'Unknown'}',
                'qr_code':        '${e['qr_code'] ?? ''}',
                'transaction_id': '${e['transaction_id'] ?? ''}',
              })
          .toList();

      // Remove duplicates by equipment_id
      final seen = <String>{};
      final unique = active.where((e) => seen.add(e['equipment_id']!)).toList();

      setState(() {
        _borrowedItems = unique;
        _loadingEquipment = false;
      });
    } catch (_) {
      setState(() => _loadingEquipment = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedEquipmentId == null || _selectedEquipmentId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select the damaged equipment.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
      return;
    }
    if (_severity == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select the damage severity.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please describe the damage.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.submitDamageReport({
        'equipment_id':   _selectedEquipmentId ?? '',
        'equipment_name': _selectedEquipmentName ?? '',
        'student_id':     Session.currentUser?['student_id']?.toString() ?? '',
        'student_number': Session.studentNumber,
        'borrower_name':  Session.name,
        'severity':       _severity ?? 'Minor',
        'description':    '${_severity ?? 'Minor'}: ${_descCtrl.text.trim()}',
      });
      if (!mounted) return;
      if (res['success'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 52),
            title: const Text('Report Submitted'),
            content: const Text(
                'Your damage report has been submitted. Lab staff will review it shortly.',
                textAlign: TextAlign.center),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message'] ?? 'Submission failed.'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ApiService.friendlyError(e)),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Damage Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0x14EF4444),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x40EF4444))),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Report any damage immediately. Unreported damage may result in clearance issues.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textDark),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Equipment selector — live from borrowed items
            FieldLabel('Equipment (Your Active Loans)'),
            const SizedBox(height: 8),
            _loadingEquipment
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider)),
                    child: const Row(children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Loading your borrowed equipment...',
                          style: TextStyle(color: AppTheme.textMid, fontSize: 13)),
                    ]),
                  )
                : _borrowedItems.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider)),
                        child: const Row(children: [
                          Icon(Icons.inventory_2_outlined,
                              color: AppTheme.textLight, size: 20),
                          SizedBox(width: 10),
                          Text('No active loans found.',
                              style: TextStyle(
                                  color: AppTheme.textMid, fontSize: 13)),
                        ]),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _selectedEquipmentId != null
                                    ? AppTheme.primary
                                    : AppTheme.divider)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedEquipmentId,
                            hint: const Text(
                                'Select borrowed equipment to report',
                                style: TextStyle(
                                    color: AppTheme.textLight, fontSize: 13)),
                            items: _borrowedItems.map((e) {
                              return DropdownMenuItem<String>(
                                value: e['equipment_id'],
                                child: Row(children: [
                                  const Icon(Icons.science_outlined,
                                      size: 16, color: AppTheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(e['equipment_name']!,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textDark)),
                                        Text(e['qr_code']!,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textMid)),
                                      ],
                                    ),
                                  ),
                                ]),
                              );
                            }).toList(),
                            onChanged: (val) {
                              final item = _borrowedItems
                                  .firstWhere((e) => e['equipment_id'] == val);
                              setState(() {
                                _selectedEquipmentId   = val;
                                _selectedEquipmentName = item['equipment_name'];
                              });
                            },
                          ),
                        ),
                      ),

            // Total borrowed count info
            if (!_loadingEquipment && _borrowedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'You currently have ${_borrowedItems.length} item(s) borrowed.',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMid),
                ),
              ),
            const SizedBox(height: 20),

            // Severity selector
            FieldLabel('Damage Severity'),
            const SizedBox(height: 10),
            Row(
              children: ['Minor', 'Moderate', 'Severe'].map((s) {
                final colors = {
                  'Minor':    AppTheme.success,
                  'Moderate': AppTheme.warning,
                  'Severe':   AppTheme.danger,
                };
                final c = colors[s]!;
                final selected = _severity == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? c.withValues(alpha: 0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected ? c : AppTheme.divider,
                            width: selected ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            s == 'Minor'    ? Icons.info_outline_rounded :
                            s == 'Moderate' ? Icons.warning_amber_rounded :
                                              Icons.report_rounded,
                            color: selected ? c : AppTheme.textLight,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(s,
                              style: TextStyle(
                                  color: selected ? c : AppTheme.textMid,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Description
            FieldLabel('Description of Damage'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Describe the damage in detail. Be specific about what is broken, missing, or not working...'),
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(_loading ? 'Submitting...' : 'Submit Report'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMid)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Session.clear();
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0x33F5A623),
                      child: Text(Session.initials,
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text(Session.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${Session.studentNumber}  •  ${courseLabel(Session.currentUser?['course'] ?? 'CEA')}',
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _ProfileStat(label: 'Total\nBorrowed', value: '—'),
                        Container(width: 1, height: 32, color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 20)),
                        const _ProfileStat(label: 'Active\nLoans', value: '—'),
                        Container(width: 1, height: 32, color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 20)),
                        const _ProfileStat(label: 'Late\nReturns', value: '0'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Account Settings ──
                  const SectionHeader(title: 'Account Settings'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _SettingTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  ),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
                  ),
                  const SizedBox(height: 20),

                  // ── Support ──
                  const SectionHeader(title: 'Support'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.policy_rounded,
                    label: 'Laboratory Policies',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LabPoliciesScreen())),
                  ),
                  _SettingTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
                  ),
                  _SettingTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About LabTrack · NEU',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  const SizedBox(height: 20),

                  // ── Sign Out ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: AppTheme.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Profile Screen ──────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  String? _selectedCourse;
  late TextEditingController _yearCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: Session.name);
    final stored = Session.currentUser?['course'] as String?;
    _selectedCourse = kCourses.contains(stored) ? stored : null;
    _yearCtrl = TextEditingController(text: '${Session.currentUser?['year_level'] ?? ''}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name   = _nameCtrl.text.trim();
    final course = _selectedCourse ?? '';
    final yearLevel = int.tryParse(_yearCtrl.text.trim()) ?? 1;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.'), backgroundColor: AppTheme.danger));
      return;
    }

    setState(() => _saving = true);
    try {
      final res = await ApiService.updateProfile(
        studentId: Session.studentId,
        name:      name,
        course:    course,
        yearLevel: yearLevel,
      );
      if (!mounted) return;

      if (res['success'] == true) {
        // Update local session so UI reflects changes immediately
        if (Session.currentUser != null) {
          Session.currentUser!['name']       = name;
          Session.currentUser!['course']     = course;
          Session.currentUser!['year_level'] = yearLevel;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Update failed.'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to server.'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0x26F5A623),
                    child: Text(Session.initials,
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 34,
                            fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Student ID (read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider)),
              child: Row(children: [
                const Icon(Icons.badge_outlined, color: AppTheme.textMid, size: 20),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Student ID', style: TextStyle(fontSize: 11, color: AppTheme.textMid)),
                  Text(Session.studentNumber,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ]),
                const Spacer(),
                const StatusBadge(label: 'Read-only', color: AppTheme.textLight),
              ]),
            ),
            const SizedBox(height: 16),

            FieldLabel('Full Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  hintText: 'e.g. Juan Santos',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textMid)),
            ),
            const SizedBox(height: 16),

            FieldLabel('Course'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  prefixIcon: Icon(Icons.school_outlined, color: AppTheme.textMid)),
              hint: const Text('Select course'),
              isExpanded: true,
              items: kCourses.map((c) => DropdownMenuItem(value: c, child: Text(courseLabel(c)))).toList(),
              onChanged: (v) => setState(() => _selectedCourse = v),
            ),
            const SizedBox(height: 16),

            FieldLabel('Year Level'),
            const SizedBox(height: 8),
            TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'e.g. 3',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.textMid)),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_rounded),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Change Password Screen ───────────────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentCtrl.text.isEmpty || _newCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: AppTheme.danger));
      return;
    }
    if (_newCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters.'), backgroundColor: AppTheme.danger));
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.'), backgroundColor: AppTheme.danger));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 52),
        title: const Text('Password Changed!'),
        content: const Text('Your password has been updated successfully.',
            textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMid),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textMid),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0x121B3A8C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x261B3A8C))),
              child: const Row(children: [
                Icon(Icons.shield_outlined, color: AppTheme.primary, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text(
                    'Use a strong password with at least 8 characters.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textDark))),
              ]),
            ),
            const SizedBox(height: 24),

            _passwordField(
              controller: _currentCtrl,
              label: 'Current Password',
              hint: 'Enter current password', // not bullets — see login field

              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),

            const Divider(color: AppTheme.divider, height: 8),
            const SizedBox(height: 16),

            _passwordField(
              controller: _newCtrl,
              label: 'New Password',
              hint: 'At least 8 characters',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),

            _passwordField(
              controller: _confirmCtrl,
              label: 'Confirm New Password',
              hint: 'Re-enter new password',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.lock_reset_rounded),
                label: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notifications Settings Screen ───────────────────────────────────────────

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});
  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _borrowApproved  = NotifPrefs.approved;
  bool _borrowRejected  = NotifPrefs.rejected;
  bool _dueSoon         = NotifPrefs.dueSoon;
  bool _overdue         = NotifPrefs.overdue;
  bool _returnConfirmed = NotifPrefs.returnConfirmed;
  bool _damageUpdate    = NotifPrefs.damageUpdate;

  @override
  void initState() {
    super.initState();
    // Re-read from disk in case this screen is opened before the dashboard
    // has loaded the preferences.
    NotifPrefs.load().then((_) {
      if (!mounted) return;
      setState(() {
        _borrowApproved  = NotifPrefs.approved;
        _borrowRejected  = NotifPrefs.rejected;
        _dueSoon         = NotifPrefs.dueSoon;
        _overdue         = NotifPrefs.overdue;
        _returnConfirmed = NotifPrefs.returnConfirmed;
        _damageUpdate    = NotifPrefs.damageUpdate;
      });
    });
  }

  Future<void> _save() async {
    NotifPrefs.approved        = _borrowApproved;
    NotifPrefs.rejected        = _borrowRejected;
    NotifPrefs.dueSoon         = _dueSoon;
    NotifPrefs.overdue         = _overdue;
    NotifPrefs.returnConfirmed = _returnConfirmed;
    NotifPrefs.damageUpdate    = _damageUpdate;
    await NotifPrefs.save();
  }

  Widget _notifTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor ?? AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Borrow Requests'),
            const SizedBox(height: 12),
            _notifTile(
              title: 'Request Approved',
              subtitle: 'When staff approves your borrow request',
              value: _borrowApproved,
              onChanged: (v) => setState(() => _borrowApproved = v),
              activeColor: AppTheme.success,
            ),
            _notifTile(
              title: 'Request Rejected',
              subtitle: 'When staff rejects your borrow request',
              value: _borrowRejected,
              onChanged: (v) => setState(() => _borrowRejected = v),
              activeColor: AppTheme.danger,
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Due Dates'),
            const SizedBox(height: 12),
            _notifTile(
              title: 'Due Soon Reminder',
              subtitle: 'Get reminded 1 day before equipment is due',
              value: _dueSoon,
              onChanged: (v) => setState(() => _dueSoon = v),
              activeColor: AppTheme.warning,
            ),
            _notifTile(
              title: 'Overdue Alert',
              subtitle: 'Alert when equipment return is overdue',
              value: _overdue,
              onChanged: (v) => setState(() => _overdue = v),
              activeColor: AppTheme.danger,
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Returns & Reports'),
            const SizedBox(height: 12),
            _notifTile(
              title: 'Return Confirmed',
              subtitle: 'When staff confirms your equipment return',
              value: _returnConfirmed,
              onChanged: (v) => setState(() => _returnConfirmed = v),
            ),
            _notifTile(
              title: 'Damage Report Update',
              subtitle: 'Updates on your submitted damage reports',
              value: _damageUpdate,
              onChanged: (v) => setState(() => _damageUpdate = v),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _save();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification preferences saved!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Help & FAQ Screen ────────────────────────────────────────────────────────

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});
  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int? _expanded;

  final _faqs = const [
    {
      'q': 'How do I borrow equipment?',
      'a': 'Go to the Equipment Catalog, tap on the item you want to borrow, fill in the Borrow Request form, and submit. Your request will be reviewed by lab staff.',
    },
    {
      'q': 'How long can I borrow equipment?',
      'a': 'The borrowing period is set when you submit your request by choosing a return date. Maximum borrowing period is 30 days.',
    },
    {
      'q': 'What happens if I return equipment late?',
      'a': 'Late returns are recorded in your profile. Repeated late returns may affect your borrowing privileges. Always return equipment on or before the due date.',
    },
    {
      'q': 'How do I scan a QR code to borrow?',
      'a': 'Tap "Scan QR" on the home screen, point your camera at the equipment\'s QR code, and the system will automatically identify the equipment for your borrow request.',
    },
    {
      'q': 'What do I do if equipment is damaged?',
      'a': 'Report it immediately using the Damage Report feature. Go to My Borrowings, find the item, and tap "Report". Describe the damage and submit — lab staff will be notified.',
    },
    {
      'q': 'Can I cancel a borrow request?',
      'a': 'You can cancel a pending request by contacting the lab staff directly. Once approved, cancellations must also be done in person at the laboratory.',
    },
    {
      'q': 'I forgot my password, what should I do?',
      'a': 'Tap "Forgot Password?" on the login screen, or contact your lab staff to reset your account credentials.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: Column(
        children: [
          // Banner
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Frequently Asked Questions',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 2),
                Text('Tap a question to see the answer',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
              ])),
            ]),
          ),

          // FAQ List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final isOpen = _expanded == i;
                return GestureDetector(
                  onTap: () => setState(() => _expanded = isOpen ? null : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isOpen ? const Color(0x4D1B3A8C) : AppTheme.divider),
                      boxShadow: isOpen ? [
                        BoxShadow(color: const Color(0x141B3A8C),
                            blurRadius: 8, offset: const Offset(0, 2))
                      ] : [],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                                color: isOpen ? AppTheme.primary : AppTheme.surface,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? Colors.white : AppTheme.textMid)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_faqs[i]['q']!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isOpen ? AppTheme.primary : AppTheme.textDark))),
                          Icon(isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: isOpen ? AppTheme.primary : AppTheme.textLight),
                        ]),
                        if (isOpen) ...[
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.divider, height: 1),
                          const SizedBox(height: 12),
                          Text(_faqs[i]['a']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMid,
                                  height: 1.5)),
                        ],
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),

          // Contact bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            color: Colors.white,
            child: Row(children: [
              const Icon(Icons.mail_outline_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Still need help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
                Text('cea.lab@neu.edu.ph', style: TextStyle(fontSize: 12, color: AppTheme.textMid)),
              ])),
              TextButton(
                onPressed: () {},
                child: const Text('Contact Us', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── About Screen ─────────────────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About LabTrack')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              child: const Column(children: [
                NeuLogo(size: 72),
                SizedBox(height: 16),
                Text('LabTrack',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                SizedBox(height: 4),
                Text('CEA Laboratory · New Era University',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                SizedBox(height: 12),
                StatusBadge(label: 'Version 1.0.0', color: AppTheme.accent),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('About This App', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      SizedBox(height: 10),
                      Text(
                        'LabTrack is a mobile equipment borrowing and return monitoring system '
                        'developed for the College of Engineering and Architecture (CEA) Laboratory '
                        'of New Era University.\n\n'
                        'The system allows students to borrow laboratory equipment digitally, '
                        'track their active loans, and report damage — while giving lab staff '
                        'full visibility and control over inventory.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMid, height: 1.6),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Info tiles
                  _AboutTile(icon: Icons.school_rounded,     label: 'Institution',  value: 'New Era University'),
                  _AboutTile(icon: Icons.business_rounded,   label: 'College',      value: 'College of Engineering & Architecture'),
                  _AboutTile(icon: Icons.code_rounded,       label: 'Platform',     value: 'Flutter (Android & iOS)'),
                  _AboutTile(icon: Icons.storage_rounded,    label: 'Backend',      value: 'PHP + MySQL (Laragon)'),
                  _AboutTile(icon: Icons.calendar_month_rounded, label: 'Year',     value: '2026'),
                  const SizedBox(height: 16),

                  // Divider
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('Developed as a Capstone Project',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text('New Era University · CEA · 2026',
                        style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _AboutTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: const Color(0x141B3A8C),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMid)),
          Text(value,  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ]),
      ]),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SettingTile({required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppTheme.textLight),
        onTap: onTap ?? () {},
      ),
    );
  }
}

