import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetLimit {
  final String category;
  final double allocated;
  final double currentOutflow;

  const BudgetLimit({
    required this.category,
    required this.allocated,
    required this.currentOutflow,
  });
}

final budgetPlannerProvider = StateProvider<List<BudgetLimit>>((ref) {
  return [
    const BudgetLimit(category: 'HARDWARE', allocated: 1000.00, currentOutflow: 850.00),
    const BudgetLimit(category: 'OPERATIONS', allocated: 500.00, currentOutflow: 542.00),
    const BudgetLimit(category: 'INFRASTRUCTURE', allocated: 3000.00, currentOutflow: 1280.00),
    const BudgetLimit(category: 'LIFESTYLE', allocated: 300.00, currentOutflow: 290.00),
  ];
});

class BudgetPlannerScreen extends ConsumerWidget {
  const BudgetPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetPlannerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF737373);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// METRIC_ALLOCATION_COMPARISON_MATRIX', style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 32),

            // Dense Table Structural Headers Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: textMain, width: 1.0)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('CATEGORY_NAME', style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('LIMIT_ALLOCATION', textAlign: TextAlign.right, style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('REAL_OUTFLOW', textAlign: TextAlign.right, style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('REMAINING_MARGIN', textAlign: TextAlign.right, style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                  Expanded(flex: 2, child: Text('SYSTEM_STATUS', textAlign: TextAlign.right, style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                ],
              ),
            ),

            // Grid Rows
            Expanded(
              child: ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final limit = budgets[index];
                  double margin = limit.allocated - limit.currentOutflow;
                  bool isBreached = margin < 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isBreached ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
                      border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            limit.category,
                            style: TextStyle(color: isBreached ? (isDark ? Colors.black : Colors.white) : textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${limit.allocated.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: isBreached ? (isDark ? Colors.black : Colors.white) : textMain, fontSize: 13, letterSpacing: 0.1),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${limit.currentOutflow.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: isBreached ? (isDark ? Colors.black : Colors.white) : textMain, fontSize: 13, letterSpacing: 0.1),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${margin.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: isBreached ? (isDark ? Colors.black : Colors.white) : textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.1),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            isBreached ? '[ BREACH ]' : '[ SAFE ]',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: isBreached ? (isDark ? Colors.black : Colors.white) : textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}