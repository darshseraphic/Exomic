import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';

class AnimatedRollingCounter extends StatefulWidget {
  final double value;
  final TextStyle style;
  const AnimatedRollingCounter({super.key, required this.value, required this.style});

  @override
  State<AnimatedRollingCounter> createState() => _AnimatedRollingCounterState();
}

class _AnimatedRollingCounterState extends State<AnimatedRollingCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _tween;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _tween = Tween<double>(begin: _oldValue, end: widget.value);
    _animation = _controller.drive(_tween);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedRollingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _tween.begin = _oldValue;
      _tween.end = widget.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('\$${_animation.value.toStringAsFixed(2)}', style: widget.style);
      },
    );
  }
}

class ExpenseItem {
  final String timestamp;
  final String description;
  final String category;
  final double amount;
  const ExpenseItem({required this.timestamp, required this.description, required this.category, required this.amount});

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp,
    'description': description,
    'category': category,
    'amount': amount,
  };

  factory ExpenseItem.fromMap(Map<dynamic, dynamic> map) => ExpenseItem(
    timestamp: map['timestamp'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
  );
}

final incomeProvider = StateProvider<double>((ref) => ExomicDatabaseEngine.getIncome());
final ledgerStreamProvider = StateProvider<List<ExpenseItem>>((ref) {
  final rawList = ExomicDatabaseEngine.getHistory();
  return rawList.map((item) => ExpenseItem.fromMap(item as Map)).toList();
});

class ExpenseLogScreen extends ConsumerStatefulWidget {
  const ExpenseLogScreen({super.key});
  @override
  ConsumerState<ExpenseLogScreen> createState() => _ExpenseLogScreenState();
}

class _ExpenseLogScreenState extends ConsumerState<ExpenseLogScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedCategory = 'INFRASTRUCTURE';
  bool _isCategoryDropdownOpen = false;
  final List<String> _categories = ['INFRASTRUCTURE', 'HARDWARE', 'OPERATIONS', 'LIFESTYLE'];

  @override
  void dispose() {
    _incomeController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitIncome() async {
    double parsed = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    if (parsed > 0) {
      ref.read(incomeProvider.notifier).state = parsed;
      await ExomicDatabaseEngine.saveIncome(parsed);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalIncome = ref.watch(incomeProvider);
    final history = ref.watch(ledgerStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const specBorderColor = Color(0xFF191919);
    final textMain = isDark ? Colors.white : Colors.black;
    final systemTextColor = isDark ? const Color(0xFFF5F3F4) : const Color(0xFF4A4A4A);

    // FIXED: Calculate current month token signature
    final DateTime nowTime = DateTime.now();
    final String currentMonthSignature = "${nowTime.year}-${nowTime.month.toString().padLeft(2, '0')}";

    // FIXED: Only compute dynamic deductions if the item falls within the active current month
    double currentMonthDeductions = history.where((item) {
      if (item.timestamp.contains('/')) {
        return item.timestamp.startsWith(currentMonthSignature);
      }
      return true;
    }).fold(0.0, (sum, item) => sum + item.amount);

    double dynamicRemainingBalance = originalIncome - currentMonthDeductions;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: textMain,
          selectionColor: textMain.withOpacity(0.2),
          selectionHandleColor: isDark ? Colors.white : Colors.black,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FINANCIAL LEDGER', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: specBorderColor, width: 0.8)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MONTHLY INCOME', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _incomeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.normal, fontFamily: 'Inter'),
                            onSubmitted: (_) => _submitIncome(),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: systemTextColor.withOpacity(0.3)),
                              prefixText: '\$ ',
                              prefixStyle: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.normal),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                            ),
                          ),
                        ),
                        if (originalIncome == 0) ...[
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: _submitIncome,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: isDark ? Colors.transparent : Colors.white,
                                  border: Border.all(color: textMain, width: 0.8)
                              ),
                              child: Text('OK', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ]
                      ],
                    ),
                    if (originalIncome > 0) ...[
                      const SizedBox(height: 24),
                      Text('RUNNING BALANCE', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      AnimatedRollingCounter(
                        value: dynamicRemainingBalance,
                        style: TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                    ]
                  ],
                ),
              ),

              if (originalIncome > 0) ...[
                const SizedBox(height: 24),
                Text('NEW TRANSACTION', style: TextStyle(color: systemTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: specBorderColor, width: 0.8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          labelText: 'AMOUNT',
                          labelStyle: TextStyle(color: systemTextColor, fontSize: 12),
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.normal),
                          isDense: true,
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descController,
                        style: TextStyle(color: textMain, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'DESCRIPTION',
                          labelStyle: TextStyle(color: systemTextColor, fontSize: 12),
                          isDense: true,
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CATEGORY', style: TextStyle(color: systemTextColor, fontSize: 11)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isCategoryDropdownOpen = !_isCategoryDropdownOpen;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: _isCategoryDropdownOpen ? textMain : specBorderColor, width: 1.0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedCategory, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                                  AnimatedRotation(
                                    turns: _isCategoryDropdownOpen ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.fastOutSlowIn,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: systemTextColor,
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
                              decoration: const BoxDecoration(
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
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                            color: textMain,
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                                : const SizedBox(width: double.infinity, height: 0),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          double amt = double.tryParse(_amountController.text) ?? 0.0;
                          String desc = _descController.text.trim();
                          if (amt > 0 && desc.isNotEmpty) {
                            final now = DateTime.now();
                            // FIXED: Prepended the year-month pattern into the unique signature string format
                            final timeStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                            final updatedItem = ExpenseItem(
                                timestamp: timeStr,
                                description: desc.toUpperCase(),
                                category: _selectedCategory,
                                amount: amt
                            );

                            final currentList = ref.read(ledgerStreamProvider);
                            final newList = [updatedItem, ...currentList];

                            ref.read(ledgerStreamProvider.notifier).state = newList;
                            // FIXED: Awaiting dynamic serialization routines smoothly to physical boxes
                            await ExomicDatabaseEngine.saveHistory(newList.map((e) => e.toMap()).toList());

                            _amountController.clear();
                            _descController.clear();
                            setState(() {
                              _isCategoryDropdownOpen = false;
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
                            'COMMIT',
                            style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Center(
                child: Text('TRANSACTION HISTORY', style: TextStyle(color: systemTextColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 16),

              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('NO TRANSACTIONS', style: TextStyle(color: systemTextColor, fontSize: 12)),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  // Displays the localized time segment cleanly inside the ledger lists view port
                  final displayTime = item.timestamp.contains(' ') ? item.timestamp.split(' ')[1] : item.timestamp;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: specBorderColor, width: 0.5))),
                    child: Row(
                      children: [
                        Text('[$displayTime]', style: TextStyle(color: systemTextColor, fontSize: 12)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(item.category, style: TextStyle(color: systemTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text('-\$${item.amount.toStringAsFixed(2)}', style: TextStyle(color: textMain, fontSize: 15, fontWeight: FontWeight.bold)),
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