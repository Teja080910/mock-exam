import 'package:flutter/material.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/category_flow/group_detail_page/group_detail_page_widget.dart';
import '/pages/home_flow/all_group_list_page/all_group_list_page_widget.dart';
import '/pages/home_flow/search_screen/search_screen_widget.dart';
import '/index.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'home_screen_model.dart';

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
  Future<_HomeData>? _homeDataFuture;

  // Max groups shown per scope section before a "View All" button appears
  // (4 columns x 3 rows = 12 slots; last slot is View All)
  static const int _maxGroupsPerSection = 11;

  Future<_HomeData> _fetchHomeData() async {
    final results = await Future.wait([
      QuizGroup.getCarouselBannersCall.call(),
      fetchCategoryGroups(),
    ]);

    final bannerRes = results[0] as ApiCallResponse;
    final categoryGroups = results[1] as List<CategoryGroup>;

    final banners = QuizGroup.getCarouselBannersCall
            .bannersList(bannerRes.jsonBody)
            ?.toList() ??
        [];

    return _HomeData(
      banners: banners,
      categoryGroups: categoryGroups,
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeScreenModel());
    _homeDataFuture = _fetchHomeData();

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().isLogin &&
          FFAppState().loginToken.isNotEmpty &&
          FFAppState().userId.isNotEmpty) {
        // showReferralPromptOnce(context);
      }
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
          FFAppState().activePlanName =
              QuizGroup.fetchUserPlanCall.planName(planRes.jsonBody) ?? '';
          FFAppState().activePlanCode =
              QuizGroup.fetchUserPlanCall.planCode(planRes.jsonBody) ?? '';
          FFAppState().hasEbookAccess =
              QuizGroup.fetchUserPlanCall.hasEbookAccess(planRes.jsonBody) ?? false;
          FFAppState().hasNotesAccess =
              QuizGroup.fetchUserPlanCall.hasNotesAccess(planRes.jsonBody) ?? false;
          FFAppState().hasMockTestAccess =
              QuizGroup.fetchUserPlanCall.hasMockTestAccess(planRes.jsonBody) ?? false;
          final rawCodes = QuizGroup.fetchUserPlanCall.activePlanCodes(planRes.jsonBody);
          if (rawCodes is List) {
            FFAppState().activePlanCodes = rawCodes.map((c) => c.toString().toUpperCase()).toList();
          } else {
            FFAppState().activePlanCodes = [];
          }
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
          padding: const EdgeInsets.only(left: 16.0, top: 18.0, right: 16.0, bottom: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: FFFont.f16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              fontFamily: 'Roboto',
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.school_outlined, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text(
                      'No tests available currently',
                      style: TextStyle(fontSize: FFFont.f14, fontWeight: FontWeight.w500, color: Colors.grey.shade500, fontFamily: 'Roboto'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check back soon for new mock tests',
                      style: TextStyle(fontSize: FFFont.f12, color: Colors.grey.shade400, fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          _buildGroupGrid(context, title, groups),
      ],
    );
  }

  // Map of group names to their icons
  IconData _getGroupIcon(String groupName) {
    final name = groupName.toLowerCase();
    if (name.contains('railway') || name.contains('rrb')) return Icons.train;
    if (name.contains('ssc')) return Icons.assignment;
    if (name.contains('psu')) return Icons.business;
    if (name.contains('defence') || name.contains('defense')) return Icons.shield;
    if (name.contains('upsc')) return Icons.account_balance;
    if (name.contains('state') || name.contains('psc')) return Icons.location_city;
    if (name.contains('bank') || name.contains('ibps')) return Icons.account_balance_wallet;
    if (name.contains('engineering')) return Icons.engineering;
    return Icons.quiz;
  }

  Widget _buildGroupGrid(BuildContext context, String title, List<CategoryGroup> groups) {
    // Show up to 11 groups; a "View All" cell appears if there are more
    final hasMore = groups.length > _maxGroupsPerSection;
    final visibleGroups = hasMore
        ? groups.take(_maxGroupsPerSection).toList()
        : groups;

    // Add one slot for the "View All" button when there are more groups
    final itemCount = hasMore ? visibleGroups.length + 1 : visibleGroups.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 0,
              childAspectRatio: 1.2,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Last slot is the View All button (when more groups exist)
              if (hasMore && index == visibleGroups.length) {
                return _buildViewAllItem(context, title, groups);
              }
              final group = visibleGroups[index];
              return _buildGroupIconItem(context, group);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllItem(
      BuildContext context, String title, List<CategoryGroup> groups) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => AllGroupListPageWidget(
            sectionTitle: title,
            groups: groups,
          ),
        ));
      },
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupIconItem(BuildContext context, CategoryGroup group) {
    final hasImage = group.image.isNotEmpty;
    final imgUrl = hasImage
        ? (group.image.startsWith('http') ? group.image : '${FFAppConstants.imageBaseURL}${group.image}')
        : '';

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => GroupDetailPageWidget(
            groupName: group.displayName,
            groupId: group.id,
            categoriesJson: group.categories.map((c) => {
              '_id': c.id,
              'name': c.name,
              'displayName': c.displayName,
              'image': c.image,
            }).toList(),
          ),
        ));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasImage ? Colors.transparent : const Color(0xFFEEF3FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6E4FF), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        _getGroupIcon(group.displayName),
                        color: const Color(0xFF2563EB),
                        size: 22,
                      ),
                    )
                  : Icon(
                      _getGroupIcon(group.displayName),
                      color: const Color(0xFF2563EB),
                      size: 22,
                    ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                (group.code.isNotEmpty
                        ? group.code
                        : group.displayName
                            .replaceAll(
                                RegExp(r'\s*Mock\s*Test[s]?\s*',
                                    caseSensitive: false),
                                '')
                            .trim())
                    .toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: FFFont.f10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Roboto',
                  height: 1.2,
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
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12.0),
              child: Container(
                width: 48.0,
                height: 48.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5FF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreenWidget(),
                      ),
                    );
                  },
                  tooltip: 'Search',
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF2563EB),
                    size: 28.0,
                  ),
                ),
              ),
            ),
          ],
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
                  _homeDataFuture = _fetchHomeData();
                });
                await _homeDataFuture;
              },
              child: FutureBuilder<_HomeData>(
                future: _homeDataFuture ??= _fetchHomeData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Failed to load data', style: FlutterFlowTheme.of(context).bodyLarge),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _homeDataFuture = _fetchHomeData();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  final banners = data.banners;
                  final categoryGroups = data.categoryGroups;
                  final centralGroups = categoryGroups.where((g) => g.scope == 'central').toList();
                  final stateGroups = categoryGroups.where((g) => g.scope == 'state').toList();
                  final otherGroups = categoryGroups.where((g) => g.scope != 'central' && g.scope != 'state').toList();

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Banner Carousel
                      if (banners.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                            child: SizedBox(
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
                                          color: Colors.black.withValues(alpha: 0.2),
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
                            ),
                          ),
                        ),

                        // Carousel Dots Indicator
                        SliverToBoxAdapter(
                          child: Padding(
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
                                            .withValues(alpha: 0.3),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],

                      // Category Groups (Central wise + State wise + Other)
                      SliverToBoxAdapter(
                        child: categoryGroups.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(child: Text('No categories found')),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildScopeSection(context, 'Central Government Exam Mock Test', centralGroups),
                                  _buildScopeSection(context, 'State Wise Government Exam Mock Test', stateGroups),
                                  if (otherGroups.isNotEmpty) _buildScopeSection(context, 'Other', otherGroups),
                                ],
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
                                        fontSize: FFFont.f12,
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeData {
  final List<dynamic> banners;
  final List<CategoryGroup> categoryGroups;

  _HomeData({
    required this.banners,
    required this.categoryGroups,
  });
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
  final String code;
  final String image;
  final String scope;
  final List<Category> categories;
  CategoryGroup({
    required this.id,
    required this.displayName,
    required this.code,
    required this.image,
    required this.scope,
    required this.categories,
  });
  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
        id: json['_id'] ?? '',
        displayName: json['displayName'] ?? '',
        code: json['code'] ?? '',
        image: json['image'] ?? '',
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

        // Keep empty groups so the home screen can show "No tests available"

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
