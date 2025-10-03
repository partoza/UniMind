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
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB41214).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.scanner,
                      color: const Color(0xFFB41214),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Discover & Connect',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan QR codes to instantly view and connect with profiles',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // QR Scanner Section
            Expanded(
              child: Stack(
                children: [
                  // Background Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            const Color(0xFF1A1A1A),
                            const Color(0xFF0A0A0A),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Animated Background Elements
                  Positioned.fill(
                    child: AnimatedScanningZone(),
                  ),
                  
                  // Main Scanner Container
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB41214).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: QRScannerWithAnimation(
                          onQRDetected: onQRDetected,
                        ),
                      ),
                    ),
                  ),
                  
                  // Scanning Instructions
                  Positioned(
                    bottom: 120,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Position QR code within frame',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
            
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Upload Button with modern design
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB41214),
                          const Color(0xFFD32F2F),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB41214).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onUploadImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.browse_gallery,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Upload from Gallery',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Alternative option
                  Text(
                    'or use your camera to scan QR codes',
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
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
            // Subtle grid pattern
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(
                  opacity: 0.05,
                  animationValue: _controller.value,
                ),
              ),
            ),
            
            // Concentric circles with gradient
            ...List.generate(3, (index) {
              final scale = _scaleAnimation.value * (1.0 - index * 0.2);
              final opacity = _opacityAnimation.value * (1.0 - index * 0.3);
              
              return Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: MediaQuery.of(context).size.width * (0.9 - index * 0.2),
                      height: MediaQuery.of(context).size.width * (0.9 - index * 0.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB41214).withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Scanning beams
            Center(
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 3,
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFB41214).withOpacity(0.8),
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

class GridPainter extends CustomPainter {
  final double opacity;
  final double animationValue;

  GridPainter({required this.opacity, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    const spacing = 40.0;
    
    // Draw grid lines
    for (var i = -size.width; i < size.width; i += spacing) {
      final offset = i + animationValue * spacing;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        paint,
      );
    }
    
    for (var i = -size.height; i < size.height; i += spacing) {
      final offset = i + animationValue * spacing;
      canvas.drawLine(
        Offset(0, offset),
        Offset(size.width, offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QRScannerWithAnimation extends StatefulWidget {
  final VoidCallback onQRDetected;

  const QRScannerWithAnimation({
    Key? key,
    required this.onQRDetected,
  }) : super(key: key);

  @override
  State<QRScannerWithAnimation> createState() => _QRScannerWithAnimationState();
}

class _QRScannerWithAnimationState extends State<QRScannerWithAnimation> 
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  late AnimationController _scanLineController;
  late Animation<Offset> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: const Offset(0, 0.4),
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    cameraController.dispose();
    _scanLineController.dispose();
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
                // Add haptic feedback here if needed
                widget.onQRDetected();
              }
            }
          },
        ),
        
        // Dark overlay with cutout
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        
        // Animated scanning line
        AnimatedBuilder(
          animation: _scanLineAnimation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.125 + 
                  (_scanLineAnimation.value.dy * MediaQuery.of(context).size.width * 0.75),
              left: 20,
              right: 20,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFB41214),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB41214).withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Modern corner design
        _buildCorner(const Alignment(-0.9, -0.9)),
        _buildCorner(const Alignment(0.9, -0.9)),
        _buildCorner(const Alignment(-0.9, 0.9)),
        _buildCorner(const Alignment(0.9, 0.9)),
        
        // Focus area indicator
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75 - 40,
            height: MediaQuery.of(context).size.width * 0.75 - 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            left: BorderSide(
              color: alignment.x < 0 ? const Color(0xFFB41214) : Colors.transparent,
              width: 3,
            ),
            top: BorderSide(
              color: alignment.y < 0 ? const Color(0xFFB41214) : Colors.transparent,
              width: 3,
            ),
            right: BorderSide(
              color: alignment.x > 0 ? const Color(0xFFB41214) : Colors.transparent,
              width: 3,
            ),
            bottom: BorderSide(
              color: alignment.y > 0 ? const Color(0xFFB41214) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}