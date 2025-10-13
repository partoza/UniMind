
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Duration duration;

  const CustomSnackBar({
    Key? key,
    required this.message,
    required this.backgroundColor,
    this.icon,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF4CAF50), // Green
      icon: Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFFE53E3E), // Red
      icon: Icons.error_outline,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFFF6AD55), // Orange
      icon: Icons.warning_outlined,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF3182CE), // Blue
      icon: Icons.info_outline,
    );
  }

  static void showFollowSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFFB41214), // UniMind Red
      icon: Icons.favorite_outline,
    );
  }

  static void showUnfollowSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF805AD5), // Purple
      icon: Icons.person_remove_outlined,
    );
  }

  static void showPendingRequest(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF4299E1), // Light Blue
      icon: Icons.schedule_outlined,
    );
  }

  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Above bottom nav
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Action snackbar with button
  static void showActionSnackBar(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Color backgroundColor = const Color(0xFF3182CE),
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
