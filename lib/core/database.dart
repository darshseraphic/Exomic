import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'encryption.dart';

part 'database.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String timestamp;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.timestamp,
  });
}

@HiveType(typeId: 1)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double cost;
  @HiveField(3)
  final int daysUntilRenewal;
  @HiveField(4)
  final bool isActive;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.cost,
    required this.daysUntilRenewal,
    required this.isActive,
  });
}

@HiveType(typeId: 2)
class SavingGoalModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double target;
  @HiveField(3)
  final double current;
  @HiveField(4)
  final String deadline;
  @HiveField(5)
  final double dailyPaceRequired;
  @HiveField(6)
  final List<String>? history;

  SavingGoalModel({
    required this.id,
    required this.title,
    required this.target,
    required this.current,
    required this.deadline,
    required this.dailyPaceRequired,
    this.history,
  });
}

@HiveType(typeId: 3)
class BudgetLimitModel extends HiveObject {
  @HiveField(0)
  final String category;
  @HiveField(1)
  final double allocated;
  @HiveField(2)
  final double currentOutflow;

  BudgetLimitModel({
    required this.category,
    required this.allocated,
    required this.currentOutflow,
  });
}

class ExomicDatabaseEngine {
  static const String expenseBoxName = 'exomic_expenses_box';
  static const String subscriptionBoxName = 'exomic_subscriptions_box';
  static const String savingsBoxName = 'exomic_savings_box';
  static const String budgetBoxName = 'exomic_budgets_box';
  static const String settingsBoxName = 'exomic_settings_box';

  static Future<void> initializeStorageEngine() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(SubscriptionModelAdapter());
    Hive.registerAdapter(SavingGoalModelAdapter());
    Hive.registerAdapter(BudgetLimitModelAdapter());

    final Uint8List encryptionKey = await ExomicEncryption.getOrCreateEncryptionKey();
    final aesSecureCipher = HiveAesCipher(encryptionKey);

    await Hive.openBox<ExpenseModel>(expenseBoxName, encryptionCipher: aesSecureCipher);
    await Hive.openBox<SubscriptionModel>(subscriptionBoxName, encryptionCipher: aesSecureCipher);
    await Hive.openBox<SavingGoalModel>(savingsBoxName, encryptionCipher: aesSecureCipher);
    await Hive.openBox<BudgetLimitModel>(budgetBoxName, encryptionCipher: aesSecureCipher);
    await Hive.openBox(settingsBoxName, encryptionCipher: aesSecureCipher);
  }

  static Box<ExpenseModel> get expenseBox => Hive.box<ExpenseModel>(expenseBoxName);
  static Box<SubscriptionModel> get subscriptionBox => Hive.box<SubscriptionModel>(subscriptionBoxName);
  static Box<SavingGoalModel> get savingsBox => Hive.box<SavingGoalModel>(savingsBoxName);
  static Box<BudgetLimitModel> get budgetBox => Hive.box<BudgetLimitModel>(budgetBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  // --- PERSISTENT CONFIG MANAGEMENT ---
  static bool getThemeMode() {
    return settingsBox.get('is_dark_mode', defaultValue: true) as bool;
  }

  static Future<void> saveThemeMode(bool isDark) async {
    await settingsBox.put('is_dark_mode', isDark);
  }

  static double getIncome() {
    return settingsBox.get('monthly_income', defaultValue: 0.0) as double;
  }

  static Future<void> saveIncome(double val) async {
    await settingsBox.put('monthly_income', val);
  }

  static List<dynamic> getHistory() {
    final items = expenseBox.values.toList();
    return items.map((e) => {
      'timestamp': e.timestamp,
      'description': e.description,
      'category': e.category,
      'amount': e.amount,
    }).toList();
  }

  static Future<void> saveHistory(List<Map<String, dynamic>> serializedList) async {
    await expenseBox.clear();
    for (int i = 0; i < serializedList.length; i++) {
      final map = serializedList[i];
      final item = ExpenseModel(
        id: DateTime.now().microsecondsSinceEpoch.toString() + '_$i',
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        description: map['description'] as String,
        timestamp: map['timestamp'] as String,
      );
      await expenseBox.add(item);
    }
  }

  static List<Map<String, dynamic>> getSubscriptions() {
    final dynamic rawData = settingsBox.get('flexible_subscription_stream');
    if (rawData == null) return [];
    return (rawData as List).map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  static Future<void> saveSubscriptions(List<Map<String, dynamic>> serializedList) async {
    await settingsBox.put('flexible_subscription_stream', serializedList);
  }

  // FIXED: Pull directly from the strongly-typed savingsBox instead of the legacy string
  static List<Map<String, dynamic>> getPools() {
    final items = savingsBox.values.toList();
    return items.map((e) => {
      'id': e.id,
      'title': e.title,
      'target': e.target,
      'current': e.current,
      'deadline': e.deadline,
      'dailyPaceRequired': e.dailyPaceRequired,
      'history': e.history ?? [],
    }).toList();
  }

  // FIXED: Route legacy savePools calls to update the natively typed savingsBox
  static Future<void> savePools(List<Map<String, dynamic>> serializedList) async {
    await savingsBox.clear();
    for (var map in serializedList) {
      final item = SavingGoalModel(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title'] ?? '',
        target: (map['target'] as num?)?.toDouble() ?? 0.0,
        current: (map['current'] as num?)?.toDouble() ?? 0.0,
        deadline: map['deadline'] ?? '',
        dailyPaceRequired: (map['dailyPaceRequired'] as num?)?.toDouble() ?? 0.0,
        history: List<String>.from(map['history'] ?? []),
      );
      await savingsBox.put(item.id, item);
    }
  }
}