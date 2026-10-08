import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/componants/payment_success_componant/payment_success_componant_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  // plan _id -> discount percent from the newest active admin offer
  Map<String, int> _offerDiscounts = {};
  String? _selectedPlanId;
  String? _selectedPlanPrice;
  String? _selectedPlanCategory;
  String? _selectedPlanName;
  String? _selectedPlanDisplayPrice;
  bool _selectedPlanUnavailable = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlansScreenModel());

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Fetch latest user plan on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshProfile());
    _loadOfferDiscounts();
  }

  Future<void> _loadOfferDiscounts() async {
    try {
      final res = await QuizGroup.getIntroAPICall.call();
      if (QuizGroup.getIntroAPICall.success(res.jsonBody) != 1) return;
      final intros = QuizGroup.getIntroAPICall
          .introDetailsList(res.jsonBody)
          ?.whereType<Map>()
          .toList();
      if (intros == null || intros.isEmpty) return;

      // The newest active offer governs the plan discounts.
      intros.sort((a, b) {
        final aTime = DateTime.tryParse(
                getJsonField(a, r'''$.updatedAt''').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(
                getJsonField(b, r'''$.updatedAt''').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      final discounts =
          (getJsonField(intros.first, r'''$.discounts''') as List?) ?? [];
      final map = <String, int>{};
      for (final d in discounts) {
        final pid = getJsonField(d, r'''$.planId''').toString();
        final pct =
            int.tryParse(getJsonField(d, r'''$.discountPercent''').toString()) ?? 0;
        if (pid.isNotEmpty && pct > 0) map[pid] = pct;
      }
      if (mounted) setState(() => _offerDiscounts = map);
    } catch (_) {}
  }

  Future<void> _showPlanSuccessDialog() async {
    await refreshProfile();
    if (!mounted) return;
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
            message:
                'Your plan has been activated successfully. You can now access your mock tests.',
            onTapHome: () async {
              Navigator.pop(dialogContext);
              context.goNamed(HomeScreenWidget.routeName);
            },
          ),
        );
      },
    );
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
      final vSuccess = getJsonField(verifyRes.jsonBody, r'''$.success''') ??
          getJsonField(verifyRes.jsonBody, r'''$.data.success''');

      if (vSuccess == true || vSuccess == 1) {
        await _showPlanSuccessDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Payment verification failed. Please contact support.')),
          );
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final msg = response.message;
    final reason = (msg != null && msg.isNotEmpty && msg != 'undefined')
        ? msg
        : 'Payment was cancelled';
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
        FFAppState().planStatus =
            QuizGroup.fetchUserPlanCall.planStatus(response.jsonBody) ?? 'none';
        FFAppState().subsIsSelectedAll =
            QuizGroup.fetchUserPlanCall.isSelectedAll(response.jsonBody) ??
                false;
        FFAppState().expiresAt =
            QuizGroup.fetchUserPlanCall.expiresAt(response.jsonBody) ?? '';
        FFAppState().activePlanName =
            QuizGroup.fetchUserPlanCall.planName(response.jsonBody) ?? '';
        FFAppState().activePlanCode =
            QuizGroup.fetchUserPlanCall.planCode(response.jsonBody) ?? '';
        FFAppState().hasEbookAccess =
            QuizGroup.fetchUserPlanCall.hasEbookAccess(response.jsonBody) ??
                false;
        FFAppState().hasNotesAccess =
            QuizGroup.fetchUserPlanCall.hasNotesAccess(response.jsonBody) ??
                false;
        FFAppState().hasMockTestAccess =
            QuizGroup.fetchUserPlanCall.hasMockTestAccess(response.jsonBody) ??
                false;

        final rawCodes =
            QuizGroup.fetchUserPlanCall.activePlanCodes(response.jsonBody);
        if (rawCodes is List) {
          FFAppState().activePlanCodes =
              rawCodes.map((c) => c.toString().toUpperCase()).toList();
        } else {
          FFAppState().activePlanCodes = [];
        }

        List<String> categoryIds = [];
        final categoryGroups =
            QuizGroup.fetchUserPlanCall.categoryGroupIds(response.jsonBody);
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

      // Wallet covered the full amount - the backend already activated the
      // plan, no Razorpay checkout needed.
      final paidWithWallet =
          QuizGroup.buyPlanCall.paidWithWallet(buyResponse.jsonBody) ?? false;
      if (paidWithWallet) {
        print('=== Paid fully with cashback wallet ===');
        await _showPlanSuccessDialog();
        return;
      }

      _currentOrderId = orderId;

      // Prefer the publishable key returned by the backend so the checkout
      // key always matches the key the order was created with (test vs live).
      final serverKey = QuizGroup.buyPlanCall.key(buyResponse.jsonBody);

      var options = {
        'key': (serverKey != null && serverKey.isNotEmpty)
            ? serverKey
            : FFAppConstants.razorpayKeyID,
        'amount':
            orderAmountPaise ?? ((double.tryParse(price) ?? 0) * 100).round(),
        'name': 'Mock Station',
        'description': categoryName,
        'order_id': orderId,
        'prefill': {
          'contact': getJsonField(FFAppState().userDetils, r'''$.phone''')
                  ?.toString() ??
              getJsonField(FFAppState().userDetils, r'''$.mobileno''')
                  ?.toString() ??
              '',
          'email': getJsonField(FFAppState().userDetils, r'''$.email''')
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
        child: SizedBox(
          height: 72,
          child: CustomPaint(
            painter: _PlanHeaderDecorationPainter(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  top: 0,
                  child: InkWell(
                    onTap: () => context.safePop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 24, color: Color(0xFF111827)),
                  ),
                ),
                Image.asset(
                  'assets/images/mock_test_horizontal_logo.png',
                  width: 174,
                  height: 42,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        'Select Your Plan',
        style: TextStyle(
          color: Color(0xFF111827),
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static const Map<int, Map<String, dynamic>> _indexThemes = {
    0: {
      'accent': Color(0xFF2563EB),
      'soft': Color(0xFFDBEAFE),
      'icon': Icons.menu_book_rounded,
      'border': Color(0xFF93C5FD),
    },
    1: {
      'accent': Color(0xFFF5026E),
      'soft': Color(0xFFFDE6F0),
      'icon': Icons.description_rounded,
      'border': Color(0xFFFBCFE8),
    },
    2: {
      'accent': Color(0xFFFD4607),
      'soft': Color(0xFFFFEDD5),
      'icon': Icons.cast_for_education_rounded,
      'border': Color(0xFFFDBA74),
    },
    3: {
      'accent': Color(0xFF7D2AFB),
      'soft': Color(0xFFF3E8FF),
      'icon': Icons.card_giftcard_rounded,
      'border': Color(0xFFD8B4FE),
    },
    4: {
      'accent': Color(0xFFB1470F),
      'soft': Color(0xFFFEF3C7),
      'icon': Icons.all_inclusive_rounded,
      'border': Color(0xFFFCD34D),
    },
  };

  // Product-specific themes matched by planName keyword.
  static const Map<String, Map<String, dynamic>> _productThemes = {
    'ebook': {
      'accent': Color(0xFF2563EB),
      'soft': Color(0xFFDBEAFE),
      'icon': Icons.menu_book_rounded,
      'border': Color(0xFF93C5FD),
    },
    'notes': {
      'accent': Color(0xFFF5026E),
      'soft': Color(0xFFFDE6F0),
      'icon': Icons.description_rounded,
      'border': Color(0xFFFBCFE8),
    },
    'mock test': {
      'accent': Color(0xFFFD4607),
      'soft': Color(0xFFFFEDD5),
      'icon': Icons.cast_for_education_rounded,
      'border': Color(0xFFFDBA74),
    },
    'all in one': {
      'accent': Color(0xFF7D2AFB),
      'soft': Color(0xFFF3E8FF),
      'icon': Icons.card_giftcard_rounded,
      'border': Color(0xFFD8B4FE),
    },
    'lifetime': {
      'accent': Color(0xFFB1470F),
      'soft': Color(0xFFFEF3C7),
      'icon': Icons.all_inclusive_rounded,
      'border': Color(0xFFFCD34D),
    },
  };

  Map<String, dynamic> _planTheme(
      String categoryName, String planName, int index) {
    final lower = '$categoryName $planName'.toLowerCase();
    // Product keyword match wins; index-based colors are the fallback.
    for (final entry in _productThemes.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return _indexThemes[index % _indexThemes.length]!;
  }

  String _displayPlanPrice(String price, int discountPercent) {
    if (discountPercent <= 0) return price;
    final priceValue = int.tryParse(price) ?? 0;
    final raw = priceValue * (100 - discountPercent) / 100;
    return raw == raw.roundToDouble()
        ? raw.toStringAsFixed(0)
        : raw.toStringAsFixed(2);
  }

  String _formatPlanCategorySubtitle(
      String planName, String? groupDisplayName) {
    final target =
        (groupDisplayName != null && groupDisplayName.trim().isNotEmpty)
            ? groupDisplayName.trim()
            : planName.trim();
    if (target.isEmpty) return 'Full Access Category';
    if (target.toLowerCase().contains('category')) {
      return target.toLowerCase().startsWith('full access')
          ? target
          : 'Full Access $target';
    }
    return 'Full Access $target Category';
  }

  Widget _buildPlanCard({
    required int index,
    required String price,
    required int discountPercent,
    required String planName,
    required String planValidity,
    required String categoryName,
    required bool isAlreadyActive,
    required bool isSelected,
    required bool isRecommended,
    required List<String> features,
    required VoidCallback onSelect,
  }) {
    final theme = _planTheme(categoryName, planName, index);
    final accent = theme['accent'] as Color;
    final soft = theme['soft'] as Color;
    final icon = theme['icon'] as IconData;
    final feature = features.isNotEmpty
        ? features.first
        : planName.toLowerCase().contains('ebook')
            ? 'High Quality Content'
            : planName.toLowerCase().contains('notes')
                ? 'Short & Concise Notes'
                : planName.toLowerCase().contains('mock')
                    ? 'Mock Tests & PYQs Pdf'
                    : 'Ebooks + Notes + Mock Tests';
    final displayPrice = _displayPlanPrice(price, discountPercent);
    // Selection is only a visual state. Show Active only when account access
    // data says the user already owns this plan.
    final showActiveBadge = isAlreadyActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isAlreadyActive
            ? const Color(0xFFF1FCF5)
            : isSelected
                ? soft.withOpacity(0.28)
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlreadyActive
              ? const Color(0xFF35C978)
              : isSelected
                  ? accent
                  : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A123047),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onSelect,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(icon, color: accent, size: 27),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            planName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF07133F),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Valid for $planValidity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF999BB2),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 18, color: accent),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  feature,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF20232A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 76,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 22),
                          if (discountPercent > 0)
                            Text(
                              '₹$price',
                              style: const TextStyle(
                                color: Color(0xFF999BB2),
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹$displayPrice',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 7,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showActiveBadge)
                      _planBadge(
                        'Active',
                        const Color(0xFF0DBB6B),
                        icon: Icons.check_circle,
                      )
                    else ...[
                      if (isRecommended)
                        _planBadge('Recommended', const Color(0xFFFFE500),
                            textColor: Colors.black),
                      if (discountPercent > 0) ...[
                        if (isRecommended) const SizedBox(width: 5),
                        _planBadge('$discountPercent% OFF',
                            const Color(0xFFFF7900)),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planBadge(String label, Color color,
      {Color textColor = Colors.white, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 11, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17324D).withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pay using',
                      style: TextStyle(
                        color: Color(0xFF8B6AA8),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_user_rounded,
                        color: Color(0xFF1685E8), size: 15),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/razorpay_logo_(1).svg',
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Razorpay',
                      style: TextStyle(
                        color: Color(0xFF263B55),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (_selectedPlanName != null &&
                    _selectedPlanDisplayPrice != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${_selectedPlanName!} · ₹${_selectedPlanDisplayPrice!}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF78889A),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 3),
                  const Text(
                    'Choose a plan',
                    style: TextStyle(
                      color: Color(0xFF78889A),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedPlanId == null ||
                      _selectedPlanPrice == null ||
                      _selectedPlanCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select a plan to continue')),
                    );
                    return;
                  }
                  if (_selectedPlanUnavailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('You already have access to this plan')),
                    );
                    return;
                  }
                  await _startPurchase(
                    planId: _selectedPlanId!,
                    price: _selectedPlanPrice!,
                    categoryName: _selectedPlanCategory!,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087FF5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
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
      backgroundColor: const Color(0xFFF0FAFF),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                      final aPrice = double.tryParse(
                              getJsonField(a, r'''$.price''').toString()) ??
                          0.0;
                      final bPrice = double.tryParse(
                              getJsonField(b, r'''$.price''').toString()) ??
                          0.0;
                      return aPrice.compareTo(bPrice);
                    });
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        _buildSectionHeader(),
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
                              final rawGroupDisplayName = getJsonField(
                                plan,
                                r'''$.categoryGroup.displayName''',
                              )?.toString();
                              final rawDescription = getJsonField(
                                plan,
                                r'''$.description''',
                              )?.toString();
                              final categoryName = (rawDescription != null &&
                                      rawDescription.trim().isNotEmpty)
                                  ? rawDescription.trim()
                                  : _formatPlanCategorySubtitle(
                                      planName,
                                      rawGroupDisplayName,
                                    );
                              final categoryGroupId = getJsonField(
                                plan,
                                r'''$.categoryGroup._id''',
                              )?.toString();
                              final planFeatures = (getJsonField(
                                    plan,
                                    r'''$.features''',
                                  ) as List<dynamic>?)
                                      ?.map((f) => f.toString())
                                      .toList() ??
                                  <String>[];

                              bool isAlreadyActive = false;
                              bool isIncludedByHigherPlan = false;
                              if (FFAppState().planStatus == 'active') {
                                final activeCodes = FFAppState()
                                    .activePlanCodes
                                    .map((c) => c.toUpperCase())
                                    .toList();
                                final cardPlanIdUpper =
                                    (getJsonField(plan, r'''$.planId''')
                                                ?.toString() ??
                                            '')
                                        .toUpperCase();
                                final cardPlanNameLower =
                                    planName.toLowerCase();

                                final isLifetimeActive =
                                    activeCodes.contains('PLAN-LTP01') ||
                                        FFAppState()
                                            .activePlanName
                                            .toLowerCase()
                                            .contains('lifetime');
                                final isAioActive =
                                    activeCodes.contains('PLAN-AIO01') ||
                                        FFAppState()
                                            .activePlanName
                                            .toLowerCase()
                                            .contains('all in one') ||
                                        FFAppState()
                                            .activePlanName
                                            .toLowerCase()
                                            .contains('all access');

                                if (isLifetimeActive) {
                                  if (cardPlanIdUpper == 'PLAN-LTP01' ||
                                      cardPlanNameLower.contains('lifetime')) {
                                    isAlreadyActive = true;
                                  } else {
                                    isIncludedByHigherPlan = true;
                                  }
                                } else if (isAioActive) {
                                  final isCardLifetime = cardPlanIdUpper ==
                                          'PLAN-LTP01' ||
                                      cardPlanNameLower.contains('lifetime');
                                  if (cardPlanIdUpper == 'PLAN-AIO01' ||
                                      cardPlanNameLower
                                          .contains('all in one') ||
                                      cardPlanNameLower
                                          .contains('all-in-one') ||
                                      cardPlanNameLower
                                          .contains('all access') ||
                                      cardPlanNameLower
                                          .contains('all-access')) {
                                    isAlreadyActive = true;
                                  } else if (!isCardLifetime) {
                                    isIncludedByHigherPlan = true;
                                  }
                                } else if (cardPlanIdUpper == 'PLAN-EBK01' ||
                                    cardPlanNameLower.contains('ebook')) {
                                  if (FFAppState().hasEbookAccess ||
                                      activeCodes.contains('PLAN-EBK01')) {
                                    isAlreadyActive = true;
                                  }
                                } else if (cardPlanIdUpper == 'PLAN-NOT01' ||
                                    cardPlanNameLower.contains('notes')) {
                                  if (FFAppState().hasNotesAccess ||
                                      activeCodes.contains('PLAN-NOT01')) {
                                    isAlreadyActive = true;
                                  }
                                } else if (cardPlanIdUpper == 'PLAN-MKT01' ||
                                    (cardPlanNameLower.contains('mock test') &&
                                        categoryGroupId == null)) {
                                  if (FFAppState().hasMockTestAccess &&
                                      (FFAppState().subsIsSelectedAll ||
                                          categoryGroupId == null)) {
                                    isAlreadyActive = true;
                                  }
                                } else if (cardPlanIdUpper.isNotEmpty &&
                                    activeCodes.contains(cardPlanIdUpper)) {
                                  isAlreadyActive = true;
                                } else if (categoryGroupId != null &&
                                    FFAppState()
                                        .allowedCategoryIds
                                        .contains(categoryGroupId)) {
                                  isAlreadyActive = true;
                                }
                              }

                              final planMongoId =
                                  getJsonField(plan, r'''$._id''').toString();
                              final discountPercent =
                                  _offerDiscounts[planMongoId] ?? 0;

                              return _buildPlanCard(
                                index: index,
                                price: price,
                                discountPercent: discountPercent,
                                planName: planName,
                                planValidity: planValidity,
                                categoryName: categoryName,
                                isAlreadyActive: isAlreadyActive ||
                                    isIncludedByHigherPlan,
                                isSelected: _selectedPlanId == planMongoId,
                                isRecommended:
                                    planName.toLowerCase().contains('lifetime'),
                                features: planFeatures,
                                onSelect: () {
                                  setState(() {
                                    _selectedPlanId = planMongoId;
                                    _selectedPlanPrice = price;
                                    _selectedPlanCategory = categoryName;
                                    _selectedPlanName = planName;
                                    _selectedPlanDisplayPrice =
                                        _displayPlanPrice(price, discountPercent);
                                    _selectedPlanUnavailable =
                                        isAlreadyActive ||
                                            isIncludedByHigherPlan;
                                  });
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ColoredBox(color: Colors.white, child: _buildPaymentBar()),
          ),
        ],
      ),
    );
  }
}

class _PlanHeaderDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void diamond(double x, double y, double side, Color color, double angle) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: side, height: side),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
      canvas.restore();
    }

    diamond(19, 12, 7, const Color(0xFFFFC52F), 0.72);
    diamond(48, 5, 7, const Color(0xFFE9697A), 0.35);
    diamond(70, 17, 6, const Color(0xFF9B51E0), 0.72);
    diamond(size.width - 78, 13, 7, const Color(0xFFFFC52F), 0.78);
    diamond(size.width - 48, 8, 8, const Color(0xFF8BC34A), 0.48);
    diamond(size.width - 20, 13, 7, const Color(0xFFE9697A), 0.65);
    diamond(21, 49, 6, const Color(0xFF8BC34A), 0.2);
    diamond(size.width - 29, 48, 6, const Color(0xFFE875BD), 0.2);

    final magenta = Paint()
      ..color = const Color(0xFFD52ACB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final leftWave = Path()
      ..moveTo(0, 39)
      ..cubicTo(8, 35, 10, 48, 17, 44)
      ..cubicTo(23, 40, 25, 34, 31, 40);
    canvas.drawPath(leftWave, magenta);

    final coral = Paint()
      ..color = const Color(0xFFE9574D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final rightWave = Path()
      ..moveTo(size.width - 42, 38)
      ..cubicTo(size.width - 32, 31, size.width - 28, 47, size.width - 20, 40)
      ..cubicTo(size.width - 14, 35, size.width - 11, 29, size.width - 5, 34);
    canvas.drawPath(rightWave, coral);

    final orange = Paint()
      ..color = const Color(0xFFF2A323)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final smallScribble = Path()
      ..moveTo(size.width - 40, 55)
      ..cubicTo(size.width - 47, 50, size.width - 32, 49, size.width - 39, 44);
    canvas.drawPath(smallScribble, orange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
