// lib/providers/expense_provider.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../app_environment.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  final StorageService _storage = StorageService();
  final AiService _ai = AiService();

  StreamSubscription<List<Expense>>? _sub;
  List<Expense> _expenses = [];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  ExpenseProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _sub?.cancel();
      if (user == null && !AppEnvironment.useOffline) {
        _expenses = [];
        notifyListeners();
      } else if (!AppEnvironment.useOffline) {
        _sub = _fs.streamExpenses(user!.uid).listen((list) {
          _expenses = list;
          notifyListeners();
        });
      } else {
        // Offline mode: keep current in-memory list
        notifyListeners();
      }
    });
  }

  Future<void> addExpense({
    required double amount,
    required DateTime date,
    required String category,
    String note = '',
    String? merchant,
    Uint8List? receiptBytes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && !AppEnvironment.useOffline) throw Exception('Not authenticated');

    String? receiptUrl;
    if (receiptBytes != null && !AppEnvironment.useOffline) {
      receiptUrl = await _storage.uploadReceipt(receiptBytes, user!.uid);
    }

    final e = Expense(
      amount: amount,
      date: date,
      category: category,
      note: note,
      merchant: merchant,
      receiptUrl: receiptUrl,
    );

    if (AppEnvironment.useOffline) {
      _expenses = [e, ..._expenses];
      notifyListeners();
    } else {
      await _fs.addExpense(user!.uid, e);
    }
  }

  Future<void> updateExpense(Expense e) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && !AppEnvironment.useOffline) throw Exception('Not authenticated');
    if (AppEnvironment.useOffline) {
      final idx = _expenses.indexWhere((x) => identical(x, e));
      if (idx >= 0) {
        _expenses[idx] = e;
        notifyListeners();
      }
    } else {
      await _fs.updateExpense(user!.uid, e);
    }
  }

  Future<void> deleteExpense(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && !AppEnvironment.useOffline) throw Exception('Not authenticated');
    if (AppEnvironment.useOffline) {
      _expenses = _expenses.where((e) => e.id != id).toList();
      notifyListeners();
    } else {
      await _fs.deleteExpense(user!.uid, id);
    }
  }

  double totalForMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1);
    return _expenses
        .where((e) => e.date.isAfter(monthStart.subtract(Duration(seconds: 1))) && e.date.isBefore(monthEnd))
        .fold(0.0, (a, b) => a + b.amount);
  }

  Map<String, double> totalsByCategory({int lastN = 9999}) {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  String suggestCategory({String? merchant, String? note}) => _ai.suggestCategory(merchant: merchant, note: note);
  String quickInsight(Expense e) => _ai.quickInsight(e);

  double predictNextMonthTotal() => _ai.predictNextMonthTotal(_expenses);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

