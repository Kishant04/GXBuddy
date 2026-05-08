import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';
import 'gx_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: GXColors.textSoft),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                GXButton(label: 'Try again', onPressed: onRetry, variant: GXButtonVariant.soft),
              ],
            ],
          ),
        ),
      );
}
