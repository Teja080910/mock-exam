import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'books_screen_model.dart';
export 'books_screen_model.dart';

class BooksScreenWidget extends StatefulWidget {
  const BooksScreenWidget({super.key});

  static String routeName = 'books_screen';
  static String routePath = '/booksScreen';

  @override
  State<BooksScreenWidget> createState() => _BooksScreenWidgetState();
}

class _BooksScreenWidgetState extends State<BooksScreenWidget> {
  late BooksScreenModel _model;
  late Future<ApiCallResponse> _ebooksFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BooksScreenModel());
    _ebooksFuture = GetAllEbooksCall().call(token: FFAppState().loginToken);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(
            title: 'Ebook',
            backIcon: true,
          ),
          Expanded(
            child: FutureBuilder<ApiCallResponse>(
              future: _ebooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.data?.jsonBody == null) {
                  return Center(
                    child:
                        Text('Could not load ebooks. Please try again later.'),
                  );
                }

                final ebooksResponse = snapshot.data!;
                final ebooks = GetAllEbooksCall()
                        .ebooksList(ebooksResponse.jsonBody)
                        ?.toList() ??
                    [];

                if (ebooks.isEmpty) {
                  return Center(
                    child: Text(
                      'No ebooks available at the moment.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  itemCount: ebooks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final ebook = ebooks[index];
                    final ebookName =
                        getJsonField(ebook, r'''$.name''').toString();
                    final ebookImage =
                        getJsonField(ebook, r'''$.image''').toString();
                    final ebookLink =
                        getJsonField(ebook, r'''$.link''').toString();
                    final imageUrl =
                        '${FFAppConstants.baseURL}/assets/userImages/$ebookImage';

                    return Material(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () async {
                          if (ebookLink.isNotEmpty) {
                            final Uri url = Uri.parse(ebookLink);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open the link.'),
                                ),
                              );
                            }
                          }
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 4.0,
                                  height: 58.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary,
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14.0, 12.0, 12.0, 12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 80.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80.0,
                                        height: 100.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        child: Center(
                                          child: SizedBox(
                                            width: 22.0,
                                            height: 22.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 80.0,
                                        height: 100.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        child: Icon(
                                          Icons.error_outline,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ebookName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Roboto',
                                                fontSize: FFFont.f16,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF10213F),
                                                lineHeight: 1.3,
                                                useGoogleFonts: false,
                                              ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Click to view ebooks',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Roboto',
                                                fontSize: FFFont.f14,
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .secondaryText,
                                                useGoogleFonts: false,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 24.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
