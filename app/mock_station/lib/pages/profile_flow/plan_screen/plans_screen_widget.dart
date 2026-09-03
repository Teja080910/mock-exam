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
                    fontSize: FFFont.f18,
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

  static const Map<int, Map<String, dynamic>> _indexThemes = {
    0: {
      'accent': Color(0xFF2563EB),
      'soft': Color(0xFFDBEAFE),
      'icon': Icons.menu_book_rounded,
      'border': Color(0xFF93C5FD),
      'features': ['High Quality Content', 'Easy to Download'],
    },
    1: {
      'accent': Color(0xFF16A34A),
      'soft': Color(0xFFDCFCE7),
      'icon': Icons.sticky_note_2_rounded,
      'border': Color(0xFF86EFAC),
      'features': ['Short & Concise Notes', 'Quick Revision Friendly'],
    },
    2: {
      'accent': Color(0xFFEA580C),
      'soft': Color(0xFFFFEDD5),
      'icon': Icons.assignment_rounded,
      'border': Color(0xFFFDBA74),
      'features': ['Unlimited Mock Tests', 'Instant Results & Analysis'],
    },
    3: {
      'accent': Color(0xFF7C3AED),
      'soft': Color(0xFFF3E8FF),
      'icon': Icons.card_giftcard_rounded,
      'border': Color(0xFFD8B4FE),
      'features': ['Ebooks + Notes + Mock Tests', 'Complete Exam Preparation in One Plan'],
    },
    4: {
      'accent': Color(0xFFDB2777),
      'soft': Color(0xFFFCE7F3),
      'icon': Icons.local_offer_rounded,
      'border': Color(0xFFF9A8D4),
      'features': ['High Quality Content', 'Easy to Download'],
    },
  };

  Map<String, dynamic> _planTheme(String categoryName, String planName, int index) {
    final lower = '$categoryName $planName'.toLowerCase();
    final base = _indexThemes[index % _indexThemes.length]!;
    // Only override the feature text (and default icon per plan type) when a
    // specific plan keyword is detected; colors are always index-based so every
    // card is guaranteed a distinct color.
    if (lower.contains('ebook')) {
      return {
        ...base,
        'features': ['High Quality Content', 'Easy to Download'],
      };
    }
    if (lower.contains('notes')) {
      return {
        ...base,
        'features': ['Short & Concise Notes', 'Quick Revision Friendly'],
      };
    }
    if (lower.contains('mock test')) {
      return {
        ...base,
        'features': ['Unlimited Mock Tests', 'Instant Results & Analysis'],
      };
    }
    return base;
  }

  Widget _buildBenefitChip({
    required Color accent,
    required IconData icon,
    required String text,
    Color? background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: background ?? accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: accent),
          const SizedBox(width: 5.0),
          Text(
            text,
            style: TextStyle(
              color: accent,
              fontSize: FFFont.f11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String price,
    required String planName,
    required String planValidity,
    required String categoryName,
    required String planId,
    required bool isAlreadyActive,
    required VoidCallback onBuyNow,
  }) {
    final theme = _planTheme(categoryName, planName, index);
    final accent = theme['accent'] as Color;
    final soft = theme['soft'] as Color;
    final icon = theme['icon'] as IconData;
    final border = theme['border'] as Color;
    final features = <String>[
      'Full access to $categoryName',
      '$planValidity validity',
      'Plan ID: $planId',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: border.withOpacity(0.7), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Icon, Title/Subtitle/Validity, Price & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54.0,
                  height: 54.0,
                  decoration: BoxDecoration(
                    color: soft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent, size: 26.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: FFFont.f16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        planName,
                        style: TextStyle(
                          fontSize: FFFont.f12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      _buildBenefitChip(
                        accent: accent,
                        icon: Icons.calendar_today_rounded,
                        text: 'Validity: $planValidity',
                        background: soft.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: FFFont.f20,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isAlreadyActive ? accent.withOpacity(0.15) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        isAlreadyActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: FFFont.f11,
                          fontWeight: FontWeight.w700,
                          color: isAlreadyActive ? accent : const Color(0xFF4B5568),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Dotted Separator
            LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => SizedBox(
                      width: 4.0,
                      height: 1.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: border),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
            // Bottom Section: Features and Buy Now button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16.0, color: accent),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: FFFont.f12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(width: 12.0),
                SizedBox(
                  width: 96.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: isAlreadyActive ? null : onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      isAlreadyActive ? 'Active' : 'Buy Now',
                      style: const TextStyle(
                        fontSize: FFFont.f12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 20.0),
          ),
          const SizedBox(height: 6.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: FFFont.f11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FFFont.f9,
              fontWeight: FontWeight.w500,
              color: FlutterFlowTheme.of(context).secondaryText,
              height: 1.1,
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
                    final rawPlans = QuizGroup.getPlanCall
                        .planDetailsList(snapshot.data!.jsonBody);
                    if (rawPlans == null || rawPlans.isEmpty) {
                      return const Center(child: Text('No plans available.'));
                    }
                    final plans = List.from(rawPlans);
                    plans.sort((a, b) {
                      final aPrice = double.tryParse(getJsonField(a, r'''$.price''').toString()) ?? 0.0;
                      final bPrice = double.tryParse(getJsonField(b, r'''$.price''').toString()) ?? 0.0;
                      return aPrice.compareTo(bPrice);
                    });
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
                                index: index,
                                price: price,
                                planName: planName,
                                planValidity: planValidity,
                                categoryName: categoryName,
                                planId: getJsonField(plan, r'''$.planId''').toString(),
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
