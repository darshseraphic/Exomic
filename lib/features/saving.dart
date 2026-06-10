import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
import 'settings.dart'; // Import to access global theme & currency providers

class SavingGoal {
  final String id;
  final String title;
  final double target;
  final double current;
  final String deadline;
  final double dailyPaceRequired;
  final List<String> history;

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
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  bool _isCreationFormOpen = false;
  String? _expandedGoalId;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _daysController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(savingGoalsProvider);
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);

    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final systemTextColor = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
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
            // CONTROL ACTION INTERFACE
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCreationFormOpen = !_isCreationFormOpen;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SAVING_GOALS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Inter',
                            color: systemTextColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _isCreationFormOpen ? '[ CLOSE ]' : '[ ALLOCATE ]',
                              style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: _isCreationFormOpen ? 0.25 : 0.0,
                              child: Icon(Icons.keyboard_arrow_right, color: systemTextColor, size: 14),
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
                    crossFadeState: _isCreationFormOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                              labelText: 'TARGET OBJECTIVE LABEL',
                              labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                              isDense: true,
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
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
                                  style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    labelText: 'TARGET SUM',
                                    labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                                    prefixText: '$currency ',
                                    prefixStyle: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                    isDense: true,
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: TextField(
                                  controller: _daysController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: textMain, fontSize: 14, fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    labelText: 'HORIZON (DAYS)',
                                    labelStyle: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter'),
                                    isDense: true,
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () async {
                              final String title = _titleController.text.trim().toUpperCase();
                              final double? target = double.tryParse(_targetController.text);
                              final int? days = int.tryParse(_daysController.text);

                              if (title.isNotEmpty && target != null && target > 0 && days != null && days > 0) {
                                final double pace = target / days;
                                final newGoal = SavingGoal(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: title,
                                  target: target,
                                  current: 0.0,
                                  deadline: 'WITHIN $days DAYS',
                                  dailyPaceRequired: pace,
                                  history: ['[LOG_START] INSTANTIATED REQ OVER $days DAYS.'],
                                );

                                final updatedList = [...goals, newGoal];
                                ref.read(savingGoalsProvider.notifier).state = updatedList;
                                await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());

                                _titleController.clear();
                                _targetController.clear();
                                _daysController.clear();
                                setState(() {
                                  _isCreationFormOpen = false;
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
                                'ENGAGE STRUCTURAL GOAL',
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

            // GOALS MONITOR STACK
            Expanded(
              child: goals.isEmpty
                  ? Center(child: Text('NO SYSTEM ASSETS ACCOUNTED', style: TextStyle(color: systemTextColor, fontSize: 12, fontFamily: 'Inter')))
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final bool isExpanded = _expandedGoalId == goal.id;
                  final double percent = goal.target > 0 ? (goal.current / goal.target).clamp(0.0, 1.0) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: specBorderColor, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // MAIN CELL HEADER TRACK
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedGoalId = isExpanded ? null : goal.id;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2, fontFamily: 'Inter'),
                                      ),
                                    ),
                                    Text(
                                      '${(percent * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(color: accentGreen, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // BAR PROGRESS STRUCT
                                Container(
                                  width: double.infinity,
                                  height: 3,
                                  color: isDark ? const Color(0xFF141414) : const Color(0xFFE5E5E5),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: percent,
                                    child: Container(color: accentGreen),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currency${goal.current.toStringAsFixed(0)} / $currency${goal.target.toStringAsFixed(0)}',
                                      style: TextStyle(color: textMain, fontSize: 12, fontFamily: 'Inter'),
                                    ),
                                    Text(
                                      'REQ: $currency${goal.dailyPaceRequired.toStringAsFixed(2)}/DAY',
                                      style: TextStyle(color: systemTextColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // DRAWER METRIC EXPANSION
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          // FIX: Changed from direct maxHeight parameter to use BoxConstraints layout framework
                          constraints: BoxConstraints(maxHeight: isExpanded ? 230 : 0),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              Divider(color: specBorderColor, height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _depositController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                                        decoration: InputDecoration(
                                          hintText: 'DEPOSIT / WITHDRAW AMOUNT',
                                          hintStyle: TextStyle(color: systemTextColor, fontSize: 11, fontFamily: 'Inter'),
                                          prefixText: '$currency ',
                                          prefixStyle: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                                          isDense: true,
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(Icons.add, color: textMain, size: 18),
                                      onPressed: () async {
                                        final double? val = double.tryParse(_depositController.text);
                                        if (val != null && val > 0) {
                                          final updatedGoal = SavingGoal(
                                            id: goal.id,
                                            title: goal.title,
                                            target: goal.target,
                                            current: goal.current + val,
                                            deadline: goal.deadline,
                                            dailyPaceRequired: goal.dailyPaceRequired,
                                            history: [...goal.history, '[DEPOSIT] APPENDED +$currency${val.toStringAsFixed(2)}'],
                                          );
                                          final updatedList = goals.map((g) => g.id == goal.id ? updatedGoal : g).toList();
                                          ref.read(savingGoalsProvider.notifier).state = updatedList;
                                          await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());
                                          _depositController.clear();
                                          FocusScope.of(context).unfocus();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove, color: textMain, size: 18),
                                      onPressed: () async {
                                        final double? val = double.tryParse(_depositController.text);
                                        if (val != null && val > 0 && (goal.current - val) >= 0) {
                                          final updatedGoal = SavingGoal(
                                            id: goal.id,
                                            title: goal.title,
                                            target: goal.target,
                                            current: goal.current - val,
                                            deadline: goal.deadline,
                                            dailyPaceRequired: goal.dailyPaceRequired,
                                            history: [...goal.history, '[WITHDRAW] REDUCED -$currency${val.toStringAsFixed(2)}'],
                                          );
                                          final updatedList = goals.map((g) => g.id == goal.id ? updatedGoal : g).toList();
                                          ref.read(savingGoalsProvider.notifier).state = updatedList;
                                          await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());
                                          _depositController.clear();
                                          FocusScope.of(context).unfocus();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: textMain, size: 18),
                                      onPressed: () async {
                                        final updatedList = goals.where((g) => g.id != goal.id).toList();
                                        ref.read(savingGoalsProvider.notifier).state = updatedList;
                                        await ExomicDatabaseEngine.savePools(updatedList.map((e) => e.toMap()).toList());
                                        setState(() {
                                          _expandedGoalId = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (goal.history.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 100,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF020202) : const Color(0xFFFAF9FA),
                                      border: Border.all(color: specBorderColor, width: 0.5),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      padding: const EdgeInsets.all(4),
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