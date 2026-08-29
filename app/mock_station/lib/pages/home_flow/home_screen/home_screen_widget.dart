import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/api_requests/api_calls.dart';
import '/componants/email_verification_dialog/email_verification_dialog_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shimmer/blank_component/blank_component_widget.dart';
import '/shimmer/shimmer_banner/shimmer_banner_widget.dart';
import '/shimmer/shimmer_container/shimmer_container_widget.dart';
import '/shimmer/shimmer_home_list/shimmer_home_list_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'home_screen_model.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;

export 'home_screen_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  static String routeName = 'home_screen';
  static String routePath = '/homeScreen';

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget>
    with TickerProviderStateMixin {
  late HomeScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  
  // Banner carousel current index
  int _bannerCurrentIndex = 0;
  bool _showDisclaimerBanner = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().isLogin) {
        _model.apiResultaov = await QuizGroup.isVerifyAccountCall.call(
          email: getJsonField(
            FFAppState().userDetils,
            r'''$.email''',
          ).toString(),
        );
      }
      _model.getUserRankRes = await QuizGroup.getuserrankApiCall.call(
        userId: getJsonField(
          FFAppState().userDetils,
          r'''$.id''',
        ).toString(),
        token: FFAppState().loginToken,
      );
      if (QuizGroup.getuserrankApiCall.success(
            (_model.getUserRankRes?.jsonBody ?? ''),
          ) ==
          1) {
        final points = QuizGroup.getuserrankApiCall.points(
          (_model.getUserRankRes?.jsonBody ?? ''),
        );
        FFAppState().userPoints = points != null ? points.toInt() : 0;
        FFAppState().update(() {});
      }
      // Fetch User Plan Status
      if (FFAppState().isLogin) {
        final planRes = await QuizGroup.fetchUserPlanCall.call(
          token: FFAppState().loginToken,
        );
        if (QuizGroup.fetchUserPlanCall.success(planRes.jsonBody) == true) {
          FFAppState().planStatus =
              QuizGroup.fetchUserPlanCall.planStatus(planRes.jsonBody) ?? 'none';
          FFAppState().subsIsSelectedAll =
              QuizGroup.fetchUserPlanCall.isSelectedAll(planRes.jsonBody) ?? false;
          FFAppState().expiresAt =
              QuizGroup.fetchUserPlanCall.expiresAt(planRes.jsonBody) ?? '';
          List<String> categoryIds = [];
          final categoryGroups =
              QuizGroup.fetchUserPlanCall.categoryGroupIds(planRes.jsonBody);
          if (categoryGroups != null) {
            for (var group in categoryGroups) {
              if (group['_id'] != null) {
                categoryIds.add(group['_id'].toString());
              }
            }
          }
          FFAppState().allowedCategoryIds = categoryIds;
        }
      }
    });

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.linear,
            delay: 50.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildScopeSection(BuildContext context, String title, List<CategoryGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 18.0, right: 16.0, bottom: 6.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        ...groups.map((group) => _buildGroupCard(context, group)),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context, CategoryGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CategoryViewallWidget(
                      allowedCategoryIds: group.categories.map((c) => c.id).toSet(),
                    ),
                  ));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primary,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 1.1,
            ),
            itemCount: group.categories.length,
            itemBuilder: (context, index) {
              final category = group.categories[index];
              return InkWell(
                onTap: () {
                  if (functions.hasCategoryAccess(
                    FFAppState().planStatus,
                    FFAppState().subsIsSelectedAll,
                    FFAppState().allowedCategoryIds,
                    category.id,
                    group.id,
                  )) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CategoryDetailPageWidget(
                        title: category.displayName.isNotEmpty ? category.displayName : category.name,
                        catId: category.id,
                        image: category.image,
                      ),
                    ));
                  } else {
                    showSubscriptionDialog(context);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    category.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: category.image.startsWith('http') ? category.image : '${FFAppConstants.imageBaseURL}${category.image}',
                          width: 44, height: 44,
                          placeholder: (context, url) => const SizedBox(width: 44, height: 44, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (context, url, error) => const Icon(Icons.category, size: 44),
                        )
                      : const Icon(Icons.category, size: 44),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 1, right: 1),
                      child: Text(
                        category.displayName.isNotEmpty ? category.displayName : category.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const SizedBox(width: 5),
              Image.asset('assets/images/mock_test_horizontal_logo.png', width: 150),
            ],
          ),
          elevation: 0,
        ),
        body: Builder(
          builder: (context) {
            if (FFAppState().connected != true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: FlutterFlowTheme.of(context).secondaryText),
                    const SizedBox(height: 16),
                    Text('No Internet Connection', style: FlutterFlowTheme.of(context).bodyLarge),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _model.bannersFuture = null;
                  _model.categoryGroupsFuture = null;
                });
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Banner Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: FutureBuilder<ApiCallResponse>(
                        future: _model.bannersFuture ??=
                            QuizGroup.getCarouselBannersCall.call(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 180.0,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final banners = QuizGroup.getCarouselBannersCall
                                  .bannersList(snapshot.data!.jsonBody)
                                  ?.toList() ??
                                [];
                          if (banners.isEmpty) return const SizedBox(height: 8);
                          return SizedBox(
                            height: 140.0,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 140.0,
                                viewportFraction: 0.9,
                                autoPlay: banners.length > 1,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: banners.length > 1,
                                onPageChanged: (index, reason) =>
                                    setState(() => _bannerCurrentIndex = index),
                              ),
                              items: banners.map((banner) {
                                final rawImg =
                                    getJsonField(banner, r'''$.image''')
                                        .toString();
                                final imgUrl = rawImg.startsWith('http')
                                    ? rawImg
                                    : '${FFAppConstants.imageBaseURL}$rawImg';
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 12.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0.0, 6.0),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imgUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Carousel Dots Indicator
                  SliverToBoxAdapter(
                    child: FutureBuilder<ApiCallResponse>(
                      future: _model.bannersFuture ??=
                          QuizGroup.getCarouselBannersCall.call(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox(height: 4);
                        final banners = QuizGroup.getCarouselBannersCall
                                .bannersList(snapshot.data!.jsonBody)
                                ?.toList() ??
                            [];
                        if (banners.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(banners.length, (index) {
                              final isSelected = _bannerCurrentIndex == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                width: isSelected ? 24.0 : 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context)
                                          .secondaryText
                                          .withOpacity(0.3),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),

                  // Category Groups (Central wise + State wise + Other)
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<CategoryGroup>>(
                      future: _model.categoryGroupsFuture ??= fetchCategoryGroups(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('Failed to load categories')),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                           return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: Text('No categories found')),
                          );
                        }

                        final centralGroups = snapshot.data!.where((g) => g.scope == 'central').toList();
                        final stateGroups = snapshot.data!.where((g) => g.scope == 'state').toList();
                        final otherGroups = snapshot.data!.where((g) => g.scope != 'central' && g.scope != 'state').toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (centralGroups.isNotEmpty) _buildScopeSection(context, 'Central wise', centralGroups),
                            if (stateGroups.isNotEmpty) _buildScopeSection(context, 'State wise', stateGroups),
                            if (otherGroups.isNotEmpty) _buildScopeSection(context, 'Other', otherGroups),
                          ],
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: StatefulBuilder(
                      builder: (context, setBannerState) {
                        if (!_showDisclaimerBanner) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFEEBA), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info, color: Color(0xFF0D6EFD), size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Disclaimer: This app is not affiliated with or represents any government entity.",
                                  style: TextStyle(
                                    color: Color(0xFF664D03),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setBannerState(() {
                                    _showDisclaimerBanner = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2B3A67),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String displayName;
  final String image;
  Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.image,
  });
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        displayName: json['displayName'] ?? '',
        image: json['image'] ?? json['imageUrl'] ?? '',
      );
}

class CategoryGroup {
  final String id;
  final String displayName;
  final String scope;
  final List<Category> categories;
  CategoryGroup({
    required this.id,
    required this.displayName,
    required this.scope,
    required this.categories,
  });
  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
        id: json['_id'] ?? '',
        displayName: json['displayName'] ?? '',
        scope: (json['scope'] is String) ? json['scope'] as String : 'none',
        categories: (json['categories'] as List?)?.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      );
}

Future<List<CategoryGroup>> fetchCategoryGroups() async {
  try {
    print('DEBUG: Fetching category groups from API...');
    final response = await QuizGroup.getCategoryGroupsCall.call(
      token: FFAppState().loginToken,
    );
    
    if (response.statusCode == 200) {
      final List? groupsData = QuizGroup.getCategoryGroupsCall.groups(response.jsonBody);
      if (groupsData != null) {
        print('DEBUG: Found ${groupsData.length} category groups from API');
        List<CategoryGroup> groups = groupsData.map((e) => CategoryGroup.fromJson(e as Map<String, dynamic>)).toList();
        
        // Remove 'Current Affairs' category from all groups
        for (var group in groups) {
          group.categories.removeWhere((c) => 
            c.name.toLowerCase().contains('current affairs') || 
            c.displayName.toLowerCase().contains('current affairs') ||
            c.id == '68d67ba5d6d9bc79cbfe054a'
          );
        }

        // Remove empty groups
        groups.removeWhere((g) => g.categories.isEmpty);

        // Sort: central first, then state, then none. Inside each, priority by name
        int scopeRank(String s) {
          if (s == 'central') return 0;
          if (s == 'state') return 1;
          return 2;
        }
        int getPriority(String name) {
          if (name.contains('railway')) return 1;
          if (name.contains('ssc')) return 2;
          if (name.contains('psu')) return 3;
          return 100;
        }
        groups.sort((a, b) {
          int rA = scopeRank(a.scope);
          int rB = scopeRank(b.scope);
          if (rA != rB) return rA.compareTo(rB);
          String nameA = a.displayName.toLowerCase();
          String nameB = b.displayName.toLowerCase();
          int pA = getPriority(nameA);
          int pB = getPriority(nameB);
          if (pA != pB) return pA.compareTo(pB);
          return nameA.compareTo(nameB);
        });
        
        return groups;
      }
    }
    
    print('DEBUG: No category groups found in API response or error status: ${response.statusCode}');
    return [];
  } catch (e, stackTrace) {
    print('DEBUG: Error fetching category groups from API: $e');
    print(stackTrace);
    return [];
  }
}
