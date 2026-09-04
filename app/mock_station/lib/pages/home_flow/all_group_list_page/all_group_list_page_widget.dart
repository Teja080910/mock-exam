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
        child: _buildGroupList(context),
      ),
    );
  }

  Widget _buildGroupList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: widget.groups.length,
      itemBuilder: (context, index) {
        final group = widget.groups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildGroupItem(context, group),
        );
      },
    );
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 30,
                color: const Color(0xFF2563EB),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        child: hasImage
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
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
                            : Icon(
                                _getGroupIcon(group.displayName),
                                size: 24,
                                color: const Color(0xFF2563EB),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.displayName,
                              style: const TextStyle(
                                fontSize: FFFont.f16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Click to view categories',
                              style: TextStyle(
                                fontSize: FFFont.f12,
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
            ],
          ),
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
}
