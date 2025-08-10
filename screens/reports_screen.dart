// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final totals = provider.totalsByCategory();
    final totalAll = totals.values.fold<double>(0.0, (a,b) => a+b);
    final predicted = provider.predictNextMonthTotal();
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: totals.isEmpty
          ? Center(child: Text('No data yet'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total spend: ₹${totalAll.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Predicted next month total: ₹${predicted.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.orange)),
                SizedBox(height: 12),
                Text('Spend by category', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: totals.entries.map((e) {
                      final percent = totalAll == 0 ? 0.0 : (e.value / totalAll);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical:8),
                        child: CategoryBar(category: e.key, amount: e.value, percent: percent),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
      ),
    );
  }
}
