import 'package:flutter/material.dart';
import '../../../models/bill_model.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../shared/widgets/gx_card.dart';

class UpcomingBillCard extends StatelessWidget {
  const UpcomingBillCard({super.key, required this.bill});

  final BillModel bill;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                  child: Text(bill.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bill.name}  RM${bill.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: GXColors.textWhite,
                    ),
                  ),
                  Text(
                    bill.daysRemaining <= 0
                        ? 'Due today · auto-paid from main'
                        : 'Due in ${bill.daysRemaining} day${bill.daysRemaining == 1 ? '' : 's'} · auto-paid from main',
                    style: const TextStyle(
                        fontSize: 11.5, color: GXColors.textSoft),
                  ),
                ],
              ),
            ),
            Text(
              bill.dueDateLabel,
              style: const TextStyle(fontSize: 11, color: GXColors.textMute),
            ),
          ],
        ),
      );
}
