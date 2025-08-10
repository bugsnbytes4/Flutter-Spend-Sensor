// lib/widgets/category_bar.dart
import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double percent;
  const CategoryBar({ required this.category, required this.amount, required this.percent, Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barColor = Colors.indigo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(category)),
          Text('₹${amount.toStringAsFixed(2)}'),
        ]),
        SizedBox(height:6),
        LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            Container(height: 12, width: constraints.maxWidth, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
            Container(height: 12, width: constraints.maxWidth * percent, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6))),
          ]);
        }),
      ],
    );
  }
}
