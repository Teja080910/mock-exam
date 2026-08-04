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
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 12.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.safePop(),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 30.0,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Subscription Plans',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 30.0),
                ],
              ),
              const SizedBox(height: 6.0),
              Text(
                'Choose a plan that best suits your preparation',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFF2563EB),
            size: 18.0,
          ),
        ),
        const SizedBox(width: 12.0),
        const Expanded(
          child: Text(
            'Available Subscription Plans',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF8B5CF6),
          size: 18.0,
        ),
      ],
    );
  }

  Map<String, dynamic> _planTheme(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('ssc')) {
      return {
        'accent': const Color(0xFF22C55E),
        'soft': const Color(0xFFEFFBF2),
        'icon': Icons.school_rounded,
      };
    }
    if (lower.contains('full access')) {
      return {
        'accent': const Color(0xFF7C3AED),
        'soft': const Color(0xFFF5F0FF),
        'icon': Icons.workspace_premium_rounded,
      };
    }
    if (lower.contains('psu')) {
      return {
        'accent': const Color(0xFFF59E0B),
        'soft': const Color(0xFFFFF5E8),
        'icon': Icons.menu_book_rounded,
      };
    }
    return {
      'accent': const Color(0xFF2563EB),
      'soft': const Color(0xFFEFF6FF),
      'icon': Icons.train_rounded,
    };
  }

  Widget _buildBenefitChip({
    required Color accent,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.0, color: accent),
          const SizedBox(width: 6.0),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
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
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 18.0),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 12.0),
                  Expanded(
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
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: plans.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12.0),
                                itemBuilder: (context, index) {
                                  final plan = plans[index];
                                  final planId =
                                      getJsonField(plan, r'''$._id''').toString();
                                  final price =
                                      getJsonField(plan, r'''$.price''')
                                          .toString();
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

                                  final theme = _planTheme(categoryName);
                                  final accent = theme['accent'] as Color;
                                  final soft = theme['soft'] as Color;
                                  final icon = theme['icon'] as IconData;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: accent.withOpacity(0.30),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x0D0F172A),
                                          blurRadius: 10.0,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 56.0,
                                            height: 56.0,
                                            decoration: BoxDecoration(
                                              color: soft,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              icon,
                                              color: accent,
                                              size: 28.0,
                                            ),
                                          ),
                                          const SizedBox(width: 14.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            categoryName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Color(
                                                                  0xFF111827),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 2.0),
                                                          Text(
                                                            planName,
                                                            style: TextStyle(
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: accent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      '₹$price',
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: accent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10.0),
                                                Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 8.0,
                                                  children: [
                                                    _buildBenefitChip(
                                                      accent: accent,
                                                      icon: Icons
                                                          .calendar_today_rounded,
                                                      text:
                                                          'Validity: $planValidity',
                                                    ),
                                                    _buildBenefitChip(
                                                      accent: accent,
                                                      icon:
                                                          Icons.all_inclusive,
                                                      text:
                                                          'Unlimited PYQs Mock Test',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 28.0),
                                            child: SizedBox(
                                              width: 80.0,
                                              height: 38.0,
                                              child: ElevatedButton(
                                                onPressed: isAlreadyActive
                                                    ? null
                                                    : () async {
                                                        await _startPurchase(
                                                          planId: planId,
                                                          price: price,
                                                          categoryName:
                                                              categoryName,
                                                        );
                                                      },
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      isAlreadyActive
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate
                                                          : const Color(
                                                              0xFF6CB6FF),
                                                  foregroundColor: Colors.white,
                                                  disabledForegroundColor:
                                                      Colors.white70,
                                                  disabledBackgroundColor:
                                                      const Color(0xFFD1D5DB),
                                                  padding: EdgeInsets.zero,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  isAlreadyActive
                                                      ? 'Active'
                                                      : 'Buy Now',
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFF),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: const Color(0xFFE5ECF7),
                                ),
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
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
