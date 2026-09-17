import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'notes_screen_model.dart';
export 'notes_screen_model.dart';

String _cleanNoteUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  var clean = path.replaceAll('\\', '/');
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

Future<void> openNotePdf(BuildContext context, String fileUrl, {String? title}) async {
  if (fileUrl.trim().isEmpty) return;
  final fullUrl = _cleanNoteUrl(fileUrl);
  final uri = Uri.parse(Uri.encodeFull(fullUrl));

  try {
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    }
  } catch (e) {
    debugPrint('Direct PDF launch error: $e');
  }

  // Fallback: Google Docs PDF viewer in browser
  try {
    final gdocsUri = Uri.parse('https://docs.google.com/viewer?url=${Uri.encodeComponent(fullUrl)}');
    if (await canLaunchUrl(gdocsUri)) {
      final launched = await launchUrl(gdocsUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    }
  } catch (e) {
    debugPrint('GDocs viewer launch error: $e');
  }

  // Fallback: in-app browser view
  try {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF file. Please try again.')),
      );
    }
  }
}

class NotesScreenWidget extends StatefulWidget {
  const NotesScreenWidget({super.key});
  static String routeName = 'notes_screen';
  static String routePath = '/notesScreen';

  @override
  State<NotesScreenWidget> createState() => _NotesScreenWidgetState();
}

class _NotesScreenWidgetState extends State<NotesScreenWidget> {
  late NotesScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotesScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final hasAccess = FFAppState().planStatus == 'active' &&
        (FFAppState().subsIsSelectedAll ||
            FFAppState().allowedCategoryIds.any((id) => id.toLowerCase() == 'notes'));

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(title: 'Notes', backIcon: true),
          Expanded(
            child: hasAccess
                ? _buildSubjectsList()
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Subscription Required',
                          style: TextStyle(
                            fontSize: FFFont.f18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Subscribe to access study notes',
                          style: TextStyle(fontSize: FFFont.f14, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => showSubscriptionDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('View Plans'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.getNoteSubjectsCall.call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No subjects available'));
        }
        final subjects = QuizGroup.getNoteSubjectsCall.subjects(snapshot.data!.jsonBody) ?? [];
        if (subjects.isEmpty) {
          return const Center(child: Text('No notes available yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final s = subjects[index];
            final subjectName = getJsonField(s, r'$.subject').toString();
            final image = getJsonField(s, r'$.image').toString();
            return _buildCard(
              name: subjectName.toUpperCase(),
              subtitle: 'Click to view notes',
              image: image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _TopicsScreen(subject: subjectName),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCard({
    required String name,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 4.5,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F5FF),
                        shape: BoxShape.circle,
                      ),
                      child: image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: CachedNetworkImage(
                                imageUrl: _cleanNoteUrl(image),
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                                errorWidget: (_, __, ___) => const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                              ),
                            )
                          : const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 28, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Topics Screen ──
class _TopicsScreen extends StatelessWidget {
  final String subject;
  const _TopicsScreen({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(title: subject.toUpperCase(), backIcon: true),
          Expanded(child: _buildTopicsList(context)),
        ],
      ),
    );
  }

  Widget _buildTopicsList(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.getNoteTopicsCall.call(subject: subject),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No topics available'));
        }
        final topics = QuizGroup.getNoteTopicsCall.topics(snapshot.data!.jsonBody) ?? [];
        if (topics.isEmpty) {
          return const Center(child: Text('No topics available yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: topics.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final t = topics[index];
            final topicName = getJsonField(t, r'$.topic').toString();
            final image = getJsonField(t, r'$.image').toString();
            return _buildCard(
              context: context,
              name: topicName.toUpperCase(),
              subtitle: 'Click to view notes',
              image: image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _NotesDetailScreen(subject: subject, topic: topicName),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 4.5,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F5FF),
                        shape: BoxShape.circle,
                      ),
                      child: image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: CachedNetworkImage(
                                imageUrl: _cleanNoteUrl(image),
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                                errorWidget: (_, __, ___) => const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                              ),
                            )
                          : const Icon(Icons.description_rounded, size: 26, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 28, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notes Detail Screen ──
class _NotesDetailScreen extends StatelessWidget {
  final String subject;
  final String topic;
  const _NotesDetailScreen({required this.subject, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(title: topic.toUpperCase(), backIcon: true),
          Expanded(child: _buildNotesList(context)),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.getNotesCall.call(subject: subject, topic: topic),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No notes available'));
        }
        final notes = QuizGroup.getNotesCall.notes(snapshot.data!.jsonBody) ?? [];
        if (notes.isEmpty) {
          return const Center(child: Text('No notes available yet'));
        }
        // If there is only 1 note for this topic, directly display the note content & PDF!
        if (notes.length == 1) {
          final n = notes[0];
          final title = getJsonField(n, r'$.title')?.toString() ?? '';
          final description = getJsonField(n, r'$.description')?.toString() ?? '';
          final fileUrl = getJsonField(n, r'$.file')?.toString() ?? '';
          final noteImage = getJsonField(n, r'$.image')?.toString() ?? '';
          return _NoteViewerScreen(
            title: title,
            description: description,
            fileUrl: fileUrl,
            noteImage: noteImage,
            showAppBar: false,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final n = notes[index];
            final title = getJsonField(n, r'$.title')?.toString() ?? '';
            final description = getJsonField(n, r'$.description')?.toString() ?? '';
            final fileUrl = getJsonField(n, r'$.file')?.toString() ?? '';
            final noteImage = getJsonField(n, r'$.image')?.toString() ?? '';
            final hasFile = fileUrl.trim().isNotEmpty && fileUrl.trim() != 'null';
            final hasContent = description.trim().isNotEmpty && description.trim() != 'null';

            return GestureDetector(
              onTap: () {
                if (hasFile && !hasContent) {
                  openNotePdf(context, fileUrl, title: title);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _NoteViewerScreen(
                        title: title,
                        description: description,
                        fileUrl: fileUrl,
                        noteImage: noteImage,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: 4.5,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0F5FF),
                                shape: BoxShape.circle,
                              ),
                              child: noteImage.trim().isNotEmpty && noteImage.trim() != 'null'
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: CachedNetworkImage(
                                        imageUrl: _cleanNoteUrl(noteImage),
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Icon(
                                          hasFile ? Icons.picture_as_pdf_rounded : Icons.note_alt_rounded,
                                          size: 26,
                                          color: const Color(0xFF2563EB),
                                        ),
                                        errorWidget: (_, __, ___) => Icon(
                                          hasFile ? Icons.picture_as_pdf_rounded : Icons.note_alt_rounded,
                                          size: 26,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      hasFile ? Icons.picture_as_pdf_rounded : Icons.note_alt_rounded,
                                      size: 26,
                                      color: hasFile ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (hasContent)
                                    Text(
                                      description.replaceAll(RegExp(r'<[^>]*>'), '').trim().length > 80
                                          ? '${description.replaceAll(RegExp(r'<[^>]*>'), '').trim().substring(0, 80)}...'
                                          : description.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade500,
                                      ),
                                    )
                                  else if (hasFile)
                                    Text(
                                      'PDF Document • Tap to view',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color(0xFF2563EB).withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 28, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Note Viewer Screen ──
class _NoteViewerScreen extends StatefulWidget {
  final String title;
  final String description;
  final String fileUrl;
  final String noteImage;
  final bool showAppBar;

  const _NoteViewerScreen({
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.noteImage,
    this.showAppBar = true,
  });

  @override
  State<_NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<_NoteViewerScreen> {
  @override
  void initState() {
    super.initState();
    final hasContent = widget.description.trim().isNotEmpty && widget.description.trim() != 'null';
    final hasFile = widget.fileUrl.trim().isNotEmpty && widget.fileUrl.trim() != 'null';
    // If it's purely a PDF document with no text description, auto-open the PDF directly
    if (hasFile && !hasContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          openNotePdf(context, widget.fileUrl, title: widget.title);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullFileUrl = _cleanNoteUrl(widget.fileUrl);
    final hasFile = fullFileUrl.trim().isNotEmpty && fullFileUrl.trim() != 'null';
    final isPdf = hasFile &&
        (fullFileUrl.toLowerCase().endsWith('.pdf') || fullFileUrl.toLowerCase().contains('.pdf'));
    final isImageFile = hasFile &&
        (fullFileUrl.toLowerCase().endsWith('.png') ||
            fullFileUrl.toLowerCase().endsWith('.jpg') ||
            fullFileUrl.toLowerCase().endsWith('.jpeg') ||
            fullFileUrl.toLowerCase().endsWith('.webp'));
    final hasContent = widget.description.trim().isNotEmpty && widget.description.trim() != 'null';

    final body = Column(
      children: [
        if (widget.showAppBar)
          AppBarWidget(
            title: widget.title.toUpperCase(),
            backIcon: true,
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasFile) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                                color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPdf ? 'PDF Document' : 'Attached Document',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => openNotePdf(context, widget.fileUrl, title: widget.title),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: Text(
                              isPdf ? 'Open PDF Document' : 'Open Attached File',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (hasContent) ...[
                  custom_widgets.HtmlConverterExp(
                    width: double.infinity,
                    height: null,
                    text: widget.description,
                  ),
                ],
                if (isImageFile) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: fullFileUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: body,
      );
    }
    return body;
  }
}
