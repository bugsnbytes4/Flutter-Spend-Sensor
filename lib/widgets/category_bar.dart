// lib/widgets/category_bar.dart
import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double percent;
  const CategoryBar({required this.category, required this.amount, required this.percent, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const barColor = Colors.indigo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(category)),
          Text('₹${amount.toStringAsFixed(2)}'),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final clamped = percent.clamp(0.0, 1.0);
          return Stack(children: [
            Container(
              height: 12,
              width: constraints.maxWidth,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)),
            ),
            Container(
              height: 12,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6)),
            ),
          ]);
        }),
      ],
    );
  }
}

