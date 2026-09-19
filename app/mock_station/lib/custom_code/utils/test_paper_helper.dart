import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';

class TestPaperHelper {
  static final Set<String> _activeDownloads = {};

  static bool isDownloading(String quizId) => _activeDownloads.contains(quizId);

  static String? getPdfForLanguage(dynamic quiz, String lang) {
    if (quiz == null) return null;

    String? extractValue(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      if (str.isEmpty || str == 'null' || str == '{}') return null;
      return str;
    }

    if (lang == 'en') {
      final val1 = extractValue(getJsonField(quiz, r'''$.pdf.en'''));
      if (val1 != null) return val1;
      final val2 = extractValue(getJsonField(quiz, r'''$.pdf_en'''));
      if (val2 != null) return val2;
      if (quiz is Map) {
        if (quiz['pdf'] is Map) {
          final val = extractValue(quiz['pdf']['en']);
          if (val != null) return val;
        }
        final val = extractValue(quiz['pdf_en']);
        if (val != null) return val;
      }
    } else if (lang == 'hi') {
      final val1 = extractValue(getJsonField(quiz, r'''$.pdf.hi'''));
      if (val1 != null) return val1;
      final val2 = extractValue(getJsonField(quiz, r'''$.pdf_hi'''));
      if (val2 != null) return val2;
      if (quiz is Map) {
        if (quiz['pdf'] is Map) {
          final val = extractValue(quiz['pdf']['hi']);
          if (val != null) return val;
        }
        final val = extractValue(quiz['pdf_hi']);
        if (val != null) return val;
      }
    }

    // Generic fallback if single PDF is provided without language tag
    final genericPdf = extractValue(getJsonField(quiz, r'''$.pdf''')) ??
        extractValue(getJsonField(quiz, r'''$.pdf_url''')) ??
        (quiz is Map
            ? extractValue(quiz['pdf']) ?? extractValue(quiz['pdf_url'])
            : null);

    if (genericPdf != null &&
        !genericPdf.startsWith('{') &&
        genericPdf.toLowerCase().endsWith('.pdf')) {
      return genericPdf;
    }

    return null;
  }

  static bool hasPdf(dynamic quiz) {
    if (quiz == null) return false;
    final en = getPdfForLanguage(quiz, 'en');
    final hi = getPdfForLanguage(quiz, 'hi');
    return (en != null && en.isNotEmpty) || (hi != null && hi.isNotEmpty);
  }

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

    // Subscription gate: PDF download is only for users with an active
    // mock test subscription. Others get the subscription popup.
    if (!functions.hasCategoryAccess(
      FFAppState().planStatus,
      FFAppState().subsIsSelectedAll,
      FFAppState().allowedCategoryIds,
      quizId,
      null,
    )) {
      await showSubscriptionDialog(context);
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

    final enPdf = getPdfForLanguage(quiz, 'en');
    final hiPdf = getPdfForLanguage(quiz, 'hi');
    final bool hasEn = enPdf != null && enPdf.isNotEmpty;
    final bool hasHi = hiPdf != null && hiPdf.isNotEmpty;

    if (!hasEn && !hasHi) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF is not available for this mock test.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    String chosenLang;
    if (hasEn && hasHi) {
      // Both languages available: Show "Select your PDF language" bottom sheet
      final String? selected = await showModalBottomSheet<String>(
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
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top drag pill
                      Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
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
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 14),

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
                      const SizedBox(height: 10),

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
                      const SizedBox(height: 16),

                      // Download PDF Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
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
                              fontSize: 15,
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

      if (selected == null || !context.mounted) return;
      chosenLang = selected;
    } else if (hasEn) {
      chosenLang = 'en';
    } else {
      chosenLang = 'hi';
    }

    await _executeDownload(context, quiz, quizId, chosenLang);
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeChar,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF94A3B8),
              size: 20,
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

    final rawQuizName =
        (getJsonField(quiz, r'''$.name''') ?? 'Mock_Test').toString();
    final langSuffix = language == 'hi' ? 'Hindi' : 'English';
    final safeName =
        '${rawQuizName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').replaceAll(RegExp(r'_+'), '_')}_$langSuffix';

    // Notify user that download has started
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
                child: Text('Downloading $rawQuizName ($langSuffix) PDF...'),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      List<int> pdfBytes = [];
      final staticPdf = getPdfForLanguage(quiz, language) ?? '';

      // 1. Download admin-uploaded static PDF
      if (staticPdf.isNotEmpty && staticPdf != 'null') {
        String targetUrl;
        if (staticPdf.startsWith('http://') ||
            staticPdf.startsWith('https://')) {
          targetUrl = staticPdf;
        } else {
          final base = FFAppConstants.imageBaseURL.endsWith('/')
              ? FFAppConstants.imageBaseURL
              : '${FFAppConstants.imageBaseURL}/';
          targetUrl = '$base$staticPdf';
        }

        try {
          final res = await http.get(Uri.parse(targetUrl));
          if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
            pdfBytes = res.bodyBytes;
          }
        } catch (e) {
          debugPrint('Failed to download from primary imageBaseURL: $e');
        }

        if (pdfBytes.isEmpty && !staticPdf.startsWith('http')) {
          // Fallback to baseURL + assets/userImages/
          try {
            final altBase = FFAppConstants.baseURL.endsWith('/')
                ? '${FFAppConstants.baseURL}assets/userImages/'
                : '${FFAppConstants.baseURL}/assets/userImages/';
            final resAlt = await http.get(Uri.parse('$altBase$staticPdf'));
            if (resAlt.statusCode == 200 && resAlt.bodyBytes.isNotEmpty) {
              pdfBytes = resAlt.bodyBytes;
            }
          } catch (e) {
            debugPrint('Failed to download from alt baseURL: $e');
          }
        }
      }

      if (pdfBytes.isEmpty) {
        throw Exception('PDF file could not be downloaded from server');
      }

      // Save to device storage
      final savedFile = await _savePdfToDevice(safeName, pdfBytes);
      _activeDownloads.remove(quizId);

      // Automatically open downloaded PDF
      try {
        await OpenFilex.open(
          savedFile.path,
          type: 'application/pdf',
        );
      } catch (e) {
        debugPrint('Auto-open failed: $e');
      }

      // Show success snackbar with direct open action
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
    const displayDuration = Duration(seconds: 3);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          duration: displayDuration,
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
    // SnackBar's auto-dismiss timer only starts once its entrance animation
    // finishes. When the app is backgrounded (the PDF auto-opens right away),
    // that animation can stay frozen and the snackbar never goes away. Hide it
    // explicitly so it always disappears after 3 seconds.
    Future.delayed(displayDuration, () => messenger.hideCurrentSnackBar());
  }
}
