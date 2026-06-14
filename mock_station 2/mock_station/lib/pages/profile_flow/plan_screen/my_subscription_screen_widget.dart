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
        
        // Extract Plan and Category Name
        activePlanName = getJsonField(response.jsonBody, r'''$.planId.planName''')?.toString();
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
                'Expires on: ${dateTimeFormat('MMM d, yyyy', DateTime.tryParse(expiry) ?? DateTime.now())}',
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
                          if (FFAppState().subsIsSelectedAll) {
                            return _buildSubscriptionCard(
                              context,
                              title: activePlanName ?? 'Full Access (All Categories)',
                              category: 'All Categories included',
                              expiry: FFAppState().expiresAt,
                            );
                          }
                          
                          if (activeCategoryGroups == null || activeCategoryGroups!.isEmpty) {
                            return _buildSubscriptionCard(
                              context,
                              title: activePlanName ?? 'Standard Category Plan',
                              category: 'No category details found',
                              expiry: FFAppState().expiresAt,
                            );
                          }

                          return Column(
                            children: activeCategoryGroups!.map((group) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: _buildSubscriptionCard(
                                  context,
                                  title: activePlanName ?? 'Standard Category Plan',
                                  category: getJsonField(group, r'''$.displayName''')?.toString() ?? 'Category Name',
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
