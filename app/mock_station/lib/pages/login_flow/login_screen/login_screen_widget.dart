import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/schema/user_record.dart';
import '/backend/schema/util/firestore_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/componants/referral_prompt/referral_prompt.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

export 'login_screen_model.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  static String routeName = 'login_screen';
  static String routePath = '/loginScreen';

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget>
    with TickerProviderStateMixin {
  late LoginScreenModel _model;
  bool _isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);
    print('DEBUG: Starting Google Sign-In');
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('DEBUG: Google user: $googleUser');
      if (googleUser == null) {
        print('DEBUG: User cancelled Google Sign-In');
        setState(() => _isLoading = false);
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('DEBUG: Google Auth: $googleAuth');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('DEBUG: Firebase credential created, signing in...');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('DEBUG: Firebase sign-in successful: ${userCredential.user}');
      
      final user = userCredential.user;
      if (user != null) {
        // Save user to Firestore 'user' collection
        print('DEBUG: Attempting to save user to Firestore: ${user.uid}');
        try {
          final userMetadata = createUserRecordData(
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            uid: user.uid,
            createdTime: getCurrentTimestamp,
          );
          await UserRecord.collection.doc(user.uid).set(userMetadata);
          print('DEBUG: User saved to Firestore successfully');
        } catch (firestoreError) {
          print('WARNING: Firestore Save Failed (Permissions?): $firestoreError');
          // We continue anyway so the user isn't blocked from the app
        }
      }
      
      // Using Node.js API for Google Sign-In to get valid backend token
      if (user != null) {
        final firebaseToken = await user.getIdToken();
        final deviceId = await actions.getDeviceId();
        
        print('DEBUG: Calling backend Google Sign-In API...');
        final apiResponse = await GoogleSigninCall.call(
          token: firebaseToken ?? '',
          deviceId: deviceId,
        );
        
        if (apiResponse.statusCode == 200 && getJsonField(apiResponse.jsonBody, r'''$.success''') == 1) {
          final backendToken = getJsonField(apiResponse.jsonBody, r'''$.data.token''').toString();
          final userDetails = getJsonField(apiResponse.jsonBody, r'''$.data.userDetails''');
          
          FFAppState().loginToken = backendToken;
          FFAppState().isLogin = true;
          FFAppState().userDetils = userDetails;
          FFAppState().userId = getJsonField(userDetails, r'''$.id''').toString();
          
          print('DEBUG: App State updated with backend JWT token');

          await _maybeShowReferralPrompt();
        } else {
          print('WARNING: Backend Login Failed: ${apiResponse.jsonBody}');
          // Fallback to Firebase token (might fail on some routes but keeps user logged in)
          FFAppState().loginToken = firebaseToken ?? '';
          FFAppState().isLogin = true;
          // Set userDetils from Firebase user as fallback
          if (user != null) {
            FFAppState().userDetils = {
              'id': user.uid,
              'email': user.email,
              'firstname': user.displayName ?? user.email?.split('@').first ?? '',
              'lastname': '',
              'image': user.photoURL ?? '',
              'phone': '',
              'points': '0',
              'is_verified': '1',
              'created_at': '',
              'updated_at': '',
            };
            FFAppState().userId = user.uid;
          }
        }
      }

    
      context.goNamed(HomeScreenWidget.routeName);
      return userCredential;
    } catch (e, stack) {
      print('ERROR during Google Sign-In: $e');
      print('STACKTRACE: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _maybeShowReferralPrompt() async {
    await showReferralPromptOnce(context);
  }

  void _showTestLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isVisible = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
            final screenWidth = MediaQuery.of(context).size.width;

            return AlertDialog(
              backgroundColor: cardColor,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.lock_person_rounded, size: 48, color: Color(0xFF6366F1)),
                            const SizedBox(height: 12),
                            Text(
                              "Account Login",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildDialogTextField(
                            controller: emailController,
                            label: "Email Address",
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildDialogTextField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            isPassword: true,
                            isVisible: isVisible,
                            onToggleVisibility: () {
                              setModalState(() => isVisible = !isVisible);
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF24389C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                              ),
                              onPressed: () => _handleTestLogin(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.white30 : Colors.black26,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _handleTestLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close dialog

    try {
      // 1. Check if this is the approved reviewer account in Firestore
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin_configs')
          .doc('test_credentials')
          .get();

      bool isApproved = false;
      if (adminDoc.exists) {
        final data = adminDoc.data()!;
        if (data['email'] == email) {
          isApproved = true;
        }
      } else {
        // Hardcoded fallback for the very first setup if needed
        if (email == "test@mockstation.com") {
          isApproved = true;
        }
      }

      if (!isApproved) {
        _showMismatchErrorDialog();
        setState(() => _isLoading = false);
        return;
      }

      // 2. Perform Firebase Auth Login
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final firebaseToken = await user.getIdToken();
        final deviceId = await actions.getDeviceId();
        
        // 3. Call same backend API to get JWT and update App State
        final apiResponse = await GoogleSigninCall.call(
          token: firebaseToken ?? '',
          deviceId: deviceId,
        );
        
        if (apiResponse.statusCode == 200 && getJsonField(apiResponse.jsonBody, r'''$.success''') == 1) {
          final backendToken = getJsonField(apiResponse.jsonBody, r'''$.data.token''').toString();
          final userDetails = getJsonField(apiResponse.jsonBody, r'''$.data.userDetails''');
          
          FFAppState().loginToken = backendToken;
          FFAppState().isLogin = true;
          FFAppState().userDetils = userDetails;
          FFAppState().userId = getJsonField(userDetails, r'''$.id''').toString();
          
          context.goNamed(HomeScreenWidget.routeName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backend Login Failed: ${apiResponse.jsonBody}')),
          );
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        _showMismatchErrorDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMismatchErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return FadeIn(
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 42),
                ),
                const SizedBox(height: 18),
                Text(
                  "Account Mismatch",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            content: Text(
              "Your account credentials mismatched. Kindly login through 'Sign in with Google' for a seamless experience.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            actions: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24389C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final statusBarTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0xFFF3F6FF),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF3F6FF),
          body: Builder(
            builder: (context) {
              if (FFAppState().connected != true) {
                return Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Lottie.asset(
                    'assets/jsons/No_Wifi.json',
                    width: 150.0,
                    height: 150.0,
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                );
              }
              return Stack(
                children: [
                  const Positioned.fill(child: ColoredBox(color: Color(0xFFF3F6FF))),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF5A58), width: 1.6),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    left: 18,
                    child: _buildDotGrid(const Color(0xFF1857F2)),
                  ),
                  Positioned(
                    top: statusBarTop + 32,
                    right: 125,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5A58),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const footerHeight = 105.0;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight - footerHeight,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: footerHeight + 4),
                                    child: Center(
                                      child: _buildMainContent(context, constraints.maxWidth, constraints.maxHeight),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _WaveFooter(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double width, double height) {
    final topMargin = (height * 0.10).clamp(40.0, 120.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width < 360 ? 18 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: topMargin),
          _buildBrandHeader(),
          const SizedBox(height: 8),
          _buildHeroIllustration(),
          const SizedBox(height: 4),
          _buildWelcomeText(),
          const SizedBox(height: 28),
          _buildGoogleButton(),
          const SizedBox(height: 28),
          _buildFeatureCard(),
          const SizedBox(height: 28),
          _buildSecureLine(),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Image.asset('assets/images/mock_test_horizontal_logo.png', width: 242, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(
          'Practice. Improve. Succeed.',
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: const Color(0xFF5A6475),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 20, height: 3, decoration: BoxDecoration(color: const Color(0xFFE52520), borderRadius: BorderRadius.circular(99))),
            const SizedBox(width: 6),
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF5A6475), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 20, height: 3, decoration: BoxDecoration(color: const Color(0xFF1848D8), borderRadius: BorderRadius.circular(99))),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroIllustration() {
    return SizedBox(
      height: 214,
      child: Center(
        child: Image.asset(
          'assets/images/mock_station_hero.png',
          width: 228,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.roboto(
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B1F2A),
        ),
        children: const [
          TextSpan(text: 'Welcome to '),
          TextSpan(text: 'Mock', style: TextStyle(color: Color(0xFFE52520))),
          TextSpan(text: ' Station', style: TextStyle(color: Color(0xFF1848D8))),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: CircularProgressIndicator(color: Color(0xFF1848D8)),
            )
          : Center(
              child: GestureDetector(
                onTap: () => signInWithGoogle(context),
                child: Container(
                  padding: const EdgeInsets.all(1.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4285F4),
                        Color(0xFFEA4335),
                        Color(0xFFFBBC05),
                        Color(0xFF34A853),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF8EA2EA),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF24306B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF1848D8),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6677FF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(child: _FeatureItem(icon: Icons.assignment_outlined, color: Color(0xFF3E6BFF), title: 'PYQs Based', subtitle: 'Mock Tests', underline: Color(0xFF3E6BFF), compact: true)),
          _FeatureDivider(),
          Expanded(child: _FeatureItem(icon: Icons.article_outlined, color: Color(0xFFFF5A58), title: 'High-quality', subtitle: 'study notes', underline: Color(0xFFFF5A58), compact: true)),
          _FeatureDivider(),
          Expanded(child: _FeatureItem(icon: Icons.newspaper_outlined, color: Color(0xFF31B95D), title: 'Daily', subtitle: 'Current Affairs', underline: Color(0xFF31B95D), compact: true)),
        ],
      ),
    );
  }

  Widget _buildSecureLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: const [
            Icon(
              Icons.shield_outlined,
              size: 26,
              color: Color(0xFF1033A0),
            ),
            Positioned(
              top: 5.5,
              child: Icon(
                Icons.lock_outline_rounded,
                size: 10,
                color: Color(0xFF1033A0),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          'Secure login with your Google account',
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: const Color(0xFF4B5568),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({required VoidCallback onTap, required Color color, required Widget content, List<BoxShadow>? boxShadow}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E7FF)),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(child: content),
      ),
    );
  }

  Widget _buildDotGrid(Color color) {
    const dotCount = 5;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              dotCount,
              (_) => Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return const [
      Positioned(top: 22, left: 54, child: _SparkleMark(size: 10, color: Color(0xFF7CA1FF))),
      Positioned(top: 64, left: 30, child: _SparkleMark(size: 8, color: Color(0xFF7CA1FF))),
      Positioned(top: 68, right: 48, child: _SparkleMark(size: 12, color: Color(0xFF7CA1FF))),
      Positioned(bottom: 40, left: 44, child: _SparkleMark(size: 8, color: Color(0xFF7CA1FF))),
      Positioned(bottom: 44, right: 82, child: _SparkleMark(size: 10, color: Color(0xFF7CA1FF))),
    ];
  }

  Widget _buildBookStack() {
    return SizedBox(
      width: 76,
      height: 66,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF2340C6),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 6,
            child: Container(
              width: 48,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF16319B), width: 1.2),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 2,
            child: Container(
              width: 58,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboard() {
    return Container(
      width: 90,
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF172A8A), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172A8A).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            left: 18,
            right: 18,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF16319B),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: 0,
            child: Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE52520), width: 3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: 28,
            left: 16,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _CheckRow(),
                SizedBox(height: 12),
                _CheckRow(),
                SizedBox(height: 12),
                _CheckRow(),
                SizedBox(height: 12),
                _CheckRow(),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: Transform.rotate(
              angle: 0.04,
              child: const Icon(Icons.check, size: 42, color: Color(0xFF12246C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPencilCup() {
    return SizedBox(
      width: 44,
      height: 76,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 34,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1848D8),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(bottom: 28, left: 7, child: _Pencil(height: 40, color: const Color(0xFFF39C12))),
          Positioned(bottom: 26, left: 17, child: _Pencil(height: 44, color: const Color(0xFF16319B))),
          Positioned(bottom: 27, right: 7, child: _Pencil(height: 41, color: const Color(0xFFE53935))),
        ],
      ),
    );
  }

  Widget _buildPlant() {
    return SizedBox(
      width: 34,
      height: 58,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 22,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 2,
            child: Container(
              width: 10,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF6EA0FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              transform: Matrix4.skewY(-0.24),
            ),
          ),
          Positioned(
            bottom: 26,
            right: 2,
            child: Container(
              width: 10,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF5C8FFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              transform: Matrix4.skewY(0.18),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.underline,
    this.compact = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color underline;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: compact ? 8.8 : 9.5,
              color: const Color(0xFF26324B),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: compact ? 8.8 : 9.5,
              color: const Color(0xFF26324B),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Container(width: 16, height: 2, decoration: BoxDecoration(color: underline, borderRadius: BorderRadius.circular(99))),
        ],
      ),
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFE7ECF8));
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: const BoxDecoration(
            color: Color(0xFF1848D8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFDFE6F8),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pencil extends StatelessWidget {
  const _Pencil({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _SparkleMark extends StatelessWidget {
  const _SparkleMark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.add, size: size, color: color);
  }
}

class _WaveFooter extends StatelessWidget {
  const _WaveFooter();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/footer_wave.png',
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    );
  }
}
