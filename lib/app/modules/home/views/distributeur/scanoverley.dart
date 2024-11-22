import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerOverlay extends StatelessWidget {
  final Function(String) onScanResult;
  final VoidCallback onCancel;

  const ScannerOverlay({required this.onScanResult, required this.onCancel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.first;
            if (barcode.rawValue != null) {
              onScanResult(barcode.rawValue!);
            }
          },
        ),
        Positioned(
          top: 20,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }
}
