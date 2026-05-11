import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'Loading…'});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: GXColors.violet,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(message,
                style: const TextStyle(fontSize: 13, color: GXColors.textSoft)),
          ],
        ),
      );
}
