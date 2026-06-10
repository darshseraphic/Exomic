import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database.dart'; // Ensure correct database import path

// Global state providers with persistent initialization
final settingsThemeModeProvider = StateProvider<bool>((ref) {
  return ExomicDatabaseEngine.getThemeMode();
});
final currencyProvider = StateProvider<String>((ref) => '\$');

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currencyController.text = ref.read(currencyProvider);
    });
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void _showDevDialog(BuildContext context, bool isDark) {
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTICE',
                  style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter', letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'This module is currently under active development. Future firmware releases are required to unlock external networking capabilities.',
                  style: TextStyle(color: textSub, fontSize: 13, fontFamily: 'Inter', height: 1.4),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '[ OK ]',
                        style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);

    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final systemTextColor = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);

    return Theme(
      // FIX: Override text selection handles (violet/blue pin) to match custom monochrome aesthetic
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: textMain,
          selectionColor: textMain.withOpacity(0.2),
          selectionHandleColor: textMain,
        ),
      ),
      child: Scaffold(
        backgroundColor: screenBg,
        body: SafeArea(
          // ... inside your _SettingsScreenState build method
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SETTINGS', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter')), // <--- Updated to dynamic white/black textMain
                const SizedBox(height: 24),
                // THEME INTERFACE RULE (WITH PERSISTENT MUTATION)
                _buildActionTile(
                  label: 'UI THEME MODE',
                  valueText: isDark ? '[ DARK ]' : '[ LIGHT ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () async {
                    final newTheme = !isDark;
                    ref.read(settingsThemeModeProvider.notifier).state = newTheme;
                    await ExomicDatabaseEngine.saveThemeMode(newTheme);
                  },
                ),
                const SizedBox(height: 12),

                // CURRENCY CONTROLLER MATRIX
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('GLOBAL CURRENCY', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Inter')),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _currencyController,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: '\$',
                            hintStyle: TextStyle(color: textSub),
                          ),
                          onChanged: (value) {
                            ref.read(currencyProvider.notifier).state = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Text('LOCAL DOCS', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter')),
                const SizedBox(height: 16),

                _buildActionTile(
                  label: 'PRIVACY POLICY',
                  valueText: '[ REQ ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () => _navigateToPage(
                    context,
                    SystemDocumentScreen(
                      title: 'PRIVACY POLICY',
                      content: '1. TELEMETRY SCOPE & ISOLATION\nAll operations, tracking parameters, liquid assets, and computational balance data are recorded exclusively inside isolated client environments. This application operates inside a completely decentralized sandbox. No external synchronization hooks exist to bridge your input data to a broader network.\n\n2. NETWORK DISCONNECT GUARANTEE\nThis architecture guarantees offline-first operational parameters. Your transaction history, subscription tokens, category limits, and goal trackers are never shared with developer endpoints, analytic channels, or third-party marketing services.\n\n3. RIGHT TO PURGE\nData sovereignty belongs to the active user. You hold explicit rights to force-wipe all matrices instantly. Standard uninstallation of the software package physically obliterates the core Hive database vectors, permanently erasing your operational imprint from the device memory blocks.',
                      isDark: isDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  label: 'DATA SECURITY',
                  valueText: '[ REQ ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () => _navigateToPage(
                    context,
                    SystemDocumentScreen(
                      title: 'DATA SECURITY',
                      content: '1. LOCAL STORAGE LAYERS\nApplication persistence vectors utilize memory-mapped file structures (Hive Data Boxes) positioned rigidly inside standard, OS-protected application directory bounds. These files are inaccessible to parallel installed system software packages or file explorers without root access.\n\n2. CRYPTOGRAPHIC INTEGRITY\nData blocks remain locally unencrypted by default to drastically minimize compute overhead during operational rendering, ensuring a perfectly smooth UI layer. Your physical platform protection parameters (Device PIN, Passcode, and Biometrics) serve as the impenetrable primary barrier against visual data breaches.\n\n3. CORRUPTION MITIGATION\nInternal matrix validations monitor hardware-level storage corruptions continuously. If system validation determines that the internal database file mapping has been manipulated, the engine will structurally hard-reset parameters to ensure the application maintains baseline stability and prevents calculation overflow.',
                      isDark: isDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  label: 'USER GUIDE',
                  valueText: '[ REQ ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () => _navigateToPage(
                    context,
                    SystemDocumentScreen(
                      title: 'USER GUIDE',
                      content: '1. MATRIX INITIALIZATION & LIMITS\nBegin navigation via the MATRIX deck. Open configuration windows to initialize specific operational bounds. Enter standard category labels and inject fluid funding thresholds to establish your maximum spending allocations per cycle.\n\n2. LIQUIDITY MANAGEMENT\nAccess active liquidity via the LEDGER. First, append an incoming resource transaction (Monthly Income). You may then record mandatory capital outflows. Tracking engines will calculate margin statistics instantaneously against your configured categories.\n\n3. OVERRUN MITIGATION\nIf your computational outflow permanently breaks configuration bounds, matrix components will flag dynamic red alert warnings. Monitor your POOLS to restructure capital vectors efficiently, and clear unused passive drains in the SUBS section.',
                      isDark: isDark,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Text('NETWORK LINKS', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter')),
                const SizedBox(height: 16),

                _buildActionTile(
                  label: 'WEB TERMINAL',
                  valueText: '[ PING ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () => _showDevDialog(context, isDark),
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  label: 'FEEDBACK PING',
                  valueText: '[ PING ]',
                  borderColor: borderColor,
                  textMain: textMain,
                  onTap: () => _showDevDialog(context, isDark),
                ),

                const Spacer(),

                // SYSTEM FOOTER BOUNDARY (Line Removed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'BUILT BY DARSHSERAPHIC',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSub, fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String label,
    required String valueText,
    required Color borderColor,
    required Color textMain,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Inter')),
            Text(valueText, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

class SystemDocumentScreen extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const SystemDocumentScreen({
    super.key,
    required this.title,
    required this.content,
    required this.isDark,
  });

  Widget _buildParsedContent(String documentText, Color textMain, Color textSub) {
    final sections = documentText.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final lines = section.split('\n');
        if (lines.isEmpty) return const SizedBox.shrink();

        final headline = lines[0];
        final bodyText = lines.skip(1).join('\n');

        return Padding(
          padding: const EdgeInsets.only(bottom: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: TextStyle(
                  color: textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                bodyText,
                style: TextStyle(
                  color: textSub,
                  fontSize: 13,
                  height: 1.6,
                  fontFamily: 'Inter',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF999999) : const Color(0xFF444444);
    final bgColor = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_left, color: textSub, size: 18),
                      const SizedBox(width: 4),
                      Text('[ BACK ]', style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildParsedContent(content, textMain, textSub),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}