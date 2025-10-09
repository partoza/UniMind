import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class DiscoverPage extends StatelessWidget {
  final VoidCallback onQRDetected;
  final VoidCallback onUploadImage;

  const DiscoverPage({
    Key? key,
    required this.onQRDetected,
    required this.onUploadImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB41214), Color(0xFF8B0000), Color(0xFF5D0000)],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animation centered around QR scanner area
            Positioned.fill(
              child: IgnorePointer(child: ModernScanningAnimation()),
            ),

            // Main UI content on top
            SafeArea(
              child: Column(
                children: [
                  // Enhanced Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      children: [
                        // App branding
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DISCOVER',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 28 * textScale,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    'Connect with students instantly',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Point your camera at a QR code to view profiles and connect with other students',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Modern QR Scanner Section
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AspectRatio(
                          aspectRatio: 1.0, // Force square aspect ratio
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                              maxHeight:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 0,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: ModernQRScanner(
                                onQRDetected: onQRDetected,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Info text
                        Text(
                          'or upload a QR code image',
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Modern Upload Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onUploadImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB41214),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Upload from Gallery',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFB41214),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern scanning animation with subtle effects
class ModernScanningAnimation extends StatefulWidget {
  @override
  State<ModernScanningAnimation> createState() =>
      _ModernScanningAnimationState();
}

class _ModernScanningAnimationState extends State<ModernScanningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Slightly slower
      vsync: this,
    )..repeat(reverse: true);

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 6000), // Slower rotation
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate QR scanner position and size
    final scannerSize = screenWidth * 0.75;
    final scannerCenterX = screenWidth * 0.5;
    final scannerCenterY = screenHeight * 0.45; // Moved higher from 0.5 to 0.45

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Reduced pulsing rings for better performance
              ...List.generate(2, (ringIndex) {
                // Reduced from 3 to 2
                final ringSize = scannerSize * (1.0 + ringIndex * 0.5);
                final opacity =
                    _opacityAnimation.value * (0.5 - ringIndex * 0.15);

                return Positioned(
                  left: scannerCenterX - ringSize / 2,
                  top: scannerCenterY - ringSize / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: _pulseAnimation.value * (1.0 + ringIndex * 0.1),
                      child: Container(
                        width: ringSize,
                        height: ringSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0 + ringIndex, // Reduced width
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Optimized scanning beams
              Positioned(
                left: scannerCenterX - scannerSize * 0.75,
                top: scannerCenterY - scannerSize * 0.75,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    size: Size(scannerSize * 1.5, scannerSize * 1.5),
                    painter: ScanningBeamPainter(
                      progress: _rotationController.value,
                      opacity: _opacityAnimation.value * 0.6, // Reduced opacity
                    ),
                  ),
                ),
              ),

              // Reduced orbiting particles for performance
              ...List.generate(6, (index) {
                // Reduced from 8 to 6
                final angle =
                    (index * 60.0) * (math.pi / 180); // Adjusted spacing
                final radius = scannerSize * 0.55;
                final x =
                    scannerCenterX +
                    radius * math.cos(angle + _rotationAnimation.value * 0.3);
                final y =
                    scannerCenterY +
                    radius * math.sin(angle + _rotationAnimation.value * 0.3);

                return Positioned(
                  left: x - 5,
                  top: y - 5,
                  child: Opacity(
                    opacity: _opacityAnimation.value * 0.7,
                    child: Container(
                      width: 10, // Slightly smaller
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Reduced floating particles
              ...List.generate(8, (index) {
                // Reduced from 12 to 8
                final random = math.Random(index);
                final baseX =
                    scannerCenterX +
                    (random.nextDouble() - 0.5) * scannerSize * 1.2;
                final baseY =
                    scannerCenterY +
                    (random.nextDouble() - 0.5) * scannerSize * 1.2;
                final animationOffset =
                    _rotationAnimation.value *
                    (random.nextDouble() - 0.5) *
                    1.5;

                return Positioned(
                  left: baseX + animationOffset * 30 - 2, // Reduced movement
                  top:
                      baseY +
                      math.sin(_pulseController.value * 2 * math.pi + index) *
                          15 -
                      2,
                  child: Opacity(
                    opacity: _opacityAnimation.value * 0.4,
                    child: Container(
                      width: 4, // Smaller particles
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),

              // Simplified central pulsing effect
              Positioned(
                left: scannerCenterX - scannerSize * 0.7,
                top: scannerCenterY - scannerSize * 0.7,
                child: Opacity(
                  opacity: _opacityAnimation.value * 0.3,
                  child: Transform.scale(
                    scale: _pulseAnimation.value * 1.3, // Reduced scale
                    child: Container(
                      width: scannerSize * 1.4,
                      height: scannerSize * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for scanning beam effects
class ScanningBeamPainter extends CustomPainter {
  final double progress;
  final double opacity;

  ScanningBeamPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Reduced stroke width

    // Reduced number of scanning beams for performance
    for (int i = 0; i < 4; i++) {
      // Reduced from 6 to 4
      final angle = (i * 90 + progress * 360) * (3.14159 / 180);
      final startAngle = angle - 0.3;
      final sweepAngle = 0.6;

      paint.shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          Colors.white.withOpacity(opacity * 0.2),
          Colors.white.withOpacity(opacity * 0.5),
          Colors.white.withOpacity(opacity * 0.7),
          Colors.white.withOpacity(opacity * 0.5),
          Colors.white.withOpacity(opacity * 0.2),
          Colors.transparent,
        ],
        [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
        TileMode.clamp,
        startAngle,
        startAngle + sweepAngle,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.4),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Simplified outer scanning rings
    for (int ring = 1; ring <= 2; ring++) {
      // Reduced from 3 to 2
      final ringRadius = radius * (0.2 + ring * 0.2);
      final ringAngle =
          (progress * 120 + ring * 45) * (3.14159 / 180); // Slower rotation

      paint.shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          Colors.white.withOpacity(opacity * 0.3),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
        TileMode.clamp,
        ringAngle - 0.4,
        ringAngle + 0.4,
      );

      canvas.drawCircle(center, ringRadius, paint..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(ScanningBeamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

/// Modern QR Scanner with clean design
class ModernQRScanner extends StatefulWidget {
  final VoidCallback onQRDetected;

  const ModernQRScanner({Key? key, required this.onQRDetected})
    : super(key: key);

  @override
  State<ModernQRScanner> createState() => _ModernQRScannerState();
}

class _ModernQRScannerState extends State<ModernQRScanner> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // QR Scanner Camera
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                widget.onQRDetected();
              }
            }
          },
        ),

        // Modern corner indicators
        Positioned(top: 24, left: 24, child: _buildModernCorner(true, true)),
        Positioned(top: 24, right: 24, child: _buildModernCorner(true, false)),
        Positioned(
          bottom: 24,
          left: 24,
          child: _buildModernCorner(false, true),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: _buildModernCorner(false, false),
        ),

        // Center target indicator
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernCorner(bool isTop, bool isLeft) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isLeft ? Colors.white : Colors.transparent,
            width: 4,
          ),
          top: BorderSide(
            color: isTop ? Colors.white : Colors.transparent,
            width: 4,
          ),
          right: BorderSide(
            color: !isLeft ? Colors.white : Colors.transparent,
            width: 4,
          ),
          bottom: BorderSide(
            color: !isTop ? Colors.white : Colors.transparent,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft
              ? const Radius.circular(8)
              : Radius.zero,
        ),
      ),
    );
  }
}
