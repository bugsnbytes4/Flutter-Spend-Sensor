// lib/screens/add_expense_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  final _merchantCtl = TextEditingController();
  DateTime _date = DateTime.now();
  String _category = 'Food';
  Uint8List? _receiptBytes;
  String? _receiptName;
  bool _loading = false;

  final List<String> _categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              controller: _amountCtl,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter amount' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMMMd().format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _merchantCtl,
              decoration: const InputDecoration(labelText: 'Merchant (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach receipt'),
                onPressed: _pickReceipt,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(_receiptName ?? 'No file selected')),
            ]),
            if (_receiptBytes != null) ...[
              const SizedBox(height: 12),
              SizedBox(height: 160, child: Image.memory(_receiptBytes!, fit: BoxFit.contain)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _loading = true);
                      try {
                        final amount = double.tryParse(_amountCtl.text.trim()) ?? 0.0;
                        String chosenCategory = _category;
                        if (chosenCategory == 'Other') {
                          final suggestion = provider.suggestCategory(
                            merchant: _merchantCtl.text,
                            note: _noteCtl.text,
                          );
                          chosenCategory = suggestion;
                        }
                        await provider.addExpense(
                          amount: amount,
                          date: _date,
                          category: chosenCategory,
                          note: _noteCtl.text.trim(),
                          merchant: _merchantCtl.text.trim(),
                          receiptBytes: _receiptBytes,
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickReceipt() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res == null || res.files.isEmpty) return;
    setState(() {
      _receiptBytes = res.files.single.bytes;
      _receiptName = res.files.single.name;
    });
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _noteCtl.dispose();
    _merchantCtl.dispose();
    super.dispose();
  }
}

