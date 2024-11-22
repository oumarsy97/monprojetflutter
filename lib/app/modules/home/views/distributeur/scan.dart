// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class QRCodeScannerPage extends StatefulWidget {
  final Function(String) onScanResult;

  const QRCodeScannerPage({Key? key, required this.onScanResult}) : super(key: key);

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isScanCompleted = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (_isScanCompleted) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanCompleted = true;
        });
        
        // Vibrer pour indiquer le succès
        HapticFeedback.heavyImpact();
        
        // Afficher un overlay de succès avant de fermer
        _showSuccessOverlay().then((_) {
          widget.onScanResult(barcode.rawValue!);
          Get.back();
        });
        
        break;
      }
    }
  }

  Future<void> _showSuccessOverlay() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'QR Code scanné avec succès !',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).timeout(
      const Duration(milliseconds: 800),
      onTimeout: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeDetection,
          ),

          // Overlay sombre avec trou transparent
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),

          // UI Elements
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),
                
                const Spacer(),
                
                // Scanner Frame
                _buildScannerFrame(),
                
                const Spacer(),
                
                // Bottom Instructions
                _buildBottomInstructions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Get.back(),
          ),
          Text(
            'Scanner QR Code',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                    _scannerController.toggleTorch();
                  });
                },
              ),
              IconButton(
                icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _isFrontCamera = !_isFrontCamera;
                    _scannerController.switchCamera();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Column(
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Coins animés
              ...List.generate(4, (index) => _buildCorner(index)),
              
              // Ligne de scan animée
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    top: 10 + (240 * _animationController.value),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(int index) {
    final isTop = index < 2;
    final isLeft = index.isEven;
    
    return Positioned(
      top: isTop ? 0 : null,
      bottom: !isTop ? 0 : null,
      left: isLeft ? 0 : null,
      right: !isLeft ? 0 : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInstructions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Alignez le QR Code',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final double scanAreaSize = 280;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double left = centerX - (scanAreaSize / 2);
    final double top = centerY - (scanAreaSize / 2);

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
      const Radius.circular(20),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(scanRect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}