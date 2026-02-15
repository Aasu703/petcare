import 'package:flutter/material.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final display = _friendlyMessage(message);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              display,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('is not a subtype') ||
        lower.contains("_map") ||
        lower.contains('type') && lower.contains('subtype')) {
      return 'Unexpected response from server. Please try again.';
    }
    if (lower.contains('socketexception') ||
        lower.contains('network') ||
        lower.contains('connection')) {
      return 'Network error. Check your internet connection and try again.';
    }
    // Default: show original message (trim if excessively long)
    if (raw.length > 200) return '${raw.substring(0, 180)}...';
    return raw;
  }
}
