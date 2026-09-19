import '/componants/app_bar/app_bar_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_subscription_screen_model.dart';
export 'my_subscription_screen_model.dart';

class MySubscriptionScreenWidget extends StatefulWidget {
  const MySubscriptionScreenWidget({super.key});

  static String routeName = 'MySubscriptionScreen';
  static String routePath = '/mySubscriptionScreen';

  @override
  State<MySubscriptionScreenWidget> createState() =>
      _MySubscriptionScreenWidgetState();
}

class _MySubscriptionScreenWidgetState extends State<MySubscriptionScreenWidget> {
  late MySubscriptionScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? activePlanName;
  List<dynamic>? activeCategoryGroups;
  List<dynamic>? activeSubscriptions;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MySubscriptionScreenModel());
    
    // Fetch latest plan status on load
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshProfile());
  }

  Future<void> refreshProfile() async {
    final response = await QuizGroup.fetchUserPlanCall.call(
      token: FFAppState().loginToken,
    );
    print('======fetchUserPlanCall====>>${response.jsonBody}');
    if (QuizGroup.fetchUserPlanCall.success(response.jsonBody) == true) {
      safeSetState(() {
        FFAppState().planStatus = QuizGroup.fetchUserPlanCall.planStatus(response.jsonBody) ?? 'none';
        FFAppState().subsIsSelectedAll = QuizGroup.fetchUserPlanCall.isSelectedAll(response.jsonBody) ?? false;
        FFAppState().expiresAt = QuizGroup.fetchUserPlanCall.expiresAt(response.jsonBody) ?? '';
        FFAppState().activePlanName = QuizGroup.fetchUserPlanCall.planName(response.jsonBody) ?? '';
        FFAppState().activePlanCode = QuizGroup.fetchUserPlanCall.planCode(response.jsonBody) ?? '';
        FFAppState().hasEbookAccess = QuizGroup.fetchUserPlanCall.hasEbookAccess(response.jsonBody) ?? false;
        FFAppState().hasNotesAccess = QuizGroup.fetchUserPlanCall.hasNotesAccess(response.jsonBody) ?? false;
        FFAppState().hasMockTestAccess = QuizGroup.fetchUserPlanCall.hasMockTestAccess(response.jsonBody) ?? false;
        
        final rawCodes = QuizGroup.fetchUserPlanCall.activePlanCodes(response.jsonBody);
        if (rawCodes is List) {
          FFAppState().activePlanCodes = rawCodes.map((c) => c.toString().toUpperCase()).toList();
        } else {
          FFAppState().activePlanCodes = [];
        }

        activeSubscriptions = QuizGroup.fetchUserPlanCall.subscriptions(response.jsonBody);
        activePlanName = QuizGroup.fetchUserPlanCall.planName(response.jsonBody) ??
            getJsonField(response.jsonBody, r'''$.planId.planName''')?.toString();
        activeCategoryGroups = QuizGroup.fetchUserPlanCall.categoryGroupIds(response.jsonBody);

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
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String category,
    required String expiry,
  }) {
    String expiryText;
    if (expiry.isEmpty || expiry == 'null') {
      expiryText = 'Lifetime Access';
    } else {
      final parsed = DateTime.tryParse(expiry);
      if (parsed != null) {
        expiryText = dateTimeFormat('MMM d, yyyy', parsed);
      } else {
        expiryText = expiry;
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 2.0),
          )
        ],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Plan Details',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Roboto',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts: false,
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).success,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                    child: Text(
                      'ACTIVE',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            useGoogleFonts: false,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 24.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: false,
                  ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
              child: Text(
                'Category: $category',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Roboto',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      useGoogleFonts: false,
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Text(
                expiryText == 'Lifetime Access'
                    ? 'Validity: Lifetime Access'
                    : 'Expires on: $expiryText',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Roboto',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: false,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
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
              title: 'My Subscription',
              backIcon: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (FFAppState().planStatus == 'active')
                      Builder(
                        builder: (context) {
                          if (activeSubscriptions != null &&
                              activeSubscriptions!.isNotEmpty) {
                            return Column(
                              children: activeSubscriptions!.map((sub) {
                                final subTitle =
                                    sub['planName']?.toString().isNotEmpty == true
                                        ? sub['planName'].toString()
                                        : 'Active Plan';
                                final subCode = (sub['planCode']?.toString() ?? '')
                                    .toUpperCase();
                                final subNameLower = subTitle.toLowerCase();
                                final subExpiry =
                                    sub['expiresAt']?.toString() ?? '';

                                String category = 'General Access';
                                if (subCode == 'PLAN-EBK01' ||
                                    subNameLower.contains('ebook')) {
                                  category = 'eBooks Access';
                                } else if (subCode == 'PLAN-NOT01' ||
                                    subNameLower.contains('notes')) {
                                  category = 'Notes Access';
                                } else if (subCode == 'PLAN-MKT01' ||
                                    (subNameLower.contains('mock test') &&
                                        sub['categoryGroup'] == null)) {
                                  category =
                                      'All Categories included (Mock Tests & PDFs)';
                                } else if (subCode == 'PLAN-AIO01' ||
                                    subNameLower.contains('all in one') ||
                                    subNameLower.contains('all-in-one') ||
                                    subNameLower.contains('all access')) {
                                  category =
                                      'Complete Access (Mock Tests, PDFs, Ebooks & Notes)';
                                } else if (subCode == 'PLAN-LTP01' ||
                                    subNameLower.contains('lifetime')) {
                                  category = 'Lifetime Complete Access';
                                } else if (sub['categoryGroup'] != null) {
                                  category = sub['categoryGroup']
                                              ['displayName']
                                          ?.toString() ??
                                      'Category Tests Access';
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildSubscriptionCard(
                                    context,
                                    title: subTitle,
                                    category: category,
                                    expiry: subExpiry,
                                  ),
                                );
                              }).toList(),
                            );
                          }

                          final displayName = (activePlanName != null &&
                                  activePlanName!.isNotEmpty)
                              ? activePlanName!
                              : (FFAppState().activePlanName.isNotEmpty
                                  ? FFAppState().activePlanName
                                  : 'Active Plan');

                          if (FFAppState().hasEbookAccess &&
                              !FFAppState().hasMockTestAccess) {
                            return _buildSubscriptionCard(
                              context,
                              title: displayName,
                              category: 'eBooks Access',
                              expiry: FFAppState().expiresAt,
                            );
                          }

                          if (FFAppState().hasNotesAccess &&
                              !FFAppState().hasMockTestAccess) {
                            return _buildSubscriptionCard(
                              context,
                              title: displayName,
                              category: 'Notes Access',
                              expiry: FFAppState().expiresAt,
                            );
                          }

                          if (FFAppState().subsIsSelectedAll) {
                            return _buildSubscriptionCard(
                              context,
                              title: displayName,
                              category: (FFAppState().hasEbookAccess &&
                                      FFAppState().hasNotesAccess)
                                  ? 'Complete Access (Mock Tests, PDFs, Ebooks & Notes)'
                                  : 'All Categories included (Mock Tests & PDFs)',
                              expiry: FFAppState().expiresAt,
                            );
                          }

                          if (activeCategoryGroups == null ||
                              activeCategoryGroups!.isEmpty) {
                            return _buildSubscriptionCard(
                              context,
                              title: displayName,
                              category: 'Standard Plan',
                              expiry: FFAppState().expiresAt,
                            );
                          }

                          return Column(
                            children: activeCategoryGroups!.map((group) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildSubscriptionCard(
                                  context,
                                  title: displayName,
                                  category: getJsonField(
                                              group, r'''$.displayName''')
                                          ?.toString() ??
                                      'Category Name',
                                  expiry: FFAppState().expiresAt,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 64,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'You do not have any active subscription.',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyLarge,
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed('PlansScreen');
                              },
                              text: 'View Available Plans',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle:
                                    FlutterFlowTheme.of(context).titleSmall.override(
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                          useGoogleFonts: false,
                                        ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
