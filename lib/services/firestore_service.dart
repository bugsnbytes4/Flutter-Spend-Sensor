// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExpense(String uid, Expense e) async {
    await _db.collection('users').doc(uid).collection('expenses').add(e.toMap());
  }

  Future<void> updateExpense(String uid, Expense e) async {
    if (e.id == null) throw Exception('Expense id is null');
    await _db.collection('users').doc(uid).collection('expenses').doc(e.id).update(e.toMap());
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _db.collection('users').doc(uid).collection('expenses').doc(expenseId).delete();
  }

  Stream<List<Expense>> streamExpenses(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Expense.fromMap(d.id, d.data())).toList());
  }
}

