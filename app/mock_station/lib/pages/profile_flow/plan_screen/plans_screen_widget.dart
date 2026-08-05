import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/componants/payment_success_componant/payment_success_componant_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'plans_screen_model.dart';
export 'plans_screen_model.dart';

class PlansScreenWidget extends StatefulWidget {
  const PlansScreenWidget({super.key});

  static String routeName = 'PlansScreen';
  static String routePath = '/plansScreen';

  @override
  State<PlansScreenWidget> createState() => _PlansScreenWidgetState();
}

class _PlansScreenWidgetState extends State<PlansScreenWidget> {
  late PlansScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Razorpay _razorpay;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlansScreenModel());
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');
    final orderId = response.orderId ?? _currentOrderId;
    final paymentId = response.paymentId;
    final signature = response.signature;

    if (orderId != null && paymentId != null && signature != null) {
      // 3. Verify Payment on Success
      final verifyRes = await QuizGroup.verifyPaymentCall.call(
        token: FFAppState().loginToken,
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      );
      
      print('=== VERIFY RESPONSE: ${verifyRes.jsonBody} ===');
      final vSuccess = getJsonField(verifyRes.jsonBody, r'''$.success''') ?? getJsonField(verifyRes.jsonBody, r'''$.data.success''');

      if (vSuccess == true || vSuccess == 1) {
        await refreshProfile();
        if (mounted) {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) {
              return Dialog(
                elevation: 0,
                insetPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                alignment: AlignmentDirectional(0.0, 0.0),
                child: PaymentSuccessComponantWidget(
                  title: 'Subscription Successful!',
                  message: 'Your plan has been activated successfully. You can now access your mock tests.',
                  onTapHome: () async {
                    Navigator.pop(dialogContext);
                    context.goNamed(HomeScreenWidget.routeName);
                  },
                ),
              );
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment verification failed. Please contact support.')),
          );
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final msg = response.message;
    final reason = (msg != null && msg.isNotEmpty && msg != 'undefined') ? msg : 'Payment was cancelled';
    print('Payment Error: ${response.code} - $reason');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: $reason')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  @override
  void dispose() {
    _model.dispose();
    _razorpay.clear(); // Clear Razorpay instance
    super.dispose();
  }

  Future<void> refreshProfile() async {
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
  }

  Future<void> _startPurchase({
    required String planId,
    required String price,
    required String categoryName,
  }) async {
    final buyResponse = await QuizGroup.buyPlanCall.call(
      token: FFAppState().loginToken,
      planId: planId,
      userId: FFAppState().userId,
      price: (int.tryParse(price) ?? 0) * 100,
      points: 0,
    );
    print('=== BUY RESPONSE: ${buyResponse.jsonBody} ===');
    final sVal = getJsonField(buyResponse.jsonBody, r'''$.success''') ??
        getJsonField(buyResponse.jsonBody, r'''$.data.success''');
    if (sVal == 1 || sVal == true) {
      final String? orderId =
          getJsonField(buyResponse.jsonBody, r'''$.orderId''')?.toString() ??
              getJsonField(buyResponse.jsonBody, r'''$.data.orderId''')
                  ?.toString();

      final int? orderAmountPaise = castToType<int>(
            getJsonField(buyResponse.jsonBody, r'''$.amountInPaise'''),
          ) ??
          castToType<int>(
            getJsonField(buyResponse.jsonBody, r'''$.data.amountInPaise'''),
          );
      final int? orderAmountINR = castToType<int>(
            getJsonField(buyResponse.jsonBody, r'''$.amount'''),
          ) ??
          castToType<int>(
            getJsonField(buyResponse.jsonBody, r'''$.data.amount'''),
          );

      print(
        '=== ORDER DATA -> ID: $orderId, PAISE: $orderAmountPaise, INR: $orderAmountINR ===',
      );

      _currentOrderId = orderId;

      var options = {
        'key': FFAppConstants.razorpayKeyID,
        'amount':
            orderAmountPaise ?? ((double.tryParse(price) ?? 0) * 100).round(),
        'name': 'Mock Station',
        'description': categoryName,
        'order_id': orderId,
        'prefill': {
          'contact':
              getJsonField(FFAppState().userDetils, r'''$.phone''')
                      ?.toString() ??
                  getJsonField(FFAppState().userDetils, r'''$.mobileno''')
                      ?.toString() ??
                  '',
          'email':
              getJsonField(FFAppState().userDetils, r'''$.email''')
                      ?.toString() ??
                  '',
        },
        'theme': {
          'color': '#60A5FA',
        },
        'currency': 'INR',
      };

      print('=== RAZORPAY OPTIONS: $options ===');

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error opening Razorpay: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to initiate purchase. Please try again.'),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.75)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.safePop(),
                borderRadius: BorderRadius.circular(999.0),
                child: Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF93C5FD).withOpacity(0.15),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.0,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              const Expanded(
                child: Text(
                  'Subscription Plans',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 38.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const SizedBox.shrink();
  }

  Map<String, dynamic> _planTheme(String categoryName, String planName) {
    final lower = '$categoryName $planName'.toLowerCase();
    if (lower.contains('full access')) {
      return {
        'accent': const Color(0xFF7C3AED),
        'soft': const Color(0xFFE8D8FF),
        'iconBg': const Color(0xFFD8C8FF),
        'icon': Icons.workspace_premium_rounded,
        'subtitleColor': const Color(0xFF7C3AED),
        'border': const Color(0xFFB7A8E8),
        'popular': true,
      };
    }
    if (lower.contains('ssc')) {
      return {
        'accent': const Color(0xFF16A34A),
        'soft': const Color(0xFFD7F7E2),
        'iconBg': const Color(0xFFC9F0D3),
        'icon': Icons.school_rounded,
        'subtitleColor': const Color(0xFF16A34A),
        'border': const Color(0xFF8AD0A4),
        'popular': false,
      };
    }
    if (lower.contains('psu')) {
      return {
        'accent': const Color(0xFFD97706),
        'soft': const Color(0xFFFCE1B0),
        'iconBg': const Color(0xFFF7D89A),
        'icon': Icons.menu_book_rounded,
        'subtitleColor': const Color(0xFFD97706),
        'border': const Color(0xFFE2BC6D),
        'popular': false,
      };
    }
    return {
      'accent': const Color(0xFFDB2777),
      'soft': const Color(0xFFF6D1F2),
      'iconBg': const Color(0xFFF4C8F0),
      'icon': Icons.directions_railway_rounded,
      'subtitleColor': const Color(0xFF7C3AED),
      'border': const Color(0xFFE6A8DE),
      'popular': false,
    };
  }

  Widget _buildBenefitChip({
    required Color accent,
    required IconData icon,
    required String text,
    Color? background,
    required double fontSize,
    required double iconSize,
    required EdgeInsets padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: accent),
          const SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem({
    required Color accent,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 24.0),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String price,
    required String planName,
    required String planValidity,
    required String categoryName,
    required bool isAlreadyActive,
    required VoidCallback onBuyNow,
  }) {
    final theme = _planTheme(categoryName, planName);
    final accent = theme['accent'] as Color;
    final soft = theme['soft'] as Color;
    final iconBg = theme['iconBg'] as Color;
    final icon = theme['icon'] as IconData;
    final subtitleColor = theme['subtitleColor'] as Color;
    final border = theme['border'] as Color;
    final popular = theme['popular'] as bool;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 360.0;
        final titleSize = compact ? 15.0 : 17.0;
        final subtitleSize = compact ? 11.0 : 12.0;
        final priceSize = compact ? 24.0 : 28.0;
        final buttonFontSize = compact ? 14.0 : 15.0;
        final chipFontSize = compact ? 12.0 : 14.0;
        final chipIconSize = compact ? 14.0 : 16.0;
        final chipPadding = compact
            ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0)
            : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 14.0),
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: border, width: 1.6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 18.0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (popular)
                Positioned(
                  top: -28.0,
                  right: 18.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 7.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD43B),
                      borderRadius: BorderRadius.circular(999.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22F59E0B),
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 72.0 : 78.0,
                    height: compact ? 72.0 : 78.0,
                    decoration: BoxDecoration(
                      color: soft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: accent, size: compact ? 30.0 : 32.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      height: 1.0,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    planName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: subtitleSize,
                                      fontWeight: FontWeight.w500,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topRight,
                              child: Text(
                                '₹$price',
                                style: TextStyle(
                                  fontSize: priceSize,
                                  height: 1.0,
                                  fontWeight: FontWeight.w900,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: [
                            _buildBenefitChip(
                              accent: accent,
                              icon: Icons.calendar_month_rounded,
                              text: 'Validity: $planValidity',
                              background: iconBg,
                              fontSize: chipFontSize,
                              iconSize: chipIconSize,
                              padding: chipPadding,
                            ),
                            _buildBenefitChip(
                              accent: accent,
                              icon: Icons.all_inclusive_rounded,
                              text: 'Unlimited PYQs Mock Test',
                              background: iconBg,
                              fontSize: chipFontSize,
                              iconSize: chipIconSize,
                              padding: chipPadding,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: compact ? 118.0 : 124.0,
                            height: compact ? 42.0 : 46.0,
                            child: ElevatedButton(
                              onPressed: isAlreadyActive ? null : onBuyNow,
                              style: ElevatedButton.styleFrom(
                                elevation: 8,
                                shadowColor: const Color(0x3360A5FA),
                                backgroundColor: const Color(0xFF2D6BDE),
                                disabledBackgroundColor: const Color(0xFFD1D5DB),
                                disabledForegroundColor: Colors.white70,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: Text(
                                isAlreadyActive ? 'Active' : 'Buy Now',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 0.0),
                child: FutureBuilder<ApiCallResponse>(
                  future: QuizGroup.getPlanCall.call(
                    token: FFAppState().loginToken,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      );
                    }
                    final plans = QuizGroup.getPlanCall
                        .planDetailsList(snapshot.data!.jsonBody);
                    if (plans == null || plans.isEmpty) {
                      return const Center(child: Text('No plans available.'));
                    }
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (var index = 0; index < plans.length; index++)
                          Builder(
                            builder: (context) {
                              final plan = plans[index];
                              final price =
                                  getJsonField(plan, r'''$.price''').toString();
                              final planName =
                                  getJsonField(plan, r'''$.planName''')
                                          ?.toString() ??
                                      'Standard Plan';
                              final planValidity =
                                  getJsonField(plan, r'''$.planValidity''')
                                          ?.toString() ??
                                      '1 year';
                              final categoryName = getJsonField(
                                    plan,
                                    r'''$.categoryGroup.displayName''',
                                  )?.toString() ??
                                  'Full Access (All Categories)';
                              final categoryGroupId = getJsonField(
                                plan,
                                r'''$.categoryGroup._id''',
                              )?.toString();

                              bool isAlreadyActive = false;
                              if (FFAppState().planStatus == 'active') {
                                if (FFAppState().subsIsSelectedAll) {
                                  isAlreadyActive = true;
                                } else if (categoryGroupId != null &&
                                    FFAppState()
                                        .allowedCategoryIds
                                        .contains(categoryGroupId)) {
                                  isAlreadyActive = true;
                                }
                              }

                              return _buildPlanCard(
                                price: price,
                                planName: planName,
                                planValidity: planValidity,
                                categoryName: categoryName,
                                isAlreadyActive: isAlreadyActive,
                                onBuyNow: () async {
                                  await _startPurchase(
                                    planId:
                                        getJsonField(plan, r'''$._id''').toString(),
                                    price: price,
                                    categoryName: categoryName,
                                  );
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 6.0),
                        Container(
                          padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              _buildTrustItem(
                                accent: const Color(0xFF2563EB),
                                icon: Icons.shield_outlined,
                                title: 'Secure Payment',
                                subtitle: '100% Safe & Secure',
                              ),
                              const SizedBox(width: 8.0),
                              _buildTrustItem(
                                accent: const Color(0xFF22C55E),
                                icon: Icons.autorenew_rounded,
                                title: 'Instant Access',
                                subtitle: 'Start immediately',
                              ),
                              const SizedBox(width: 8.0),
                              _buildTrustItem(
                                accent: const Color(0xFF8B5CF6),
                                icon: Icons.support_agent_rounded,
                                title: '24/7 Support',
                                subtitle: 'We\'re here to help',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18.0),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
