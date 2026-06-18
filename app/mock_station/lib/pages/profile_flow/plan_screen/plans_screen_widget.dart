import '/componants/app_bar/app_bar_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/componants/payment_success_componant/payment_success_componant_widget.dart';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
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

  String? _currentOrderId;

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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          wrapWithModel(
            model: _model.appBarModel,
            updateCallback: () => safeSetState(() {}),
            child: AppBarWidget(
              title: 'Subscription Plans',
              backIcon: true,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Subscription Plans',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Roboto',
                          letterSpacing: 0.0,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          useGoogleFonts: false,
                        ),
                  ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
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
                        return Center(child: Text('No plans available.'));
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          final planId = getJsonField(plan, r'''$._id''').toString();
                          final price = getJsonField(plan, r'''$.price''').toString();
                          final planName = getJsonField(plan, r'''$.planName''')?.toString() ?? 'Standard Plan';
                          final planValidity = getJsonField(plan, r'''$.planValidity''')?.toString() ?? '1 Year';
                          
                          // More robust extraction of the plan name
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

                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$categoryName - $planName',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            fontFamily: 'Roboto',
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            useGoogleFonts: false,
                                          ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 16.0),
                                      child: Text(
                                        'Validity: $planValidity',
                                        style: FlutterFlowTheme.of(context).bodySmall,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹$price',
                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                fontFamily: 'Roboto',
                                                color: FlutterFlowTheme.of(context).primary,
                                                fontWeight: FontWeight.bold,
                                                useGoogleFonts: false,
                                              ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: isAlreadyActive
                                              ? null
                                              : () async {
                                                  // 1. Create Order / Buy Plan
                                                  final buyResponse = await QuizGroup.buyPlanCall.call(
                                                    token: FFAppState().loginToken,
                                                    planId: planId,
                                                    userId: FFAppState().userId,
                                                    price: (int.tryParse(price) ?? 0) * 100,
                                                    points: 0,
                                                  );
                                                  print('=== BUY RESPONSE: ${buyResponse.jsonBody} ===');
                                                  final sVal = getJsonField(buyResponse.jsonBody, r'''$.success''') ?? getJsonField(buyResponse.jsonBody, r'''$.data.success''');
                                                  if (sVal == 1 || sVal == true) {
                                                    // Robust extraction of orderId and amount
                                                    final String? orderId = getJsonField(buyResponse.jsonBody, r'''$.orderId''')?.toString() ?? 
                                                                         getJsonField(buyResponse.jsonBody, r'''$.data.orderId''')?.toString();
                                                    
                                                    final int? orderAmountPaise = castToType<int>(getJsonField(buyResponse.jsonBody, r'''$.amountInPaise''')) ?? 
                                                                               castToType<int>(getJsonField(buyResponse.jsonBody, r'''$.data.amountInPaise'''));
                                                    final int? orderAmountINR = castToType<int>(getJsonField(buyResponse.jsonBody, r'''$.amount''')) ?? 
                                                                             castToType<int>(getJsonField(buyResponse.jsonBody, r'''$.data.amount'''));
                                                    
                                                    print('=== ORDER DATA -> ID: $orderId, PAISE: $orderAmountPaise, INR: $orderAmountINR ===');
                                                    
                                                    // Calculate display price (INR) to pass to razorpayCustom
                                                    double displayPrice = 0;
                                                    if (orderAmountPaise != null && orderAmountPaise > 0) {
                                                      displayPrice = orderAmountPaise / 100.0;
                                                    } else if (orderAmountINR != null && orderAmountINR > 0) {
                                                      displayPrice = orderAmountINR.toDouble();
                                                    } else {
                                                      displayPrice = double.tryParse(price) ?? 0;
                                                    }
                                                    
                                                    print('=== PASSING TO RAZORPAY -> INR: $displayPrice, OrderId: $orderId ===');

                                                    _currentOrderId = orderId;

                                                    // 2. Open Razorpay using local instance
                                                    var options = {
                                                      'key': FFAppConstants.razorpayKeyID,
                                                      'amount': orderAmountPaise ?? ((double.tryParse(price) ?? 0) * 100).round(),
                                                      'name': 'Mock Station',
                                                      'description': categoryName.toString(),
                                                      'order_id': orderId,
                                                      'prefill': {
                                                        'contact': getJsonField(FFAppState().userDetils, r'''$.phone''')?.toString() ?? 
                                                                  getJsonField(FFAppState().userDetils, r'''$.mobileno''')?.toString() ?? '',
                                                        'email': getJsonField(FFAppState().userDetils, r'''$.email''')?.toString() ?? '',
                                                      },
                                                      'theme': {
                                                        'color': '#3399cc',
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
                                                      SnackBar(content: Text('Failed to initiate purchase. Please try again.')),
                                                    );
                                                  }
                                                },
                                          text: isAlreadyActive ? 'Already Active' : 'Buy Now',
                                          options: FFButtonOptions(
                                            height: 40.0,
                                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                            color: isAlreadyActive
                                                ? FlutterFlowTheme.of(context).alternate
                                                : FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                  fontFamily: 'Roboto',
                                                  color: Colors.white,
                                                  useGoogleFonts: false,
                                                ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
