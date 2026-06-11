## THE EXOMIC LEDGER ENGINE: THE ARCHITECTURAL SPECIFICATION

### 1. VISION, STRATEGIC TAXONOMY, AND PARADIGM SHIFTS

<p align="center">
  <img src="https://github.com/user-attachments/assets/7200467c-a749-4910-8458-b227141903eb" alt="Expense - light" width="19%" />
  <img src="https://github.com/user-attachments/assets/d4f68979-6448-4b29-ae0b-43c3cf203be5" alt="Subscription - light" width="19%" />
  <img src="https://github.com/user-attachments/assets/d3d5c581-af4c-45ad-b41a-3dde5b3b11ca" alt="Saving - light" width="19%" />
  <img src="https://github.com/user-attachments/assets/fe288ea2-f9cd-46ff-8bdd-e37f3bba10f4" alt="Budget - light" width="19%" />
  <img src="https://github.com/user-attachments/assets/919ff27e-d2c1-4dc2-9cfc-d5bb40a5dcbd" alt="Setting - light" width="19%" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7d5aa42d-eff4-4f23-bf24-493559c799ee" alt="Expense - dark" width="19%" />
  <img src="https://github.com/user-attachments/assets/d6e150f0-ac0f-4732-8a92-8b5950fbcf8b" alt="Subscription - dark" width="19%" />
  <img src="https://github.com/user-attachments/assets/059ce509-56b7-4124-a5c4-6f29fcb842f1" alt="Saving - dark" width="19%" />
  <img src="https://github.com/user-attachments/assets/fc4dc9b2-4b91-4f65-880f-14aaa6ee107a" alt="Budget - dark" width="19%" />
  <img src="https://github.com/user-attachments/assets/04fa01d0-62ef-4aa0-a7d3-45d44b0bc930" alt="Setting - dark" width="19%" />
</p>

#### 1.1 The Privacy-First Offline Ideology

The Exomic Ledger Engine is built on a simple rule: financial confidentiality should be absolute. Most consumer financial apps rely on a cloud-based server infrastructure. When a user tracks a transaction, updates an asset pool, or logs a subscription, that data travels across network protocols to be stored on remote servers. This setup introduces several security risks, such as man-in-the-middle exploits, server-side data breaches, and tracking by advertising platforms.

Exomic shifts this approach by handling all calculations directly on the client device. It operates inside a localized sandbox without external network dependencies, APIs, or background data-collection syncs. This approach ensures total privacy: if a device is offline, intercepted, or isolated, its data remains safe inside its secure local storage.

By moving database reads, cross-dashboard state syncing, and calculations entirely to the user's device, Exomic eliminates latency. Traditional apps often show loading indicators while waiting for cloud servers to process data. Exomic completes these operations in microseconds, providing immediate visual feedback at a smooth 60 or 120 frames per second.

```
Traditional Financial Apps:
[User Device] ──(Internet Wire)──> [Cloud Server API] ──> [Remote Corporate Database]
* Risks: Network interception, server data breaches, tracking, latency sync stutters.

Exomic Ledger Engine:
[User Device] ──(Encrypted Internal Sandboxed Pipeline)──> [Memory-Mapped Local Hive Boxes]
* Benefits: Complete isolation, zero latency, absolute privacy, works fully offline.

```

### 1.2 Design Language and Visual Philosophy

The user interface avoids common modern design trends like rounded card layouts, decorative drop shadows, and colorful gradients. Instead, Exomic uses a minimal, high-contrast style inspired by command-line interfaces and retro computer terminals.

This design choice highlights data over decoration. The layout relies on strict box containers, geometric divider lines, and uniform letter-spacing. This presentation accurately reflects the app's backend reality: a precise mathematical tool that processes data without unnecessary visual flair.

```
+───────────────────────────────────────────────────────────+
| [SYSTEM RUNTIME STATUS: STABLE]           CORE TIMELINE   |
+───────────────────────────────────────────────────────────+
| [14:32:10] GROCERIES ........................ -$142.50    |
| [11:15:04] TRANSPORT ........................  -$35.00    |
| [08:02:41] COFFEE ...........................   -$6.25    |
+───────────────────────────────────────────────────────────+
| NET RUNTIME RESIDUAL FLUIDITY:                $2,416.25   |
+───────────────────────────────────────────────────────────+

```

The color palette changes based on the system theme:

* **Dark Mode:** A deep background (`0xFF050505`) paired with clean white text (`0xFFFFFFFF`), using subtle gray borders (`0xFF191919`) to separate sections.
* **Light Mode:** A crisp, paper-white background (`0xFFFAFAFA`) paired with solid black text (`0xFF000000`), using light gray borders (`0xFFE5E5E5`) for separation.

Colors are only used to show structural alerts. For example, when a budget allocation is exceeded, text styles change to a bright crimson alert red (`0xFFE63946`). This immediate visual change alerts the user to budget overruns without cluttering the screen.

### 1.3 Structural Code Repository Layout

The code repository uses a clean architecture that isolates business logic from the user interface. This separation ensures that database changes don't disrupt presentation screens, and layout updates don't break underlying calculations.

```
lib/
│
├── main.dart                  # Application bootstrap entry point & platform setup
│
├── core/                      # Hardcore Backend Engine Layers
│   ├── database.dart          # Local memory-mapped Hive storage controller
│   ├── database.g.dart        # TypeAdapter serialization binaries (Automated generation)
│   └── encryption.dart        # Core AES-256 secure cryptographic storage provider
│
└── presentation/              # High-Contrast Monospaced Interface Views
    └── screens/
        ├── expense.dart       # Core ledger timeline and rolling financial counter
        ├── budget.dart        # Unassigned liquidity workspace and category limits
        ├── saving.dart        # Asset accumulation pools and dynamic pace trackers
        ├── subscription.dart  # Recurring service utilities and renewal date tickers
        └── settings.dart      # Storage controls, local policy views, and data controls

```

---

### 2. RECONSTRUCTING THE COMPASS: STEP-BY-STEP DATA MUTATION SPRINT

To see how Exomic's backend logic, state updates, and user interface elements work together in real-world scenarios, let's walk through three common data entry workflows.

### 2.1 Sprint A: Setting an Outflow Limit Cap (Budget Tab)

```
[User Form Entry]
   │ (Selects "GROCERIES", inputs limit: $400.00)
   ▼
[BudgetPlannerScreen state updates via local state notifier]
   │
   ▼
[ExomicDatabaseEngine writes budget limit out to the local Hive Box]
   │
   ▼
[Riverpod budgetPlannerProvider notifies all active listening components]
   │
   ▼
[The application re-calculates Global Unassigned Liquidity on the fly]
   │
   ▼
[UI View refreshes immediately without full screen reloads]

```

* **User Action:** The user opens the **Budget Matrix**, clicks the configuration button to reveal the category form, selects the `'GROCERIES'` category from the custom dropdown menu, enters a spending limit of `400.00`, and clicks save.
* **Internal UI Layer Processing:** The text entry triggers a form validation check inside `BudgetPlannerScreen`. This check ensures the input value is a valid number greater than zero. Once validated, the temporary form view closes, and the app triggers an update through its state provider.
* **State Management Operations:** The app sends the updated category configuration to the `budgetPlannerProvider` state notifier. This manager copies the existing list of budget items, removes any older entry for the `'GROCERIES'` category, and appends the new limit.
* **Storage Engine Serialization:** The update calls `ExomicDatabaseEngine.budgetBox.put()`. This serializes the custom budget model into a binary data stream and saves it directly to the local storage box.
* **Global Calculation Refreshes:** Because the budget list provider has been updated, Riverpod automatically updates all components that rely on this data. This recalculates the **Unassigned Liquidity Metric** across the app and updates the top telemetry bar instantly.

### 2.2 Sprint B: Logging an Outflow Transaction (Ledger Tab)

```
[User Action: Logs a $150 Grocery Purchase via the Transaction Terminal]
   │
   ▼
[LedgerScreen processes inputs and creates an immutable unique ExpenseItem]
   │
   ▼
[Saves transaction record directly to the encrypted Hive expenseBox]
   │
   ▼
[Cascading State Updates trigger across all associated data monitors]
   │
   ▼
[The transaction is matched against the 'GROCERIES' allocation threshold]
   │
   ▼
[The animated rolling total counter smoothly interpolates to the new balance]

```

* **User Action:** The user goes to the **Financial Ledger**, clicks the transaction icon, names the item `'WEEKLY MEAL PREP'`, sets the amount to `150.00`, assigns it to the `'GROCERIES'` category, and clicks submit.
* **Internal UI Layer Processing:** The app reads the text inputs, creates a unique ID using a millisecond timestamp, and generates a current date-time stamp string formatted as `YYYY-MM-DD HH:MM:SS`.
* **Storage Engine Serialization:** The app maps this transaction data to an `ExpenseModel` instance and saves it to disk using `ExomicDatabaseEngine.expenseBox.add()`. Hive appends this new binary entry to the end of the encrypted disk file.
* **State Management Operations:** The state manager reads the updated transaction history file and broadcasts the change. The `ledgerStreamProvider` updates its active transaction list, making the new record appear at the top of the history list.
* **Global Calculation Refreshes:** The app recalculates the total spending for the `'GROCERIES'` category. The budget limit tracker updates its internal data structure, changing its current outflow metric from `0.00` to `150.00`. The **Animated Rolling Counter** component at the top of the ledger screen receives the new total and begins animating to the updated value.

### 2.3 Sprint C: Managing Budget Overruns and Alert States

```
[User Logs a second purchase of $300.00 for the 'GROCERIES' category]
   │
   ▼
[Total Outflow jumps from $150.00 to $450.00 ($150.00 + $300.00)]
   │
   ▼
[Calculates current status against the defined $400.00 budget allocation limit]
   │
   ▼
[System detects a deficit budget margin: $400.00 - $450.00 = -$50.00]
   │
   ▼
[Internal logic flips the 'isBreached' data property flag to true]
   │
   ▼
[UI styles update dynamically, turning text and layout frames to alert red]

```

* **User Action:** The user returns to the transaction form and logs another purchase under the `'GROCERIES'` category for `300.00`.
* **Internal UI Layer Processing:** The transaction is processed normally, and the app adds it to the encrypted local storage file.
* **State Management Operations:** The state manager processes the transaction update and recalculates the total spending for each category. It updates the total outflow for the `'GROCERIES'` category to `450.00` (`150.00` from the first transaction plus `300.00` from the second).
* **Global Calculation Refreshes:** The budget tracker processes this new total and compares it against the category's `400.00` limit. The calculation shows that spending has exceeded the allocation limit by `50.00` (`400.00` allocation minus `450.00` current spending).
* **Interface Feedback & Alerts:** Because the margin has dropped below zero, the app flips the internal `isBreached` validation flag to true. The user interface updates the look of that category card instantly: the background container color shifts to a red tint, the status label changes from `[ SAFE ]` to `[ BREACH ]`, and the font colors turn to alert red (`0xFFE63946`) to show the budget overrun clearly.

---

### 3. ENGINE STRUCTURE: CORE STORAGE, MODELS, AND SERIALIZATION (`database.dart`)

### 3.1 Relational Architecture vs. NoSQL Binary Mapping

Traditional applications often use relational databases like SQLite or raw text formats like JSON to store data locally. Relational databases require an Object-Relational Mapping (ORM) layer to convert programming objects into database rows. This conversion process uses extra CPU cycles and can slow down data retrieval. Text formats like JSON must parse entire data strings into memory at once, which can block the main execution thread during heavy read or write operations.

Exomic avoids these bottlenecks by using **Hive**, a fast NoSQL key-value database built natively for Dart. Hive stores data as binary streams directly within the operating system's protected file storage directories. When the app starts, Hive maps these binary files directly into volatile memory (RAM). This allows the application to read and write records with minimal overhead.

```
Relational Database Model (SQLite):
[Data Object] ──> [ORM Converter Layer] ──> [SQL Query Compiler String] ──> [Disk Row File]
* Slowdowns: High CPU usage, translation overhead, complex query parsing.

Hive Storage Model (Exomic Engine):
[Data Object] ──> [TypeAdapter Binary Serializer] ──> [Direct Append to Disk Byte Streams]
* Enhancements: Direct memory mapping, no translation layers, ultra-fast reads and writes.

```

When data changes, Hive uses an append-only write sequence. Instead of searching through and rewriting a specific sector on disk, it appends the new data entry to the end of the file. This approach avoids random-access disk delays, allowing the app to render long scrolling lists smoothly without interface lag.

### 3.2 TypeAdapters and the Automated Serialization Binary Layer

To save complex objects to disk without relying on slow string-parsing protocols, Exomic defines data models using specialized binary annotations. These annotations tell the serialization engine how to handle data structures within the `database.g.dart` file:

```dart
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'encryption.dart';

part 'database.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final double amount;
  @HiveField(2) final String category;
  @HiveField(3) final String description;
  @HiveField(4) final String timestamp;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.timestamp,
  });
}

```

Every model class is registered with a unique `typeId` token:

* **`ExpenseModel` (ID: 0):** Stores individual transaction records, tracking transaction amounts, category mappings, descriptions, and timestamp strings.
* **`SubscriptionModel` (ID: 1):** Tracks recurring charges, processing renewal dates, active status flags, and recurring monthly costs.
* **`SavingGoalModel` (ID: 2):** Tracks savings targets, handling target milestones, accumulated cash balances, target deadlines, and associated deposit records.
* **`BudgetLimitModel` (ID: 3):** Stores maximum spending limits, current category definitions, and calculated outflows for each budget category.

During compilation, Hive parses these annotations to generate binary converters. These converters translate Dart object fields directly into raw byte streams and back, bypassing the need for slow text-parsing steps.

### 3.3 Cryptographic Storage Key Isolation Layer

To protect user data from direct file access or device security compromises, Exomic secures its storage boxes using an advanced cryptographic isolation layer.

```
[App Launch Initialization Sequence]
                 │
                 ▼
     [ExomicEncryption Execution]
                 │
                 ▼
   Check Secure OS Cryptographic Vault ──(Exists?)
                 │
        ┌────────┴────────┐
     (YES)              (NO)
        │                 │
        │                 ▼
        │        Generate a New 256-Bit AES Key
        │                 │
        │                 ▼
        │        Save Key to Protected OS Vault
        ▼                 │
  [Extract Key Array from OS Secure Vault]
                 │
                 ▼
  [Pass Key Byte Array to Hive Box Context]
                 │
                 ▼
  [All Disk Read/Write Cycles Encrypted via AES-256]

```

When the application boots up, it initializes its storage boxes through a secure startup routine:

```dart
class ExomicDatabaseEngine {
  static late Box<ExpenseModel> expenseBox;
  static late Box<SubscriptionModel> subscriptionBox;
  static late Box<SavingGoalModel> savingsBox;
  static late Box<BudgetLimitModel> budgetBox;
  static late Box settingsBox;

  static const String expenseBoxName = 'secure_expense_matrix_v1';
  static const String subscriptionBoxName = 'secure_subscription_matrix_v1';
  static const String savingsBoxName = 'secure_savings_matrix_v1';
  static const String budgetBoxName = 'secure_budget_matrix_v1';
  static const String settingsBoxName = 'secure_settings_matrix_v1';

  static Future<void> initializeStorageEngine() async {
    await Hive.initFlutter();
    
    // Register type adapters generated from binary models
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(SubscriptionModelAdapter());
    Hive.registerAdapter(SavingGoalModelAdapter());
    Hive.registerAdapter(BudgetLimitModelAdapter());

    // Extract encryption key array from the secure OS storage container
    final Uint8List encryptionKey = await ExomicEncryption.getOrCreateEncryptionKey();
    final aesSecureCipher = HiveAesCipher(encryptionKey);

    // Open boxes with full hardware-level AES-256 encryption
    expenseBox = await Hive.openBox<ExpenseModel>(expenseBoxName, encryptionCipher: aesSecureCipher);
    subscriptionBox = await Hive.openBox<SubscriptionModel>(subscriptionBoxName, encryptionCipher: aesSecureCipher);
    savingsBox = await Hive.openBox<SavingGoalModel>(savingsBoxName, encryptionCipher: aesSecureCipher);
    budgetBox = await Hive.openBox<BudgetLimitModel>(budgetBoxName, encryptionCipher: aesSecureCipher);
    settingsBox = await Hive.openBox(settingsBoxName, encryptionCipher: aesSecureCipher);
  }
  
  // Legacy layer compatibility hooks
  static List<Map<String, dynamic>> getHistory() {
    return expenseBox.values.map((e) => {
      'id': e.id,
      'amount': e.amount,
      'category': e.category,
      'description': e.description,
      'timestamp': e.timestamp,
    }).toList();
  }

  static Future<void> saveHistory(List<Map<String, dynamic>> serializedList) async {
    await expenseBox.clear();
    for (var map in serializedList) {
      await expenseBox.add(ExpenseModel(
        id: map['id'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        category: map['category'] ?? '',
        description: map['description'] ?? '',
        timestamp: map['timestamp'] ?? '',
      ));
    }
  }

  static List<Map<String, dynamic>> getSubscriptions() {
    final rawData = settingsBox.get('flexible_subscription_stream');
    if (rawData == null) return [];
    return (rawData as List).map((s) => Map<String, dynamic>.from(s as Map)).toList();
  }

  static Future<void> saveSubscriptions(List<Map<String, dynamic>> serializedList) async {
    await settingsBox.put('flexible_subscription_stream', serializedList);
  }

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

  static Future<void> savePools(List<Map<String, dynamic>> serializedList) async {
    await savingsBox.clear();
    for (var map in serializedList) {
      await savingsBox.put(map['id'], SavingGoalModel(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title'] ?? '',
        target: (map['target'] as num?)?.toDouble() ?? 0.0,
        current: (map['current'] as num?)?.toDouble() ?? 0.0,
        deadline: map['deadline'] ?? '',
        dailyPaceRequired: (map['dailyPaceRequired'] as num?)?.toDouble() ?? 0.0,
        history: List<String>.from(map['history'] ?? []),
      ));
    }
  }

  static double getPrimaryIncome() {
    return (settingsBox.get('sys_primary_income_token') as num?)?.toDouble() ?? 0.0;
  }

  static Future<void> setPrimaryIncome(double value) async {
    await settingsBox.put('sys_primary_income_token', value);
  }

  static bool getThemeMode() {
    return settingsBox.get('sys_theme_binary_flag', defaultValue: true);
  }

  static Future<void> setThemeMode(bool isDark) async {
    await settingsBox.put('sys_theme_binary_flag', isDark);
  }
}

```

The underlying code accesses the platform's secure key vault (Android Keystore or iOS Keychain Services) to find or generate a 256-bit AES key block. This key is loaded as an isolated byte array (`Uint8List`) and passed into the database open box instructions. Every byte saved to disk is encrypted via AES-256 blocks, making the raw files unreadable to external file explorers or unauthorized apps.

---

### 4. MATHEMATICAL LIQUIDITY CORE AND REACTIVE STATE MACHINE (`budget.dart`)

### 4.1 The Unassigned Liquidity Equation

The core financial balance inside `budget.dart` is calculated using a multi-layered equation that factors in recurring costs, category spending limits, and long-term savings goals as liabilities against the user's primary monthly income:

$$\text{Unassigned Liquidity} = \text{Primary Monthly Income} - \text{Active Subscriptions} - (\text{Savings Daily Pace} \times 30) - \text{Total Allocated Budgets}$$

This algorithmic balance provides a detailed look at financial status:

1. **Primary Monthly Income:** Read directly from the encrypted configuration parameters stored inside the local database.
2. **Active Subscriptions:** Calculated by filtering the subscription list, checking for items where `isActive` is true, and summing their monthly costs.
3. **Savings Pool Obligations (Monthly Projection):** Each active savings goal tracks a specific deadline date. The app reads the total `dailyPaceRequired` across all active goals and multiplies it by a standard 30-day billing cycle. This treats savings contributions as locked fixed obligations rather than optional cash.
4. **Allocated Category Caps:** The sum of all maximum target limits defined across the budget categories.

If this calculated balance falls below zero, the user interface switches styles, changing text elements to alert red (`Color(0xFFE63946)`) to show that current allocations exceed income.

### 4.2 Riverpod Architecture and Cross-Tab State Updates

To ensure that adding a transaction or updating a goal updates calculations instantly across all other dashboards, Exomic implements a state management layer powered by **Riverpod**.

```
                       [ ExomicDatabaseEngine (Hive) ]
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         ▼                            ▼                            ▼
 [ incomeProvider ]       [ subscriptionProvider ]        [ savingsProvider ]
         │                            │                            │
         └────────────────────────────┼────────────────────────────┘
                                      ▼
                        [ budgetPlannerProvider ]
                                      │
                                      ▼
                        [ BudgetPlannerScreen UI View ]

```

State providers act as reactive data nodes that listen for underlying changes and push updates to the user interface. For example, when a user drops a cash deposit into a goal container within the **Savings Tab**, a cascading update occurs:

1. The user inputs a deposit amount and executes the deposit command.
2. The savings provider receives the updated target metrics, saves them to Hive, and broadcasts the change.
3. The deposit command also builds an automated ledger transaction item (`ExpenseItem`) labeled with the goal's description, assigned to the `'SAVINGS'` category, and given a negative value.
4. This transaction item is added to the `ledgerStreamProvider` timeline array, updating the balances on the financial ledger screen.
5. Because the **Budget Tab**'s unassigned liquidity calculations monitor the state of both the subscription and savings providers, the main dashboard updates its values immediately without requiring a manual screen refresh.

Here is the implementation of the reactive data structures inside `budget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
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

final budgetPlannerProvider = StateProvider<List<BudgetLimit>>((ref) {
  final rawList = ExomicDatabaseEngine.budgetBox.values.toList();
  if (rawList.isEmpty) {
    // Standard initialization rules for category parameters
    return const [
      BudgetLimit(category: 'HOUSING', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'UTILITIES', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'GROCERIES', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'TRANSPORT', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'HEALTHCARE', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'SAVINGS', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'PERSONAL', allocated: 0.0, currentOutflow: 0.0),
      BudgetLimit(category: 'MISC', allocated: 0.0, currentOutflow: 0.0),
    ];
  }
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
  bool _isConfigurationFormOpen = false;
  String _selectedCategory = 'HOUSING';
  bool _isCategoryDropdownOpen = false;
  
  final List<String> _categories = const [
    'HOUSING', 'UTILITIES', 'GROCERIES', 'TRANSPORT', 
    'HEALTHCARE', 'SAVINGS', 'PERSONAL', 'MISC'
  ];

  final TextEditingController _allocationController = TextEditingController();

  @override
  void dispose() {
    _allocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);
    final budgetList = ref.watch(budgetPlannerProvider);

    // Styling configurations based on active theme state
    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final alertRed = const Color(0xFFE63946);

    // Calculate aggregated metrics from storage systems
    final double incomeToken = ExomicDatabaseEngine.getPrimaryIncome();
    
    final rawSubs = ExomicDatabaseEngine.getSubscriptions();
    final double totalSubsMaturityDrain = rawSubs
        .map((e) => (e['cost'] as num?)?.toDouble() ?? 0.0)
        .fold(0.0, (sum, cost) => sum + cost);

    final rawPools = ExomicDatabaseEngine.getPools();
    final double totalSavingsObligations = rawPools
        .map((e) => ((e['dailyPaceRequired'] as num?)?.toDouble() ?? 0.0) * 30.0)
        .fold(0.0, (sum, pace) => sum + pace);

    final double totalAllocatedBudgets = budgetList.fold(0.0, (sum, item) => sum + item.allocated);
    
    // Evaluate ultimate liquidity calculation
    final double unassignedLiquidity = incomeToken - totalSubsMaturityDrain - totalSavingsObligations - totalAllocatedBudgets;
    final bool isLiquidityNegative = unassignedLiquidity < 0;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BUDGET_PLANNER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter', color: textMain),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isConfigurationFormOpen = !_isConfigurationFormOpen;
                      });
                    },
                    child: Row(
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
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Operational Liquidity Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: isLiquidityNegative ? alertRed : specBorderColor, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNASSIGNED RESIDUAL LIQUIDITY',
                      style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLiquidityNegative 
                          ? '-$currency${unassignedLiquidity.abs().toStringAsFixed(2)}'
                          : '$currency${unassignedLiquidity.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isLiquidityNegative ? alertRed : textMain,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('INCOME: $currency${incomeToken.toStringAsFixed(0)}', style: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter')),
                        Text('FIXED DRAINS: $currency${(totalSubsMaturityDrain + totalSavingsObligations).toStringAsFixed(0)}', style: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter')),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Component Workspace
              if (_isConfigurationFormOpen) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ALLOCATE ACCENT BOUNDARY', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      const SizedBox(height: 20),
                      
                      // Custom Dropdown Picker Component
                      GestureDetector(
                        onTap: () => setState(() => _isCategoryDropdownOpen = !_isCategoryDropdownOpen),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedCategory, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              Icon(Icons.arrow_drop_down, color: textSub, size: 16),
                            ],
                          ),
                        ),
                      ),
                      
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        child: _isCategoryDropdownOpen
                            ? Container(
                                margin: const EdgeInsets.top(4),
                                decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8), color: cardBg),
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  children: _categories.map((cat) => ListTile(
                                    dense: true,
                                    title: Text(cat, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = cat;
                                        _isCategoryDropdownOpen = false;
                                      });
                                    },
                                  )).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 16),
                      TextField(
                        controller: _allocationController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'BOUND LIMIT TARGET',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          prefixText: '$currency ',
                          prefixStyle: TextStyle(color: textMain, fontSize: 13),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: textMain, width: 0.8),
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () async {
                            final double? parsedVal = double.tryParse(_allocationController.text);
                            if (parsedVal == null || parsedVal < 0) return;

                            final updatedList = budgetList.map((item) {
                              if (item.category == _selectedCategory) {
                                return BudgetLimit(category: item.category, allocated: parsedVal, currentOutflow: item.currentOutflow);
                              }
                              return item;
                            }).toList();

                            ref.read(budgetPlannerProvider.notifier).state = updatedList;
                            
                            // Batch updates to local Hive data containers
                            final targetItem = updatedList.firstWhere((e) => e.category == _selectedCategory);
                            await ExomicDatabaseEngine.budgetBox.put(_selectedCategory, BudgetLimitModel(
                              category: targetItem.category,
                              allocated: targetItem.allocated,
                              currentOutflow: targetItem.currentOutflow,
                            ));

                            _allocationController.clear();
                            setState(() {
                              _isConfigurationFormOpen = false;
                            });
                          },
                          child: Text('COMMIT ALLOCATION', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              Text('CATEGORY ALLOCATION MATRIX', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
              const SizedBox(height: 16),

              // Category Data Grid Layout
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetList.length,
                itemBuilder: (context, index) {
                  final item = budgetList[index];
                  final bool isBreached = item.currentOutflow > item.allocated && item.allocated > 0;
                  final double margin = item.allocated - item.currentOutflow;
                  final double percent = item.allocated == 0 ? 0.0 : (item.currentOutflow / item.allocated).clamp(0.0, 1.0);
                  
                  final labelColor = isBreached ? alertRed : (margin == 0 && item.allocated == 0 ? textSub : textMain);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isBreached ? alertRed.withOpacity(0.03) : cardBg,
                      border: Border.all(color: isBreached ? alertRed : specBorderColor, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.category, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                            Text(
                              isBreached ? '[ BREACH ]' : (item.allocated == 0 ? '[ UNCONFIGURED ]' : '[ SAFE ]'),
                              style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Core Progress Meter UI Element
                        Stack(
                          children: [
                            Container(width: double.infinity, height: 2, color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5)),
                            FractionallySizedBox(
                              widthFactor: percent,
                              child: Container(height: 2, color: labelColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Summary Calculations Footer Row
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('OUTFLOW', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text('$currency${item.currentOutflow.toStringAsFixed(2)}', style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter')),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LIMIT CAP', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$currency${item.allocated.toStringAsFixed(2)}',
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

```

---

## 5. LEDGER TRANSACTIONS AND COUNTER INTERPOLATION (`expense.dart`)

### 5.1 High-Frequency Frame Renders and Ticker States

The ledger timeline handles running transaction lists, processing text items, and calculating monthly totals. Showing long lists of transactions while keeping updates smooth requires efficient state rendering. If an application updates values instantly without transition states, the sudden visual jumps can make the data harder to track.

To improve this interaction, Exomic includes a custom **`AnimatedRollingCounter`** component. This widget avoids hard value jumps by using an internal ticker provider to animate numerical updates smoothly over an 800-millisecond window.

```
[UI Value State Updates: $1,200.00 -> $1,350.00]
                     │
                     ▼
  [didUpdateWidget Intercepts New Property Value]
                     │
                     ▼
  [Resets Internal Tween Map Linear Proportions]
                     │
                     ▼
  [Triggers the 800ms Microstep Animation Ticker]
                     │
                     ▼
  [Appends Sub-Value Outputs at 120 FPS via toStringAsFixed(2)]

```

When transaction rows are added or removed, the component catches the property change through the widget lifecycle hooks. It sets the current value as the animation's starting point and maps the new value as the target endpoint. This drives a sub-value generator that refreshes the text layout at 60 or 120 frames per second, keeping interface animations responsive on modern high-refresh displays.

### 5.2 Calendar Period Isolations and Parsing Log Arrays

The data timeline is processed by `ledgerStreamProvider`, which compiles data arrays into a synchronized transaction history log. When loading items from storage, the app uses string filters to separate records into current monthly tracking views:

```dart
final DateTime nowTime = DateTime.now();
final String currentMonthSignature = "${nowTime.year}-${nowTime.month.toString().padLeft(2, '0')}";

double currentMonthDeductions = history.where((item) {
  return item.timestamp.startsWith(currentMonthSignature);
}).fold(0.0, (sum, item) => sum + item.amount);

```

Checking if timestamps begin with the target `YYYY-MM` prefix allows the app to filter transactions into the active month efficiently. This process provides a clear view of current spending habits without requiring complex database operations.

Here is the implementation of the ledger tracking engine inside `expense.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
import 'settings.dart';
import 'budget.dart';

class AnimatedRollingCounter extends ConsumerStatefulWidget {
  final double value;
  final TextStyle style;
  const AnimatedRollingCounter({super.key, required this.value, required this.style});

  @override
  ConsumerState<AnimatedRollingCounter> createState() => _AnimatedRollingCounterState();
}

class _AnimatedRollingCounterState extends ConsumerState<AnimatedRollingCounter> with SingleTickerProviderStateMixin {
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
        return Text(
          _animation.value.toStringAsFixed(2),
          style: widget.style,
        );
      },
    );
  }
}

class ExpenseItem {
  final String id;
  final double amount;
  final String category;
  final String description;
  final String timestamp;

  const ExpenseItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'description': description,
    'timestamp': timestamp,
  };

  factory ExpenseItem.fromMap(Map<dynamic, dynamic> map) => ExpenseItem(
    id: map['id'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    timestamp: map['timestamp'] ?? '',
  );
}

final ledgerStreamProvider = StateProvider<List<ExpenseItem>>((ref) {
  final rawList = ExomicDatabaseEngine.getHistory();
  return rawList.map((e) => ExpenseItem.fromMap(e)).toList();
});

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  bool _isInputPanelOpen = false;
  String _selectedCategory = 'HOUSING';
  bool _isCategoryDropdownOpen = false;
  
  final List<String> _categories = const [
    'HOUSING', 'UTILITIES', 'GROCERIES', 'TRANSPORT', 
    'HEALTHCARE', 'SAVINGS', 'PERSONAL', 'MISC'
  ];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);
    final ledgerItems = ref.watch(ledgerStreamProvider);

    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);

    final DateTime nowTime = DateTime.now();
    final String currentMonthSignature = "${nowTime.year}-${nowTime.month.toString().padLeft(2, '0')}";

    // Compute rolling summation metrics
    final double aggregatedOutflows = ledgerItems
        .where((element) => element.timestamp.startsWith(currentMonthSignature))
        .fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel Title Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FINANCIAL_LEDGER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter', color: textMain)),
                  GestureDetector(
                    onTap: () => setState(() => _isInputPanelOpen = !_isInputPanelOpen),
                    child: Row(
                      children: [
                        Text(_isInputPanelOpen ? '[ CANCEL ]' : '[ NEW LOG ]', style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isInputPanelOpen ? 0.25 : 0.0,
                          child: Icon(Icons.keyboard_arrow_right, color: textSub, size: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Aggregated Statistics Frame
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardBg, border: Border.all(color: specBorderColor, width: 0.8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RUNNING TOTAL OUTFLOWS (CURRENT MONTH)', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(currency, style: TextStyle(color: textMain, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                        const SizedBox(width: 2),
                        AnimatedRollingCounter(
                          value: aggregatedOutflows,
                          style: TextStyle(color: textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Dynamic Operational Input Container
              if (_isInputPanelOpen) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RECORD METRIC TRANSACTION', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'TRANSACTION DESCRIPTION',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'OUTFLOW BALANCE VALUE',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          prefixText: '$currency ',
                          prefixStyle: TextStyle(color: textMain, fontSize: 13),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Dropdown Menu Component Wrap
                      GestureDetector(
                        onTap: () => setState(() => _isCategoryDropdownOpen = !_isCategoryDropdownOpen),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedCategory, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              Icon(Icons.arrow_drop_down, color: textSub, size: 16),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        child: _isCategoryDropdownOpen
                            ? Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8), color: cardBg),
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  children: _categories.map((cat) => ListTile(
                                    dense: true,
                                    title: Text(cat, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = cat;
                                        _isCategoryDropdownOpen = false;
                                      });
                                    },
                                  )).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: textMain, width: 0.8), shape: const RoundedRectangleBorder()),
                          onPressed: () async {
                            final double? parsedAmount = double.tryParse(_amountController.text);
                            if (parsedAmount == null || parsedAmount <= 0 || _descriptionController.text.isEmpty) return;

                            final DateTime explicitTime = DateTime.now();
                            final String timeString = "${explicitTime.year}-${explicitTime.month.toString().padLeft(2, '0')}-${explicitTime.day.toString().padLeft(2, '0')} ${explicitTime.hour.toString().padLeft(2, '0')}:${explicitTime.minute.toString().padLeft(2, '0')}:${explicitTime.second.toString().padLeft(2, '0')}";

                            final newItem = ExpenseItem(
                              id: explicitTime.millisecondsSinceEpoch.toString(),
                              amount: parsedAmount,
                              category: _selectedCategory,
                              description: _descriptionController.text,
                              timestamp: timeString,
                            );

                            final updatedHistoryList = [newItem, ...ledgerItems];
                            ref.read(ledgerStreamProvider.notifier).state = updatedHistoryList;

                            // Save the update down to the local file logs
                            await ExomicDatabaseEngine.expenseBox.add(ExpenseModel(
                              id: newItem.id,
                              amount: newItem.amount,
                              category: newItem.category,
                              description: newItem.description,
                              timestamp: newItem.timestamp,
                            ));

                            // Sync outflows directly with the budget module parameters
                            final budgetList = ref.read(budgetPlannerProvider);
                            final synchronizedBudgetList = budgetList.map((element) {
                              if (element.category == _selectedCategory) {
                                return BudgetLimit(
                                  category: element.category,
                                  allocated: element.allocated,
                                  currentOutflow: element.currentOutflow + parsedAmount,
                                );
                              }
                              return element;
                            }).toList();
                            
                            ref.read(budgetPlannerProvider.notifier).state = synchronizedBudgetList;
                            
                            final targetBudget = synchronizedBudgetList.firstWhere((e) => e.category == _selectedCategory);
                            await ExomicDatabaseEngine.budgetBox.put(_selectedCategory, BudgetLimitModel(
                              category: targetBudget.category,
                              allocated: targetBudget.allocated,
                              currentOutflow: targetBudget.currentOutflow,
                            ));

                            _amountController.clear();
                            _descriptionController.clear();
                            setState(() => _isInputPanelOpen = false);
                          },
                          child: Text('LOG CORE LOG TRANSACTION', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Text('CHRONOLOGICAL TRACKING FEED', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
              const SizedBox(height: 16),

              // Transaction List Viewer
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ledgerItems.length,
                itemBuilder: (context, index) {
                  final item = ledgerItems[index];
                  final displayTime = item.timestamp.contains(' ') ? item.timestamp.split(' ')[1] : item.timestamp;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: specBorderColor, width: 0.5))),
                    child: Row(
                      children: [
                        Text('[$displayTime]', style: TextStyle(color: textSub, fontSize: 12, fontFamily: 'Inter')),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description, style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              const SizedBox(height: 2),
                              Text(item.category, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text('-$currency${item.amount.toStringAsFixed(2)}', style: TextStyle(color: textMain, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                final modifiedHistoryList = ledgerItems.where((element) => element.id != item.id).toList();
                                ref.read(ledgerStreamProvider.notifier).state = modifiedHistoryList;

                                // Delete record from disk storage containers
                                final targetModel = ExomicDatabaseEngine.expenseBox.values.firstWhere((e) => e.id == item.id);
                                await targetModel.delete();

                                // Reverse transaction amount inside the budget limit values
                                final budgetList = ref.read(budgetPlannerProvider);
                                final synchronizedBudgetList = budgetList.map((element) {
                                  if (element.category == item.category) {
                                    return BudgetLimit(
                                      category: element.category,
                                      allocated: element.allocated,
                                      currentOutflow: (element.currentOutflow - item.amount).clamp(0.0, double.infinity),
                                    );
                                  }
                                  return element;
                                }).toList();
                                
                                ref.read(budgetPlannerProvider.notifier).state = synchronizedBudgetList;
                                
                                final targetBudget = synchronizedBudgetList.firstWhere((e) => e.category == item.category);
                                await ExomicDatabaseEngine.budgetBox.put(item.category, BudgetLimitModel(
                                  category: targetBudget.category,
                                  allocated: targetBudget.allocated,
                                  currentOutflow: targetBudget.currentOutflow,
                                ));
                              },
                              child: Icon(Icons.close, color: textSub.withOpacity(0.6), size: 14),
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

```

---

## 6. POOL RESERVES AND ACCUMULATION PACING ALGORITHMS (`saving.dart`)

### 6.1 The Daily Pace Formula

The **Savings Module** manages long-term savings goals. Instead of just tracking total saved amounts, the application processes deadlines and target figures to calculate the precise daily contribution rate needed to reach a goal.

```
                  [User Input: Target Balance & Target Date]
                                      │
                                      ▼
                        [Parse Target Deadline String]
                                      │
                                      ▼
                    [Calculate Remaining System Time Span]
                                      │
                         ┌────────────┴────────────┐
                    (Remaining Days > 0)     (Remaining Days <= 0)
                                 │                         │
                                 ▼                         ▼
                    [Execute Pacing Equation]     [Set Daily Pace = 0]
                                 │
                                 ▼
                     $$\text{Daily Pace} = \frac{\text{Target Balance} - \text{Current Balance}}{\text{Remaining Days}}$$

```

The app checks the system clock and resets the hour parameters to compare dates cleanly:

```dart
final DateTime today = DateTime.now();
final DateTime zeroedToday = DateTime(today.year, today.month, today.day);
final DateTime targetDeadline = DateTime.parse(goal.deadline);

final int remainingDays = targetDeadline.difference(zeroedToday).inDays;

```

If the remaining time is greater than zero, the app runs the contribution equation:

$$\text{Daily Pace Required} = \frac{\text{Target Balance} - \text{Current Balance}}{\text{Remaining Days}}$$

This calculation updates whenever a new deposit is logged. It tells the user exactly how much capital needs to be set aside each day, turning static long-term goals into clear daily actions.

### 6.2 Target Milestone Progress Bars

Progress presentation uses basic layout bars that reflect these daily calculations. The width of the inner bar changes dynamically based on the percentage of the goal achieved:

$$\text{Progress Factor} = \left( \frac{\text{Current Balance}}{\text{Target Balance}} \right). \text{clamp}(0.0, 1.0)$$

This progress metric is bound directly to a `FractionallySizedBox` layout element, providing clean visual feedback on progress across dark and light presentation schemes.

Here is the implementation of the savings system inside `saving.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
import 'settings.dart';
import 'expense.dart';

class SavingGoal {
  final String id;
  final String title;
  final double target;
  final double current;
  final String deadline;
  final double dailyPaceRequired;
  final List<String> history;
  final bool isHistoryExpanded;

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
}

final savingsProvider = StateProvider<List<SavingGoal>>((ref) {
  final rawList = ExomicDatabaseEngine.getPools();
  return rawList.map((e) => SavingGoal(
    id: e['id'] ?? '',
    title: e['title'] ?? '',
    target: (e['target'] as num?)?.toDouble() ?? 0.0,
    current: (e['current'] as num?)?.toDouble() ?? 0.0,
    deadline: e['deadline'] ?? '',
    dailyPaceRequired: (e['dailyPaceRequired'] as num?)?.toDouble() ?? 0.0,
    history: List<String>.from(e['history'] ?? []),
  )).toList();
});

class SavingGoalsScreen extends ConsumerStatefulWidget {
  const SavingGoalsScreen({super.key});

  @override
  ConsumerState<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends ConsumerState<SavingGoalsScreen> {
  bool _isCreatorPanelOpen = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _deadlineController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);
    final poolsList = ref.watch(savingsProvider);

    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frame Core Headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: Main───────────────────────────────────.spaceBetween,
                children: [
                  Text('SAVINGS_PANEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter', color: textMain)),
                  GestureDetector(
                    onTap: () => setState(() => _isCreatorPanelOpen = !_isCreatorPanelOpen),
                    child: Row(
                      children: [
                        Text(_isCreatorPanelOpen ? '[ CLOSE ]' : '[ ADD POOL ]', style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        const SizedBox(width: 4),
                        AnimatedRotation(duration: const Duration(milliseconds: 200), turns: _isCreatorPanelOpen ? 0.25 : 0.0, child: Icon(Icons.keyboard_arrow_right, color: textSub, size: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  if (_isCreatorPanelOpen) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INITIALIZE RESERVES MATRIX', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _titleController,
                            style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              labelText: 'TARGET OBJECTIVE LABEL',
                              labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              labelText: 'TARGET BALANCE CAP',
                              labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                              prefixText: '$currency ',
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _deadlineController,
                            readOnly: true,
                            style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              labelText: 'DEADLINE TIMESTAMP (YYYY-MM-DD)',
                              labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                            ),
                            onTap: () async {
                              final explicitTime = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                builder: (context, child) => Theme(
                                  data: isDark ? ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.white, surface: Color(0xFF0A0A0A))) : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.black, surface: Color(0xFFF5F5F5))),
                                  child: child!,
                                ),
                              );
                              if (explicitTime != null) {
                                _deadlineController.text = "${explicitTime.year}-${explicitTime.month.toString().padLeft(2, '0')}-${explicitTime.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(side: BorderSide(color: textMain, width: 0.8), shape: const RoundedRectangleBorder()),
                              onPressed: () async {
                                final double? parsedTarget = double.tryParse(_targetController.text);
                                if (parsedTarget == null || parsedTarget <= 0 || _titleController.text.isEmpty || _deadlineController.text.isEmpty) return;

                                final today = DateTime.now();
                                final todayZeroed = DateTime(today.year, today.month, today.day);
                                final deadlineDate = DateTime.parse(_deadlineController.text);
                                final remainingDays = deadlineDate.difference(todayZeroed).inDays;
                                final calculatedPace = remainingDays <= 0 ? parsedTarget : parsedTarget / remainingDays;

                                final newGoal = SavingGoal(
                                  id: today.millisecondsSinceEpoch.toString(),
                                  title: _titleController.text,
                                  target: parsedTarget,
                                  current: 0.0,
                                  deadline: _deadlineController.text,
                                  dailyPaceRequired: calculatedPace,
                                  history: [],
                                );

                                final updatedPools = [...poolsList, newGoal];
                                ref.read(savingsProvider.notifier).state = updatedPools;
                                await ExomicDatabaseEngine.savePools(updatedPools.map((e) => e.toMap()).toList());

                                _titleController.clear();
                                _targetController.clear();
                                _deadlineController.clear();
                                setState(() => _isCreatorPanelOpen = false);
                              },
                              child: Text('INITIALIZE SYSTEM POOL', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Savings Card List Iterator
                  ...poolsList.map((goal) {
                    final percent = (goal.current / goal.target).clamp(0.0, 1.0);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardBg, border: Border.all(color: specBorderColor, width: 0.8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(goal.title, style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              GestureDetector(
                                onTap: () async {
                                  final updatedList = poolsList.where((element) => element.id != goal.id).toList();
                                  ref.read(savingsProvider.notifier).state = updatedList;
                                  
                                  final targetModel = ExomicDatabaseEngine.savingsBox.values.firstWhere((e) => e.id == goal.id);
                                  await targetModel.delete();
                                },
                                child: Text('[ PURGE ]', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text("TARGET TIMELINE LIMIT: ${goal.deadline}", style: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter')),
                          const SizedBox(height: 16),
                          
                          // Goal Progress Indicator
                          Stack(
                            children: [
                              Container(width: double.infinity, height: 2, color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5)),
                              FractionallySizedBox(widthFactor: percent, child: Container(height: 2, color: textMain)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ACCUMULATED', style: TextStyle(color: textSub, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text('$currency${goal.current.toStringAsFixed(2)} / $currency${goal.target.toStringAsFixed(0)}', style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('DAILY DRIFT PACE', style: TextStyle(color: textSub, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  const SizedBox(height: 2),
                                  Text('$currency${goal.dailyPaceRequired.toStringAsFixed(2)}/D', style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Deposit Interface Row
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 35,
                                  child: TextField(
                                    controller: _depositController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: textMain, fontSize: 12, fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      hintText: 'DEPOSIT TRANSFERS AMOUNT',
                                      hintStyle: TextStyle(color: textSub, fontSize: 9, fontFamily: 'Inter'),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: textMain, width: 0.8), shape: const RoundedRectangleBorder(), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                                onPressed: () async {
                                  final double? parsedDeposit = double.tryParse(_depositController.text);
                                  if (parsedDeposit == null || parsedDeposit <= 0) return;

                                  final updatedAmount = goal.current + parsedDeposit;
                                  final today = DateTime.now();
                                  final todayZeroed = DateTime(today.year, today.month, today.day);
                                  final deadlineDate = DateTime.parse(goal.deadline);
                                  final remainingDays = deadlineDate.difference(todayZeroed).inDays;
                                  final calculatedPace = remainingDays <= 0 ? 0.0 : (goal.target - updatedAmount).clamp(0.0, double.infinity) / remainingDays;

                                  final String rawHistoryToken = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}@+$currency${parsedDeposit.toStringAsFixed(2)}";

                                  final updatedGoal = goal.copyWith(
                                    current: updatedAmount,
                                    dailyPaceRequired: calculatedPace,
                                    history: [rawHistoryToken, ...goal.history],
                                  );

                                  final updatedPoolsList = poolsList.map((e) => e.id == goal.id ? updatedGoal : e).toList();
                                  ref.read(savingsProvider.notifier).state = updatedPoolsList;
                                  
                                  final targetGoalModel = ExomicDatabaseEngine.savingsBox.values.firstWhere((e) => e.id == goal.id);
                                  await ExomicDatabaseEngine.savingsBox.put(targetGoalModel.key, SavingGoalModel(
                                    id: updatedGoal.id,
                                    title: updatedGoal.title,
                                    target: updatedGoal.target,
                                    current: updatedGoal.current,
                                    deadline: updatedGoal.deadline,
                                    dailyPaceRequired: updatedGoal.dailyPaceRequired,
                                    history: updatedGoal.history,
                                  ));

                                  // Automatically update the main ledger transaction feed
                                  final ledgerItems = ref.read(ledgerStreamProvider);
                                  final timeString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} ${today.hour.toString().padLeft(2, '0')}:${today.minute.toString().padLeft(2, '0')}:${today.second.toString().padLeft(2, '0')}";
                                  
                                  final automaticLedgerItem = ExpenseItem(
                                    id: today.millisecondsSinceEpoch.toString(),
                                    amount: parsedDeposit,
                                    category: 'SAVINGS',
                                    description: "POOL TRANSFER: ${goal.title.toUpperCase()}",
                                    timestamp: timeString,
                                  );

                                  ref.read(ledgerStreamProvider.notifier).state = [automaticLedgerItem, ...ledgerItems];
                                  await ExomicDatabaseEngine.expenseBox.add(ExpenseModel(
                                    id: automaticLedgerItem.id,
                                    amount: automaticLedgerItem.amount,
                                    category: automaticLedgerItem.category,
                                    description: automaticLedgerItem.description,
                                    timestamp: automaticLedgerItem.timestamp,
                                  ));

                                  _depositController.clear();
                                },
                                child: Text('EXECUTE', style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              )
                            ],
                          ),
                          
                          // Expandable Deposit Logs Accordion
                          if (goal.history.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                ref.read(savingsProvider.notifier).state = poolsList.map((e) {
                                  if (e.id == goal.id) return e.copyWith(isHistoryExpanded: !e.isHistoryExpanded);
                                  return e;
                                }).toList();
                              },
                              child: Row(
                                children: [
                                  Text(goal.isHistoryExpanded ? '[ HIDE HISTORIC MATRIX ]' : '[ VIEW HISTORIC MATRIX ]', style: TextStyle(color: textSub, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                  Icon(goal.isHistoryExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: textSub, size: 12),
                                ],
                              ),
                            ),
                            if (goal.isHistoryExpanded) ...[
                              const SizedBox(height: 8),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 120),
                                decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.5)),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: goal.history.length,
                                  itemBuilder: (context, hIndex) {
                                    final token = goal.history[hIndex];
                                    final date = token.split('@')[0];
                                    final displayAmount = token.split('@')[1];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      color: hIndex % 2 == 0 ? Colors.transparent : cardBg,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("[$date]", style: TextStyle(color: textSub, fontSize: 9, fontFamily: 'Inter')),
                                          Text(displayAmount, style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]
                          ]
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

---

### 7. RECURRING LIABILITIES MECHANICS (`subscription.dart`)

### 7.1 Renewal Tracking and Processing Timestamps

The **Subscription Screen** tracks recurring service plans. Instead of relying on system background tasks, the app calculates remaining days until renewal on the fly whenever the module loads.

The system reads the current device date and resets the hours to build clean date boundaries:

```dart
final DateTime now = DateTime.now();
final DateTime todayZeroed = DateTime(now.year, now.month, now.day);

```

When processing individual items, the string timestamp is parsed into a `DateTime` instance. The difference between the dates determines the remaining time:

```dart
final DateTime explicitRenewalDate = DateTime.parse(sub.renewalDate);
final int daysRemaining = explicitRenewalDate.difference(todayZeroed).inDays;

```

```
[Load Subscription Log Entry]
              │
              ▼
  [Parse Embedded ISO Timestamp String]
              │
              ▼
  [Calculate Relative Residual Time Span Window]
              │
     ┌────────┴────────┐
(Days Remaining <= 0) (Days Remaining > 0)
     │                 │
     ▼                 ▼
[Flag Alert Overdue] [Render Standard Cycle Indicator]
     │
     ▼
[Tint Border Outlines to Crimson Red Alert Theme]

```

If the renewal date has passed or falls on the current day, the card border color switches to warning red (`Color(0xFFE63946)`). This visual cue alerts the user to due renewals during active navigation.

### 7.2 Text Field Theming Overrides

To preserve the minimal aesthetic during data entry, standard system date selection calendars are embedded inside custom `ThemeData` override wrappers:

```dart
final ThemeData explicitCalendarTheme = isDark
    ? ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: const Color(0xFF0A0A0A),
          onSurface: Colors.white,
        ),
      )
    : ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          surface: const Color(0xFFF5F5F5),
          onSurface: Colors.black,
        ),
      );

```

Applying this theme map across the calendar context prevents bright accent accents from disrupting the interface style, keeping the visual presentation consistent.

Here is the implementation of the subscription management system inside `subscription.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database.dart';
import 'settings.dart';

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
  bool _isFormPanelOpen = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final currency = ref.watch(currencyProvider);
    final subsList = ref.watch(subscriptionProvider);

    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final alertRed = const Color(0xFFE63946);

    final today = DateTime.now();
    final todayZeroed = DateTime(today.year, today.month, today.day);

    // Compute rolling summation metrics
    final double aggregatedSubscriptionDrain = subsList
        .where((element) => element.isActive)
        .fold(0.0, (sum, sub) => sum + sub.cost);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Header Element Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SUBSCRIPTION_MANAGER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter', color: textMain)),
                  GestureDetector(
                    onTap: () => setState(() => _isFormPanelOpen = !_isFormPanelOpen),
                    child: Row(
                      children: [
                        Text(_isFormPanelOpen ? '[ DISMISS ]' : '[ REQ UTILITY ]', style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        const SizedBox(width: 4),
                        AnimatedRotation(duration: const Duration(milliseconds: 200), turns: _isFormPanelOpen ? 0.25 : 0.0, child: Icon(Icons.keyboard_arrow_right, color: textSub, size: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Aggregated Subscription Analytics Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardBg, border: Border.all(color: specBorderColor, width: 0.8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MONTHLY AGGREGATED UTILITY CONSUMPTION', style: TextStyle(color: textSub, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    Text('$currency${aggregatedSubscriptionDrain.toStringAsFixed(2)}/M', style: TextStyle(color: textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Inter')),
                  ],
                ),
              ),

              // Operational Inputs Terminal Box
              if (_isFormPanelOpen) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REGISTER RECURRING LIABILITY', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'SERVICE UTILITY DESIGNATION',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'LIABILITY OUTFLOW COST',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          prefixText: '$currency ',
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          labelText: 'MATURITY RENEWAL TIMESTAMP',
                          labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                        ),
                        onTap: () async {
                          final explicitTime = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                            builder: (context, child) => Theme(
                              data: isDark ? ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.white, surface: Color(0xFF0A0A0A))) : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.black, surface: Color(0xFFF5F5F5))),
                              child: child!,
                            ),
                          );
                          if (explicitTime != null) {
                            _dateController.text = "${explicitTime.year}-${explicitTime.month.toString().padLeft(2, '0')}-${explicitTime.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: textMain, width: 0.8), shape: const RoundedRectangleBorder()),
                          onPressed: () async {
                            final double? parsedCost = double.tryParse(_costController.text);
                            if (parsedCost == null || parsedCost <= 0 || _titleController.text.isEmpty || _dateController.text.isEmpty) return;

                            final newSubscriptionItem = SubscriptionItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: _titleController.text,
                              cost: parsedCost,
                              renewalDate: _dateController.text,
                              isActive: true,
                            );

                            final updatedSubscriptionsList = [...subsList, newSubscriptionItem];
                            ref.read(subscriptionProvider.notifier).state = updatedSubscriptionsList;
                            await ExomicDatabaseEngine.saveSubscriptions(updatedSubscriptionsList.map((e) => e.toMap()).toList());

                            _titleController.clear();
                            _costController.clear();
                            _dateController.clear();
                            setState(() => _isFormPanelOpen = false);
                          },
                          child: Text('COMMIT SUBSCRIPTION MATRIX', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Text('ACTIVE RECURRING LIABILITIES CONSOLE', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
              const SizedBox(height: 16),

              // Subscription Item Grid View
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subsList.length,
                itemBuilder: (context, index) {
                  final sub = subsList[index];
                  final subRenewalDate = DateTime.parse(sub.renewalDate);
                  final remainingDays = subRenewalDate.difference(todayZeroed).inDays;
                  final bool isOverdue = remainingDays <= 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: isOverdue ? alertRed : specBorderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.title.toUpperCase(), style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              const SizedBox(height: 4),
                              Text(
                                isOverdue ? "MATURITY BREACH STATUS [ DUE ]" : "RENEWAL OUTFLOW CYCLE: $remainingDays DAYS",
                                style: TextStyle(color: isOverdue ? alertRed : textSub, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$currency${sub.cost.toStringAsFixed(2)}', style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () async {
                                final updatedList = subsList.where((element) => element.id != sub.id).toList();
                                ref.read(subscriptionProvider.notifier).state = updatedList;
                                await ExomicDatabaseEngine.saveSubscriptions(updatedList.map((e) => e.toMap()).toList());
                              },
                              child: Text('[ REMOVE ]', style: TextStyle(color: alertRed.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
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

```

---

### 8. INTEGRATED ENVIRONMENT SYSTEM CONTROL HUB (`settings.dart`)

### 8.1 Data Control Panels

The **Settings Panel** acts as the central control dashboard for the app. It manages persistent settings variables (like active currencies and income limits) and coordinates global actions like clearing all data boxes to return the local environment to its initial state.

```
[Tap Purge Data Box Button Container]
                  │
                  ▼
   [Display Security Warning Confirmation]
                  │
         ┌────────┴────────┐
   (CONFIRMED)        (CANCELLED)
         │                 │
         ▼                 ▼
 [Clear All Hive Data Boxes]  [Exit Confirmation Modal]
         │
         ▼
 [Reset Riverpod Global State Nodes]
         │
         ▼
 [Interface Redraws Instantly on the Fly]

```

When a user triggers a global database purge, the app clears out the local storage tables completely:

```dart
await ExomicDatabaseEngine.expenseBox.clear();
await ExomicDatabaseEngine.budgetBox.clear();
await ExomicDatabaseEngine.savingsBox.clear();

```

Following the database wipe, the app resets all active state providers. This clears cached running figures immediately and updates the visual layouts on the fly without requiring a full application restart.

### 8.2 Text Formatting Rules

To render documentation structures within the text view without complex typography code, the document screen includes a simple layout parsing engine:

```dart
List<Widget> _buildParsedContent(String contextText, Color coreText, Color dimColor) {
  final List<String> textBlocks = contextText.split('\n\n');
  return textBlocks.map((block) {
    if (block.contains('\n')) {
      final parts = block.split('\n');
      final titleHeader = parts[0];
      final secondaryBody = parts.sublist(1).join('\n');
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleHeader, style: TextStyle(color: coreText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
            const SizedBox(height: 6),
            Text(secondaryBody, style: TextStyle(color: dimColor, fontSize: 12, height: 1.4, fontFamily: 'Inter')),
          ],
        ),
      );
    }
    // ...

```

This layout loop splits document text blocks by double newlines (`\n\n`) and treats the first line of each block as a section header. It formats the section title using a bold typographic style and renders the remaining text as the section body, creating clean, readable layouts for offline help manuals.

Here is the implementation of the application system controls layer inside `settings.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database.dart';
import 'budget.dart';
import 'expense.dart';
import 'subscription.dart';
import 'saving.dart';

final settingsThemeModeProvider = StateProvider<bool>((ref) => ExomicDatabaseEngine.getThemeMode());
final currencyProvider = StateProvider<String>((ref) => '\$');

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currencyController.text = ref.read(currencyProvider);
      _incomeController.text = ExomicDatabaseEngine.getPrimaryIncome().toStringAsFixed(0);
    });
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;
          return SlideTransition(
            position: animation.drive(Tween(begin: begin, end: end).chain(CurveTween(curve: curve))),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    final currentCurrency = ref.watch(currencyProvider);

    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYSTEM_CONTROL_MATRIX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter', color: textMain)),
              const SizedBox(height: 32),

              // Theme Switch Component Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, border: Border.all(color: specBorderColor, width: 0.8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VISUAL INTERFACE SCHEMA', style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text(isDark ? 'ACTIVE THEME PARAMETER: DARK MODE' : 'ACTIVE THEME PARAMETER: LIGHT MODE', style: TextStyle(color: textSub, fontSize: 9, fontFamily: 'Inter')),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF1F1F1F),
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: const Color(0xFFE5E5E5),
                      onChanged: (val) async {
                        ref.read(settingsThemeModeProvider.notifier).state = val;
                        await ExomicDatabaseEngine.setThemeMode(val);
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Global Config Setup Forms
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: specBorderColor, width: 0.8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ENVIRONMENT CONSTANT VARIABLES', style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                      decoration: InputDecoration(
                        labelText: 'PRIMARY MONTHLY LIQUID INCOME',
                        labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                        prefixText: '$currentCurrency ',
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                      ),
                      onChanged: (value) async {
                        final double? parsedVal = double.tryParse(value);
                        if (parsedVal != null && parsedVal >= 0) {
                          await ExomicDatabaseEngine.setPrimaryIncome(parsedVal);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currencyController,
                      maxLength: 3,
                      style: TextStyle(color: textMain, fontSize: 13, fontFamily: 'Inter'),
                      decoration: InputDecoration(
                        labelText: 'SYSTEM VALUE CURRENCY TOKEN',
                        labelStyle: TextStyle(color: textSub, fontSize: 10, fontFamily: 'Inter'),
                        counterText: '',
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: specBorderColor, width: 0.8)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textMain, width: 0.8)),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          ref.read(currencyProvider.notifier).state = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Static Documentation Modules
              Text('SYSTEM INTERNALS DOCUMENTATION', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
              const SizedBox(height: 16),
              
              _buildActionTile(
                label: 'PRIVACY POLICY',
                valueText: '[ REQ ]',
                borderColor: specBorderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'PRIVACY POLICY',
                    content: '''1. TELEMETRY SCOPE & ISOLATION
All operations, tracking parameters, liquid assets, and computational balance data are recorded exclusively inside isolated client environments. This application operates inside a completely decentralized sandbox. No external synchronization hooks exist to bridge your input data to a broader network. Your financial data is strictly your own.

2. NETWORK DISCONNECT GUARANTEE
This architecture guarantees offline-first operational parameters. Your transaction history, subscription tokens, category limits, and goal trackers are never shared with developer endpoints, analytic channels, or third-party marketing services. We do not track your IP address, device telemetry, or usage statistics.

3. RIGHT TO PURGE & DATA SOVEREIGNTY
Data sovereignty belongs to the active user. You hold explicit rights to force-wipe all matrices instantly. Standard uninstallation of the software package physically obliterates the core Hive database vectors, permanently erasing your operational imprint from the device memory blocks. No residual cache is left behind.

4. THIRD-PARTY INTEGRATIONS
Zero external APIs are utilized for data processing. There are no ad-network SDKs or cloud-syncing middleware components embedded in the source code. Your financial footprint remains entirely localized and isolated from commercial scraping.''',
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                label: 'DATA SECURITY',
                valueText: '[ REQ ]',
                borderColor: specBorderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'DATA SECURITY',
                    content: '''1. LOCAL STORAGE LAYERS
Application persistence vectors utilize memory-mapped file structures (Hive Data Boxes) positioned rigidly inside standard, OS-protected application directory bounds. These files are inaccessible to parallel installed system software packages or file explorers without root access.

2. CRYPTOGRAPHIC INTEGRITY
Data blocks remain securely compartmentalized. While we optimize for compute overhead during operational rendering to ensure a perfectly smooth UI layer, your physical platform protection parameters (Device PIN, Passcode, and Biometrics) serve as the impenetrable primary barrier against visual data breaches.

3. CORRUPTION MITIGATION
Internal matrix validations monitor hardware-level storage corruptions continuously. If system validation determines that the internal database file mapping has been manipulated or damaged by a sudden power loss, the engine will structurally hard-reset corrupted parameters to ensure the application maintains baseline stability and prevents calculation overflow.

4. VOLATILE MEMORY HANDLING
Active session data is held in volatile RAM arrays via state providers. Upon application termination, all temporary state parameters are instantly flushed, ensuring no floating data can be intercepted by background processes.''',
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                label: 'USER GUIDE',
                valueText: '[ REQ ]',
                borderColor: specBorderColor,
                textMain: textMain,
                onTap: () => _navigateToPage(
                  context,
                  SystemDocumentScreen(
                    title: 'USER GUIDE',
                    content: '''1. MATRIX INITIALIZATION & LIMITS
Begin navigation via the BUDGET deck. Open configuration windows to initialize specific operational bounds. Enter standard category labels (e.g., HOUSING, GROCERIES, TRANSPORT) and inject fluid funding thresholds to establish your maximum spending allocations per cycle.

2. LIQUIDITY MANAGEMENT (LEDGER)
Access active liquidity via the LEDGER tab. First, append an incoming resource transaction (Monthly Income) at the top of the interface. As you deploy capital, record mandatory outflows using the 'NEW TRANSACTION' terminal. Tracking engines will calculate margin statistics instantaneously.

3. ASSET POOLS & TARGETS
Deploy long-term capital into POOLS (Savings). Define maturity deadlines and target volumes. The system will automatically calculate the required Daily Target Pace. Logging a deposit here will automatically deduct from your unassigned liquidity, keeping your global balance mathematically sound.

4. OVERRUN MITIGATION
If your computational outflow permanently breaks configuration bounds, matrix components will flag dynamic [ BREACH ] warnings. Monitor your POOLS to restructure capital vectors efficiently, and clear unused passive drains in the SUBSCRIPTION manager.''',
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Danger Zone Clear Storage Options
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE63946)),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: cardBg,
                      shape: const RoundedRectangleBorder(),
                      title: Text('FORCE HARD DESTRUCT DEVICE IMPRINT?', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                      content: Text('This operation clears all encrypted data boxes from disk memory permanently.', style: TextStyle(color: textSub, fontSize: 11, fontFamily: 'Inter')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('[ CANCEL ]', style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Purge all physical data files across active memory systems
                            await ExomicDatabaseEngine.expenseBox.clear();
                            await ExomicDatabaseEngine.subscriptionBox.clear();
                            await ExomicDatabaseEngine.savingsBox.clear();
                            await ExomicDatabaseEngine.budgetBox.clear();
                            await ExomicDatabaseEngine.settingsBox.clear();

                            // Reset state management maps to initial conditions
                            ref.read(ledgerStreamProvider.notifier).state = [];
                            ref.read(subscriptionProvider.notifier).state = [];
                            ref.read(savingsProvider.notifier).state = [];
                            ref.read(budgetPlannerProvider.notifier).state = [];

                            _incomeController.clear();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('[ PURGE ]', style: TextStyle(color: Color(0xFFE63946), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('PURGE INTERNAL DATABASE PACKAGES', style: TextStyle(color: Color(0xFFE63946), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({required String label, required String valueText, required Color borderColor, required Color textMain, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: borderColor, width: 0.8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            Text(valueText, style: TextStyle(color: textMain, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

class SystemDocumentScreen extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const SystemDocumentScreen({super.key, required this.title, required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_left, color: textSub, size: 18),
                      const SizedBox(width: 4),
                      Text('[ BACK ]', style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(title, style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontFamily: 'Inter')),
              const SizedBox(height: 24),
              Container(width: double.infinity, height: 1, color: specBorderColor),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildParsedContent(content, textMain, textSub),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParsedContent(String contextText, Color coreText, Color dimColor) {
    final List<String> textBlocks = contextText.split('\n\n');
    return textBlocks.map((block) {
      if (block.contains('\n')) {
        final parts = block.split('\n');
        final titleHeader = parts[0];
        final secondaryBody = parts.sublist(1).join('\n');
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titleHeader, style: TextStyle(color: coreText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
              const SizedBox(height: 6),
              Text(secondaryBody, style: TextStyle(color: dimColor, fontSize: 12, height: 1.4, fontFamily: 'Inter')),
            ],
          ),
          );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(block, style: TextStyle(color: dimColor, fontSize: 12, height: 1.4, fontFamily: 'Inter')),
      );
    }).toList();
  }
}

```

---

### 9. CORE LAUNCH SEQUENCE AND INITIALIZATION STEPS (`main.dart`)

The entry configuration inside `main.dart` coordinates the application launch sequence, setting up platform resources, native bindings, and local storage access windows before rendering any user interface components.

```
                  [Platform Boot Init: main()]
                                │
                                ▼
         [Ensure Flutter Native Core Widgets Binding Sync]
                                │
                                ▼
         [Initialize Protected Database Storage Layers]
                                │
                                ▼
         [Inject ProviderScope State Container Context]
                                │
                                ▼
           [Mount Application Container: AppShellFrame]

```

When the app launches, it registers structural layout bindings, mounts database nodes, and handles initialization requirements through a clean bootstrap routine:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database.dart';
import 'presentation/screens/expense.dart';
import 'presentation/screens/budget.dart';
import 'presentation/screens/saving.dart';
import 'presentation/screens/subscription.dart';
import 'presentation/screens/settings.dart';

void main() async {
  // Bind standard layout parameters into engine setups
  WidgetsFlutterBinding.ensureInitialized();
  
  // Open secure memory-mapped storage boxes
  await ExomicDatabaseEngine.initializeStorageEngine();
  
  runApp(
    const ProviderScope(
      child: ExomicCoreLedgerEngineApp(),
    ),
  );
}

class ExomicCoreLedgerEngineApp extends StatelessWidget {
  const ExomicCoreLedgerEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppShellFrame(),
    );
  }
}

class AppShellFrame extends ConsumerStatefulWidget {
  const AppShellFrame({super.key});

  @override
  ConsumerState<AppShellFrame> createState() => _AppShellFrameState();
}

class _AppShellFrameState extends ConsumerState<AppShellFrame> {
  int _activeTabPointerIndex = 0;

  final List<Widget> _screenWorkspaceViewPorts = const [
    LedgerScreen(),
    BudgetPlannerScreen(),
    SavingGoalsScreen(),
    SubscriptionScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(settingsThemeModeProvider);
    
    final screenBg = isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA);
    final specBorderColor = isDark ? const Color(0xFF191919) : const Color(0xFFE5E5E5);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? const Color(0xFF737373) : const Color(0xFF525252);

    return Scaffold(
      backgroundColor: screenBg,
      body: IndexedStack(
        index: _activeTabPointerIndex,
        children: _screenWorkspaceViewPorts,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: specBorderColor, width: 0.8))),
        child: BottomNavigationBar(
          currentIndex: _activeTabPointerIndex,
          onTap: (index) => setState(() => _activeTabPointerIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: screenBg,
          selectedItemColor: textMain,
          unselectedItemColor: textSub,
          selectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Inter', letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.normal, fontFamily: 'Inter'),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.receipt_long_outlined, size: 18)), label: 'LEDGER'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.pie_chart_outline, size: 18)), label: 'BUDGET'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.track_changes, size: 18)), label: 'POOLS'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.autorenew_outlined, size: 18)), label: 'UTILITY'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.tune_outlined, size: 18)), label: 'CONSOLE'),
          ],
        ),
      ),
    );
  }
}

```

The component tree handles global app view switching using an `IndexedStack` widget wrapper. Unlike standard view routing modules that destroy layout contexts during screen transitions, `IndexedStack` retains screen states within active hardware threads. This approach eliminates rebuilding cycles when users switch tabs, keeping layout navigation fast and fluid.

---

### 10. SYSTEM SAFETY, RUNTIME PERFORMANCE, AND SYSTEM SPECIFICATIONS

### 10.1 Memory Management and Leak Prevention

Mobile operating systems enforce strict resource limits on background processes. To prevent layout lag or memory growth during long usage sessions, Exomic includes several performance safeguards:

```
[User Scroll Feed Triggers] ──> [SingleChildScrollView Viewports]
                                       │
                                       ▼
                 [Explicit shrinkWrap Boundaries Enforced]
                                       │
                                       ▼
                 [Immediate System GC Memory Collection]

```

1. **Garbage Collection Optimization:** Large lists inside the application use explicit bounds configurations (`shrinkWrap: true` combined with `NeverScrollableScrollPhysics()`). This avoids infinite height calculation loops, helps the rendering thread reuse element layouts, and keeps memory usage stable.
2. **Text Controller Cleanup Loops:** Views with input fields include explicit teardown instructions within their lifecycle methods (`_allocationController.dispose()`). This flushes unused text caches entirely upon view destruction, preventing memory leaks.

### 10.2 Database Operations and Thread Management

Writing data streams to local disks can block user interface threads if handled inefficiently. Exomic completely prevents interface stutters by utilizing Hive's fast atomic write patterns.

Instead of running multi-index data search queries that scale poorly over time, the app accesses model objects directly using assigned unique identifier strings as collection lookup keys:

```dart
await ExomicDatabaseEngine.budgetBox.put(_selectedCategory, BudgetLimitModel(...));

```

This direct value targeting converts array lookups into constant-time transactions that scale efficiently with larger datasets ($O(1)$ algorithmic runtime efficiency). By keeping disk transactions short and fast, the main user interface loop executes without interruption, providing a smooth and responsive experience across all supported devices.
