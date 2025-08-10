// lib/widgets/expense_tile.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  const ExpenseTile({ required this.expense, Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitle = '${DateFormat.yMMMd().format(expense.date)} · ${expense.merchant ?? ''}';
    return Card(
      margin: EdgeInsets.symmetric(vertical:6, horizontal: 4),
      child: ListTile(
        leading: expense.receiptUrl != null ? SizedBox(width:56, height:56, child: Image.network(expense.receiptUrl!, fit: BoxFit.cover)) : CircleAvatar(child: Text(expense.category[0])),
        title: Text('₹${expense.amount.toStringAsFixed(2)} — ${expense.category}'),
        subtitle: Text('$subtitle\n${expense.note}', maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: expense.note.isNotEmpty,
      ),
    );
  }
}
