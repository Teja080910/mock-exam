import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'test_paper_viewer_model.dart';
export 'test_paper_viewer_model.dart';

class TestPaperViewerWidget extends StatefulWidget {
  const TestPaperViewerWidget({
    super.key,
    required this.quizId,
    this.quiz,
  });

  final String quizId;
  final dynamic quiz;

  static String routeName = 'test_paper_viewer';
  static String routePath = '/testPaperViewer';

  @override
  State<TestPaperViewerWidget> createState() => _TestPaperViewerWidgetState();
}

class _TestPaperViewerWidgetState extends State<TestPaperViewerWidget>
    with SingleTickerProviderStateMixin {
  late TestPaperViewerModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';

  String _quizTitle = 'Mock Test Paper';
  String _subcategoryName = '';
  String _categoryName = '';
  int _totalQuestions = 0;
  String _timeMinutes = '60';
  num _rewardPerQ = 1;
  num _penaltyPerQ = 0;
  num _totalMarks = 100;

  List<Map<String, dynamic>> _questions = [];
  String _selectedLang = 'both'; // 'both', 'en', 'hi'

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TestPaperViewerModel());
    _tabController = TabController(length: 3, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _cleanHtml(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'<p><br\s*/?></p>'), '').trim();
  }

  String _stripTags(String s) {
    return s.replaceAll(RegExp(r'<[^>]*>'), '').trim().toLowerCase();
  }

  String _extractBiText(dynamic node, String lang) {
    if (node == null) return '';
    if (node is String) return lang == 'en' ? node : '';
    if (node is Map) {
      final val = node[lang];
      return val != null ? val.toString() : '';
    }
    return '';
  }

  String _formatImgUrl(String? img) {
    if (img == null || img.trim().isEmpty) return '';
    final clean = img.trim();
    if (clean.startsWith('http://') ||
        clean.startsWith('https://') ||
        clean.startsWith('data:')) {
      return clean;
    }
    if (clean.startsWith('/')) {
      return '${FFAppConstants.baseURL.replaceAll(RegExp(r'/+$'), '')}$clean';
    }
    return '${FFAppConstants.baseURL.replaceAll(RegExp(r'/+$'), '')}/assets/userImages/$clean';
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res =
          await GetquestionsbyquizidApiCall().call(quizId: widget.quizId);
      if (!res.succeeded) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load test questions.';
        });
        return;
      }

      final body = res.jsonBody;
      final rawList = getJsonField(body, r'''$.data.questionsDetails''');

      if (rawList == null || !(rawList is List) || rawList.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Questions for this mock test are currently being prepared.';
        });
        return;
      }

      _quizTitle = (getJsonField(widget.quiz, r'''$.name''') ??
              getJsonField(rawList.first, r'''$.quizId.name''') ??
              'Mock Test Paper')
          .toString();

      _categoryName =
          (getJsonField(widget.quiz, r'''$.categoryName''') ?? '').toString();
      _subcategoryName =
          (getJsonField(widget.quiz, r'''$.subcategoryName''') ??
                  getJsonField(rawList.first, r'''$.subcategoryName''') ??
                  '')
              .toString();

      _totalQuestions = rawList.length;
      _timeMinutes = (getJsonField(widget.quiz, r'''$.minutes_per_quiz''') ??
              getJsonField(
                  rawList.first, r'''$.quizId.minutes_per_quiz''') ??
              (_totalQuestions > 0 ? _totalQuestions : 60))
          .toString();

      _rewardPerQ = (num.tryParse(
              (getJsonField(widget.quiz,
                          r'''$.correct_ans_reward_per_question''') ??
                      getJsonField(rawList.first,
                          r'''$.quizId.correct_ans_reward_per_question''') ??
                      1)
                  .toString()) ??
          1);

      _penaltyPerQ = (num.tryParse((getJsonField(
                      widget.quiz, r'''$.penalty_per_question''') ??
                  getJsonField(
                      rawList.first, r'''$.quizId.penalty_per_question''') ??
                  0)
              .toString()) ??
          0);

      _totalMarks = _totalQuestions * _rewardPerQ;

      final List<Map<String, dynamic>> parsedQuestions = [];

      for (int i = 0; i < rawList.length; i++) {
        final q = rawList[i];
        final qNum = i + 1;

        final titleEn = _cleanHtml(
            _extractBiText(getJsonField(q, r'''$.question_title'''), 'en'));
        final titleHi = _cleanHtml(
            _extractBiText(getJsonField(q, r'''$.question_title'''), 'hi'));

        final subject = (getJsonField(q, r'''$.subject''') ?? '').toString();
        final image = (getJsonField(q, r'''$.image''') ?? '').toString();

        final optAEn = _extractBiText(
            getJsonField(q, r'''$.option.a.text'''), 'en');
        final optAHi = _extractBiText(
            getJsonField(q, r'''$.option.a.text'''), 'hi');
        final optAImg =
            (getJsonField(q, r'''$.option.a.image''') ?? '').toString();

        final optBEn = _extractBiText(
            getJsonField(q, r'''$.option.b.text'''), 'en');
        final optBHi = _extractBiText(
            getJsonField(q, r'''$.option.b.text'''), 'hi');
        final optBImg =
            (getJsonField(q, r'''$.option.b.image''') ?? '').toString();

        final optCEn = _extractBiText(
            getJsonField(q, r'''$.option.c.text'''), 'en');
        final optCHi = _extractBiText(
            getJsonField(q, r'''$.option.c.text'''), 'hi');
        final optCImg =
            (getJsonField(q, r'''$.option.c.image''') ?? '').toString();

        final optDEn = _extractBiText(
            getJsonField(q, r'''$.option.d.text'''), 'en');
        final optDHi = _extractBiText(
            getJsonField(q, r'''$.option.d.text'''), 'hi');
        final optDImg =
            (getJsonField(q, r'''$.option.d.image''') ?? '').toString();

        final ansEn =
            _extractBiText(getJsonField(q, r'''$.answer'''), 'en').trim();
        final ansHi =
            _extractBiText(getJsonField(q, r'''$.answer'''), 'hi').trim();

        String correctOption = 'A';
        final ansLowerEn = ansEn.toLowerCase();
        final ansLowerHi = ansHi.toLowerCase();

        if (ansLowerEn == 'a' ||
            ansLowerHi == 'a' ||
            ansLowerEn == '1' ||
            ansLowerHi == '1') {
          correctOption = 'A';
        } else if (ansLowerEn == 'b' ||
            ansLowerHi == 'b' ||
            ansLowerEn == '2' ||
            ansLowerHi == '2') {
          correctOption = 'B';
        } else if (ansLowerEn == 'c' ||
            ansLowerHi == 'c' ||
            ansLowerEn == '3' ||
            ansLowerHi == '3') {
          correctOption = 'C';
        } else if (ansLowerEn == 'd' ||
            ansLowerHi == 'd' ||
            ansLowerEn == '4' ||
            ansLowerHi == '4') {
          correctOption = 'D';
        } else {
          final cleanAnsEn = _stripTags(ansEn);
          final cleanAnsHi = _stripTags(ansHi);

          bool checkMatch(String en, String hi) {
            final cEn = _stripTags(en);
            final cHi = _stripTags(hi);
            if (cleanAnsEn.isNotEmpty && cEn.isNotEmpty && cleanAnsEn == cEn) {
              return true;
            }
            if (cleanAnsHi.isNotEmpty && cHi.isNotEmpty && cleanAnsHi == cHi) {
              return true;
            }
            if (cleanAnsHi.isNotEmpty && cEn.isNotEmpty && cleanAnsHi == cEn) {
              return true;
            }
            if (cleanAnsEn.isNotEmpty && cHi.isNotEmpty && cleanAnsEn == cHi) {
              return true;
            }
            return false;
          }

          if (checkMatch(optAEn, optAHi)) {
            correctOption = 'A';
          } else if (checkMatch(optBEn, optBHi)) {
            correctOption = 'B';
          } else if (checkMatch(optCEn, optCHi)) {
            correctOption = 'C';
          } else if (checkMatch(optDEn, optDHi)) {
            correctOption = 'D';
          } else {
            correctOption =
                ansEn.isNotEmpty ? ansEn : (ansHi.isNotEmpty ? ansHi : '-');
          }
        }

        final descEn = _cleanHtml(
            _extractBiText(getJsonField(q, r'''$.description'''), 'en'));
        final descHi = _cleanHtml(
            _extractBiText(getJsonField(q, r'''$.description'''), 'hi'));

        parsedQuestions.add({
          'number': qNum,
          'subject': subject,
          'titleEn': titleEn,
          'titleHi': titleHi,
          'image': image,
          'optAEn': optAEn,
          'optAHi': optAHi,
          'optAImg': optAImg,
          'optBEn': optBEn,
          'optBHi': optBHi,
          'optBImg': optBImg,
          'optCEn': optCEn,
          'optCHi': optCHi,
          'optCImg': optCImg,
          'optDEn': optDEn,
          'optDHi': optDHi,
          'optDImg': optDImg,
          'correctOption': correctOption,
          'descEn': descEn,
          'descHi': descHi,
        });
      }

      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading test paper: $e';
      });
    }
  }

  Future<void> _shareOrExportHtml() async {
    if (_questions.isEmpty) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final safeName = _quizTitle
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
          .toLowerCase();
      final file = File('${tempDir.path}/${safeName}_${widget.quizId}.html');

      // Generate HTML string for offline viewing & printing
      final html = _buildHtmlFileContent();
      await file.writeAsString(html, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$_quizTitle Question Paper - Mock Station',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share test paper: $e')),
        );
      }
    }
  }

  String _buildHtmlFileContent() {
    final StringBuffer qBuf = StringBuffer();
    for (final q in _questions) {
      String opt(String letter, String en, String hi, String img) {
        if (en.isEmpty && hi.isEmpty && img.isEmpty) return '';
        return '<div style="margin-bottom:6px;"><strong>($letter)</strong> ${hi.isNotEmpty ? hi : en}</div>';
      }

      qBuf.write('''
        <div style="border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:12px; background:#fff;">
          <div style="font-weight:700; color:#1d6fff; margin-bottom:6px;">Question ${q['number']} ${q['subject'].toString().isNotEmpty ? '(${q['subject']})' : ''}</div>
          <div style="margin-bottom:8px;">${q['titleHi'].toString().isNotEmpty ? q['titleHi'] : q['titleEn']}</div>
          ${q['image'].toString().isNotEmpty ? '<img src="${_formatImgUrl(q['image'])}" style="max-width:100%; border-radius:4px; margin-bottom:8px;" />' : ''}
          <div style="padding-left:8px;">
            ${opt('A', q['optAEn'], q['optAHi'], q['optAImg'])}
            ${opt('B', q['optBEn'], q['optBHi'], q['optBImg'])}
            ${opt('C', q['optCEn'], q['optCHi'], q['optCImg'])}
            ${opt('D', q['optDEn'], q['optDHi'], q['optDImg'])}
          </div>
        </div>
      ''');
    }

    final StringBuffer ansKeyBuf = StringBuffer();
    ansKeyBuf.write('<table border="1" cellpadding="6" style="border-collapse:collapse; width:100%; text-align:center; font-size:13px; margin-bottom:20px;"><tr>');
    for (int c = 1; c <= 10; c++) {
      ansKeyBuf.write('<th>Q</th><th>Ans</th>');
    }
    ansKeyBuf.write('</tr>');
    for (int i = 0; i < _questions.length; i += 10) {
      ansKeyBuf.write('<tr>');
      final chunk = _questions.skip(i).take(10).toList();
      for (int c = 0; c < 10; c++) {
        if (c < chunk.length) {
          final item = chunk[c];
          ansKeyBuf.write('<td>${item['number']}</td><td><strong>${item['correctOption']}</strong></td>');
        } else {
          ansKeyBuf.write('<td>-</td><td>-</td>');
        }
      }
      ansKeyBuf.write('</tr>');
    }
    ansKeyBuf.write('</table>');

    final StringBuffer solBuf = StringBuffer();
    for (final q in _questions) {
      solBuf.write('''
        <div style="border:1px solid #e2e8f0; border-radius:8px; padding:12px; margin-bottom:10px; background:#fff;">
          <div style="font-weight:700; margin-bottom:4px;">Q. ${q['number']} &mdash; <span style="color:#16a34a;">Correct Option: (${q['correctOption']})</span></div>
          <div style="font-size:13px; color:#334155;">${q['descHi'].toString().isNotEmpty ? q['descHi'] : (q['descEn'].toString().isNotEmpty ? q['descEn'] : 'Correct answer: Option (' + q['correctOption'] + ')')}</div>
        </div>
      ''');
    }

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$_quizTitle - Mock Station Paper</title>
  <style>
    body { font-family: -apple-system, sans-serif; background: #f8fafc; color: #1e293b; padding: 20px; line-height: 1.6; }
    .header { text-align: center; background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 20px; }
    @media print { .no-print { display: none; } body { background: #fff; padding: 0; } }
  </style>
</head>
<body>
  <div class="no-print" style="text-align:right; margin-bottom:12px;">
    <button onclick="window.print()" style="background:#1d6fff; color:#fff; border:none; padding:8px 16px; border-radius:6px; font-weight:700; cursor:pointer;">Print / Save PDF</button>
  </div>
  <div class="header">
    <h2 style="margin:0 0 6px 0;">$_quizTitle</h2>
    <div style="color:#64748b; font-size:14px;">Total Questions: $_totalQuestions | Time: $_timeMinutes Mins | Max Marks: $_totalMarks | Marking: +$_rewardPerQ / -$_penaltyPerQ</div>
  </div>
  <h3>QUESTIONS</h3>
  $qBuf
  <h3 style="margin-top:30px;">ANSWER KEY</h3>
  $ansKeyBuf
  <h3 style="margin-top:30px;">SOLUTIONS & EXPLANATIONS</h3>
  $solBuf
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TEST QUESTION PAPER',
              style: TextStyle(
                color: Color(0xFF1D6FFF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              _quizTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher Dropdown
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBED5FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLang == 'both'
                        ? 'दोनों'
                        : (_selectedLang == 'hi' ? 'हिन्दी' : 'EN'),
                    style: const TextStyle(
                      color: Color(0xFF1D6FFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF1D6FFF), size: 16),
                ],
              ),
            ),
            onSelected: (val) => setState(() => _selectedLang = val),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'both',
                child: Text('Both (हिन्दी / English)'),
              ),
              const PopupMenuItem(
                value: 'hi',
                child: Text('हिन्दी (Hindi only)'),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Text('English (English only)'),
              ),
            ],
          ),
          // Share / Export button
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: Color(0xFF1D6FFF), size: 20),
            tooltip: 'Share / Save Question Paper',
            onPressed: _shareOrExportHtml,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1D6FFF),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF1D6FFF),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Questions (${_questions.length})'),
            const Tab(text: 'Answer Key'),
            const Tab(text: 'Solutions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1D6FFF)),
                  SizedBox(height: 16),
                  Text(
                    'Preparing Test Question Paper...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D6FFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _loadQuestions,
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuestionsTab(),
                    _buildAnswerKeyTab(),
                    _buildSolutionsTab(),
                  ],
                ),
    );
  }

  Widget _buildQuestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: _questions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeaderMetaCard();
        }
        final q = _questions[index - 1];
        return _buildQuestionCard(q);
      },
    );
  }

  Widget _buildHeaderMetaCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_subcategoryName.isNotEmpty || _categoryName.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _categoryName.isNotEmpty && _subcategoryName.isNotEmpty
                    ? '$_categoryName • $_subcategoryName'
                    : (_subcategoryName.isNotEmpty ? _subcategoryName : _categoryName),
                style: const TextStyle(
                  color: Color(0xFF1D6FFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            _quizTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetaPill(
                  'Questions', '$_totalQuestions', Icons.help_outline),
              const SizedBox(width: 8),
              _buildMetaPill('Time', '$_timeMinutes Mins', Icons.timer_outlined),
              const SizedBox(width: 8),
              _buildMetaPill('Max Marks', '$_totalMarks', Icons.emoji_events_outlined),
              const SizedBox(width: 8),
              _buildMetaPill('Scheme', '+$_rewardPerQ / -$_penaltyPerQ',
                  Icons.calculate_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE047)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF854D0E), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All questions are compulsory. Each question has 4 options with only one correct choice. Answer key & solutions are available in other tabs.',
                    style: TextStyle(
                      color: Color(0xFF713F12),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                textBaseline: TextBaseline.alphabetic,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final titleHi = (q['titleHi'] as String?) ?? '';
    final titleEn = (q['titleEn'] as String?) ?? '';
    final subject = (q['subject'] as String?) ?? '';
    final image = (q['image'] as String?) ?? '';

    final showHi =
        (_selectedLang == 'both' || _selectedLang == 'hi') && titleHi.isNotEmpty;
    final showEn =
        (_selectedLang == 'both' || _selectedLang == 'en') && titleEn.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q. ${q['number']}',
                  style: const TextStyle(
                    color: Color(0xFF1D6FFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                children: [
                  if (subject.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '+$_rewardPerQ / -$_penaltyPerQ',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Titles (Bilingual)
          if (showHi)
            Html(
              data: titleHi,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14.5),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),
          if (showHi && showEn) const SizedBox(height: 6),
          if (showEn)
            Html(
              data: titleEn,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),

          // Question Image
          if (image.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _formatImgUrl(image),
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  height: 120,
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Options List
          _buildOptionTile('A', q['optAEn'], q['optAHi'], q['optAImg']),
          _buildOptionTile('B', q['optBEn'], q['optBHi'], q['optBImg']),
          _buildOptionTile('C', q['optCEn'], q['optCHi'], q['optCImg']),
          _buildOptionTile('D', q['optDEn'], q['optDHi'], q['optDImg']),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String letter, dynamic en, dynamic hi, dynamic img) {
    final textEn = (en as String?) ?? '';
    final textHi = (hi as String?) ?? '';
    final imgUrl = (img as String?) ?? '';

    if (textEn.isEmpty && textHi.isEmpty && imgUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final showHi =
        (_selectedLang == 'both' || _selectedLang == 'hi') && textHi.isNotEmpty;
    final showEn =
        (_selectedLang == 'both' || _selectedLang == 'en') && textEn.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHi)
                  Text(
                    textHi,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                if (showHi && showEn) const SizedBox(height: 2),
                if (showEn)
                  Text(
                    textEn,
                    style: TextStyle(
                      color: showHi
                          ? const Color(0xFF64748B)
                          : const Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                if (imgUrl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: _formatImgUrl(imgUrl),
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        height: 60,
                        color: const Color(0xFFF1F5F9),
                      ),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerKeyTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ANSWER KEY (उत्तर कुंजी)',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.checklist_rounded,
                      color: Color(0xFF1D6FFF), size: 20),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Quick reference of correct options for all questions.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Q.${q['number']}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${q['correctOption']}',
                          style: const TextStyle(
                            color: Color(0xFF1D6FFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final q = _questions[index];
        final descHi = (q['descHi'] as String?) ?? '';
        final descEn = (q['descEn'] as String?) ?? '';

        final showHi = (_selectedLang == 'both' || _selectedLang == 'hi') &&
            descHi.isNotEmpty;
        final showEn = (_selectedLang == 'both' || _selectedLang == 'en') &&
            descEn.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q. ${q['number']} Solution',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF16A34A), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Option (${q['correctOption']})',
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (showHi)
                Html(
                  data: descHi,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(13),
                      color: const Color(0xFF334155),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                ),
              if (showHi && showEn) const SizedBox(height: 6),
              if (showEn)
                Html(
                  data: descEn,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(13),
                      color: const Color(0xFF475569),
                      lineHeight: const LineHeight(1.5),
                    ),
                  },
                ),
              if (!showHi && !showEn)
                Text(
                  'Option (${q['correctOption']}) is the correct answer.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
