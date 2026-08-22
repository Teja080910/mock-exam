import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'profile_screen_model.dart';
export 'profile_screen_model.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  static String routeName = 'profile_screen';
  static String routePath = '/profileScreen';

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late ProfileScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileScreenModel());
    
    // Fetch latest info on load
    if (FFAppState().isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => refreshProfile());
    }
  }

  Future<void> refreshProfile() async {
    // 1. Fetch Plan Status
    final response = await QuizGroup.fetchUserPlanCall.call(
      token: FFAppState().loginToken,
    );
    if (QuizGroup.fetchUserPlanCall.success(response.jsonBody) == true) {
      safeSetState(() {
        FFAppState().planStatus = QuizGroup.fetchUserPlanCall.planStatus(response.jsonBody) ?? 'none';
        FFAppState().subsIsSelectedAll = QuizGroup.fetchUserPlanCall.isSelectedAll(response.jsonBody) ?? false;
        FFAppState().expiresAt = QuizGroup.fetchUserPlanCall.expiresAt(response.jsonBody) ?? '';
        
        List<String> categoryIds = [];
        final categoryGroups = QuizGroup.fetchUserPlanCall.categoryGroupIds(response.jsonBody);
        if (categoryGroups != null) {
          for (var group in categoryGroups) {
            if (group['_id'] != null) {
              categoryIds.add(group['_id'].toString());
            }
          }
        }
        FFAppState().allowedCategoryIds = categoryIds;
      });
    }

    // 2. Fetch User Details
    final userResponse = await QuizGroup.getuserApiCall.call(
      userId: FFAppState().userId,
      token: FFAppState().loginToken,
    );
    if (QuizGroup.getuserApiCall.success(userResponse.jsonBody) == 1) {
      safeSetState(() {
        FFAppState().userDetils = QuizGroup.getuserApiCall.userCred(userResponse.jsonBody);
      });
    }
  }

  String get _displayName {
    if (!FFAppState().isLogin) {
      return 'Guest User';
    }
    final firstName = getJsonField(
          FFAppState().userDetils,
          r'''$.firstname''',
        )?.toString() ??
        '';
    final lastName = getJsonField(
          FFAppState().userDetils,
          r'''$.lastname''',
        )?.toString() ??
        '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : 'Profile';
  }

  Widget _buildAvatar() {
    if (!FFAppState().isLogin) {
      return Image.asset(
        'assets/images/place_holderProfile.png',
        fit: BoxFit.cover,
      );
    }

    return CachedNetworkImage(
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      imageUrl:
          '${FFAppConstants.imageBaseURL}${getJsonField(FFAppState().userDetils, r'''$.image''') ?? ''}',
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) => Image.asset(
        'assets/images/place_holderProfile.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 22.0),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3FF),
      ),
      child: Column(
        children: [
          const SizedBox(height: 2.0),
          const Text(
            'Profile',
            style: TextStyle(
              color: Color(0xFF10213F),
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22.0),
          SizedBox(
            width: double.infinity,
            height: 100.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 36.0,
                  top: 18.0,
                  child: _buildDecorDot(10.0, const Color(0xFFC7DBFF)),
                ),
                Positioned(
                  right: 24.0,
                  top: 0.0,
                  child: _buildDecorDot(44.0, const Color(0xFFD8E6FF)),
                ),
                Positioned(
                  left: 54.0,
                  bottom: 14.0,
                  child: _buildDotGrid(),
                ),
                Container(
                  width: 90.0,
                  height: 90.0,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.18),
                        blurRadius: 18.0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildAvatar()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _displayName,
                  style: const TextStyle(
                    color: Color(0xFF10213F),
                    fontSize: 21.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (FFAppState().planStatus == 'active') ...[
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildDotGrid() {
    return SizedBox(
      width: 42.0,
      height: 28.0,
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: List.generate(
          18,
          (_) => Container(
            width: 3.0,
            height: 3.0,
            decoration: const BoxDecoration(
              color: Color(0xFFC9DAF8),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Container(
            height: 62.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 12.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 23.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF1F2A44),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF64748B),
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: () async => refreshProfile(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildProfileHero(),
          Container(
            color: const Color(0xFFF8FBFF),
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
            child: Column(
              children: [
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    label: 'My profile',
                    color: const Color(0xFF2F80ED),
                    onTap: () {
                      context.pushNamed(
                        MyProfileWidget.routeName,
                        queryParameters: {
                          'fname': serializeParam(
                            FFAppState().userFirstName,
                            ParamType.String,
                          ),
                          'lname': serializeParam(
                            FFAppState().userLastName,
                            ParamType.String,
                          ),
                          'profilePicture': serializeParam(
                            '${FFAppConstants.imageBaseURL}${getJsonField(
                              FFAppState().userDetils,
                              r'''$.image''',
                            ).toString()}',
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                  ),
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.credit_card_rounded,
                    label: 'My Subscription',
                    color: const Color(0xFF20C997),
                    onTap: () {
                      context.pushNamed(MySubscriptionScreenWidget.routeName);
                    },
                  ),
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Subscription Plans',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      context.pushNamed(PlansScreenWidget.routeName);
                    },
                  ),
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.menu_book_outlined,
                    label: 'eBook',
                    color: const Color(0xFF6366F1),
                    onTap: () {},
                  ),
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Notes',
                    color: const Color(0xFF06B6D4),
                    onTap: () {},
                  ),
                if (FFAppState().isLogin == true)
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      context.pushNamed(NotificationScreenWidget.routeName);
                    },
                  ),
                _buildMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    launchURL(
                      'https://mockstation.blogspot.com/2026/05/privacy-policy-for-mockstation.html',
                    );
                  },
                ),
                _buildMenuTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Help & Support',
                  color: const Color(0xFF14B8A6),
                  onTap: () {
                    context.pushNamed(HelplineCenterScreenWidget.routeName);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Refer and Earn',
                  color: const Color(0xFFE11D48),
                  onTap: () {
                    context.pushNamed(ReferAndEarnScreenWidget.routeName);
                  },
                ),
                  _buildMenuTile(
                    icon: Icons.share_outlined,
                    label: 'Share App',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Share.share(
                        'Check out Mock Station app for your preparation! Download here: https://play.google.com/store/apps/details?id=com.mock.exam.app',
                        subject: 'Mock Station App',
                      );
                    },
                  ),
                _buildMenuTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  color: const Color(0xFF2F80ED),
                  onTap: () {
                    context.pushNamed(SettingPageWidget.routeName);
                  },
                ),
                if (FFAppState().isLogin == false)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(LoginScreenWidget.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Login/Register',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8FBFF),
        body: Builder(
          builder: (context) {
            if (FFAppState().connected == true) {
              return _buildProfileContent();
            }

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
          },
        ),
      ),
    );
  }
}
