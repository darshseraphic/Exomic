import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';

class SavingGoal {
  final String id;
  final String title;
  final double target;
  final double current;
  final String deadline;
  final double dailyPaceRequired;
  final List<String> history; // Telemetry log array for incremental deposits

  const SavingGoal({
    required this.id,
    required this.title,
    required this.target,
    required this.current,
    required this.deadline,
    required this.dailyPaceRequired,
    required this.history,
  });

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

final savingGoalsProvider = StateProvider<List<SavingGoal>>((ref) {
  final rawList = ExomicDatabaseEngine.getPools();
  return rawList.map((item) => SavingGoal.fromMap(item)).toList();
});

class SavingGoalsScreen extends ConsumerStatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  ConsumerState<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends ConsumerState<SavingGoalsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();

  // Trackers for dynamic inline deposit actions
  String? _selectedPoolIdForDeposit;
  final TextEditingController _depositController = TextEditingController();

  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadlineDate(BuildContext context, bool isDark) async {
    final DateTime now = DateTime.now();
    final ThemeData datePickerTheme = isDark
        ? ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF050505),
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        surface: Color(0xFF0A0A0A),
        onSurface: Colors.white,
      ),
      dialogBackgroundColor: const Color(0xFF050505),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12),
          foregroundColor: Colors.white,
        ),
      ),
    )
        : ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        surface: Color(0xFFF5F5F5),
        onSurface: Colors.black,
      ),
      dialogBackgroundColor: const Color(0xFFF9F9F9),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12),
          foregroundColor: Colors.black,
        ),
      ),
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(data: datePickerTheme, child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsList = ref.watch(savingGoalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const specBorderColor = Color(0xFF191919);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFB5B5B5);
    final textFootnote = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF525252);
    const alertRed = Color(0xFFE63946);
    final accentGreen = isDark ? const Color(0xFF4BB543) : const Color(0xFF2E7D32);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: textMain,
          selectionColor: textMain.withOpacity(0.2),
          selectionHandleColor: textMain,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ASSET POOLS REALLOCATION', style: TextStyle(color: textFootnote, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 16),
                  Container(
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
                          style: TextStyle(color: textMain, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'POOL DESTINATION TARGET',
                            labelStyle: TextStyle(color: textFootnote, fontSize: 11),
                            isDense: true,
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _targetController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(color: textMain, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'TARGET CAP',
                                  labelStyle: TextStyle(color: textFootnote, fontSize: 11),
                                  prefixText: '\$ ',
                                  prefixStyle: TextStyle(color: textMain, fontSize: 14),
                                  isDense: true,
                                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: TextField(
                                controller: _currentController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(color: textMain, fontSize: 14),
                                decoration: InputDecoration(
                                  labelText: 'INIT RESERVE',
                                  labelStyle: TextStyle(color: textFootnote, fontSize: 11),
                                  prefixText: '\$ ',
                                  prefixStyle: TextStyle(color: textMain, fontSize: 14),
                                  isDense: true,
                                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TARGET INTERCEPT DEADLINE', style: TextStyle(color: textFootnote, fontSize: 11)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _pickDeadlineDate(context, isDark),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: specBorderColor, width: 1.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDeadline == null
                                          ? 'SELECT MATURITY DEADLINE'
                                          : '${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          color: _selectedDeadline == null ? textFootnote.withOpacity(0.5) : textMain,
                                          fontSize: 14,
                                          fontWeight: _selectedDeadline == null ? FontWeight.normal : FontWeight.bold
                                      ),
                                    ),
                                    Icon(Icons.calendar_today_outlined, color: textFootnote, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        InkWell(
                          onTap: () async {
                            final String title = _titleController.text.trim().toUpperCase();
                            final double? parsedTarget = double.tryParse(_targetController.text);
                            final double? parsedCurrent = double.tryParse(_currentController.text);

                            if (title.isNotEmpty && parsedTarget != null && parsedTarget > 0 && _selectedDeadline != null) {
                              final dateStr = '${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}';

                              final today = DateTime.now();
                              final difference = _selectedDeadline!.difference(today).inDays;
                              final remainingDays = difference <= 0 ? 1 : difference;

                              final double actualTarget = parsedTarget;
                              final double actualCurrent = parsedCurrent ?? 0.0;

                              final double balanceNeeded = actualTarget - actualCurrent;
                              final double pace = balanceNeeded <= 0 ? 0.0 : (balanceNeeded / remainingDays);

                              final List<String> initialHistory = [];
                              if (actualCurrent > 0) {
                                initialHistory.add('[${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}] INIT VALUE ASSIGNED: +\$${actualCurrent.toStringAsFixed(2)}');
                              }

                              final newGoal = SavingGoal(
                                id: DateTime.now().microsecondsSinceEpoch.toString(),
                                title: title,
                                target: actualTarget,
                                current: actualCurrent,
                                deadline: dateStr,
                                dailyPaceRequired: pace,
                                history: initialHistory,
                              );

                              final updatedList = [...goalsList, newGoal];
                              ref.read(savingGoalsProvider.notifier).state = updatedList;
                              await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());

                              _titleController.clear();
                              _targetController.clear();
                              _currentController.clear();
                              setState(() {
                                _selectedDeadline = null;
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
                              'INITIALIZE LIQUIDITY POOL',
                              style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: goalsList.isEmpty
                  ? Center(
                child: Text('NO TRACKED LIQUIDITY POOLS', style: TextStyle(color: textFootnote, fontSize: 12)),
              )
                  : ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: goalsList.length,
                itemBuilder: (context, index) {
                  final goal = goalsList[index];
                  final bool isExpandedForDeposit = _selectedPoolIdForDeposit == goal.id;

                  double progressPercent = goal.target > 0 ? (goal.current / goal.target) : 0.0;
                  if (progressPercent > 1.0) progressPercent = 1.0;
                  if (progressPercent < 0.0) progressPercent = 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: specBorderColor, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPoolIdForDeposit = isExpandedForDeposit ? null : goal.id;
                                    _depositController.clear();
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isExpandedForDeposit ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                                      color: textFootnote,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                final updatedList = goalsList.where((element) => element.id != goal.id).toList();
                                ref.read(savingGoalsProvider.notifier).state = updatedList;
                                await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());
                                if (isExpandedForDeposit) {
                                  _selectedPoolIdForDeposit = null;
                                }
                              },
                              child: Text(
                                '[CLEAR]',
                                style: TextStyle(color: alertRed.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FUNDED: \$${goal.current.toStringAsFixed(2)}',
                              style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'CAP: \$${goal.target.toStringAsFixed(2)}',
                              style: TextStyle(color: textSub, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: specBorderColor, width: 0.8),
                              ),
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: constraints.maxWidth * progressPercent,
                                color: textMain,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'PACE: \$${goal.dailyPaceRequired.toStringAsFixed(2)} / DAY',
                                style: TextStyle(color: textFootnote, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'DEADLINE: ${goal.deadline}',
                              style: TextStyle(color: textFootnote, fontSize: 10, letterSpacing: 0.1),
                            ),
                          ],
                        ),

                        if (isExpandedForDeposit) ...[
                          const SizedBox(height: 16),
                          const Divider(color: specBorderColor, height: 1, thickness: 0.5),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _depositController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(color: textMain, fontSize: 12),
                                  decoration: InputDecoration(
                                    labelText: 'APPEND LIQUIDITY INBOUND',
                                    labelStyle: TextStyle(color: textFootnote, fontSize: 9),
                                    prefixText: '\$ ',
                                    prefixStyle: TextStyle(color: textMain, fontSize: 12),
                                    isDense: true,
                                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              InkWell(
                                onTap: () async {
                                  final double? depositAmount = double.tryParse(_depositController.text);
                                  if (depositAmount != null && depositAmount > 0) {
                                    final double updatedCurrent = goal.current + depositAmount;

                                    final today = DateTime.now();
                                    DateTime parsedDead;
                                    try {
                                      final components = goal.deadline.split('-');
                                      parsedDead = DateTime(int.parse(components[0]), int.parse(components[1]), int.parse(components[2]));
                                    } catch (_) {
                                      parsedDead = today.add(const Duration(days: 30));
                                    }
                                    final difference = parsedDead.difference(today).inDays;
                                    final remainingDays = difference <= 0 ? 1 : difference;

                                    final double balanceNeeded = goal.target - updatedCurrent;
                                    final double updatedPace = balanceNeeded <= 0 ? 0.0 : (balanceNeeded / remainingDays);

                                    final String timestampStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                                    final List<String> updatedHistory = [
                                      ...goal.history,
                                      '[$timestampStr] REALLOCATED: +\$${depositAmount.toStringAsFixed(2)}'
                                    ];

                                    final updatedGoal = SavingGoal(
                                      id: goal.id,
                                      title: goal.title,
                                      target: goal.target,
                                      current: updatedCurrent,
                                      deadline: goal.deadline,
                                      dailyPaceRequired: updatedPace,
                                      history: updatedHistory,
                                    );

                                    final updatedList = goalsList.map((g) => g.id == goal.id ? updatedGoal : g).toList();
                                    ref.read(savingGoalsProvider.notifier).state = updatedList;
                                    await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());

                                    _depositController.clear();
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  color: textMain,
                                  child: Text(
                                    'DEPOSIT',
                                    style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (goal.history.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('POOL TELEMETRY HISTORY:', style: TextStyle(color: textFootnote, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            // FIXED: Swapped out raw container parameter for a standard ConstrainedBox configuration
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 70),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF020202) : const Color(0xFFFAF9FA),
                                  border: Border.all(color: specBorderColor, width: 0.5),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(6),
                                  itemCount: goal.history.length,
                                  itemBuilder: (context, hIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        goal.history[hIndex],
                                        style: TextStyle(color: accentGreen, fontFamily: 'Courier', fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ]
                        ],
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