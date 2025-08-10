// lib/services/ai_service.dart
// Provides local rule-based suggestions + a small predictor for next-month totals.
import '../models/expense.dart';
import 'dart:math';

class AiService {
  String suggestCategory({String? merchant, String? note}) {
    final text = ((merchant ?? '') + ' ' + (note ?? '')).toLowerCase();
    final mapping = {
      'food': ['restaurant', 'cafe', 'hotel', 'diner', 'burger', 'pizza', 'kfc', 'mcdonald'],
      'transport': ['uber', 'ola', 'taxi', 'bus', 'train', 'metro', 'fuel', 'petrol', 'diesel'],
      'shopping': ['amazon', 'flipkart', 'store', 'mall', 'shopping', 'shop'],
      'bills': ['electricity', 'water', 'bill', 'internet', 'reliance', 'jio'],
      'entertainment': ['netflix', 'hotstar', 'prime', 'movie', 'cinema', 'spotify'],
    };

    for (final entry in mapping.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) return _capitalize(entry.key);
      }
    }
    return 'Other';
  }

  String quickInsight(Expense e) {
    if (e.amount >= 10000) return 'Large expense — consider reviewing this purchase.';
    if (e.amount >= 5000) return 'Big spend — check if it was planned.';
    return 'Looks normal.';
  }

  /// Predict next month's total using a simple linear regression on monthly totals.
  /// Accepts a list of expenses (any date) and returns predicted total for the month after the latest expense.
  double predictNextMonthTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    // Group expenses by year-month
    final map = <String, double>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month}';
      map[key] = (map[key] ?? 0) + e.amount;
    }
    // sort keys by date
    final entries = map.entries.toList()
      ..sort((a, b) {
        final pa = a.key.split('-'); final pb = b.key.split('-');
        final ay = int.parse(pa[0]), am = int.parse(pa[1]);
        final by = int.parse(pb[0]), bm = int.parse(pb[1]);
        if (ay != by) return ay - by;
        return am - bm;
      });
    final n = entries.length;
    if (n == 1) return entries.first.value; // only one month -> return same total
    // simple linear regression on index -> value
    final xs = List<double>.generate(n, (i) => i.toDouble());
    final ys = entries.map((e) => e.value).toList();
    final xMean = xs.reduce((a,b) => a+b)/n;
    final yMean = ys.reduce((a,b) => a+b)/n;
    double num = 0, den = 0;
    for (var i=0;i<n;i++) {
      num += (xs[i]-xMean) * (ys[i]-yMean);
      den += (xs[i]-xMean) * (xs[i]-xMean);
    }
    final slope = den == 0 ? 0.0 : num / den;
    final intercept = yMean - slope * xMean;
    final nextX = n.toDouble();
    final pred = intercept + slope * nextX;
    // Add small jitter lower bound 0
    return max(0.0, pred);
  }

  String _capitalize(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
}
