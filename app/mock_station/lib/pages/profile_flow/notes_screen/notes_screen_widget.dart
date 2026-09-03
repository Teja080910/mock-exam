import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'notes_screen_model.dart';
export 'notes_screen_model.dart';

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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppBarWidget(
            title: 'Notes',
            backIcon: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Study Notes',
                          style: const TextStyle(
                            color: Color(0xFF10213F),
                            fontSize: FFFont.f20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sticky_note_2_outlined,
                          color: Color(0xFF06B6D4),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(1, 'Notes will help you revise key concepts quickly.'),
                  const SizedBox(height: 12),
                  _buildInfoTile(2, 'Crisp and concise study material for all subjects.'),
                  const SizedBox(height: 12),
                  _buildInfoTile(3, 'Access topic-wise notes anytime, anywhere.'),
                  const SizedBox(height: 12),
                  _buildInfoTile(4, 'Perfect for last-minute revision before exams.'),
                  const SizedBox(height: 12),
                  _buildInfoTile(5, 'More notes are being added regularly — stay tuned!'),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 30.0),
            child: Container(
              height: 52.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: const Center(
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: FFFont.f16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ',
          style: const TextStyle(
            color: Color(0xFF10213F),
            fontSize: FFFont.f16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF10213F),
              fontSize: FFFont.f16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
