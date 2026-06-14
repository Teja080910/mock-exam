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
            title: 'Books',
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
                        Text('Could not load books. Please try again later.'),
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
                      'No books available at the moment.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: ebooks.length,
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

                    return Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  ebookName,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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