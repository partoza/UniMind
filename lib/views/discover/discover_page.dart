import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFB41214),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'DISCOVER A GA!',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan a QR code to instantly view and connect with other profiles.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Square QR Scanner in the middle
            Expanded(
              child: Stack(
                children: [
                  // Background Zone Animation
                  Positioned.fill(child: AnimatedScanningZone()),

                  // QR Scanner Container
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: QRScannerWithAnimation(
                          onQRDetected: onQRDetected,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Use your camera to scan QR codes or',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Bottom Section
                  const SizedBox(height: 20),

                  // Upload Button
                  ElevatedButton(
                    onPressed: onUploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB41214),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // keeps row compact
                      children: [
                        const Icon(
                          Icons.photo_library, // gallery icon
                          size: 20,
                        ),
                        const SizedBox(
                          width: 8,
                        ), // spacing between icon and text
                        Text(
                          'Upload Image',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

class AnimatedScanningZone extends StatefulWidget {
  @override
  State<AnimatedScanningZone> createState() => _AnimatedScanningZoneState();
}

class _AnimatedScanningZoneState extends State<AnimatedScanningZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Scale animation for pulsing effect
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Opacity animation for fading effect
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Large background pulsing circle 1
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value * 0.4,
                child: Transform.scale(
                  scale: _scaleAnimation.value * 1.8,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.5,
                    height: MediaQuery.of(context).size.width * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Large background pulsing circle 2
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value * 0.5,
                child: Transform.scale(
                  scale: _scaleAnimation.value * 1.5,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.3,
                    height: MediaQuery.of(context).size.width * 1.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Medium pulsing circle 1
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value * 0.6,
                child: Transform.scale(
                  scale: _scaleAnimation.value * 1.2,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.1,
                    height: MediaQuery.of(context).size.width * 1.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Medium pulsing circle 2
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value * 0.7,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 3.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Small pulsing circle
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value * 0.8,
                child: Transform.scale(
                  scale: _scaleAnimation.value * 0.8,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Rotating scanning line 1
            Center(
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 4,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Rotating scanning line 2 (perpendicular)
            Center(
              child: Transform.rotate(
                angle:
                    _rotationAnimation.value + 1.5708, // 90 degrees in radians
                child: Container(
                  width: 4,
                  height: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Additional diagonal rotating lines
            Center(
              child: Transform.rotate(
                angle: _rotationAnimation.value + 0.7854, // 45 degrees
                child: Container(
                  width: 3,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Transform.rotate(
                angle: _rotationAnimation.value + 2.3562, // 135 degrees
                child: Container(
                  width: 3,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class QRScannerWithAnimation extends StatefulWidget {
  final VoidCallback onQRDetected;

  const QRScannerWithAnimation({Key? key, required this.onQRDetected})
    : super(key: key);

  @override
  State<QRScannerWithAnimation> createState() => _QRScannerWithAnimationState();
}

class _QRScannerWithAnimationState extends State<QRScannerWithAnimation> {
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
        // QR Scanner Camera using mobile_scanner
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

        // Semi-transparent overlay
        Container(color: Colors.black.withOpacity(0.1)),

        // Corner Borders
        Positioned(top: 20, left: 20, child: _buildCorner(true, true)),
        Positioned(top: 20, right: 20, child: _buildCorner(true, false)),
        Positioned(bottom: 20, left: 20, child: _buildCorner(false, true)),
        Positioned(bottom: 20, right: 20, child: _buildCorner(false, false)),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isLeft ? Colors.white : Colors.transparent,
            width: 3,
          ),
          top: BorderSide(
            color: isTop ? Colors.white : Colors.transparent,
            width: 3,
          ),
          right: BorderSide(
            color: !isLeft ? Colors.white : Colors.transparent,
            width: 3,
          ),
          bottom: BorderSide(
            color: !isTop ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
