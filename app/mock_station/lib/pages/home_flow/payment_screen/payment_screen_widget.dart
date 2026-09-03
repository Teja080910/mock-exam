import '';
import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/componants/payment_success_componant/payment_success_componant_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'payment_screen_model.dart';
export 'payment_screen_model.dart';

class PaymentScreenWidget extends StatefulWidget {
  const PaymentScreenWidget({
    super.key,
    this.paymentPrice,
    this.points,
    this.planId,
  });

  final int? paymentPrice;
  final int? points;
  final String? planId;

  static String routeName = 'payment_screen';
  static String routePath = '/paymentScreen';

  @override
  State<PaymentScreenWidget> createState() => _PaymentScreenWidgetState();
}

class _PaymentScreenWidgetState extends State<PaymentScreenWidget> {
  late PaymentScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late Razorpay _razorpay;

  int? _currentPoints;
  String? _currentPlanId;
  int? _currentPrice;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentScreenModel());
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    refreshProfile();
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');
    
    // 3. Buy Plan (Create Order on Backend)
    _model.planResCopy = await QuizGroup.buyPlanCall.call(
      userId: getJsonField(FFAppState().userDetils, r'''$.id''')?.toString() ?? 
              getJsonField(FFAppState().userDetils, r'''$._id''')?.toString() ?? '',
      planId: _currentPlanId,
      points: _currentPoints,
      price: _currentPrice,
      token: FFAppState().loginToken,
    );

    final bSuccess = getJsonField(_model.planResCopy?.jsonBody, r'''$.success''') ?? getJsonField(_model.planResCopy?.jsonBody, r'''$.data.success''');

    if (bSuccess == 1 || bSuccess == true) {
      // 4. Add Points
      _model.apiResultxs = await QuizGroup.addPointsApiCall.call(
        userId: getJsonField(FFAppState().userDetils, r'''$.id''')?.toString() ?? 
                getJsonField(FFAppState().userDetils, r'''$._id''')?.toString() ?? '',
        points: _currentPoints?.toDouble(),
        description: 'Purchase ${_currentPoints} points',
        token: FFAppState().loginToken,
      );

      final pSuccess = getJsonField(_model.apiResultxs?.jsonBody, r'''$.success''') ?? getJsonField(_model.apiResultxs?.jsonBody, r'''$.data.success''');

      if (pSuccess == 1 || pSuccess == true) {
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
                child: GestureDetector(
                  onTap: () => FocusScope.of(dialogContext).unfocus(),
                  child: Container(
                    height: 450.0,
                    child: PaymentSuccessComponantWidget(
                      price: _currentPoints,
                      title: 'Points Purchased!',
                      message: 'You have successfully purchased ${_currentPoints} points. You can now use them for mock tests.',
                      onTapHome: () async {
                        // Handle Home Tap...
                        _model.planHis = await QuizGroup.planHistoryAPICall.call(
                          userId: getJsonField(FFAppState().userDetils, r'''$.id''')?.toString() ?? 
                                  getJsonField(FFAppState().userDetils, r'''$._id''')?.toString() ?? '',
                          token: FFAppState().loginToken,
                        );
                        if (mounted) {
                          FFAppState().isPremium = true;
                          await refreshProfile();
                          Navigator.pop(dialogContext);
                          context.goNamed(HomeScreenWidget.routeName);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
      }
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Verification failed: ${getJsonField(_model.planResCopy?.jsonBody, r'''$.message''') ?? 'Unknown error'}')),
         );
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
    _razorpay.clear();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Builder(
          builder: (context) {
            if (FFAppState().connected == true) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.appBarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: AppBarWidget(
                      title: 'Payment method',
                      backIcon: false,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          16.0,
                          0,
                          16.0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 20.0),
                            child: Text(
                              'Select payment method',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Roboto',
                                    fontSize: FFFont.f18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts: false,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.selectPayment = 0;
                                safeSetState(() {});
                              },
                              child: Container(
                                width: double.infinity,
                                height: 66.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 16.0, 16.0, 16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: Image.asset(
                                          'assets/images/stripe_ic.png',
                                          width: 34.0,
                                          height: 34.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            'Stripe',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Roboto',
                                                  fontSize: FFFont.f18,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  useGoogleFonts: false,
                                                  lineHeight: 1.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Builder(
                                        builder: (context) {
                                          if (_model.selectPayment == 0) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: SvgPicture.asset(
                                                'assets/images/Component_25.svg',
                                                width: 24.0,
                                                height: 24.0,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          } else {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: SvgPicture.asset(
                                                'assets/images/Component_25-1.svg',
                                                width: 24.0,
                                                height: 24.0,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.selectPayment = 1;
                                safeSetState(() {});
                              },
                              child: Container(
                                width: double.infinity,
                                height: 66.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 16.0, 16.0, 16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: SvgPicture.asset(
                                          'assets/images/razorpay_logo_(1).svg',
                                          width: 34.0,
                                          height: 34.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            'RazorPay',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Roboto',
                                                  fontSize: FFFont.f18,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  useGoogleFonts: false,
                                                  lineHeight: 1.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Builder(
                                        builder: (context) {
                                          if (_model.selectPayment == 1) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: SvgPicture.asset(
                                                'assets/images/Component_25.svg',
                                                width: 24.0,
                                                height: 24.0,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          } else {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: SvgPicture.asset(
                                                'assets/images/Component_25-1.svg',
                                                width: 24.0,
                                                height: 24.0,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.paymentPrice?.toString()}.00',
                          maxLines: 1,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Roboto',
                                    fontSize: FFFont.f20,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    useGoogleFonts: false,
                                    lineHeight: 1.5,
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 10.0),
                          child: Builder(
                            builder: (context) {
                              if (_model.selectPayment != 2) {
                                return Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Builder(
                                    builder: (context) => FFButtonWidget(
                                      onPressed: () async {
                                        if (_model.selectPayment == 1) {
                                          // Store current payment info to use in success handler
                                          _currentPoints = widget.points;
                                          _currentPlanId = widget.planId;
                                          _currentPrice = widget.paymentPrice;

                                          var options = {
                                            'key': FFAppConstants.razorpayKeyID,
                                            'amount': (widget.paymentPrice! * 100).round(),
                                            'name': 'Mock Station',
                                            'description': 'Purchase ${widget.points} points',
                                            'prefill': {
                                              'contact': "6209593580", 
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
                                        }
 else {
                                          /*if (_model.selectPayment == 0) {
                                            await actions.initStripeAction(
                                              FFAppConstants
                                                  .stripePublishableKey,
                                            );
                                            *//*await actions.customStripe(
                                              context,
                                              (widget.paymentPrice!)
                                                  .toString(),
                                              'USD',
                                              'US',
                                              () async {
                                                _model.planResCopy2 =
                                                    await QuizGroup.buyPlanCall
                                                        .call(
                                                  userId: getJsonField(
                                                    FFAppState().userDetils,
                                                    r'''$.id''',
                                                  ).toString(),
                                                  planId: widget.planId,
                                                  points: widget.points,
                                                  price: widget.paymentPrice,
                                                  token:
                                                      FFAppState().loginToken,
                                                );

                                                if (QuizGroup.buyPlanCall
                                                        .success(
                                                      (_model.planResCopy2
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    1) {
                                                  _model.apiResultx =
                                                      await QuizGroup
                                                          .addPointsApiCall
                                                          .call(
                                                    userId: getJsonField(
                                                      FFAppState().userDetils,
                                                      r'''$.id''',
                                                    ).toString(),
                                                    points: widget.points
                                                        ?.toDouble(),
                                                    description:
                                                        'Purchase ${widget.points?.toString()} points',
                                                    token:
                                                        FFAppState().loginToken,
                                                  );

                                                  if (QuizGroup.addPointsApiCall
                                                          .success(
                                                        (_model.apiResultx
                                                                ?.jsonBody ??
                                                            ''),
                                                      ) ==
                                                      1) {
                                                    await showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      dialogContext)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child: Container(
                                                              height: 450.0,
                                                              child:
                                                                  PaymentSuccessComponantWidget(
                                                                price: widget
                                                                    .paymentPrice,
                                                                title: 'Payment Successful!',
                                                                message: 'Your payment was successful. You can now access your premium content.',
                                                                onTapHome:
                                                                    () async {
                                                                  _model.his =
                                                                      await QuizGroup
                                                                          .planHistoryAPICall
                                                                          .call(
                                                                    userId:
                                                                        getJsonField(
                                                                      FFAppState()
                                                                          .userDetils,
                                                                      r'''$.id''',
                                                                    ).toString(),
                                                                    token: FFAppState()
                                                                        .loginToken,
                                                                  );

                                                                  if (QuizGroup
                                                                          .planHistoryAPICall
                                                                          .success(
                                                                        (_model.his?.jsonBody ??
                                                                            ''),
                                                                      ) ==
                                                                      1) {
                                                                    FFAppState()
                                                                            .isPremium =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    Navigator.pop(
                                                                        context);
                                                                    FFAppState()
                                                                        .clearCoinsCache();
                                                                    FFAppState()
                                                                        .clearCoinsHistoryCache();

                                                                    context.goNamed(
                                                                        HomeScreenWidget
                                                                            .routeName);
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          QuizGroup
                                                                              .planHistoryAPICall
                                                                              .message(
                                                                            (_model.his?.jsonBody ??
                                                                                ''),
                                                                          )!,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).info,
                                                                            fontSize: FFFont.f16,
                                                                          ),
                                                                        ),
                                                                        duration:
                                                                            Duration(milliseconds: 4000),
                                                                        backgroundColor:
                                                                            FlutterFlowTheme.of(context).error,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        QuizGroup.buyPlanCall
                                                            .message(
                                                          (_model.planResCopy2
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!,
                                                        style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 4000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                    ),
                                                  );
                                                }
                                              },
                                              () async {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Payment failed',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        fontSize: FFFont.f16,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .error,
                                                  ),
                                                );
                                              },
                                              FFAppConstants.stripeSecretKey,
                                            );*//*
                                          }*/
                                        }

                                        safeSetState(() {});
                                      },
                                      text: 'Pay now',
                                      options: FFButtonOptions(
                                        width: 190.0,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24.0, 0.0, 24.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Roboto',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .black,
                                              fontSize: FFFont.f18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              useGoogleFonts: false,
                                              lineHeight: 1.2,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  width: 200.0,
                                  height: 60.0,
                                  child: custom_widgets.GooglePayWidget(
                                    width: 200.0,
                                    height: 60.0,
                                    priceAmount:
                                        (widget.paymentPrice!).toString(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
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
          },
        ),
      ),
    );
  }
}
