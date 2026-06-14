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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white; 
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: bgColor,
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
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF43F5E).withOpacity(0.15),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FadeInDown(
                                  duration: const Duration(milliseconds: 600),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withOpacity(0.2),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 64,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48),
                                FadeInUp(
                                  duration: const Duration(milliseconds: 700),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Welcome to",
                                        style: GoogleFonts.pacifico(
                                          fontSize: 30,
                                          fontWeight: FontWeight.normal,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Mock Station",
                                        style: GoogleFonts.righteous(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF24389C),
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildSocialLogin(isDark, cardColor, textColor),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSocialLogin(bool isDark, Color cardColor, Color textColor) {
    return Column(
      children: [
        const SizedBox(height: 12),
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF6366F1))
              : _buildButton(
                  onTap: () => signInWithGoogle(context),
                  color: cardColor,
                  boxShadow: [
                    const BoxShadow(color: Color.fromRGBO(60, 64, 67, 0.3), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0),
                    const BoxShadow(color: Color.fromRGBO(60, 64, 67, 0.15), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 1),
                  ],
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('https://img.icons8.com/color/48/000000/google-logo.png', width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 32)),
                      const SizedBox(width: 12),
                      Text("Sign in with Google", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _showTestLoginDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                    ),
                  ),
                  child: const Text(
                    "Signin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildLegalText(isDark),
        const SizedBox(height: 18),
        FadeInUp(
          duration: const Duration(milliseconds: 1100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF1CB58F), size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Roboto'),
                    children: [
                      const TextSpan(text: '100% Secure • '),
                      const TextSpan(text: 'Made ', style: TextStyle(color: Color(0xFFFF9933))),
                      TextSpan(text: 'in ', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF000080))),
                      const TextSpan(text: 'India 🇮🇳', style: TextStyle(color: Color(0xFF138808))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLegalText(bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54, height: 1.5),
          children: [
            const TextSpan(text: "By Continuing, You agree to MockStation "),
            TextSpan(
              text: "Terms & Conditions ",
              style: TextStyle(color: const Color(0xFF6366F1), decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
              mouseCursor: SystemMouseCursors.click,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await launchURL("https://mockstation.blogspot.com/2026/05/terms-conditions-of-mockstation.html");
                },
            ),
            const TextSpan(text: "and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(color: const Color(0xFF6366F1), decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
              mouseCursor: SystemMouseCursors.click,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await launchURL("https://mockstation.blogspot.com/2026/05/privacy-policy-for-mockstation.html");
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required VoidCallback onTap, required Color color, required Widget content, List<BoxShadow>? boxShadow}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), boxShadow: boxShadow ?? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Center(child: content),
      ),
    );
  }


}
