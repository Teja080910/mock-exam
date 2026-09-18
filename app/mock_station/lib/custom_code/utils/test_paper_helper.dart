import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TestPaperHelper {
  static final Set<String> _activeDownloads = {};

  static bool isDownloading(String quizId) => _activeDownloads.contains(quizId);

  static Future<void> downloadOrOpenTestPaper(
    BuildContext context,
    dynamic quiz,
  ) async {
    final quizId = (getJsonField(quiz, r'''$._id''') ??
            getJsonField(quiz, r'''$.id''') ??
            '')
        .toString()
        .trim();

    if (quizId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test information is not available.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (_activeDownloads.contains(quizId)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download is already in progress...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // Show "Select your PDF language" modal bottom sheet
    final String? chosenLang = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        String selectedLang = 'en';
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag pill
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    const Text(
                      'Select your PDF language',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // English Option Card
                    _buildLanguageCard(
                      title: 'English',
                      badgeChar: 'A',
                      badgeBg: const Color(0xFFF3E8FF),
                      badgeTextColor: const Color(0xFF9333EA),
                      isSelected: selectedLang == 'en',
                      onTap: () {
                        setState(() {
                          selectedLang = 'en';
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Hindi Option Card
                    _buildLanguageCard(
                      title: 'Hindi',
                      badgeChar: 'अ',
                      badgeBg: const Color(0xFFFFEDD5),
                      badgeTextColor: const Color(0xFFEA580C),
                      isSelected: selectedLang == 'hi',
                      onTap: () {
                        setState(() {
                          selectedLang = 'hi';
                        });
                      },
                    ),
                    const SizedBox(height: 26),

                    // Download PDF Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx, selectedLang);
                        },
                        child: const Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );

    if (chosenLang == null || !context.mounted) return;

    await _executeDownload(context, quiz, quizId, chosenLang);
  }

  /// Downloads a remote PDF (e.g. an ebook link) and saves it to the device
  /// using the same save + open flow as test papers.
  static Future<void> downloadPdfFromUrl(
    BuildContext context,
    String url, {
    String? title,
  }) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    final targetUrl = _resolveRemoteUrl(trimmedUrl);
    final rawName =
        (title != null && title.trim().isNotEmpty) ? title.trim() : 'Ebook';
    final safeName = _sanitizeFileName(rawName);
    final downloadKey = 'url:$safeName';

    if (_activeDownloads.contains(downloadKey)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download is already in progress...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }
    _activeDownloads.add(downloadKey);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Downloading $rawName PDF...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      final res = await http
          .get(Uri.parse(targetUrl))
          .timeout(const Duration(seconds: 90));

      if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
        throw Exception('Server returned ${res.statusCode}');
      }

      final bytes = res.bodyBytes;
      final isPdf = bytes.length >= 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;
      if (!isPdf) {
        throw Exception('The link does not point to a valid PDF file');
      }

      final savedFile = await _savePdfToDevice(safeName, bytes);
      _activeDownloads.remove(downloadKey);

      if (context.mounted) {
        _showDownloadedSnackBar(
          context,
          savedFile: savedFile,
          safeName: safeName,
          displayName: rawName,
        );
      }
    } catch (e) {
      _activeDownloads.remove(downloadKey);
      debugPrint('PDF download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Download failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Widget _buildLanguageCard({
    required String title,
    required String badgeChar,
    required Color badgeBg,
    required Color badgeTextColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeChar,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _executeDownload(
    BuildContext context,
    dynamic quiz,
    String quizId,
    String language,
  ) async {
    _activeDownloads.add(quizId);

    final rawQuizName = (getJsonField(quiz, r'''$.name''') ?? 'Mock_Test').toString();
    final langSuffix = language == 'hi' ? 'Hindi' : 'English';
    final safeName = '${rawQuizName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').replaceAll(RegExp(r'_+'), '_')}_$langSuffix';

    // Notify user that download / generation has started
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Generating $rawQuizName ($langSuffix) PDF...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      List<int> pdfBytes = [];

      final staticPdf = (getJsonField(quiz, r'''$.pdf''') ??
              getJsonField(quiz, r'''$.pdf_url''') ??
              getJsonField(quiz, r'''$.file''') ??
              getJsonField(quiz, r'''$.link''') ??
              '')
          .toString()
          .trim();

      // 1. If static PDF is attached, download it
      if (staticPdf.isNotEmpty && staticPdf != 'null' && staticPdf.toLowerCase().endsWith('.pdf')) {
        final targetUrl = staticPdf.startsWith('http')
            ? staticPdf
            : (FFAppConstants.baseURL.endsWith('/')
                ? '${FFAppConstants.baseURL}$staticPdf'
                : '${FFAppConstants.baseURL}/$staticPdf');

        final res = await http.get(Uri.parse(targetUrl));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          pdfBytes = res.bodyBytes;
        }
      }

      // 2. If no static PDF bytes, generate complete PDF dynamically from questions API
      if (pdfBytes.isEmpty) {
        final apiRes = await GetquestionsbyquizidApiCall().call(quizId: quizId);
        if (!apiRes.succeeded) {
          throw Exception('Failed to fetch quiz questions');
        }

        final body = apiRes.jsonBody;
        final rawList = getJsonField(body, r'''$.data.questionsDetails''');

        if (rawList == null || !(rawList is List) || rawList.isEmpty) {
          throw Exception('Questions for this mock test are not available yet');
        }

        final subcategoryName = (getJsonField(quiz, r'''$.subcategoryName''') ??
                getJsonField(rawList.first, r'''$.subcategoryName''') ??
                '')
            .toString();

        final totalQuestions = rawList.length;
        final timeMinutes = (getJsonField(quiz, r'''$.minutes_per_quiz''') ??
                getJsonField(rawList.first, r'''$.quizId.minutes_per_quiz''') ??
                (totalQuestions > 0 ? totalQuestions : 60))
            .toString();

        final rewardPerQ = num.tryParse((getJsonField(quiz, r'''$.correct_ans_reward_per_question''') ??
                getJsonField(rawList.first, r'''$.quizId.correct_ans_reward_per_question''') ??
                1)
            .toString()) ?? 1;

        final penaltyPerQ = num.tryParse((getJsonField(quiz, r'''$.penalty_per_question''') ??
                getJsonField(rawList.first, r'''$.quizId.penalty_per_question''') ??
                0)
            .toString()) ?? 0;

        final totalMarks = totalQuestions * rewardPerQ;

        final List<Map<String, dynamic>> parsedQuestions = [];
        for (int i = 0; i < rawList.length; i++) {
          final q = rawList[i];
          final qNum = i + 1;

          final titleEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.question_title'''), 'en'));
          final titleHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.question_title'''), 'hi'));
          final subject = (getJsonField(q, r'''$.subject''') ?? '').toString();

          final optAEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.a.text'''), 'en'));
          final optAHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.a.text'''), 'hi'));
          final optBEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.b.text'''), 'en'));
          final optBHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.b.text'''), 'hi'));
          final optCEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.c.text'''), 'en'));
          final optCHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.c.text'''), 'hi'));
          final optDEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.d.text'''), 'en'));
          final optDHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.option.d.text'''), 'hi'));

          final ansEn = _extractBiText(getJsonField(q, r'''$.answer'''), 'en').trim();
          final ansHi = _extractBiText(getJsonField(q, r'''$.answer'''), 'hi').trim();

          String correctOption = 'A';
          final ansLowerEn = ansEn.toLowerCase();
          final ansLowerHi = ansHi.toLowerCase();

          if (ansLowerEn == 'a' || ansLowerHi == 'a' || ansLowerEn == '1' || ansLowerHi == '1') {
            correctOption = 'A';
          } else if (ansLowerEn == 'b' || ansLowerHi == 'b' || ansLowerEn == '2' || ansLowerHi == '2') {
            correctOption = 'B';
          } else if (ansLowerEn == 'c' || ansLowerHi == 'c' || ansLowerEn == '3' || ansLowerHi == '3') {
            correctOption = 'C';
          } else if (ansLowerEn == 'd' || ansLowerHi == 'd' || ansLowerEn == '4' || ansLowerHi == '4') {
            correctOption = 'D';
          } else {
            final cleanAnsEn = _stripTags(ansEn);
            final cleanAnsHi = _stripTags(ansHi);

            bool checkMatch(String en, String hi) {
              final cEn = _stripTags(en);
              final cHi = _stripTags(hi);
              if (cleanAnsEn.isNotEmpty && cEn.isNotEmpty && cleanAnsEn == cEn) return true;
              if (cleanAnsHi.isNotEmpty && cHi.isNotEmpty && cleanAnsHi == cHi) return true;
              if (cleanAnsHi.isNotEmpty && cEn.isNotEmpty && cleanAnsHi == cEn) return true;
              if (cleanAnsEn.isNotEmpty && cHi.isNotEmpty && cleanAnsEn == cHi) return true;
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
            }
          }

          final descEn = _cleanHtml(_extractBiText(getJsonField(q, r'''$.description'''), 'en'));
          final descHi = _cleanHtml(_extractBiText(getJsonField(q, r'''$.description'''), 'hi'));

          parsedQuestions.add({
            'number': qNum,
            'subject': subject,
            'titleEn': titleEn,
            'titleHi': titleHi,
            'optAEn': optAEn,
            'optAHi': optAHi,
            'optBEn': optBEn,
            'optBHi': optBHi,
            'optCEn': optCEn,
            'optCHi': optCHi,
            'optDEn': optDEn,
            'optDHi': optDHi,
            'correctOption': correctOption,
            'descEn': descEn,
            'descHi': descHi,
          });
        }

        // Generate PDF bytes using syncfusion_flutter_pdf
        pdfBytes = await _generatePdfBytes(
          quizTitle: rawQuizName,
          subcategoryName: subcategoryName,
          totalQuestions: totalQuestions,
          timeMinutes: timeMinutes,
          rewardPerQ: rewardPerQ,
          penaltyPerQ: penaltyPerQ,
          totalMarks: totalMarks,
          questions: parsedQuestions,
          language: language,
        );
      }

      // 3. Save to device storage
      final savedFile = await _savePdfToDevice(safeName, pdfBytes);

      _activeDownloads.remove(quizId);

      // 4. Show success snackbar with direct open action
      if (context.mounted) {
        _showDownloadedSnackBar(
          context,
          savedFile: savedFile,
          safeName: safeName,
          displayName: '$rawQuizName ($langSuffix)',
        );
      }
    } catch (e) {
      _activeDownloads.remove(quizId);
      debugPrint('PDF download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Download failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Future<File> _savePdfToDevice(String safeName, List<int> bytes) async {
    Directory primaryDir;
    try {
      final extDir = await getExternalStorageDirectory();
      primaryDir = extDir ?? await getApplicationDocumentsDirectory();
    } catch (_) {
      primaryDir = await getApplicationDocumentsDirectory();
    }

    final primaryFile = File('${primaryDir.path}/$safeName.pdf');
    await primaryFile.writeAsBytes(bytes, flush: true);

    // Also write to public Download folder on Android if possible
    if (Platform.isAndroid) {
      try {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          final downloadFile = File('${downloadDir.path}/$safeName.pdf');
          await downloadFile.writeAsBytes(bytes, flush: true);
        }
      } catch (e) {
        debugPrint('Could not copy to public Download folder: $e');
      }
    }

    return primaryFile;
  }

  static void _showDownloadedSnackBar(
    BuildContext context, {
    required File savedFile,
    required String safeName,
    required String displayName,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 6),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Downloaded: $displayName.pdf',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: Colors.white,
          onPressed: () async {
            try {
              final result = await OpenFilex.open(
                savedFile.path,
                type: 'application/pdf',
              );
              if (result.type == ResultType.noAppToOpen) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFFDC2626),
                      content: Text(
                        'No PDF reader app found on your device. Please install a PDF viewer.',
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              } else if (result.type != ResultType.done) {
                // Try opening public Download path if available
                final publicDownload =
                    File('/storage/emulated/0/Download/$safeName.pdf');
                if (await publicDownload.exists()) {
                  await OpenFilex.open(
                    publicDownload.path,
                    type: 'application/pdf',
                  );
                }
              }
            } catch (e) {
              debugPrint('Could not open PDF file: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFDC2626),
                    content: Text('Could not open PDF: $e'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  static String _resolveRemoteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    var clean = url.replaceAll('\\', '/');
    while (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('assets/userImages/')) {
      final base = FFAppConstants.baseURL.endsWith('/')
          ? FFAppConstants.baseURL
          : '${FFAppConstants.baseURL}/';
      return '$base$clean';
    }
    final imgBase = FFAppConstants.imageBaseURL.endsWith('/')
        ? FFAppConstants.imageBaseURL
        : '${FFAppConstants.imageBaseURL}/';
    return '$imgBase$clean';
  }

  static String _sanitizeFileName(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'[^\p{L}\p{N}_-]+', unicode: true), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (cleaned.isEmpty) return 'Ebook';
    return cleaned;
  }

  static String _cleanHtml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll(RegExp(r'<p><br\s*/?></p>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>')
        .replaceAll(RegExp(r'&quot;', caseSensitive: false), '"')
        .replaceAll(RegExp(r'&#39;', caseSensitive: false), "'")
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  static String _stripTags(String s) {
    return s.replaceAll(RegExp(r'<[^>]*>'), '').trim().toLowerCase();
  }

  static String _extractBiText(dynamic node, String lang) {
    if (node == null) return '';
    if (node is Map) {
      final val = node[lang];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
      return '';
    }
    if (node is String) {
      final trimmed = node.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            final val = decoded[lang];
            if (val != null && val.toString().trim().isNotEmpty) {
              return val.toString();
            }
            return '';
          }
        } catch (_) {}
      }
      final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(trimmed);
      if (hasDevanagari) {
        return lang == 'hi' ? trimmed : '';
      } else {
        return lang == 'en' ? trimmed : '';
      }
    }
    return '';
  }

  static Future<List<int>> _generatePdfBytes({
    required String quizTitle,
    required String subcategoryName,
    required int totalQuestions,
    required String timeMinutes,
    required num rewardPerQ,
    required num penaltyPerQ,
    required num totalMarks,
    required List<Map<String, dynamic>> questions,
    required String language,
  }) async {
    final isHindi = language == 'hi';
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 25;
    document.pageSettings.size = PdfPageSize.a4;

    // Load fonts — Mukta covers both Latin and Devanagari scripts
    ByteData regularData;
    ByteData boldData;
    try {
      regularData = await rootBundle.load('assets/fonts/Mukta-Regular.ttf');
      boldData = await rootBundle.load('assets/fonts/Mukta-Bold.ttf');
    } catch (_) {
      regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    }

    final PdfFont normalFont = PdfTrueTypeFont(regularData.buffer.asUint8List(), 9.5);
    final PdfFont boldFont = PdfTrueTypeFont(boldData.buffer.asUint8List(), 10.5);
    final PdfFont titleFont = PdfTrueTypeFont(boldData.buffer.asUint8List(), 13);
    final PdfFont smallFont = PdfTrueTypeFont(regularData.buffer.asUint8List(), 8);

    final PdfColor primaryColor = PdfColor(29, 111, 255);
    final PdfColor darkColor = PdfColor(15, 23, 42);
    final PdfColor grayColor = PdfColor(100, 116, 139);
    final PdfColor lightBg = PdfColor(241, 245, 249);
    final PdfColor greenColor = PdfColor(22, 163, 74);

    PdfPage page = document.pages.add();
    double y = 0;
    final double pageWidth = page.getClientSize().width;

    // Header Banner
    page.graphics.drawString(
      'MOCK STATION EXAM PORTAL',
      PdfTrueTypeFont(boldData.buffer.asUint8List(), 11),
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, y, pageWidth, 16),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    y += 18;

    // Title
    final displayTitle = isHindi ? '$quizTitle (हिन्दी)' : '$quizTitle (English)';
    final titleResult = PdfTextElement(
      text: displayTitle,
      font: titleFont,
      brush: PdfSolidBrush(darkColor),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 40));
    y = (titleResult?.bounds.bottom ?? y) + 4;

    if (subcategoryName.isNotEmpty) {
      page.graphics.drawString(
        subcategoryName,
        smallFont,
        brush: PdfSolidBrush(grayColor),
        bounds: Rect.fromLTWH(0, y, pageWidth, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      y += 14;
    }

    // Meta Grid Table
    final PdfGrid metaGrid = PdfGrid();
    metaGrid.columns.add(count: 4);
    final metaHeader = metaGrid.headers.add(1)[0];
    metaHeader.cells[0].value = isHindi ? 'कुल प्रश्न' : 'Total Questions';
    metaHeader.cells[1].value = isHindi ? 'समय' : 'Time Allowed';
    metaHeader.cells[2].value = isHindi ? 'पूर्णांक' : 'Maximum Marks';
    metaHeader.cells[3].value = isHindi ? 'अंकन योजना' : 'Marking Scheme';

    for (int c = 0; c < 4; c++) {
      metaHeader.cells[c].style.font = smallFont;
      metaHeader.cells[c].style.textBrush = PdfSolidBrush(grayColor);
      metaHeader.cells[c].style.backgroundBrush = PdfSolidBrush(lightBg);
      metaHeader.cells[c].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
    }

    final metaRow = metaGrid.rows.add();
    metaRow.cells[0].value = '$totalQuestions';
    metaRow.cells[1].value = isHindi ? '$timeMinutes मिनट' : '$timeMinutes Mins';
    metaRow.cells[2].value = '$totalMarks';
    metaRow.cells[3].value = '+$rewardPerQ / -$penaltyPerQ';

    for (int c = 0; c < 4; c++) {
      metaRow.cells[c].style.font = boldFont;
      metaRow.cells[c].style.textBrush = PdfSolidBrush(darkColor);
      metaRow.cells[c].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
    }

    metaGrid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 3, bottom: 3);
    final metaLayout = metaGrid.draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
    y = (metaLayout?.bounds.bottom ?? y) + 10;

    // Instructions
    final instText = isHindi
        ? '📌 निर्देश: 1. सभी प्रश्न अनिवार्य हैं। 2. प्रत्येक प्रश्न के लिए $rewardPerQ अंक निर्धारित हैं। गलत उत्तर के लिए -$penaltyPerQ अंक की नकारात्मक अंकन प्रणाली लागू होगी। 3. उत्तर कुंजी और विस्तृत समाधान अंत में संलग्न हैं।'
        : '📌 Instructions: 1. All questions are compulsory. 2. Each question carries $rewardPerQ mark(s). Negative marking: -$penaltyPerQ marks for wrong answers. 3. Answer Key and Solutions are attached at the end.';

    final instLayout = PdfTextElement(
      text: instText,
      font: smallFont,
      brush: PdfSolidBrush(PdfColor(113, 63, 18)),
    ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 30));
    y = (instLayout?.bounds.bottom ?? y) + 8;

    // Divider
    page.graphics.drawLine(PdfPen(primaryColor, width: 1.2), Offset(0, y), Offset(pageWidth, y));
    y += 4;
    final questionsHeader = isHindi ? 'प्रश्नावली / QUESTIONS' : 'QUESTIONS';
    page.graphics.drawString(questionsHeader, boldFont, brush: PdfSolidBrush(primaryColor), bounds: Rect.fromLTWH(0, y, pageWidth, 14));
    y += 16;

    // Render questions
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final qNum = q['number'] ?? (i + 1);
      final titleHi = q['titleHi']?.toString() ?? '';
      final titleEn = q['titleEn']?.toString() ?? '';

      final qText = isHindi
          ? (titleHi.isNotEmpty ? titleHi : titleEn)
          : (titleEn.isNotEmpty ? titleEn : titleHi);

      final optA = isHindi
          ? (q['optAHi']?.toString().isNotEmpty == true ? q['optAHi'] : q['optAEn'])
          : (q['optAEn']?.toString().isNotEmpty == true ? q['optAEn'] : q['optAHi']);

      final optB = isHindi
          ? (q['optBHi']?.toString().isNotEmpty == true ? q['optBHi'] : q['optBEn'])
          : (q['optBEn']?.toString().isNotEmpty == true ? q['optBEn'] : q['optBHi']);

      final optC = isHindi
          ? (q['optCHi']?.toString().isNotEmpty == true ? q['optCHi'] : q['optCEn'])
          : (q['optCEn']?.toString().isNotEmpty == true ? q['optCEn'] : q['optCHi']);

      final optD = isHindi
          ? (q['optDHi']?.toString().isNotEmpty == true ? q['optDHi'] : q['optDEn'])
          : (q['optDEn']?.toString().isNotEmpty == true ? q['optDEn'] : q['optDHi']);

      if (y > page.getClientSize().height - 80) {
        page = document.pages.add();
        y = 10;
      }

      final qLayout = PdfTextElement(
        text: 'Q.$qNum. $qText',
        font: boldFont,
        brush: PdfSolidBrush(darkColor),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );

      if (qLayout != null) {
        page = qLayout.page;
        y = qLayout.bounds.bottom + 3;
      }

      final PdfGrid optGrid = PdfGrid();
      optGrid.columns.add(count: 2);
      final row1 = optGrid.rows.add();
      row1.cells[0].value = '(A) $optA';
      row1.cells[1].value = '(B) $optB';
      final row2 = optGrid.rows.add();
      row2.cells[0].value = '(C) $optC';
      row2.cells[1].value = '(D) $optD';

      for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 2; c++) {
          optGrid.rows[r].cells[c].style.font = normalFont;
          optGrid.rows[r].cells[c].style.textBrush = PdfSolidBrush(PdfColor(30, 41, 59));
          optGrid.rows[r].cells[c].style.borders.all = PdfPens.transparent;
        }
      }
      optGrid.style.cellPadding = PdfPaddings(left: 6, right: 6, top: 1.5, bottom: 1.5);

      final optLayout = optGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(4, y, pageWidth - 8, 0),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );

      if (optLayout != null) {
        page = optLayout.page;
        y = optLayout.bounds.bottom + 8;
      }
    }

    // Answer Key Page
    page = document.pages.add();
    y = 10;
    final ansKeyTitle = isHindi ? 'उत्तर कुंजी / ANSWER KEY' : 'ANSWER KEY';
    page.graphics.drawString(ansKeyTitle, titleFont, brush: PdfSolidBrush(primaryColor), bounds: Rect.fromLTWH(0, y, pageWidth, 18), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    y += 22;

    final PdfGrid ansGrid = PdfGrid();
    ansGrid.columns.add(count: 10);
    final ansHeader = ansGrid.headers.add(1)[0];
    for (int c = 0; c < 10; c++) {
      ansHeader.cells[c].value = 'Q#';
      ansHeader.cells[c].style.font = smallFont;
      ansHeader.cells[c].style.backgroundBrush = PdfSolidBrush(lightBg);
      ansHeader.cells[c].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
    }

    for (int i = 0; i < questions.length; i += 10) {
      final qRow = ansGrid.rows.add();
      final aRow = ansGrid.rows.add();
      final chunk = questions.skip(i).take(10).toList();

      for (int c = 0; c < 10; c++) {
        if (c < chunk.length) {
          final item = chunk[c];
          qRow.cells[c].value = '${item['number']}';
          qRow.cells[c].style.font = smallFont;
          qRow.cells[c].style.textBrush = PdfSolidBrush(grayColor);
          qRow.cells[c].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);

          aRow.cells[c].value = '${item['correctOption']}';
          aRow.cells[c].style.font = boldFont;
          aRow.cells[c].style.textBrush = PdfSolidBrush(primaryColor);
          aRow.cells[c].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
        } else {
          qRow.cells[c].value = '-';
          aRow.cells[c].value = '-';
        }
      }
    }

    ansGrid.style.cellPadding = PdfPaddings(left: 2, right: 2, top: 2.5, bottom: 2.5);
    final ansLayout = ansGrid.draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
    y = (ansLayout?.bounds.bottom ?? y) + 16;

    // Detailed Solutions
    if (y > page.getClientSize().height - 100) {
      page = document.pages.add();
      y = 10;
    }

    final solTitle = isHindi ? 'विस्तृत समाधान / DETAILED SOLUTIONS' : 'DETAILED SOLUTIONS';
    page.graphics.drawString(solTitle, titleFont, brush: PdfSolidBrush(primaryColor), bounds: Rect.fromLTWH(0, y, pageWidth, 18), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    y += 22;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final qNum = q['number'] ?? (i + 1);
      final correctOpt = q['correctOption'] ?? 'A';
      final descHi = q['descHi']?.toString() ?? '';
      final descEn = q['descEn']?.toString() ?? '';

      final desc = isHindi
          ? (descHi.isNotEmpty ? descHi : (descEn.isNotEmpty ? descEn : 'सही उत्तर विकल्प ($correctOpt) है।'))
          : (descEn.isNotEmpty ? descEn : (descHi.isNotEmpty ? descHi : 'Correct option is ($correctOpt).'));

      if (y > page.getClientSize().height - 50) {
        page = document.pages.add();
        y = 10;
      }

      final optLabel = isHindi ? 'Q.$qNum. सही विकल्प: ($correctOpt)' : 'Q.$qNum. Correct Option: ($correctOpt)';
      page.graphics.drawString(optLabel, boldFont, brush: PdfSolidBrush(greenColor), bounds: Rect.fromLTWH(0, y, pageWidth, 14));
      y += 15;

      final solLayout = PdfTextElement(
        text: desc,
        font: normalFont,
        brush: PdfSolidBrush(darkColor),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );

      if (solLayout != null) {
        page = solLayout.page;
        y = solLayout.bounds.bottom + 6;
      }
    }

    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }
}
