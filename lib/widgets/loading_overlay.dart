import 'package:flutter/material.dart';
import '../services/loading_service.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LoadingService().notifier,
      builder: (context, isLoading, child) {
        return Stack(
          children: [
            child!,
            if (isLoading)
              const ModalBarrier(
                color: Colors.black54,
                dismissible: false,
              ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
      child: child,
    );
  }
}