import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NewsScreenWidget extends StatefulWidget {
  const NewsScreenWidget({super.key});

  static String routeName = 'news_screen';
  static String routePath = '/newsScreen';

  @override
  State<NewsScreenWidget> createState() => _NewsScreenWidgetState();
}

class _NewsScreenWidgetState extends State<NewsScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await QuizGroup.getAllNewsApiCall.call();
      if (response.succeeded) {
        final body = response.jsonBody;
        final data = body is Map ? (body['data'] ?? body) : body;
        setState(() {
          _news = (data is Map && data['news'] is List) ? data['news'] : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load news';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong';
        _isLoading = false;
      });
    }
  }

  String _getCategoryLabel(String category, String postType) {
    if (category.toString().isNotEmpty) return category;
    switch (postType) {
      case 'result':
        return 'Result';
      case 'admit_card':
        return 'Admit Card';
      case 'answer_key':
        return 'Answer Key';
      case 'notification':
        return 'Notification';
      default:
        return 'General';
    }
  }

  Color _getCategoryColor(String category, String postType) {
    final label = _getCategoryLabel(category, postType).toLowerCase();
    if (label.contains('government') || label.contains('upsc') || label.contains('ssc')) {
      return const Color(0xFF2563EB);
    }
    if (label.contains('banking') || label.contains('bank')) {
      return const Color(0xFF2563EB);
    }
    if (label.contains('railway')) {
      return const Color(0xFF16A34A);
    }
    if (label.contains('result')) {
      return const Color(0xFF16A34A);
    }
    if (label.contains('admit')) {
      return const Color(0xFFEAB308);
    }
    if (label.contains('answer')) {
      return const Color(0xFF0EA5E9);
    }
    return const Color(0xFF6B7280);
  }

  int _calculateReadTime(String description) {
    final words = description.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  void _openNewsDetail(Map<String, dynamic> news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreenWidget(news: news),
      ),
    );
  }

  void _shareNews(Map<String, dynamic> news) {
    final title = news['title'] ?? '';
    final link = news['link'] ?? '';
    final text = '$title${link.toString().isNotEmpty ? '\n$link' : ''}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            AppBarWidget(
              title: 'News',
              backIcon: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48,
                                  color: FlutterFlowTheme.of(context).black40),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _error = null;
                                  });
                                  _fetchNews();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _news.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.newspaper_rounded,
                                      size: 56,
                                      color: FlutterFlowTheme.of(context)
                                          .black40),
                                  const SizedBox(height: 12),
                                  Text('No news available',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium),
                                  const SizedBox(height: 6),
                                  Text('Check back later for updates',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await _fetchNews();
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                itemCount: _news.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final news = _news[index];
                                  final title = news['title'] ?? '';
                                  final description =
                                      news['short_description'] ??
                                          news['description'] ??
                                          '';
                                  final image = news['image'] ?? '';
                                  final category = news['category'] ?? '';
                                  final postType =
                                      news['post_type'] ?? 'notification';
                                  final link = news['link'] ?? '';
                                  final createdAt = news['createdAt'];
                                  final readTime =
                                      _calculateReadTime(description);

                                  return GestureDetector(
                                    onTap: () => _openNewsDetail(news),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.06),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (image.toString().isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          16.0)),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '${FFAppConstants.imageBaseURL}$image',
                                                width: double.infinity,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: double.infinity,
                                                  height: 150,
                                                  color: const Color(
                                                      0xFFF0F5FF),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Container(
                                                  width: double.infinity,
                                                  height: 150,
                                                  color: const Color(
                                                      0xFFF0F5FF),
                                                  child: Icon(
                                                    Icons
                                                        .newspaper_rounded,
                                                    size: 48,
                                                    color: Colors
                                                        .grey.shade300,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: double.infinity,
                                              height: 150,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF0F5FF),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius
                                                            .circular(
                                                                16.0)),
                                              ),
                                              child: Icon(
                                                Icons.newspaper_rounded,
                                                size: 48,
                                                color:
                                                    Colors.grey.shade300,
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(
                                                14.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 4.0,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color:
                                                            _getCategoryColor(
                                                                    category,
                                                                    postType)
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    6.0),
                                                      ),
                                                      child: Text(
                                                        _getCategoryLabel(
                                                            category,
                                                            postType),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .copyWith(
                                                                  color: _getCategoryColor(
                                                                      category,
                                                                      postType),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      FFFont
                                                                          .f12,
                                                                ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _shareNews(
                                                              news),
                                                      child: Icon(
                                                        Icons
                                                            .share_outlined,
                                                        size: 20,
                                                        color: Colors
                                                            .grey.shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height: 10.0),
                                                Text(
                                                  title,
                                                  style: FlutterFlowTheme
                                                          .of(context)
                                                      .titleLarge
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                        fontSize:
                                                            FFFont.f18,
                                                        height: 1.3,
                                                      ),
                                                ),
                                                const SizedBox(
                                                    height: 8.0),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 14,
                                                      color: Colors
                                                          .grey.shade500,
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      createdAt != null
                                                          ? dateTimeFormat(
                                                              'd/M/y',
                                                              DateTime
                                                                  .parse(
                                                                      createdAt))
                                                          : '',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .copyWith(
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                            fontSize:
                                                                FFFont.f12,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                        width: 16),
                                                    Icon(
                                                      Icons
                                                          .access_time_rounded,
                                                      size: 14,
                                                      color: Colors
                                                          .grey.shade500,
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      '$readTime min read',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .copyWith(
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                            fontSize:
                                                                FFFont.f12,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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

class NewsDetailScreenWidget extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreenWidget({super.key, required this.news});

  String _getCategoryLabel(String category, String postType) {
    if (category.toString().isNotEmpty) return category;
    switch (postType) {
      case 'result':
        return 'Result';
      case 'admit_card':
        return 'Admit Card';
      case 'answer_key':
        return 'Answer Key';
      case 'notification':
        return 'Notification';
      default:
        return 'General';
    }
  }

  Color _getCategoryColor(String category, String postType) {
    final label = _getCategoryLabel(category, postType).toLowerCase();
    if (label.contains('government') ||
        label.contains('upsc') ||
        label.contains('ssc')) {
      return const Color(0xFF2563EB);
    }
    if (label.contains('banking') || label.contains('bank')) {
      return const Color(0xFF2563EB);
    }
    if (label.contains('railway')) {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final title = news['title'] ?? '';
    final description =
        news['short_description'] ?? news['description'] ?? '';
    final image = news['image'] ?? '';
    final category = news['category'] ?? '';
    final postType = news['post_type'] ?? 'notification';
    final link = news['link'] ?? '';
    final createdAt = news['createdAt'];
    final fullDescription =
        news['description'] ?? news['short_description'] ?? '';

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(
            title: 'News',
            backIcon: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image.toString().isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: '${FFAppConstants.imageBaseURL}$image',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        color: const Color(0xFFF0F5FF),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        color: const Color(0xFFF0F5FF),
                        child: Icon(Icons.newspaper_rounded,
                            size: 48, color: Colors.grey.shade300),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(category, postType)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                _getCategoryLabel(category, postType),
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .copyWith(
                                      color: _getCategoryColor(
                                          category, postType),
                                      fontWeight: FontWeight.w600,
                                      fontSize: FFFont.f12,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            if (link.toString().isNotEmpty)
                              GestureDetector(
                                onTap: () => launchURL(link),
                                child: Icon(
                                  Icons.open_in_new_rounded,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          title,
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: FFFont.f22,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              createdAt != null
                                  ? dateTimeFormat(
                                      'd/M/y', DateTime.parse(createdAt))
                                  : '',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .copyWith(
                                    color: Colors.grey.shade500,
                                    fontSize: FFFont.f12,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        if (fullDescription.toString().isNotEmpty)
                          Text(
                            fullDescription,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .copyWith(
                                  fontSize: FFFont.f14,
                                  height: 1.6,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText
                                      .withOpacity(0.85),
                                ),
                          ),
                        if (link.toString().isNotEmpty) ...[
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => launchURL(link),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Visit Website',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20.0),
                      ],
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
