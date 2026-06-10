import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/expense.dart';
import 'features/subscription.dart';
import 'features/saving.dart';
import 'features/budget.dart';
import 'features/settings.dart';

// Persistent tracking provider for the active mobile tab index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class ExomicNavbarShell extends ConsumerWidget {
  const ExomicNavbarShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(navigationIndexProvider);

    // Explicitly watch the global theme provider to trigger instant structural frame paints
    final isDark = ref.watch(settingsThemeModeProvider);

    // Dynamic color properties based on active UI theme state
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFB5B5B5);
    final barBackgroundColor = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);

    // Primary mobile viewport stack arrays linking exact code files
    final List<Widget> mobileViewports = [
      const ExpenseLogScreen(),
      const SubscriptionScreen(),
      const SavingGoalsScreen(),
      const BudgetPlannerScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Wrapped IndexedStack in a SafeArea to dynamically shield all tabs from the top notch
      body: SafeArea(
        top: true,
        bottom: false, // Kept false because the bottom navbar already uses its own SafeArea below
        child: IndexedStack(
          index: currentTab,
          children: mobileViewports,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: barBackgroundColor,
          border: Border(
            top: BorderSide(color: specBorderColor, width: 0.8),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 56, // Flat aesthetic spacing for text-only elements
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TextNavbarItem(
                  label: 'LEDGER',
                  isSelected: currentTab == 0,
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _TextNavbarItem(
                  label: 'SUBS',
                  isSelected: currentTab == 1,
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _TextNavbarItem(
                  label: 'POOLS',
                  isSelected: currentTab == 2,
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _TextNavbarItem(
                  label: 'MATRIX',
                  isSelected: currentTab == 3,
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _TextNavbarItem(
                  label: 'CORE',
                  isSelected: currentTab == 4,
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TEXT-ONLY OPTIMIZED COMPONENT WITH MICRO-INTERACTION LOOPS
class _TextNavbarItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _TextNavbarItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 0.5,
              color: isSelected ? activeColor : inactiveColor,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}