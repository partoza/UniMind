import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimind/views/home/home_page.dart';

class MatchedPage extends StatefulWidget {
  final String? currentUserAvatar;
  final String? currentUserDepartment;
  final String? currentUserName;
  final String? partnerAvatar;
  final String? partnerDepartment;
  final String? partnerName;
  final VoidCallback? onGoToChat;
  
  const MatchedPage({
    super.key,
    this.currentUserAvatar,
    this.currentUserDepartment,
    this.currentUserName,
    this.partnerAvatar,
    this.partnerDepartment,
    this.partnerName,
    this.onGoToChat,
  });

  @override
  State<MatchedPage> createState() => _MatchedPageState();
}

class _MatchedPageState extends State<MatchedPage>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _cardsController;
  late AnimationController _leftCardController;
  late AnimationController _rightCardController;
  late AnimationController _bookController;
  late AnimationController _bottomController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<double> _cardsScaleAnimation;
  late Animation<Offset> _leftCardSlideAnimation;
  late Animation<Offset> _rightCardSlideAnimation;
  late Animation<double> _bookFadeAnimation;
  late Animation<double> _bookScaleAnimation;
  late Animation<double> _bookRotationAnimation;
  late Animation<double> _bottomFadeAnimation;
  late Animation<Offset> _bottomSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _leftCardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rightCardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bookController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bottomController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize animations
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    _titleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    
    _cardsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );
    _cardsScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );
    
    // Left card slides in from the left with more dramatic movement
    _leftCardSlideAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _leftCardController, curve: Curves.elasticOut));
    
    // Right card slides in from the right with more dramatic movement
    _rightCardSlideAnimation = Tween<Offset>(
      begin: const Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _rightCardController, curve: Curves.elasticOut));
    
    _bookFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeOut),
    );
    _bookScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.elasticOut),
    );
    _bookRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeOut),
    );
    
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );
    _bottomSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bottomController, curve: Curves.easeOut));
    
    // Start animations with staggered timing
    _startAnimations();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _titleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsController.forward();
    
    // Start card slide animations with slight delay
    await Future.delayed(const Duration(milliseconds: 100));
    _leftCardController.forward();
    _rightCardController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _bookController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _bottomController.forward();
  }


  @override
  void dispose() {
    _titleController.dispose();
    _cardsController.dispose();
    _leftCardController.dispose();
    _rightCardController.dispose();
    _bookController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button only
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 10 : 20),
            
            // MATCHED title with gradient effect and animation
            AnimatedBuilder(
              animation: _titleController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: ScaleTransition(
                    scale: _titleScaleAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFB71C1C),
                          const Color(0xFFD32F2F),
                          const Color(0xFFB71C1C),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        'MATCHED',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 32 : 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: isSmallScreen ? 20 : 40),
            
            // Study partner cards with circular background and animation
            AnimatedBuilder(
              animation: _cardsController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _cardsFadeAnimation,
                  child: ScaleTransition(
                    scale: _cardsScaleAnimation,
                    child: SizedBox(
                      height: isSmallScreen ? 300 : 360,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular background layers - smaller sizing
                          Positioned(
                            child: Container(
                              width: isSmallScreen ? 240 : 280,
                              height: isSmallScreen ? 240 : 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFB71C1C).withOpacity(0.15),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              width: isSmallScreen ? 200 : 240,
                              height: isSmallScreen ? 200 : 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFB71C1C),
                                    const Color(0xFFD32F2F),
                                    const Color(0xFFB71C1C),
                                  ],
                                  stops: [0.0, 0.7, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB71C1C).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              width: isSmallScreen ? 160 : 200,
                              height: isSmallScreen ? 160 : 200,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ),
                          
                          // Left card (user's card) - slides in from left
                          Positioned(
                            left: isSmallScreen ? 0.5 : 5,
                            top: isSmallScreen ? -5 : 0,
                            child: AnimatedBuilder(
                              animation: _leftCardController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _leftCardSlideAnimation,
                                  child: Transform.rotate(
                                    angle: -0.15,
                                    child: Container(
                                      width: isSmallScreen ? 110 : 140,
                                      height: isSmallScreen ? 180 : 220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // User image
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                image: widget.currentUserAvatar != null && widget.currentUserAvatar!.isNotEmpty
                                                    ? DecorationImage(
                                                        image: widget.currentUserAvatar!.startsWith('http')
                                                            ? NetworkImage(widget.currentUserAvatar!)
                                                            : AssetImage(widget.currentUserAvatar!) as ImageProvider,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                                color: widget.currentUserAvatar == null || widget.currentUserAvatar!.isEmpty
                                                    ? Colors.grey[300]
                                                    : null,
                                              ),
                                              child: widget.currentUserAvatar == null || widget.currentUserAvatar!.isEmpty
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    )
                                                  : null,
                                            ),
                                            // Bookmark badge (matching home page style)
                                            Positioned(
                                              top: 0,
                                              right: 6,
                                              child: BookmarkBadgeWidget(
                                                department: widget.currentUserDepartment ?? 'CCE',
                                                size: Size(
                                                  isSmallScreen ? 28 : 32,
                                                  isSmallScreen ? 42 : 48,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Right card (partner's card) - slides in from right
                          Positioned(
                            right: isSmallScreen ? 0.5 : 5,
                            top: isSmallScreen ? -5 : 0,
                            child: AnimatedBuilder(
                              animation: _rightCardController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _rightCardSlideAnimation,
                                  child: Transform.rotate(
                                    angle: 0.15,
                                    child: Container(
                                      width: isSmallScreen ? 110 : 140,
                                      height: isSmallScreen ? 180 : 220,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Partner image
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                image: widget.partnerAvatar != null && widget.partnerAvatar!.isNotEmpty
                                                    ? DecorationImage(
                                                        image: widget.partnerAvatar!.startsWith('http')
                                                            ? NetworkImage(widget.partnerAvatar!)
                                                            : AssetImage(widget.partnerAvatar!) as ImageProvider,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                                color: widget.partnerAvatar == null || widget.partnerAvatar!.isEmpty
                                                    ? Colors.grey[300]
                                                    : null,
                                              ),
                                              child: widget.partnerAvatar == null || widget.partnerAvatar!.isEmpty
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    )
                                                  : null,
                                            ),
                                            // Bookmark badge (matching home page style)
                                            Positioned(
                                              top: 0,
                                              right: 6,
                                              child: BookmarkBadgeWidget(
                                                department: widget.partnerDepartment ?? 'CAS',
                                                size: Size(
                                                  isSmallScreen ? 28 : 32,
                                                  isSmallScreen ? 42 : 48,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Center book icon - positioned to overlap both cards (on top) with animation
                          Positioned(
                            top: isSmallScreen ? 70 : 75,
                            child: AnimatedBuilder(
                              animation: _bookController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _bookFadeAnimation,
                                  child: ScaleTransition(
                                    scale: _bookScaleAnimation,
                                    child: Transform.rotate(
                                      angle: _bookRotationAnimation.value,
                                      child: Container(
                                        width: isSmallScreen ? 40 : 45,
                                        height: isSmallScreen ? 40 : 45,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB41214), // Maroon fill
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFFB41214).withOpacity(0.4),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Transform.scale(
                                            scale: isSmallScreen ? 0.8 : 0.9,
                                            child: SvgPicture.asset(
                                              'assets/icon/book_icon.svg',
                                              colorFilter: const ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Text label - positioned at bottom of red circle
                          Positioned(
                            bottom: isSmallScreen ? 40 : 50,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              child: Text(
                                'Meet Your Study\nPartner,\nGA !',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Bottom section - more compact with animation
            AnimatedBuilder(
              animation: _bottomController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _bottomFadeAnimation,
                  child: SlideTransition(
                    position: _bottomSlideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Column(
                        children: [
                          Text(
                            'This study partner will help you stay motivated and\nfocused, and you can chat with it now.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF333333),
                              fontSize: isSmallScreen ? 10 : 12,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 44 : 48,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFB71C1C),
                                    const Color(0xFFD32F2F),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB71C1C).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Call the callback to navigate to chat
                                  if (widget.onGoToChat != null) {
                                    widget.onGoToChat!();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Go to chat',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 13 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}