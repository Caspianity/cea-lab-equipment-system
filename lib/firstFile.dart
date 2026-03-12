import 'package:flutter/material.dart';

void main() {
  runApp(const LabBorrowApp());
}

// ─── App Entry ───────────────────────────────────────────────────────────────

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

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  static const Color primary = Color(0xFF0A2540);       // Deep navy
  static const Color accent = Color(0xFF00B4D8);        // Cyan-teal
  static const Color success = Color(0xFF06D6A0);       // Mint green
  static const Color warning = Color(0xFFFFB703);       // Amber
  static const Color danger = Color(0xFFEF476F);        // Rose-red
  static const Color surface = Color(0xFFF4F7FB);       // Light gray-blue
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0A2540);
  static const Color textMid = Color(0xFF5A7184);
  static const Color textLight = Color(0xFF9EB3C2);
  static const Color divider = Color(0xFFE4EBF0);

  static ThemeData get lightTheme => ThemeData(
        fontFamily: 'Georgia',
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
        ),
      );
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.accent, width: 2),
                ),
                child: const Icon(Icons.science_rounded,
                    size: 48, color: AppTheme.accent),
              ),
              const SizedBox(height: 24),
              const Text('LabTrack',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('Equipment Borrowing System',
                  style: TextStyle(
                      color: AppTheme.textLight, fontSize: 14, letterSpacing: 1)),
              const SizedBox(height: 60),
              const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Login Screen ─────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isStudent = true;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.science_rounded, size: 52, color: AppTheme.accent),
            const SizedBox(height: 12),
            const Text('LabTrack',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const SizedBox(height: 4),
            const Text('School Laboratory Management',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
            const SizedBox(height: 36),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Role Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _RoleTab(
                                label: 'Student',
                                icon: Icons.school_rounded,
                                selected: _isStudent,
                                onTap: () => setState(() => _isStudent = true)),
                            _RoleTab(
                                label: 'Lab Staff',
                                icon: Icons.admin_panel_settings_rounded,
                                selected: !_isStudent,
                                onTap: () => setState(() => _isStudent = false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text('Welcome back',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Text(
                          _isStudent
                              ? 'Sign in to borrow lab equipment'
                              : 'Sign in to manage the lab',
                          style: const TextStyle(
                              color: AppTheme.textMid, fontSize: 14)),
                      const SizedBox(height: 24),
                      const Text('Student ID / Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2024-00123',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: AppTheme.textMid),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppTheme.textMid),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textMid),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Forgot password?',
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isStudent) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const StudentHomeScreen()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AdminDashboardScreen()));
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                      // ── Sign Up Link (students only) ──
                      if (_isStudent) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.textMid)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen())),
                              child: const Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sign Up Screen ───────────────────────────────────────────────────────────

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  // Live email validation state
  bool get _emailValid =>
      RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@neu\.edu\.ph$')
          .hasMatch(_emailCtrl.text.trim());

  // Live student ID validation
  bool get _idValid =>
      RegExp(r'^\d{2}-\d{5}-\d{3}$').hasMatch(_studentIdCtrl.text.trim());

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@neu\.edu\.ph$')
        .hasMatch(val.trim())) {
      return 'Must be firstname.lastname@neu.edu.ph';
    }
    return null;
  }

  String? _validateStudentId(String? val) {
    if (val == null || val.trim().isEmpty) return 'Required';
    if (!RegExp(r'^\d{2}-\d{5}-\d{3}$').hasMatch(val.trim())) {
      return 'Format: ##-#####-### (e.g. 19-10975-366)';
    }
    return null;
  }

  String? _validateRequired(String? val) {
    if (val == null || val.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Required';
    if (val.length < 8) return 'At least 8 characters';
    return null;
  }

  String? _validateConfirmPass(String? val) {
    if (val == null || val.isEmpty) return 'Required';
    if (val != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  void _submitSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms and Conditions'),
            backgroundColor: AppTheme.danger,
          ),
        );
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Account Created!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark)),
              const SizedBox(height: 10),
              Text(
                  'Welcome, ${_firstNameCtrl.text}! Your account has been created. You can now sign in to LabTrack.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMid)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()));
                  },
                  child: const Text('Go to Sign In'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _studentIdCtrl.dispose();
    _courseCtrl.dispose();
    _yearCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('Student Registration',
                            style: TextStyle(
                                color: AppTheme.textLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: const Text('NEU',
                        style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1)),
                  ),
                ],
              ),
            ),
            // Form Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── SECTION: Identity Verification ──
                        _SectionDivider(
                          icon: Icons.verified_user_outlined,
                          label: 'Identity Verification',
                          color: AppTheme.accent,
                        ),
                        const SizedBox(height: 16),

                        // Institutional Email
                        _FieldLabel('Institutional Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: _validateEmail,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'juan.delacruz@neu.edu.ph',
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppTheme.textMid),
                            suffixIcon: _emailCtrl.text.isNotEmpty
                                ? Icon(
                                    _emailValid
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: _emailValid
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Format: firstname.lastname@neu.edu.ph',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                        const SizedBox(height: 16),

                        // Student ID
                        _FieldLabel('Student ID'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _studentIdCtrl,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          validator: _validateStudentId,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '19-10975-366',
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: AppTheme.textMid),
                            suffixIcon: _studentIdCtrl.text.isNotEmpty
                                ? Icon(
                                    _idValid
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: _idValid
                                        ? AppTheme.success
                                        : AppTheme.danger,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Format: ##-#####-### (e.g. 19-10975-366)',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                        const SizedBox(height: 20),

                        // Info box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.accent.withOpacity(0.2)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: AppTheme.accent),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                    'Your institutional email and Student ID are used to verify that you are an enrolled student. These must match your school records.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMid,
                                        height: 1.5)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── SECTION: Personal Information ──
                        _SectionDivider(
                          icon: Icons.person_outline_rounded,
                          label: 'Personal Information',
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('First Name'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _firstNameCtrl,
                                    validator: _validateRequired,
                                    decoration: const InputDecoration(
                                        hintText: 'Juan'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Last Name'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _lastNameCtrl,
                                    validator: _validateRequired,
                                    decoration: const InputDecoration(
                                        hintText: 'Dela Cruz'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Course / Program'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _courseCtrl,
                                    validator: _validateRequired,
                                    decoration: const InputDecoration(
                                        hintText: 'BSECE'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Year Level'),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    validator: (v) =>
                                        v == null ? 'Required' : null,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 14)),
                                    hint: const Text('Year'),
                                    items: ['1st', '2nd', '3rd', '4th', '5th']
                                        .map((y) => DropdownMenuItem(
                                            value: y, child: Text(y)))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _yearCtrl.text = v ?? ''),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── SECTION: Account Security ──
                        _SectionDivider(
                          icon: Icons.lock_outline_rounded,
                          label: 'Account Security',
                          color: AppTheme.warning,
                        ),
                        const SizedBox(height: 16),

                        _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            hintText: 'Minimum 8 characters',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppTheme.textMid),
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                              child: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMid),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _FieldLabel('Confirm Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: _obscureConfirm,
                          validator: _validateConfirmPass,
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppTheme.textMid),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                              child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMid),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Terms and Conditions
                        GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _agreedToTerms
                                      ? AppTheme.accent
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _agreedToTerms
                                          ? AppTheme.accent
                                          : AppTheme.textLight,
                                      width: 1.5),
                                ),
                                child: _agreedToTerms
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textMid),
                                    children: [
                                      TextSpan(
                                          text: 'Terms and Conditions',
                                          style: TextStyle(
                                              color: AppTheme.accent,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                              color: AppTheme.accent,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              ' of the LabTrack borrowing system.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitSignUp,
                            icon: const Icon(Icons.how_to_reg_rounded),
                            label: const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? ',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.textMid)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sign Up helper widgets ──

class _SectionDivider extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionDivider(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppTheme.divider)),
      ],
    );
  }
}

Widget _FieldLabel(String label) => Text(label,
    style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark));

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _RoleTab(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppTheme.accent : AppTheme.textMid),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textMid,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Student Home Screen ──────────────────────────────────────────────────────

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});
  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _StudentDashboard(),
    EquipmentCatalogScreen(),
    MyBorrowingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textLight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Catalog'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'My Loans'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ─── Student Dashboard ────────────────────────────────────────────────────────

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF0D3561)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.accent.withOpacity(0.2),
                          child: const Text('JS',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning,',
                                style: TextStyle(
                                    color: AppTheme.textLight, fontSize: 12)),
                            Text('Juan Santos',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        Stack(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.notifications_outlined,
                                    color: Colors.white),
                                onPressed: () {}),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppTheme.danger,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  Row(
                    children: [
                      _StatCard(
                          label: 'Active Loans',
                          value: '2',
                          icon: Icons.inventory_2_rounded,
                          color: AppTheme.accent),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Due Today',
                          value: '1',
                          icon: Icons.schedule_rounded,
                          color: AppTheme.warning),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Overdue',
                          value: '0',
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAction(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan QR',
                          color: AppTheme.primary,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const QRScanScreen()))),
                      const SizedBox(width: 12),
                      _QuickAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'New Request',
                          color: AppTheme.accent,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BorrowRequestScreen()))),
                      const SizedBox(width: 12),
                      _QuickAction(
                          icon: Icons.report_problem_outlined,
                          label: 'Report',
                          color: AppTheme.warning,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DamageReportScreen()))),
                      const SizedBox(width: 12),
                      _QuickAction(
                          icon: Icons.history_rounded,
                          label: 'History',
                          color: AppTheme.textMid,
                          onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Loans
                  const SectionHeader(title: 'Active Loans', action: 'See all'),
                  const SizedBox(height: 12),
                  _LoanCard(
                      name: 'Digital Multimeter',
                      id: 'EQ-0042',
                      dueDate: 'Today, 5:00 PM',
                      statusColor: AppTheme.warning,
                      statusLabel: 'Due Soon'),
                  const SizedBox(height: 10),
                  _LoanCard(
                      name: 'Oscilloscope',
                      id: 'EQ-0018',
                      dueDate: 'Mar 7, 5:00 PM',
                      statusColor: AppTheme.success,
                      statusLabel: 'On Time'),
                  const SizedBox(height: 24),

                  // Notifications
                  const SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 12),
                  _NotificationCard(
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.success,
                      title: 'Request Approved',
                      body: 'Your request for Soldering Kit has been approved.',
                      time: '2h ago'),
                  const SizedBox(height: 10),
                  _NotificationCard(
                      icon: Icons.access_alarm_rounded,
                      color: AppTheme.warning,
                      title: 'Due Date Reminder',
                      body: 'Digital Multimeter is due back today at 5:00 PM.',
                      time: '4h ago'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 94,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
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
                          fontSize: 10, color: AppTheme.textMid),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final String name, id, dueDate, statusLabel;
  final Color statusColor;
  const _LoanCard(
      {required this.name,
      required this.id,
      required this.dueDate,
      required this.statusLabel,
      required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.science_outlined,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(id,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMid)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: statusLabel, color: statusColor),
              const SizedBox(height: 4),
              Text(dueDate,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMid)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body, time;
  const _NotificationCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(body,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMid)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}

// ─── Equipment Catalog Screen ─────────────────────────────────────────────────

class EquipmentCatalogScreen extends StatefulWidget {
  const EquipmentCatalogScreen({super.key});
  @override
  State<EquipmentCatalogScreen> createState() => _EquipmentCatalogScreenState();
}

class _EquipmentCatalogScreenState extends State<EquipmentCatalogScreen> {
  String _search = '';
  String _filter = 'All';
  final _categories = ['All', 'Electronics', 'Optics', 'Measurement', 'Tools'];

  final _items = [
    {'name': 'Digital Multimeter', 'id': 'EQ-0042', 'cat': 'Electronics', 'qty': 5, 'available': 3},
    {'name': 'Oscilloscope', 'id': 'EQ-0018', 'cat': 'Electronics', 'qty': 3, 'available': 1},
    {'name': 'Soldering Iron Kit', 'id': 'EQ-0055', 'cat': 'Tools', 'qty': 8, 'available': 6},
    {'name': 'Vernier Caliper', 'id': 'EQ-0031', 'cat': 'Measurement', 'qty': 10, 'available': 7},
    {'name': 'Optical Lens Set', 'id': 'EQ-0067', 'cat': 'Optics', 'qty': 4, 'available': 4},
    {'name': 'Breadboard Kit', 'id': 'EQ-0022', 'cat': 'Electronics', 'qty': 15, 'available': 9},
    {'name': 'Micrometer', 'id': 'EQ-0038', 'cat': 'Measurement', 'qty': 6, 'available': 0},
    {'name': 'Power Supply Unit', 'id': 'EQ-0011', 'cat': 'Electronics', 'qty': 4, 'available': 2},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final matchCat = _filter == 'All' || e['cat'] == _filter;
      final matchSearch = _search.isEmpty ||
          (e['name'] as String).toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Catalog')),
      body: Column(
        children: [
          // Search + Filter
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search equipment...',
                    hintStyle: const TextStyle(color: AppTheme.textLight),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textLight),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.accent, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = _categories[i];
                      final sel = _filter == c;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppTheme.accent
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  color: sel ? Colors.white : AppTheme.textLight,
                                  fontSize: 12,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final e = filtered[i];
                final avail = e['available'] as int;
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BorrowRequestScreen(
                              equipmentName: e['name'] as String))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.science_outlined,
                              color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.textDark)),
                              const SizedBox(height: 2),
                              Text('${e['id']}  •  ${e['cat']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMid)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: AppTheme.divider,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: avail /
                                          (e['qty'] as int),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: avail > 0
                                              ? AppTheme.success
                                              : AppTheme.danger,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$avail/${e['qty']} available',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: avail > 0
                                              ? AppTheme.success
                                              : AppTheme.danger,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                            avail > 0
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.block_rounded,
                            size: 16,
                            color: avail > 0
                                ? AppTheme.accent
                                : AppTheme.danger),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Borrow Request Screen ─────────────────────────────────────────────────────

class BorrowRequestScreen extends StatefulWidget {
  final String? equipmentName;
  const BorrowRequestScreen({super.key, this.equipmentName});
  @override
  State<BorrowRequestScreen> createState() => _BorrowRequestScreenState();
}

class _BorrowRequestScreenState extends State<BorrowRequestScreen> {
  DateTime? _returnDate;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.1))),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.science_outlined,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.equipmentName ?? 'Select Equipment',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 2),
                      const Text('Lab Equipment',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMid)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            _FieldLabel('Borrower Name'),
            const SizedBox(height: 8),
            const TextField(
                decoration: InputDecoration(hintText: 'Juan Santos')),
            const SizedBox(height: 16),
            _FieldLabel('Student ID'),
            const SizedBox(height: 8),
            const TextField(
                decoration: InputDecoration(hintText: '2024-00123')),
            const SizedBox(height: 16),
            _FieldLabel('Subject / Section'),
            const SizedBox(height: 8),
            const TextField(
                decoration:
                    InputDecoration(hintText: 'PHYS101 - Sec A')),
            const SizedBox(height: 16),
            _FieldLabel('Quantity'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () =>
                          setState(() => _qty = (_qty - 1).clamp(1, 10)),
                      icon: const Icon(Icons.remove_rounded)),
                  Expanded(
                      child: Center(
                          child: Text('$_qty',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)))),
                  IconButton(
                      onPressed: () =>
                          setState(() => _qty = (_qty + 1).clamp(1, 10)),
                      icon: const Icon(Icons.add_rounded)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Return Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)));
                if (d != null) setState(() => _returnDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppTheme.textMid, size: 18),
                    const SizedBox(width: 12),
                    Text(
                        _returnDate == null
                            ? 'Select return date'
                            : '${_returnDate!.month}/${_returnDate!.day}/${_returnDate!.year}',
                        style: TextStyle(
                            color: _returnDate == null
                                ? AppTheme.textLight
                                : AppTheme.textDark,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Purpose / Notes'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Describe the purpose of borrowing...'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            icon: const Icon(Icons.check_circle_rounded,
                                color: AppTheme.success, size: 52),
                            title: const Text('Request Submitted!'),
                            content: const Text(
                                'Your borrowing request has been submitted and is awaiting staff approval.',
                                textAlign: TextAlign.center),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Done'))
                            ],
                          ));
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─── QR Scan Screen ───────────────────────────────────────────────────────────

class QRScanScreen extends StatelessWidget {
  const QRScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
          title: const Text('Scan QR / Barcode'),
          backgroundColor: AppTheme.primary),
      body: Stack(
        children: [
          // Simulated camera feed
          Container(
            color: const Color(0xFF0A1628),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scan frame
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accent, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Corner marks
                        ..._buildCorners(),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner_rounded,
                                  color: AppTheme.accent.withOpacity(0.3),
                                  size: 80),
                              const SizedBox(height: 8),
                              Text('Point at QR code',
                                  style: TextStyle(
                                      color: AppTheme.accent.withOpacity(0.6),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Align the QR code or barcode within the frame',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  // Scan mode toggles
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScanModeBtn(label: 'Check-Out', selected: true),
                        _ScanModeBtn(label: 'Check-In', selected: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Manual entry
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.keyboard_alt_outlined,
                        color: AppTheme.accent),
                    label: const Text('Enter ID manually',
                        style: TextStyle(color: AppTheme.accent)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [
      Positioned(
          top: 0,
          left: 0,
          child: _Corner(topLeft: true)),
      Positioned(
          top: 0,
          right: 0,
          child: _Corner(topRight: true)),
      Positioned(
          bottom: 0,
          left: 0,
          child: _Corner(bottomLeft: true)),
      Positioned(
          bottom: 0,
          right: 0,
          child: _Corner(bottomRight: true)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  const _Corner(
      {this.topLeft = false,
      this.topRight = false,
      this.bottomLeft = false,
      this.bottomRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? const BorderSide(color: AppTheme.accent, width: 3)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? const BorderSide(color: AppTheme.accent, width: 3)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? const BorderSide(color: AppTheme.accent, width: 3)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? const BorderSide(color: AppTheme.accent, width: 3)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(4) : Radius.zero,
          topRight: topRight ? const Radius.circular(4) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(4) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(4) : Radius.zero,
        ),
      ),
    );
  }
}

class _ScanModeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  const _ScanModeBtn({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: selected ? Colors.white : AppTheme.textLight,
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    );
  }
}

// ─── My Borrowings Screen ─────────────────────────────────────────────────────

class MyBorrowingsScreen extends StatelessWidget {
  const MyBorrowingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Borrowings'),
          bottom: const TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textLight,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BorrowList(items: _activeItems),
            _BorrowList(items: _pendingItems),
            _BorrowList(items: _historyItems),
          ],
        ),
      ),
    );
  }
}

const _activeItems = [
  {'name': 'Digital Multimeter', 'id': 'EQ-0042', 'due': 'Mar 5, 5:00 PM', 'status': 'Due Soon', 'statusColor': 0xFFFFB703},
  {'name': 'Oscilloscope', 'id': 'EQ-0018', 'due': 'Mar 7, 5:00 PM', 'status': 'Active', 'statusColor': 0xFF06D6A0},
];
const _pendingItems = [
  {'name': 'Soldering Iron Kit', 'id': 'EQ-0055', 'due': 'Mar 8, 5:00 PM', 'status': 'Pending', 'statusColor': 0xFF00B4D8},
];
const _historyItems = [
  {'name': 'Breadboard Kit', 'id': 'EQ-0022', 'due': 'Feb 28, 5:00 PM', 'status': 'Returned', 'statusColor': 0xFF9EB3C2},
  {'name': 'Vernier Caliper', 'id': 'EQ-0031', 'due': 'Feb 20, 5:00 PM', 'status': 'Returned', 'statusColor': 0xFF9EB3C2},
];

class _BorrowList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _BorrowList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child: Text('No items', style: TextStyle(color: AppTheme.textMid)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final e = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.science_outlined,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.textDark)),
                        Text('${e['id']}  •  Due: ${e['due']}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMid)),
                      ],
                    ),
                  ),
                  StatusBadge(
                      label: e['status']!,
                      color: Color(e['statusColor']!)),
                ],
              ),
              if (e['status'] == 'Active' || e['status'] == 'Due Soon') ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DamageReportScreen())),
                        icon: const Icon(Icons.report_problem_outlined,
                            size: 16),
                        label: const Text('Report'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.warning,
                            side: const BorderSide(color: AppTheme.warning)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QRScanScreen())),
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            size: 16),
                        label: const Text('Return'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Damage Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.danger.withOpacity(0.2))),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.danger),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                        'Please report any damage to equipment immediately. This helps us maintain quality for all students.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _FieldLabel('Equipment'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select equipment',
                      style: TextStyle(color: AppTheme.textLight)),
                  items: ['Digital Multimeter (EQ-0042)', 'Oscilloscope (EQ-0018)']
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Severity'),
            const SizedBox(height: 8),
            Row(
              children: ['Minor', 'Moderate', 'Severe'].map((s) {
                final colors = {
                  'Minor': AppTheme.success,
                  'Moderate': AppTheme.warning,
                  'Severe': AppTheme.danger
                };
                final c = colors[s]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _severity == s
                            ? c.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _severity == s ? c : AppTheme.divider,
                            width: _severity == s ? 2 : 1),
                      ),
                      child: Center(
                          child: Text(s,
                              style: TextStyle(
                                  color: _severity == s ? c : AppTheme.textMid,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Description of Damage'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Describe the damage in detail...'),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Photo Evidence (Optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.divider, style: BorderStyle.solid)),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppTheme.textLight, size: 32),
                      SizedBox(height: 6),
                      Text('Tap to add photos',
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            icon: const Icon(Icons.check_circle_rounded,
                                color: AppTheme.success, size: 52),
                            title: const Text('Report Submitted'),
                            content: const Text(
                                'Your damage report has been submitted. Lab staff will review it shortly.',
                                textAlign: TextAlign.center),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'))
                            ],
                          ));
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit Report'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.accent.withOpacity(0.2),
                      child: const Text('JS',
                          style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Juan Santos',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('2024-00123  •  BSECE',
                        style:
                            TextStyle(color: AppTheme.textLight, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProfileStat(label: 'Total\nBorrowed', value: '14'),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                        _ProfileStat(label: 'Active\nLoans', value: '2'),
                        Container(width: 1, height: 32, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                        _ProfileStat(label: 'Late\nReturns', value: '0'),
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
                  const SectionHeader(title: 'Account Settings'),
                  const SizedBox(height: 12),
                  _SettingTile(icon: Icons.person_outline_rounded, label: 'Edit Profile'),
                  _SettingTile(icon: Icons.lock_outline_rounded, label: 'Change Password'),
                  _SettingTile(icon: Icons.notifications_outlined, label: 'Notifications'),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Support'),
                  const SizedBox(height: 12),
                  _SettingTile(icon: Icons.help_outline_rounded, label: 'Help & FAQ'),
                  _SettingTile(icon: Icons.info_outline_rounded, label: 'About LabTrack'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
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
  const _SettingTile({required this.icon, required this.label});
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
        onTap: () {},
      ),
    );
  }
}

// ─── Admin Dashboard Screen ────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _AdminHome(),
    AdminRequestsScreen(),
    EquipmentCatalogScreen(),
    AdminReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textLight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Requests'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Inventory'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Reports'),
          ],
        ),
      ),
    );
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            actions: [
              IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF0D3561)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ADMIN',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ),
                        const SizedBox(width: 10),
                        const Text('Maria Cruz',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Physics Laboratory · March 5, 2026',
                        style: TextStyle(
                            color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin stat grid — explicit rows, no aspect ratio
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _AdminStatCard(
                            label: 'Pending Requests',
                            value: '5',
                            icon: Icons.pending_actions_rounded,
                            color: AppTheme.accent)),
                        const SizedBox(width: 12),
                        Expanded(child: _AdminStatCard(
                            label: 'Active Loans',
                            value: '18',
                            icon: Icons.inventory_2_rounded,
                            color: AppTheme.success)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _AdminStatCard(
                            label: 'Overdue Items',
                            value: '3',
                            icon: Icons.warning_amber_rounded,
                            color: AppTheme.danger)),
                        const SizedBox(width: 12),
                        Expanded(child: _AdminStatCard(
                            label: 'Total Equipment',
                            value: '64',
                            icon: Icons.science_rounded,
                            color: AppTheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pending Requests
                  SectionHeader(
                      title: 'Pending Approvals',
                      action: 'View all',
                      onAction: () {}),
                  const SizedBox(height: 12),
                  _AdminRequestCard(
                      student: 'Juan Santos',
                      studentId: '2024-00123',
                      item: 'Digital Multimeter',
                      dueDate: 'Mar 7'),
                  const SizedBox(height: 10),
                  _AdminRequestCard(
                      student: 'Ana Reyes',
                      studentId: '2024-00145',
                      item: 'Oscilloscope',
                      dueDate: 'Mar 8'),
                  const SizedBox(height: 24),

                  // Overdue alerts
                  const SectionHeader(title: 'Overdue Alerts'),
                  const SizedBox(height: 12),
                  _OverdueCard(
                      student: 'Carlo Lim',
                      item: 'Soldering Kit',
                      overdueDays: 2),
                  const SizedBox(height: 10),
                  _OverdueCard(
                      student: 'Bea Torres',
                      item: 'Vernier Caliper',
                      overdueDays: 1),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _AdminStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMid),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _AdminRequestCard extends StatelessWidget {
  final String student, studentId, item, dueDate;
  const _AdminRequestCard(
      {required this.student,
      required this.studentId,
      required this.item,
      required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accent.withOpacity(0.1),
                child: Text(student[0],
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textDark)),
                    Text('$studentId  •  $item  •  Due $dueDate',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMid)),
                  ],
                ),
              ),
              StatusBadge(label: 'Pending', color: AppTheme.accent),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Deny'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: const BorderSide(color: AppTheme.danger)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  final String student, item;
  final int overdueDays;
  const _OverdueCard(
      {required this.student,
      required this.item,
      required this.overdueDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled_rounded,
              color: AppTheme.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text('$item  •  $overdueDays day${overdueDays > 1 ? 's' : ''} overdue',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMid)),
              ],
            ),
          ),
          TextButton(
              onPressed: () {},
              child: const Text('Notify',
                  style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

// ─── Admin Requests Screen ────────────────────────────────────────────────────

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: const TabBar(
            indicatorColor: AppTheme.accent,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textLight,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'All'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AdminReqList(status: 'Pending', color: AppTheme.accent),
            _AdminReqList(status: 'Approved', color: AppTheme.success),
            _AdminReqList(status: 'All', color: AppTheme.textMid),
          ],
        ),
      ),
    );
  }
}

class _AdminReqList extends StatelessWidget {
  final String status;
  final Color color;
  const _AdminReqList({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    // Different data sets per tab
    final pendingItems = [
      {'student': 'Juan Santos', 'id': '2024-00123', 'item': 'Digital Multimeter', 'due': 'Mar 7', 'qty': '1'},
      {'student': 'Ana Reyes', 'id': '2024-00145', 'item': 'Oscilloscope', 'due': 'Mar 8', 'qty': '1'},
      {'student': 'Leo Cruz', 'id': '2024-00167', 'item': 'Breadboard Kit', 'due': 'Mar 6', 'qty': '2'},
    ];
    final approvedItems = [
      {'student': 'Maria Lim', 'id': '2024-00111', 'item': 'Soldering Kit', 'due': 'Mar 5', 'qty': '1', 'approvedBy': 'Cruz, M.'},
      {'student': 'Carlo Bato', 'id': '2024-00099', 'item': 'Vernier Caliper', 'due': 'Mar 4', 'qty': '3', 'approvedBy': 'Cruz, M.'},
    ];
    final allItems = [
      {'student': 'Juan Santos', 'id': '2024-00123', 'item': 'Digital Multimeter', 'due': 'Mar 7', 'status': 'Pending', 'qty': '1'},
      {'student': 'Ana Reyes', 'id': '2024-00145', 'item': 'Oscilloscope', 'due': 'Mar 8', 'status': 'Pending', 'qty': '1'},
      {'student': 'Maria Lim', 'id': '2024-00111', 'item': 'Soldering Kit', 'due': 'Mar 5', 'status': 'Approved', 'qty': '1'},
      {'student': 'Carlo Bato', 'id': '2024-00099', 'item': 'Vernier Caliper', 'due': 'Mar 4', 'status': 'Approved', 'qty': '3'},
      {'student': 'Leo Cruz', 'id': '2024-00167', 'item': 'Breadboard Kit', 'due': 'Mar 6', 'status': 'Pending', 'qty': '2'},
      {'student': 'Bea Torres', 'id': '2024-00188', 'item': 'Power Supply Unit', 'due': 'Mar 3', 'status': 'Returned', 'qty': '1'},
    ];

    if (status == 'Pending') {
      return _PendingTab(items: pendingItems);
    } else if (status == 'Approved') {
      return _ApprovedTab(items: approvedItems);
    } else {
      return _AllRequestsTab(items: allItems);
    }
  }
}

// ── Pending Tab: shows Approve/Deny action buttons ──
class _PendingTab extends StatelessWidget {
  final List<Map<String, String>> items;
  const _PendingTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary bar
        Container(
          color: AppTheme.accent.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded,
                  color: AppTheme.accent, size: 16),
              const SizedBox(width: 8),
              Text('${items.length} requests awaiting your approval',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final e = items[i];
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppTheme.accent.withOpacity(0.12),
                            child: Text(e['student']![0],
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + badge on same row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(e['student']!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.textDark)),
                                    ),
                                    const SizedBox(width: 6),
                                    StatusBadge(
                                        label: 'Pending',
                                        color: AppTheme.accent),
                                  ],
                                ),
                                Text('ID: ${e['id']}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMid)),
                                const SizedBox(height: 8),
                                // Equipment chip — Flexible prevents overflow
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary
                                              .withOpacity(0.07),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.science_outlined,
                                                size: 12,
                                                color: AppTheme.primary),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(e['item']!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppTheme.primary,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Qty: ${e['qty']}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textMid)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 11, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Text('Due: ${e['due']}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textMid)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: AppTheme.divider)),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.close_rounded,
                                  size: 15),
                              label: const Text('Deny'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.danger,
                                  side: const BorderSide(
                                      color: AppTheme.danger),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check_rounded,
                                  size: 15),
                              label: const Text('Approve Request'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Approved Tab: shows check-in QR scan action ──
class _ApprovedTab extends StatelessWidget {
  final List<Map<String, String>> items;
  const _ApprovedTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.success.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${items.length} approved — ready for equipment release',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final e = items[i];
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.success.withOpacity(0.25))),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.science_outlined,
                              color: AppTheme.success),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['item']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.textDark)),
                              Text(
                                  '${e['student']}  •  Qty: ${e['qty']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMid)),
                            ],
                          ),
                        ),
                        StatusBadge(
                            label: 'Approved', color: AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 13, color: AppTheme.textMid),
                          const SizedBox(width: 6),
                          Text('Approved by: ${e['approvedBy']}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMid)),
                          const Spacer(),
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: AppTheme.textMid),
                          const SizedBox(width: 6),
                          Text('Due: ${e['due']}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMid)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QRScanScreen())),
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            size: 16),
                        label: const Text('Scan to Release Equipment'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── All Requests Tab: compact list with colour-coded status pills + filter ──
class _AllRequestsTab extends StatefulWidget {
  final List<Map<String, String>> items;
  const _AllRequestsTab({required this.items});
  @override
  State<_AllRequestsTab> createState() => _AllRequestsTabState();
}

class _AllRequestsTabState extends State<_AllRequestsTab> {
  String _filter = 'All';

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending': return AppTheme.accent;
      case 'Approved': return AppTheme.success;
      case 'Returned': return AppTheme.textMid;
      default: return AppTheme.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Pending', 'Approved', 'Returned'];
    final visible = _filter == 'All'
        ? widget.items
        : widget.items.where((e) => e['status'] == _filter).toList();

    return Column(
      children: [
        // Filter chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: filters.map((f) {
              final sel = _filter == f;
              final c = _statusColor(f);
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? c : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? c : AppTheme.divider),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppTheme.textMid)),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: AppTheme.divider),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = visible[i];
              final sc = _statusColor(e['status']!);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                      left: BorderSide(color: sc, width: 3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: sc.withOpacity(0.12),
                      child: Text(e['student']![0],
                          style: TextStyle(
                              color: sc,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['student']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.textDark)),
                          Text(
                              '${e['item']}  •  Qty: ${e['qty']}  •  Due: ${e['due']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMid)),
                        ],
                      ),
                    ),
                    StatusBadge(label: e['status']!, color: sc),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Admin Reports Screen ──────────────────────────────────────────────────────

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                _ReportCard(label: 'This Month\nBorrowings', value: '47', icon: Icons.trending_up_rounded, color: AppTheme.accent),
                const SizedBox(width: 12),
                _ReportCard(label: 'On-Time\nReturns', value: '91%', icon: Icons.check_circle_outline_rounded, color: AppTheme.success),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ReportCard(label: 'Total\nOverdue', value: '3', icon: Icons.warning_amber_rounded, color: AppTheme.danger),
                const SizedBox(width: 12),
                _ReportCard(label: 'Damage\nReports', value: '2', icon: Icons.report_problem_outlined, color: AppTheme.warning),
              ],
            ),
            const SizedBox(height: 24),

            // Most Borrowed
            const SectionHeader(title: 'Most Borrowed Equipment'),
            const SizedBox(height: 12),
            ...[
              ('Digital Multimeter', 0.9, '18x'),
              ('Breadboard Kit', 0.72, '14x'),
              ('Oscilloscope', 0.55, '11x'),
              ('Soldering Iron Kit', 0.4, '8x'),
            ].map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.$1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: e.$2,
                                  minHeight: 6,
                                  backgroundColor: AppTheme.divider,
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(e.$3,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export Full Report'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                  color: color.withOpacity(0.12),
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