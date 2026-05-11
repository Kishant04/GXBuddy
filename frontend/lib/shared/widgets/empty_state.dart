import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.emoji = '✨'});
  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: GXColors.textSoft),
            ),
          ],
        ),
      );
}
