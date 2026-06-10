import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
import 'settings.dart'; // Import to access global theme & currency providers
import 'expense.dart'; // LINKED BACKEND: Imported to access ledgerStreamProvider and ExpenseItem

class SavingGoal {
  final String id;
  final String title;
  final double target;
  final double current;
  final String deadline;
  final double dailyPaceRequired;
  final List<String> history;
  final bool isHistoryExpanded; // UI State tracker for accordion dropdown

  const SavingGoal({
    required this.id,
    required this.title,
    required this.target,
    required this.current,
    required this.deadline,
    required this.dailyPaceRequired,
    required this.history,
    this.isHistoryExpanded = false,
  });

  SavingGoal copyWith({
    String? id,
    String? title,
    double? target,
    double? current,
    String? deadline,
    double? dailyPaceRequired,
    List<String>? history,
    bool? isHistoryExpanded,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      target: target ?? this.target,
      current: current ?? this.current,
      deadline: deadline ?? this.deadline,
      dailyPaceRequired: dailyPaceRequired ?? this.dailyPaceRequired,
      history: history ?? this.history,
      isHistoryExpanded: isHistoryExpanded ?? this.isHistoryExpanded,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'target': target,
    'current': current,
    'deadline': deadline,
    'dailyPaceRequired': dailyPaceRequired,
    'history': history,
  };

  factory SavingGoal.fromMap(Map<dynamic, dynamic> map) => SavingGoal(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    target: (map['target'] as num?)?.toDouble() ?? 0.0,
    current: (map['current'] as num?)?.toDouble() ?? 0.0,
    deadline: map['deadline'] ?? '',
    dailyPaceRequired: (map['dailyPaceRequired'] as num?)?.toDouble() ?? 0.0,
    history: List<String>.from(map['history'] ?? []),
  );
}

// Global provider mapping directly to your app's database storage boxes
final savingsProvider = StateProvider<List<SavingGoal>>((ref) {
  // Explicitly convert stored SavingGoalModel entries into UI-bound SavingGoal instances
  return ExomicDatabaseEngine.savingsBox.values.map((model) => SavingGoal(
    id: model.id,
    title: model.title,
    target: model.target,
    current: model.current,
    deadline: model.deadline,
    dailyPaceRequired: model.dailyPaceRequired,
    history: model.history ?? [],
  )).toList();
});

class SavingGoalsScreen extends ConsumerStatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  ConsumerState<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends ConsumerState<SavingGoalsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  DateTime? _selectedDate;
  bool _isConfigurationFormOpen = false;

  // Local state map to hold active controllers for the inner deposit fields
  final Map<String, TextEditingController> _depositControllers = {};

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    for (var controller in _depositControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getDepositController(String id) {
    if (!_depositControllers.containsKey(id)) {
      _depositControllers[id] = TextEditingController();
    }
    return _depositControllers[id]!;
  }

  Future<void> _selectDate(BuildContext context, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark ? Colors.white : Colors.black,
              onPrimary: isDark ? Colors.black : Colors.white,
              surface: isDark ? const Color(0xFF191919) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _calculateAndAddGoal(List<SavingGoal> currentGoals) async {
    final title = _titleController.text.trim().toUpperCase();
    final target = double.tryParse(_targetController.text);

    if (title.isNotEmpty && target != null && _selectedDate != null) {
      final daysLeft = _selectedDate!.difference(DateTime.now()).inDays;
      final dailyPace = daysLeft > 0 ? target / daysLeft : target;

      final newGoal = SavingGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        target: target,
        current: 0.0,
        deadline: "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
        dailyPaceRequired: dailyPace,
        history: ["INIT: TARGET $target SET FOR ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"],
      );

      final updatedList = [...currentGoals, newGoal];
      ref.read(savingsProvider.notifier).state = updatedList;

      // Transformed structure to a clean SavingGoalModel before DB insertion
      await ExomicDatabaseEngine.savingsBox.put(
        newGoal.id,
        SavingGoalModel(
          id: newGoal.id,
          title: newGoal.title,
          target: newGoal.target,
          current: newGoal.current,
          deadline: newGoal.deadline,
          dailyPaceRequired: newGoal.dailyPaceRequired,
          history: newGoal.history, // Passes history array to DB
        ),
      );

      _titleController.clear();
      _targetController.clear();
      setState(() {
        _selectedDate = null;
        _isConfigurationFormOpen = false;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _processDeposit(SavingGoal goal, String amountText, String currencySymbol) async {
    final depositAmount = double.tryParse(amountText);
    if (depositAmount == null || depositAmount <= 0) return;

    final currentGoals = ref.read(savingsProvider);
    final goalIndex = currentGoals.indexWhere((g) => g.id == goal.id);
    if (goalIndex == -1) return;

    final newCurrent = goal.current + depositAmount;

    // Recalculate daily pace
    final deadlineDate = DateTime.parse(goal.deadline);
    final daysLeft = deadlineDate.difference(DateTime.now()).inDays;
    final remainingAmount = goal.target - newCurrent;
    double newDailyPace = 0.0;

    if (remainingAmount > 0) {
      newDailyPace = daysLeft > 0 ? remainingAmount / daysLeft : remainingAmount;
    }

    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final logEntry = "[$timeString] +$currencySymbol${depositAmount.toStringAsFixed(0)}";

    final updatedGoal = goal.copyWith(
      current: newCurrent,
      dailyPaceRequired: newDailyPace,
      history: [...goal.history, logEntry],
    );

    final updatedList = [...currentGoals];
    updatedList[goalIndex] = updatedGoal;

    ref.read(savingsProvider.notifier).state = updatedList;

    // Transformed structure to a clean SavingGoalModel before DB updates
    await ExomicDatabaseEngine.savingsBox.put(
      updatedGoal.id,
      SavingGoalModel(
        id: updatedGoal.id,
        title: updatedGoal.title,
        target: updatedGoal.target,
        current: updatedGoal.current,
        deadline: updatedGoal.deadline,
        dailyPaceRequired: updatedGoal.dailyPaceRequired,
        history: updatedGoal.history, // Passes history array to DB
      ),
    );

    // =========================================================================
    // CROSS-OVER LINKING LOGIC (Affects Running Balance dynamically)
    // =========================================================================
    final dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final transactionTimestamp = "$dateString $timeString";

    final savingsInterceptionItem = ExpenseItem(
      timestamp: transactionTimestamp,
      description: "DEPOSIT: ${goal.title}",
      category: "OPERATIONS",
      amount: -depositAmount, // Passing negative decreases month deductions, increasing Running Balance
    );

    final currentLedger = ref.read(ledgerStreamProvider);
    final updatedLedger = [savingsInterceptionItem, ...currentLedger];

    // Triggers instantaneous state notifications across all active widget systems
    ref.read(ledgerStreamProvider.notifier).state = updatedLedger;

    // Persists the newly intercepted array directly into standard encrypted storage structures
    await ExomicDatabaseEngine.saveHistory(updatedLedger.map((e) => e.toMap()).toList());
    // =========================================================================

    _getDepositController(goal.id).clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(savingsProvider);

    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);

    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final progressBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0);

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
        body: Column(
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
                    child: Row( // <--- Changed parent to Row for side-by-side layout
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // <--- Pushes title left, button right
                      children: [
                        Text(
                          'SAVINGS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Inter',
                            color: textMain,
                          ),
                        ),
                        Row( // <--- Keeps button elements grouped together on the right side
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
                            controller: _titleController,
                            style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              labelText: 'ASSET POOL LABEL',
                              labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                              isDense: true,
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _targetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              labelText: 'TARGET VOLUME',
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
                            onTap: () => _selectDate(context, isDark),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: specBorderColor)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'MATURITY DEADLINE',
                                    style: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                                  ),
                                  Text(
                                    _selectedDate == null
                                        ? '[ SELECT ]'
                                        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                                    style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () => _calculateAndAddGoal(goals),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              color: textMain,
                              alignment: Alignment.center,
                              child: Text(
                                'INITIALIZE COMPUTATION',
                                style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter'),
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

            // SAVINGS MATRIX SCROLLABLE LISTVIEW
            Expanded(
              child: goals.isEmpty
                  ? Center(
                child: Text(
                  'NO ACTIVE POOLS',
                  style: TextStyle(color: textSub, fontSize: 12, fontFamily: 'Inter'),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = goal.target > 0 ? (goal.current / goal.target).clamp(0.0, 1.0) : 0.0;
                  final isComplete = goal.current >= goal.target;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: specBorderColor, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Card Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onLongPress: () async {
                                        final updatedList = goals.where((element) => element.id != goal.id).toList();
                                        ref.read(savingsProvider.notifier).state = updatedList;
                                        await ExomicDatabaseEngine.savingsBox.delete(goal.id);
                                      },
                                      child: Text(
                                        goal.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Inter'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '[ TGT: $currency${goal.target.toStringAsFixed(0)} ]',
                                    style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('VOLUME', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$currency${goal.current.toStringAsFixed(0)}',
                                          style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('DAILY PACE', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        const SizedBox(height: 2),
                                        Text(
                                          isComplete ? '--' : '$currency${goal.dailyPaceRequired.toStringAsFixed(2)}',
                                          style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('PROGRESS', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Linear Progress Matrix
                              Container(
                                height: 4,
                                width: double.infinity,
                                color: progressBg,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(color: textMain),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Interactive Action Matrix (Deposit & Logs)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: specBorderColor, width: 0.8)),
                            color: textMain.withOpacity(isDark ? 0.03 : 0.02),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: TextField(
                                    controller: _getDepositController(goal.id),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      hintText: 'INSERT LIQUIDITY',
                                      hintStyle: TextStyle(color: textSub.withOpacity(0.5), fontSize: 11, fontFamily: 'Inter'),
                                      prefixText: '$currency ',
                                      prefixStyle: TextStyle(color: textSub, fontSize: 13, fontFamily: 'Inter'),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.zero,
                                        borderSide: BorderSide(color: specBorderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.zero,
                                        borderSide: BorderSide(color: textMain),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _processDeposit(goal, _getDepositController(goal.id).text, currency),
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  color: textMain,
                                  child: Text(
                                    'DEPOSIT',
                                    style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter', letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expandable History Log Toggle
                        if (goal.history.isNotEmpty) ...[
                          InkWell(
                            onTap: () {
                              final currentGoals = ref.read(savingsProvider);
                              final goalIndex = currentGoals.indexWhere((g) => g.id == goal.id);
                              if (goalIndex != -1) {
                                final updatedList = [...currentGoals];
                                updatedList[goalIndex] = goal.copyWith(isHistoryExpanded: !goal.isHistoryExpanded);
                                ref.read(savingsProvider.notifier).state = updatedList;
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: specBorderColor, width: 0.8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '[ LOGS ]',
                                    style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                  ),
                                  const SizedBox(width: 4),
                                  AnimatedRotation(
                                    duration: const Duration(milliseconds: 200),
                                    turns: goal.isHistoryExpanded ? 0.5 : 0.0,
                                    child: Icon(Icons.keyboard_arrow_down, color: textSub, size: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // REDESIGNED EXPENSE-STYLE LOG VIEW
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            sizeCurve: Curves.easeInOutCubic,
                            crossFadeState: goal.isHistoryExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Container(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: goal.history.reversed.length,
                                itemBuilder: (context, hIndex) {
                                  final logText = goal.history.reversed.toList()[hIndex];

                                  String displayTime = '';
                                  String title = 'TRANSACTION';
                                  String subtitle = 'POOL UPDATE';
                                  String displayAmount = '';

                                  if (logText.startsWith('INIT:')) {
                                    displayTime = 'INIT';
                                    title = 'POOL INITIALIZED';
                                    final parts = logText.split(' SET FOR ');
                                    if (parts.length > 1) {
                                      subtitle = 'DEADLINE: ${parts[1]}';
                                    } else {
                                      subtitle = 'TARGET CONFIGURATION';
                                    }
                                    final targetStr = logText.replaceAll('INIT: TARGET ', '').split(' SET FOR ')[0];
                                    displayAmount = '$currency$targetStr';
                                  } else if (logText.startsWith('[')) {
                                    final closeIndex = logText.indexOf(']');
                                    if (closeIndex != -1) {
                                      displayTime = logText.substring(1, closeIndex);
                                      displayAmount = logText.substring(closeIndex + 1).trim();
                                      title = 'LIQUIDITY DEPOSIT';
                                      subtitle = 'POOL INFLOW';
                                    }
                                  } else {
                                    title = logText;
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: specBorderColor, width: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text('[$displayTime]', style: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter')),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(title, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                              const SizedBox(height: 2),
                                              Text(subtitle, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                            ],
                                          ),
                                        ),
                                        Text(displayAmount, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]
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