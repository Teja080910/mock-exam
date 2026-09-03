import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';

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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'result':
        return const Color(0xFF16A34A);
      case 'admit_card':
        return const Color(0xFFEAB308);
      case 'answer_key':
        return const Color(0xFF0EA5E9);
      case 'notification':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'result':
        return Icons.emoji_events_rounded;
      case 'admit_card':
        return Icons.badge_rounded;
      case 'answer_key':
        return Icons.key_rounded;
      case 'notification':
        return Icons.notifications_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'result':
        return 'Result';
      case 'admit_card':
        return 'Admit Card';
      case 'answer_key':
        return 'Answer Key';
      case 'notification':
        return 'Notification';
      default:
        return 'Other';
    }
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
              backIcon: false,
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
                                  size: 48, color: FlutterFlowTheme.of(context).black40),
                              const SizedBox(height: 12),
                              Text(_error!, style: FlutterFlowTheme.of(context).bodyMedium),
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
                                      size: 56, color: FlutterFlowTheme.of(context).black40),
                                  const SizedBox(height: 12),
                                  Text('No news available',
                                      style: FlutterFlowTheme.of(context).titleMedium),
                                  const SizedBox(height: 6),
                                  Text('Check back later for updates',
                                      style: FlutterFlowTheme.of(context).bodySmall),
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
                                padding: const EdgeInsets.all(16.0),
                                itemCount: _news.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14.0),
                                itemBuilder: (context, index) {
                                  final news = _news[index];
                                  final postType = news['post_type'] ?? 'notification';
                                  final title = news['title'] ?? '';
                                  final description = news['short_description'] ?? news['description'] ?? '';
                                  final link = news['link'] ?? '';
                                  final createdAt = news['createdAt'];

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: _getTypeColor(postType).withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0, vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: _getTypeColor(postType).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getTypeIcon(postType),
                                                      size: 12.0,
                                                      color: _getTypeColor(postType),
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      _getTypeLabel(postType),
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .copyWith(
                                                            color: _getTypeColor(postType),
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: FFFont.f11,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              if (createdAt != null)
                                                Text(
                                                  dateTimeFormat('relative',DateTime.parse(createdAt)),
                                                  style: FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .copyWith(fontSize: FFFont.f11),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            title,
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: FFFont.f16,
                                                  height: 1.3,
                                                ),
                                          ),
                                          if (description.toString().isNotEmpty) ...[
                                            const SizedBox(height: 8.0),
                                            Text(
                                              description,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .copyWith(
                                                    color: FlutterFlowTheme.of(context)
                                                        .primaryText
                                                        .withOpacity(0.7),
                                                    fontSize: FFFont.f14,
                                                    height: 1.5,
                                                  ),
                                            ),
                                          ],
                                          if (link.toString().isNotEmpty) ...[
                                            const SizedBox(height: 10.0),
                                            GestureDetector(
                                              onTap: () => launchURL(link),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.link_rounded,
                                                    size: 14.0,
                                                    color: _getTypeColor(postType),
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  Text(
                                                    'Visit Website',
                                                    style: FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .copyWith(
                                                          color: _getTypeColor(postType),
                                                          fontWeight: FontWeight.w600,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
