import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubcategoryDetailPageWidget extends StatefulWidget {
  const SubcategoryDetailPageWidget({
    Key? key,
    this.subcategoryId,
    this.subcategoryName,
  }) : super(key: key);

  final String? subcategoryId;
  final String? subcategoryName;

  static String routeName = 'subcategory_detail_page';
  static String routePath = '/subcategoryDetailPage';

  @override
  State<SubcategoryDetailPageWidget> createState() => _SubcategoryDetailPageWidgetState();
}

class _SubcategoryDetailPageWidgetState extends State<SubcategoryDetailPageWidget> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final subcategoryId = args != null ? args['subcategoryId'] : widget.subcategoryId;
    final subcategoryName = args != null ? args['subcategoryName'] : widget.subcategoryName;

    return Scaffold(
      appBar: AppBar(
        title: Text(subcategoryName ?? 'Subcategory'),
      ),
      body: FutureBuilder<ApiCallResponse>(
        future: QuizGroup.getQuizBySubcategoryCall.call(subcategoryId: subcategoryId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final quizzesList = QuizGroup.getQuizBySubcategoryCall.quizList(snapshot.data!.jsonBody) ?? [];
          // Sort quizzes by date and shift extracted from name
          final quizzes = quizzesList.toList();
          quizzes.sort((a, b) {
            String nameA = a['name'] ?? '';
            String nameB = b['name'] ?? '';
            
            DateTime? parseDate(String name) {
              final monthMap = {
                'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
                'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
                'january': 1, 'february': 2, 'march': 3, 'april': 4, 'may': 5, 'june': 6,
                'july': 7, 'august': 8, 'september': 9, 'october': 10, 'november': 11, 'december': 12
              };
              
              // Handle various formats like "28 Dec 2024", "28-Dec-2024", "28.Dec.2024"
              final regex = RegExp(r'(\d{1,2})[\s\-\.]*([a-zA-Z]+)[\s\-\.]*(\d{4})', caseSensitive: false);
              final match = regex.firstMatch(name);
              
              if (match != null) {
                final day = int.tryParse(match.group(1)!);
                final monthStr = match.group(2)!.toLowerCase();
                final year = int.tryParse(match.group(3)!);
                
                final month = monthMap[monthStr];
                
                if (day != null && month != null && year != null) {
                  return DateTime(year, month, day);
                }
              }
              return null;
            }

            int parseShift(String name) {
              final match = RegExp(r'\(Shift\s*(\d+)\)', caseSensitive: false).firstMatch(name);
              if (match != null) {
                return int.tryParse(match.group(1) ?? '0') ?? 0;
              }
              return 0;
            }

            DateTime? dateA = parseDate(nameA);
            DateTime? dateB = parseDate(nameB);

            if (dateA != null && dateB != null) {
              int dateComp = dateB.compareTo(dateA); // Newest first
              if (dateComp != 0) return dateComp;
            } else if (dateA != null) {
              return -1; // Move items with dates to top
            } else if (dateB != null) {
              return 1;
            }

            int shiftA = parseShift(nameA);
            int shiftB = parseShift(nameB);
            return shiftB.compareTo(shiftA); // Higher shift first
          });

          if (quizzes.isEmpty) {
            return Center(child: Text('No quizzes found for this subcategory.'));
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(width: 8),
                        //Text('.', style: TextStyle(color: Colors.grey[700])),
                        SizedBox(width: 8),
                        Text(
                          '${quiz['minutes_per_quiz'] ?? ''} mins',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(width: 8),
                       // Text('.', style: TextStyle(color: Colors.grey[700])),
                        SizedBox(width: 8),
                        Text(
                          '${quiz['minimum_required_points'] ?? 'N/A'} Marks',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(
                              'quiz_questions_screen',
                              queryParameters: {
                                'quizID': quiz['_id'],
                                'title': quiz['name'],
                                'image': '${FFAppConstants.imageBaseURL}${quiz['image']}',
                                'quizTime': quiz['minutes_per_quiz'].toString(),
                                'description': quiz['description'],
                              },
                            );
                          },
                          child: Text(
                            'Start Test',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'English, Hindi',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 