import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart'; // Ensure database syncing works
import 'settings.dart';
import 'expense.dart'; // IMPORTED: Access incomeProvider
import 'subscription.dart'; // IMPORTED: Access subscriptionProvider
import 'saving.dart'; // IMPORTED: Access savingsProvider

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
  final TextEditingController _allocationController = TextEditingController();
  bool _isConfigurationFormOpen = false;

  // DROPDOWN ADAPTATION: Category selection states perfectly synced with expense.dart
  String _selectedCategory = 'INFRASTRUCTURE';
  bool _isCategoryDropdownOpen = false;
  final List<String> _categories = ['INFRASTRUCTURE', 'HARDWARE', 'OPERATIONS', 'LIFESTYLE'];

  @override
  void dispose() {
    _allocationController.dispose();
    super.dispose();
  }

  // UNIFIED SUMMARY ROW COMPONENT: Uses matching style properties for maximum readability
  Widget _buildSummaryRow(String label, String value, TextStyle unifiedStyle, {bool isSavings = false, double dailyPace = 0.0, String currency = '\$'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: unifiedStyle),
            if (isSavings) ...[
              const SizedBox(height: 4),
              Text(
                'DAILY TARGET PACE: $currency${dailyPace.toStringAsFixed(2)}',
                style: TextStyle(color: unifiedStyle.color?.withOpacity(0.5), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
        Text(value, style: unifiedStyle.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetPlannerProvider);

    // DYNAMIC METRIC STREAM INGESTION
    final originalIncome = ref.watch(incomeProvider);
    final subscriptions = ref.watch(subscriptionProvider);
    final savingsGoals = ref.watch(savingsProvider);

    // Direct observations to achieve instantaneous theme and currency updates
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);

    // Reactive styles definition mapping perfectly synced with expense.dart
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    const alertRed = Color(0xFFE63946);

    // UNIFIED READABILITY TEXT STYLE: Matches the "MAXIMUM LIQUIDITY LIMIT CAP" text style
    final readableRowStyle = TextStyle(color: textMain, fontSize: 12, fontFamily: 'Inter');

    // UNASSIGNED LIQUIDITY EQUATION ALGORITHM
    double totalSubscriptions = subscriptions.fold(0.0, (sum, sub) => sum + (sub.isActive ? sub.cost : 0.0));
    double totalSavingsDailyPace = savingsGoals.fold(0.0, (sum, goal) => sum + goal.dailyPaceRequired);
    double totalSavingsMonthlyPace = totalSavingsDailyPace * 30; // Monthly pace projection
    double totalBudgetsAllocated = budgets.fold(0.0, (sum, b) => sum + b.allocated);

    double unassignedLiquidity = originalIncome - totalSubscriptions - totalSavingsMonthlyPace - totalBudgetsAllocated;

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
                          // UPDATED: Renamed to "BUDGET" and changed color to primary white (textMain)
                          Text(
                            'BUDGET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontFamily: 'Inter',
                              color: textMain,
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
                            // ADJUSTABLE DROPDOWN SELECTION COMPONENT (Sourced from expense.dart)
                            Text(
                              'METRIC CATEGORY LABEL',
                              style: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCategoryDropdownOpen = !_isCategoryDropdownOpen;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: specBorderColor)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCategory,
                                      style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                                    ),
                                    AnimatedRotation(
                                      duration: const Duration(milliseconds: 250),
                                      turns: _isCategoryDropdownOpen ? 0.5 : 0.0,
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: textSub,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                              alignment: Alignment.topCenter,
                              child: _isCategoryDropdownOpen
                                  ? Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: specBorderColor, width: 0.8),
                                    right: BorderSide(color: specBorderColor, width: 0.8),
                                    bottom: BorderSide(color: specBorderColor, width: 0.8),
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  children: _categories.map((category) {
                                    final isSelected = category == _selectedCategory;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _isCategoryDropdownOpen = false;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        color: isSelected ? textMain.withOpacity(0.05) : Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              category,
                                              style: TextStyle(
                                                color: isSelected ? textMain : textSub,
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            if (isSelected) Icon(Icons.check, color: textMain, size: 14),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                                  : const SizedBox(width: double.infinity),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _allocationController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: readableRowStyle, // Uses easy to read style
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
                                final String category = _selectedCategory;
                                final double? allocatedAmount = double.tryParse(_allocationController.text);

                                if (allocatedAmount != null && allocatedAmount > 0) {
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

              // UNASSIGNED LIQUIDITY ANALYSIS DASHBOARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: unassignedLiquidity < 0 ? alertRed.withOpacity(isDark ? 0.08 : 0.04) : Colors.transparent,
                    border: Border.all(
                      color: unassignedLiquidity < 0 ? alertRed.withOpacity(0.4) : specBorderColor,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNASSIGNED LIQUIDITY METRIC',
                        style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        unassignedLiquidity < 0
                            ? '-$currency${unassignedLiquidity.abs().toStringAsFixed(2)}'
                            : '$currency${unassignedLiquidity.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: unassignedLiquidity < 0 ? alertRed : textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(color: specBorderColor, height: 1),
                      const SizedBox(height: 14),

                      // UPDATED: All summary rows now match the readable text configuration style perfectly
                      _buildSummaryRow('TOTAL CASH INCOME Stream', '+$currency${originalIncome.toStringAsFixed(2)}', readableRowStyle),
                      const SizedBox(height: 10),
                      _buildSummaryRow('ACTIVE UTILITY SUBSCRIPTIONS', '-$currency${totalSubscriptions.toStringAsFixed(2)}', readableRowStyle),
                      const SizedBox(height: 10),
                      _buildSummaryRow('POOL RESERVES SEGREGATION (MO)', '-$currency${totalSavingsMonthlyPace.toStringAsFixed(2)}', readableRowStyle, isSavings: true, dailyPace: totalSavingsDailyPace, currency: currency),
                      const SizedBox(height: 10),
                      _buildSummaryRow('ALLOCATED BOUNDARY CAPS', '-$currency${totalBudgetsAllocated.toStringAsFixed(2)}', readableRowStyle),
                    ],
                  ),
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