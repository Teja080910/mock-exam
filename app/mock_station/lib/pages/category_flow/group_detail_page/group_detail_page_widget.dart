import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';

class GroupDetailPageWidget extends StatefulWidget {
  const GroupDetailPageWidget({
    super.key,
    this.groupName,
    this.groupId,
    this.categoriesJson,
  });

  final String? groupName;
  final String? groupId;
  final List<dynamic>? categoriesJson;

  static String routeName = 'group_detail_page';
  static String routePath = '/groupDetailPage';

  @override
  State<GroupDetailPageWidget> createState() => _GroupDetailPageWidgetState();
}

class _GroupDetailPageWidgetState extends State<GroupDetailPageWidget> {
  @override
  Widget build(BuildContext context) {
    final categories = widget.categoriesJson ?? [];

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827), size: 22),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          widget.groupName ?? '',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No exams available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Check back soon for new mock tests',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildCategoryList(context, categories),
            ),
            _buildDisclaimer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<dynamic> categories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index] as Map<String, dynamic>;
        final catId = category['_id'] ?? '';
        final catName = category['name'] ?? '';
        final displayName = category['displayName'] ?? '';
        final image = category['image'] ?? '';
        final displayTitle = displayName.isNotEmpty ? displayName : catName;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              if (functions.hasCategoryAccess(
                FFAppState().planStatus,
                FFAppState().subsIsSelectedAll,
                FFAppState().allowedCategoryIds,
                catId.toString(),
                widget.groupId ?? '',
              )) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CategoryDetailPageWidget(
                    title: displayTitle,
                    catId: catId.toString(),
                    image: image.toString(),
                  ),
                ));
              } else {
                showSubscriptionDialog(context);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: image.toString().isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: image.toString().startsWith('http')
                                  ? image.toString()
                                  : '${FFAppConstants.imageBaseURL}$image',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.category,
                                size: 24,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          )
                        : const Icon(Icons.category, size: 24, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Click to view quizzes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEBFF),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.verified_user_outlined, color: Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Disclaimer: Mock Station is not affiliated with any government entity. These mock tests are for practice purposes only.',
              style: TextStyle(
                fontSize: 10.0,
                height: 1.35,
                color: FlutterFlowTheme.of(context).secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
