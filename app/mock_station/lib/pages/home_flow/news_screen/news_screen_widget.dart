import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
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
  final List<Map<String, String>> _news = const [
    {
      'title': 'UPSC Civil Services 2026 Notification Released',
      'category': 'Government Exams',
      'date': 'Aug 20, 2026',
      'read': '5 min read',
      'image': 'https://picsum.photos/seed/news1/400/300',
    },
    {
      'title': 'New Exam Pattern Announced for Banking Prelims',
      'category': 'Banking',
      'date': 'Aug 18, 2026',
      'read': '4 min read',
      'image': 'https://picsum.photos/seed/news2/400/300',
    },
    {
      'title': 'Railway Group D Application Window Opens',
      'category': 'Railways',
      'date': 'Aug 15, 2026',
      'read': '6 min read',
      'image': 'https://picsum.photos/seed/news3/400/300',
    },
    {
      'title': 'SSC CGL Tier 1 Admit Cards Released',
      'category': 'SSC',
      'date': 'Aug 12, 2026',
      'read': '3 min read',
      'image': 'https://picsum.photos/seed/news4/400/300',
    },
    {
      'title': 'State Police Constable Recruitment 2026',
      'category': 'State Exams',
      'date': 'Aug 10, 2026',
      'read': '7 min read',
      'image': 'https://picsum.photos/seed/news5/400/300',
    },
    {
      'title': 'Latest Updates on NIOS and School Board Exams',
      'category': 'Education',
      'date': 'Aug 08, 2026',
      'read': '2 min read',
      'image': 'https://picsum.photos/seed/news6/400/300',
    },
  ];

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
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _news.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  final news = _news[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          news['image']!,
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 150.0,
                            color: FlutterFlowTheme.of(context).lightGrey,
                            child: Icon(
                              Icons.newspaper_rounded,
                              size: 48.0,
                              color: FlutterFlowTheme.of(context).black40,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 3.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Text(
                                      news['category']!,
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .copyWith(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.0,
                                          ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.share_outlined,
                                    size: 18.0,
                                    color: FlutterFlowTheme.of(context).black40,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                news['title']!,
                                style:
                                    FlutterFlowTheme.of(context).titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                          height: 1.3,
                                        ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14.0,
                                    color: FlutterFlowTheme.of(context).black40,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    news['date']!,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .copyWith(fontSize: 12.0),
                                  ),
                                  const SizedBox(width: 14.0),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14.0,
                                    color: FlutterFlowTheme.of(context).black40,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    news['read']!,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .copyWith(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}