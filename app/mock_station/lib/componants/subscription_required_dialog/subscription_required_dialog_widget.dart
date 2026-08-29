import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

class SubscriptionRequiredDialogWidget extends StatefulWidget {
  const SubscriptionRequiredDialogWidget({super.key});

  @override
  State<SubscriptionRequiredDialogWidget> createState() =>
      _SubscriptionRequiredDialogWidgetState();
}

class _SubscriptionRequiredDialogWidgetState
    extends State<SubscriptionRequiredDialogWidget> {
  Widget _buildConfettiDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.0),
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top graphic with lock and wider spaced confetti dots
              SizedBox(
                width: 140,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer faint ring 1
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.03),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Outer faint ring 2
                    Container(
                      width: 106,
                      height: 106,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Inner lock circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.35),
                            blurRadius: 16.0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 34.0,
                      ),
                    ),
                    // Confetti dots positioned wider out
                    Positioned(top: 12, left: 16, child: _buildConfettiDot(const Color(0xFF7C3AED), 8)), // purple top-left
                    Positioned(top: 24, right: 12, child: _buildConfettiDot(const Color(0xFF10B981), 7)), // green top-right
                    Positioned(bottom: 16, left: 20, child: _buildConfettiDot(const Color(0xFF3B82F6), 6)), // blue bottom-left
                    Positioned(bottom: 20, right: 18, child: _buildConfettiDot(const Color(0xFFEC4899), 7)), // pink bottom-right
                    Positioned(top: 50, right: 4, child: _buildConfettiDot(const Color(0xFFF59E0B), 8)), // orange right
                    Positioned(top: 8, left: 62, child: _buildConfettiDot(const Color(0xFF06B6D4), 6)), // cyan top
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Title with lock emoji
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🔓',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Subscription Required',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Roboto',
                          color: const Color(0xFF111827),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          useGoogleFonts: false,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Small gradient bar separator
              Container(
                width: 48.0,
                height: 3.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 16.0),

              // Subtitle description with highlighted links
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Roboto',
                        color: const Color(0xFF6B7280),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        lineHeight: 1.4,
                        useGoogleFonts: false,
                      ),
                  children: const [
                    TextSpan(text: 'Upgrade your plan to get access to\n'),
                    TextSpan(
                      text: 'mock tests',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ', '),
                    TextSpan(
                      text: 'ebook',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'notes',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 10.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          context.pushNamed(PlansScreenWidget.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '👑',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'View Plans',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable helper to show the Subscription Required popup as a centered,
/// scalable dialog. Use this from anywhere in the app:
///
///   showSubscriptionDialog(context);
Future<void> showSubscriptionDialog(BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Subscription Required',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: const SubscriptionRequiredDialogWidget(),
        ),
      ),
    ),
  );
}
