// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import 'add_expense_screen.dart';
import '../widgets/expense_tile.dart';
import 'reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Scaffold(
          appBar: AppBar(
            title: const Text('SpendSense'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                ),
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.signOut()),
            ],
          ),
          drawer: isWide ? null : const Drawer(child: _SideMenu()),
          body: Row(children: [
            if (isWide) const SizedBox(width: 300, child: _SideMenu()),
            const Expanded(child: _ExpenseList()),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ),
            child: const Icon(Icons.add),
            tooltip: 'Add expense',
          ),
        );
      },
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final total = provider.expenses.fold<double>(0.0, (a, b) => a + b.amount);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Total: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            'This month: ₹${provider.totalForMonth(DateTime.now()).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text('Categories', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: provider
                .totalsByCategory()
                .keys
                .map((c) => Chip(label: Text(c)))
                .toList(),
          ),
        ]),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList();

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(builder: (context, provider, _) {
      final expenses = provider.expenses;
      if (expenses.isEmpty) {
        return const Center(child: Text('No expenses yet. Tap + to add.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: expenses.length,
        itemBuilder: (context, i) => ExpenseTile(expense: expenses[i]),
      );
    });
  }
}

