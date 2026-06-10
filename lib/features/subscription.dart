import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';

class SubscriptionItem {
  final String id;
  final String title;
  final double cost;
  final String renewalDate;
  final bool isActive;

  const SubscriptionItem({
    required this.id,
    required this.title,
    required this.cost,
    required this.renewalDate,
    required this.isActive,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'cost': cost,
    'renewalDate': renewalDate,
    'isActive': isActive,
  };

  factory SubscriptionItem.fromMap(Map<dynamic, dynamic> map) => SubscriptionItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
    renewalDate: map['renewalDate'] ?? '',
    isActive: map['isActive'] ?? true,
  );
}

final subscriptionProvider = StateProvider<List<SubscriptionItem>>((ref) {
  final rawList = ExomicDatabaseEngine.getSubscriptions();
  return rawList.map((item) => SubscriptionItem.fromMap(item)).toList();
});

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickRenewalDate(BuildContext context, Color mainText, bool isDark) async {
    final DateTime now = DateTime.now();

    // Custom flat theme data config mapping directly to the rest of Exomic layers
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
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: datePickerTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subsList = ref.watch(subscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const specBorderColor = Color(0xFF191919);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFFF5F3F4) : const Color(0xFF4A4A4A);
    const alertRed = Color(0xFFE63946);

    final DateTime today = DateTime.now();
    final DateTime todayZeroed = DateTime(today.year, today.month, today.day);

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
                  Text('SUBSCRIPTION MANAGER', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
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
                            labelText: 'SUBSCRIPTION NAME',
                            labelStyle: TextStyle(color: textSub, fontSize: 11),
                            isDense: true,
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _costController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: textMain, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'MONTHLY OUTFLOW AMOUNT',
                            labelStyle: TextStyle(color: textSub, fontSize: 11),
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(color: textMain, fontSize: 14),
                            isDense: true,
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: specBorderColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: textMain)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // REDESIGNED minimalist calendar interface component
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DUE CYCLE DATE', style: TextStyle(color: textSub, fontSize: 11)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _pickRenewalDate(context, textMain, isDark),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: specBorderColor, width: 1.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'SELECT DATE FROM LOG'
                                          : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                          color: _selectedDate == null ? textSub.withOpacity(0.5) : textMain,
                                          fontSize: 14,
                                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: textSub,
                                      size: 14,
                                    ),
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
                            final double? cost = double.tryParse(_costController.text);

                            if (title.isNotEmpty && cost != null && cost > 0 && _selectedDate != null) {
                              final dateStr = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

                              final newSub = SubscriptionItem(
                                id: DateTime.now().microsecondsSinceEpoch.toString(),
                                title: title,
                                cost: cost,
                                renewalDate: dateStr,
                                isActive: true,
                              );

                              final updatedList = [...subsList, newSub];
                              ref.read(subscriptionProvider.notifier).state = updatedList;
                              await ExomicDatabaseEngine.saveSubscriptions(updatedList.map((e) => e.toMap()).toList());

                              _titleController.clear();
                              _costController.clear();
                              setState(() {
                                _selectedDate = null;
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
                              'COMMIT SERVICE',
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
              child: subsList.isEmpty
                  ? Center(
                child: Text('NO SYSTEM SUBSCRIPTIONS', style: TextStyle(color: textSub, fontSize: 12)),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: subsList.length,
                itemBuilder: (context, index) {
                  final sub = subsList[index];

                  DateTime parsedDate;
                  try {
                    parsedDate = DateTime.parse(sub.renewalDate);
                  } catch (_) {
                    parsedDate = todayZeroed;
                  }
                  final DateTime subDateZeroed = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
                  final bool isOverdueOrToday = subDateZeroed.isBefore(todayZeroed) || subDateZeroed.isAtSameMomentAs(todayZeroed);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: isOverdueOrToday ? alertRed : specBorderColor,
                        width: isOverdueOrToday ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.title,
                                style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'CYCLE DUE: ${sub.renewalDate}',
                                style: TextStyle(
                                  color: isOverdueOrToday ? alertRed : textSub,
                                  fontSize: 11,
                                  fontWeight: isOverdueOrToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${sub.cost.toStringAsFixed(2)}',
                              style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                final updatedList = subsList.where((element) => element.id != sub.id).toList();
                                ref.read(subscriptionProvider.notifier).state = updatedList;
                                await ExomicDatabaseEngine.saveSubscriptions(updatedList.map((e) => e.toMap()).toList());
                              },
                              child: Text(
                                '[REMOVE]',
                                style: TextStyle(color: alertRed.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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