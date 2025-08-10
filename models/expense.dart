// lib/models/expense.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final double amount;
  final DateTime date;
  final String category;
  final String note;
  final String? receiptUrl;
  final String? merchant;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
    this.receiptUrl,
    this.merchant,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'note': note,
      'receiptUrl': receiptUrl,
      'merchant': merchant,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    final d = map['date'];
    DateTime parsedDate;
    if (d is Timestamp) parsedDate = d.toDate();
    else parsedDate = DateTime.tryParse(d?.toString() ?? '') ?? DateTime.now();

    final c = map['createdAt'];
    DateTime created;
    if (c is Timestamp) created = c.toDate();
    else created = DateTime.tryParse(c?.toString() ?? '') ?? DateTime.now();

    return Expense(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      date: parsedDate,
      category: (map['category'] ?? 'Other') as String,
      note: (map['note'] ?? '') as String,
      receiptUrl: (map['receiptUrl'] ?? null) as String?,
      merchant: (map['merchant'] ?? null) as String?,
      createdAt: created,
    );
  }
}
