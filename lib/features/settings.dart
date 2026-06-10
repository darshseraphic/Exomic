import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global state providers for configuration management
final settingsThemeModeProvider = StateProvider<bool>((ref) => true);
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
        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 0.8),
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            '// NOTICE',
            style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          content: Text(
            'MODULE_UNDER_DEV.\nFUTURE_FIRMWARE_REQ.',
            style: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Courier', letterSpacing: 0.2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('[ OK ]', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);

    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('// CONFIG_PANEL', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Courier')),
              const SizedBox(height: 24),

              // THEME INTERFACE RULE
              _buildActionTile(
                label: 'UI_THEME_MODE',
                valueText: isDark ? '[ DARK ]' : '[ LIGHT ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => ref.read(settingsThemeModeProvider.notifier).update((state) => !state),
              ),
              const SizedBox(height: 12),

              // CURRENCY CONTROLLER MATRIX
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('GLOBAL_CURRENCY', style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Courier')),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _currencyController,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
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
              Text('// LOCAL_DOCS', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Courier')),
              const SizedBox(height: 16),

              _buildActionTile(
                label: 'PRIVACY_POLICY',
                valueText: '[ REQ ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'PRIVACY_POLICY',
                    content: '1. TELEMETRY SCOPE\nAll operations, tracking parameters, assets, and computational balance data are recorded exclusively inside isolated client environments. No external synchronization hooks exist.\n\n2. NETWORK DISCONNECT\nThis architecture guarantees offline tracking parameters. No tracking data tokens, category configurations, or logs are shared with developer endpoints or third-party analytical channels.\n\n3. PURGE PRIVILEGES\nThe user holds explicit rights to force-wipe all data matrices instantly from the physical root directory using systemic clear codes.',
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                label: 'DATA_SECURITY',
                valueText: '[ REQ ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'DATA_SECURITY',
                    content: '1. STORAGE LAYERS\nApplication vectors utilize memory-mapped file structures (Hive Boxes) positioned inside standard application directory bounds. Files are inaccessible to parallel installed system software packages.\n\n2. CRYPTO INTEGRITY\nData blocks remain unencrypted by default to minimize compute overhead during operational rendering. Physical platform protection (Device Passcode/Biometrics) serves as the primary barrier against visual data breach.\n\n3. INSTANCE INTEGRITY\nAny manipulation of internal file hashes or hardware-level storage corruptions resets internal matrices to zero parameters to ensure application structural stability.',
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                label: 'USER_GUIDE',
                valueText: '[ REQ ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'USER_GUIDE',
                    content: '1. MATRIX INITIALIZATION\nNavigate to the limits deck. Open configuration to initialize specific operational bounds. Enter category labels and fluid funding thresholds.\n\n2. LIQUIDITY MANAGEMENT\nAccess active liquidity asset decks. Append incoming resource transactions or record mandatory capital outflows. Tracking ledgers calculate margin statistics instantaneously.\n\n3. OVERRUN MITIGATION\nIf the computational outflow breaks configuration bounds, system components flag red alert warnings. Restructure capital vectors immediately.',
                    isDark: isDark,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text('// NETWORK_LINKS', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Courier')),
              const SizedBox(height: 16),

              _buildActionTile(
                label: 'WEB_TERMINAL',
                valueText: '[ PING ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => _showDevDialog(context, isDark),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                label: 'FEEDBACK_PING',
                valueText: '[ PING ]',
                borderColor: borderColor,
                textMain: textMain,
                onTap: () => _showDevDialog(context, isDark),
              ),

              const Spacer(),

              // SYSTEM FOOTER BOUNDARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 0.8))),
                child: Text(
                  'SYS_VER: 1.1.0 // CACHE: ACTV // CRYPTO: IDLE',
                  style: TextStyle(color: textSub, fontSize: 10, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Courier')),
            Text(valueText, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Courier')),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MINIMAL SYSTEM DOCUMENTATION SCREEN
// -----------------------------------------------------------------------------
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

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF999999) : const Color(0xFF444444);
    final bgColor = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                      Icon(Icons.keyboard_arrow_left, color: textSub, size: 16),
                      const SizedBox(width: 2),
                      Text('[ BACK ]', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Courier')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '// $title',
                style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Courier'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      content,
                      style: TextStyle(color: textSub, fontSize: 11, height: 1.6, letterSpacing: 0.2, fontFamily: 'Courier'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}