import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart'; // Ensure database syncing works
import 'settings.dart';

class BudgetLimit {
  final String category;
  final double allocated;
  final double currentOutflow;

  const BudgetLimit({
    required this.category,
    required this.allocated,
    required this.currentOutflow,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'allocated': allocated,
    'currentOutflow': currentOutflow,
  };

  factory BudgetLimit.fromMap(Map<dynamic, dynamic> map) => BudgetLimit(
    category: map['category'] ?? '',
    allocated: (map['allocated'] as num?)?.toDouble() ?? 0.0,
    currentOutflow: (map['currentOutflow'] as num?)?.toDouble() ?? 0.0,
  );
}

// Global state provider initializing directly from your secure Hive storage instance
final budgetPlannerProvider = StateProvider<List<BudgetLimit>>((ref) {
  final rawList = ExomicDatabaseEngine.budgetBox.values.toList();
  return rawList.map((item) => BudgetLimit(
    category: item.category,
    allocated: item.allocated,
    currentOutflow: item.currentOutflow,
  )).toList();
});

class BudgetPlannerScreen extends ConsumerStatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  ConsumerState<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends ConsumerState<BudgetPlannerScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _allocationController = TextEditingController();
  bool _isConfigurationFormOpen = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _allocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetPlannerProvider);

    // Direct observations to achieve instantaneous theme and currency updates
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);

    // Reactive styles definition mapping perfectly synced with expense.dart
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    const alertRed = Color(0xFFE63946);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: textMain,
          selectionColor: textMain.withOpacity(0.2),
          selectionHandleColor: textMain,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CONFIGURATION ACTION BAR
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isConfigurationFormOpen = !_isConfigurationFormOpen;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BUDGET_PANEL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontFamily: 'Inter',
                              color: textSub,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _isConfigurationFormOpen ? '[ CLOSE ]' : '[ CONFIGURE ]',
                                style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: _isConfigurationFormOpen ? 0.25 : 0.0,
                                child: Icon(Icons.keyboard_arrow_right, color: textSub, size: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      sizeCurve: Curves.easeInOutCubic,
                      firstCurve: Curves.easeInQuad,
                      secondCurve: Curves.easeOutQuad,
                      crossFadeState: _isConfigurationFormOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: specBorderColor, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _categoryController,
                              style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                              decoration: InputDecoration(
                                labelText: 'METRIC CATEGORY LABEL',
                                labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _allocationController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                              decoration: InputDecoration(
                                labelText: 'MAXIMUM LIQUIDITY LIMIT CAP',
                                labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                                prefixText: '$currency ',
                                prefixStyle: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            InkWell(
                              onTap: () async {
                                final String category = _categoryController.text.trim().toUpperCase();
                                final double? allocatedAmount = double.tryParse(_allocationController.text);

                                if (category.isNotEmpty && allocatedAmount != null && allocatedAmount > 0) {
                                  final existingIndex = budgets.indexWhere((element) => element.category == category);
                                  List<BudgetLimit> updatedList;

                                  if (existingIndex != -1) {
                                    final oldBudget = budgets[existingIndex];
                                    updatedList = [...budgets];
                                    updatedList[existingIndex] = BudgetLimit(
                                      category: category,
                                      allocated: allocatedAmount,
                                      currentOutflow: oldBudget.currentOutflow,
                                    );
                                  } else {
                                    updatedList = [
                                      ...budgets,
                                      BudgetLimit(category: category, allocated: allocatedAmount, currentOutflow: 0.0),
                                    ];
                                  }

                                  // Update Riverpod State
                                  ref.read(budgetPlannerProvider.notifier).state = updatedList;

                                  // Save new entry to persistent Hive storage
                                  await ExomicDatabaseEngine.budgetBox.clear();
                                  for (var limit in updatedList) {
                                    await ExomicDatabaseEngine.budgetBox.add(BudgetLimitModel(
                                      category: limit.category,
                                      allocated: limit.allocated,
                                      currentOutflow: limit.currentOutflow,
                                    ));
                                  }

                                  _categoryController.clear();
                                  _allocationController.clear();
                                  setState(() {
                                    _isConfigurationFormOpen = false;
                                  });
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: textMain,
                                alignment: Alignment.center,
                                child: Text(
                                  'INITIALIZE OPERATIONAL CAP',
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: specBorderColor, height: 1),
              ),

              // DATA MATRIX LISTVIEW (MODERN CARD VIEW - NO OVERFLOW)
              budgets.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'NO ACTIVE BOUNDARIES SET',
                    style: TextStyle(color: textSub, fontSize: 12, fontFamily: 'Inter'),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final limit = budgets[index];
                  final double margin = limit.allocated - limit.currentOutflow;
                  final bool isBreached = margin < 0;

                  final Color cardBg = isBreached
                      ? alertRed.withOpacity(isDark ? 0.08 : 0.04)
                      : Colors.transparent;
                  final Color labelColor = isBreached ? alertRed : textMain;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(
                        color: isBreached ? alertRed.withOpacity(0.4) : specBorderColor,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header block: Title and Operational Status Tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onLongPress: () async {
                                  final updatedList = budgets.where((element) => element.category != limit.category).toList();

                                  // Update Riverpod State
                                  ref.read(budgetPlannerProvider.notifier).state = updatedList;

                                  // Handle Hive Database Deletion successfully
                                  await ExomicDatabaseEngine.budgetBox.clear();
                                  for (var b in updatedList) {
                                    await ExomicDatabaseEngine.budgetBox.add(BudgetLimitModel(
                                      category: b.category,
                                      allocated: b.allocated,
                                      currentOutflow: b.currentOutflow,
                                    ));
                                  }
                                },
                                child: Text(
                                  limit.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Inter'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isBreached ? '[ BREACH ]' : '[ SAFE ]',
                              style: TextStyle(
                                color: isBreached ? alertRed : (isDark ? const Color(0xFF4BB543) : const Color(0xFF2E7D32)),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Metric grid block: Distributed proportionally to ensure text space
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LIMIT', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$currency${limit.allocated.toStringAsFixed(0)}',
                                    style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('OUTFLOW', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$currency${limit.currentOutflow.toStringAsFixed(2)}',
                                    style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('MARGIN', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text(
                                    isBreached
                                        ? '-$currency${margin.abs().toStringAsFixed(2)}'
                                        : '$currency${margin.toStringAsFixed(2)}',
                                    style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}