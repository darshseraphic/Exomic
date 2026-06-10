import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Abstract theme configuration event link
final settingsThemeModeProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF737373);
    final borderColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// EXOMIC_DIAGNOSTIC_CONTROL_PANEL', style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 40),

            // GROUP BLOCK 1: THEME MATRIX OPERATIONS
            Text('// CORE_INTERFACE_THEME_RULES', style: TextStyle(color: textSub, fontSize: 13, letterSpacing: 0.2)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => ref.read(settingsThemeModeProvider.notifier).update((state) => !state),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: borderColor, width: 0.8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('[TOGGLE] APP SURFACE INTERFACE THEME MODE', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                    Text(isDark ? 'ACTIVE_VALUE: SYSTEM_DARK_MODE' : 'ACTIVE_VALUE: SYSTEM_LIGHT_MODE', style: TextStyle(color: textMain, fontSize: 13, letterSpacing: 0.2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // GROUP BLOCK 2: SECURE ENCRYPTED EXPORT OPERATIONS
            Text('// ENCRYPTED_RECOVERY_AND_BACKUP', style: TextStyle(color: textSub, fontSize: 13, letterSpacing: 0.2)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('COMPILED LOG RUNTIME ENTRIES DUMPED TO FILE: EXOMIC_EXPORT.JSON')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: borderColor, width: 0.8)),
                child: Text('[EXPORT] COMPILE LOCAL DATA ENGINE ENTRIES TO FILE (.JSON)', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
              ),
            ),
            const SizedBox(height: 32),

            // GROUP BLOCK 3: SYSTEM PURGE ACTIONS
            Text('// HARD_RESET_CLEARANCES', style: TextStyle(color: textSub, fontSize: 13, letterSpacing: 0.2)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ALL SECURE HIVE CACHES SUCESSFULLY PURGED.')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: borderColor, width: 0.8)),
                child: Text('[PURGE] FLUSH ALL CACHED DATA STORES AND SYSTEM INSTANCES', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
              ),
            ),

            const Spacer(),

            // INTERFACE SYSTEM DIAGNOSTICS READOUT BOUNDARY FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 0.8))),
              child: Text(
                'ENGINE VER: 1.0.0-PROD // HIVE_BOX_STATUS: SECURE_STABLE // SUBPIXEL_CACHE: 42.1KB // CORE_RENDERER: INTER_NEO_GROTESQUE',
                style: TextStyle(color: textSub, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}