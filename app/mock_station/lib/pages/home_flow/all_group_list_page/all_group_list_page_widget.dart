import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/category_flow/group_detail_page/group_detail_page_widget.dart';
import '/pages/home_flow/home_screen/home_screen_widget.dart';

class AllGroupListPageWidget extends StatefulWidget {
  const AllGroupListPageWidget({
    super.key,
    required this.sectionTitle,
    required this.groups,
  });

  final String sectionTitle;
  final List<CategoryGroup> groups;

  @override
  State<AllGroupListPageWidget> createState() => _AllGroupListPageWidgetState();
}

class _AllGroupListPageWidgetState extends State<AllGroupListPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827), size: 22),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          widget.sectionTitle,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: FFFont.f18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 0,
            childAspectRatio: 1.2,
          ),
          itemCount: widget.groups.length,
          itemBuilder: (context, index) {
            final group = widget.groups[index];
            return _buildGroupItem(context, group);
          },
        ),
      ),
    );
  }

  IconData _getGroupIcon(String displayName) {
    final s = displayName.toLowerCase();
    if (s.contains('railway') || s.contains('rrb')) return Icons.train;
    if (s.contains('ssc')) return Icons.assignment;
    if (s.contains('psu')) return Icons.business;
    if (s.contains('defence') || s.contains('defense')) return Icons.shield;
    if (s.contains('upsc')) return Icons.account_balance;
    if (s.contains('state') || s.contains('psc')) return Icons.location_city;
    if (s.contains('bank') || s.contains('ibps')) return Icons.account_balance_wallet;
    if (s.contains('engineer')) return Icons.engineering;
    return Icons.quiz;
  }

  Widget _buildGroupItem(BuildContext context, CategoryGroup group) {
    final hasImage = group.image.isNotEmpty;
    final imgUrl = hasImage
        ? (group.image.startsWith('http')
            ? group.image
            : '${FFAppConstants.imageBaseURL}${group.image}')
        : '';

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => GroupDetailPageWidget(
            groupName: group.displayName,
            groupId: group.id,
            categoriesJson: group.categories.map((c) => {
              '_id': c.id,
              'name': c.name,
              'displayName': c.displayName,
              'image': c.image,
            }).toList(),
          ),
        ));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasImage ? Colors.transparent : const Color(0xFFEEF3FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6E4FF), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        _getGroupIcon(group.displayName),
                        color: const Color(0xFF2563EB),
                        size: 22,
                      ),
                    )
                  : Icon(
                      _getGroupIcon(group.displayName),
                      color: const Color(0xFF2563EB),
                      size: 22,
                    ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                group.code.isNotEmpty
                    ? group.code
                    : group.displayName
                        .replaceAll(RegExp(r'\s*Mock\s*Test[s]?\s*', caseSensitive: false), '')
                        .trim(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: FFFont.f10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Roboto',
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
