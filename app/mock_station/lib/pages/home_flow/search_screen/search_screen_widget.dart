import 'package:flutter/material.dart';

import '/backend/api_requests/api_calls.dart';
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/pages/profile_flow/notes_screen/notes_screen_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/category_flow/category_detail_page/category_detail_page_widget.dart';
import '/pages/category_flow/group_detail_page/group_detail_page_widget.dart';
import '/pages/home_flow/news_screen/news_screen_widget.dart';
import '/pages/home_flow/quiz_questions_screen/quiz_questions_screen_widget.dart';
enum _SearchResultType { group, category, quiz, news, ebook }

class _GlobalSearchResult {
  const _GlobalSearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.data,
    this.keywords = '',
  });

  final _SearchResultType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, dynamic> data;
  final String keywords;

  String get searchableText =>
      '$title $subtitle $keywords'.toLowerCase().trim();
}

class SearchScreenWidget extends StatefulWidget {
  const SearchScreenWidget({super.key});

  @override
  State<SearchScreenWidget> createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final _searchController = TextEditingController();
  List<_GlobalSearchResult> _allResults = [];
  List<_GlobalSearchResult> _visibleResults = [];
  Map<String, String> _categoryGroupIds = {};
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterResults);

    // Warm the global index in the background. The empty search state is
    // rendered before the loader, so opening this page never shows a spinner.
    _loadSearchIndex();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filterResults)
      ..dispose();
    super.dispose();
  }

  Future<ApiCallResponse?> _safeRequest(
    Future<ApiCallResponse> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadSearchIndex() async {
    try {
      await _buildSearchIndex();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasLoadError = _allResults.isEmpty;
      });
    }
  }

  Future<void> _buildSearchIndex() async {
    final responses = await Future.wait<ApiCallResponse?>([
      _safeRequest(
        () => QuizGroup.getCategoryGroupsCall.call(
          token: FFAppState().loginToken,
        ),
      ),
      _safeRequest(
        () => QuizGroup.getAllCategoriesCall.call(
          token: FFAppState().loginToken,
        ),
      ),
      _safeRequest(
        () => QuizGroup.getallquizzesApiCall.call(
          token: FFAppState().loginToken,
        ),
      ),
      _safeRequest(
        () => QuizGroup.getAllNewsApiCall.call(
          token: FFAppState().loginToken,
        ),
      ),
      _safeRequest(
        () => GetAllEbooksCall().call(
          token: FFAppState().loginToken,
        ),
      ),
    ]);

    final results = <_GlobalSearchResult>[];
    final categoryGroupIds = <String, String>{};
    var successfulRequests = 0;

    final groupResponse = responses[0];
    if (groupResponse != null && groupResponse.succeeded) {
      successfulRequests++;
      final groups = QuizGroup.getCategoryGroupsCall.groups(
            groupResponse.jsonBody,
          ) ??
          [];
      for (final rawGroup in groups) {
        final group = _asMap(rawGroup);
        final title = _firstValue([
          group['displayName'],
          group['name'],
          group['code'],
        ]);
        if (title.isEmpty) continue;
        final categories = group['categories'] is List
            ? List<dynamic>.from(group['categories'] as List)
            : <dynamic>[];
        final groupId = _value(group['_id'] ?? group['id']);
        for (final rawCategory in categories) {
          final category = _asMap(rawCategory);
          final categoryId = _value(category['_id'] ?? category['id']);
          if (groupId.isNotEmpty && categoryId.isNotEmpty) {
            categoryGroupIds[categoryId] = groupId;
          }
        }
        final scope = _value(group['scope']);
        results.add(
          _GlobalSearchResult(
            type: _SearchResultType.group,
            title: title,
            subtitle: scope.isEmpty ? 'Exam group' : '$scope exams',
            icon: Icons.account_balance_outlined,
            data: {
              ...group,
              'categories': categories,
            },
            keywords: _value(group['code']),
          ),
        );
      }
    }

    final categoryResponse = responses[1];
    if (categoryResponse != null && categoryResponse.succeeded) {
      successfulRequests++;
      final categories = QuizGroup.getAllCategoriesCall.category(
            categoryResponse.jsonBody,
          ) ??
          [];
      for (final rawCategory in categories) {
        final category = _asMap(rawCategory);
        final title = _firstValue([
          category['displayName'],
          category['name'],
        ]);
        final id = _value(category['_id'] ?? category['id']);
        if (title.isEmpty || id.isEmpty) continue;
        results.add(
          _GlobalSearchResult(
            type: _SearchResultType.category,
            title: title,
            subtitle: 'Exam category',
            icon: Icons.category_outlined,
            data: category,
            keywords: _value(category['name']),
          ),
        );
      }
    }

    final quizResponse = responses[2];
    if (quizResponse != null && quizResponse.succeeded) {
      successfulRequests++;
      final quizzes = QuizGroup.getallquizzesApiCall.quizDetailsList(
            quizResponse.jsonBody,
          ) ??
          [];
      for (final rawQuiz in quizzes) {
        final quiz = _asMap(rawQuiz);
        final title = _firstValue([quiz['name'], quiz['title']]);
        final id = _value(quiz['_id'] ?? quiz['id']);
        if (title.isEmpty || id.isEmpty) continue;
        results.add(
          _GlobalSearchResult(
            type: _SearchResultType.quiz,
            title: title,
            subtitle: 'Mock test',
            icon: Icons.assignment_outlined,
            data: quiz,
            keywords: _value(quiz['description']),
          ),
        );
      }
    }

    final newsResponse = responses[3];
    if (newsResponse != null && newsResponse.succeeded) {
      successfulRequests++;
      final news = _newsFromResponse(newsResponse.jsonBody);
      for (final rawNews in news) {
        final item = _asMap(rawNews);
        final title = _value(item['title']);
        if (title.isEmpty) continue;
        results.add(
          _GlobalSearchResult(
            type: _SearchResultType.news,
            title: title,
            subtitle: _value(item['category']).isEmpty
                ? 'News'
                : _value(item['category']),
            icon: Icons.newspaper_outlined,
            data: item,
            keywords:
                '${_value(item['short_description'])} ${_value(item['description'])}',
          ),
        );
      }
    }

    final ebooksResponse = responses[4];
    if (ebooksResponse != null && ebooksResponse.succeeded) {
      successfulRequests++;
      final ebooks = GetAllEbooksCall().ebooksList(
            ebooksResponse.jsonBody,
          ) ??
          [];
      for (final rawEbook in ebooks) {
        final ebook = _asMap(rawEbook);
        final title = _firstValue([ebook['name'], ebook['title']]);
        if (title.isEmpty) continue;
        results.add(
          _GlobalSearchResult(
            type: _SearchResultType.ebook,
            title: title,
            subtitle: 'E-book',
            icon: Icons.menu_book_outlined,
            data: ebook,
            keywords: _value(ebook['description']),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _allResults = results;
      _categoryGroupIds = categoryGroupIds;
      _hasLoadError = successfulRequests == 0;
      _isLoading = false;
    });
    _filterResults();
  }

  void _filterResults() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? <_GlobalSearchResult>[]
        : _allResults
            .where((result) => result.searchableText.contains(query))
            .toList();
    if (mounted) {
      setState(() => _visibleResults = filtered);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _value(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      return apiBiText(value).trim();
    }
    return value.toString().trim();
  }

  String _firstValue(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _value(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _idFromReference(dynamic value) {
    if (value is Map) return _value(value['_id'] ?? value['id']);
    return _value(value);
  }

  List<dynamic> _newsFromResponse(dynamic response) {
    if (response is! Map) return <dynamic>[];
    final data = response['data'];
    if (data is Map && data['news'] is List) {
      return List<dynamic>.from(data['news'] as List);
    }
    if (response['news'] is List) {
      return List<dynamic>.from(response['news'] as List);
    }
    return <dynamic>[];
  }

  String _resultTypeLabel(_SearchResultType type) {
    switch (type) {
      case _SearchResultType.group:
        return 'Exam group';
      case _SearchResultType.category:
        return 'Category';
      case _SearchResultType.quiz:
        return 'Mock test';
      case _SearchResultType.news:
        return 'News';
      case _SearchResultType.ebook:
        return 'E-book';
    }
  }

  Future<void> _openResult(_GlobalSearchResult result) async {
    switch (result.type) {
      case _SearchResultType.group:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailPageWidget(
              groupName: result.title,
              groupId: _value(result.data['_id'] ?? result.data['id']),
              categoriesJson: result.data['categories'] as List<dynamic>?,
            ),
          ),
        );
        return;
      case _SearchResultType.category:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailPageWidget(
              title: result.title,
              catId: _value(result.data['_id'] ?? result.data['id']),
              image: _value(result.data['image']),
            ),
          ),
        );
        return;
      case _SearchResultType.quiz:
        await _openQuiz(result.data);
        return;
      case _SearchResultType.news:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreenWidget(news: result.data),
          ),
        );
        return;
      case _SearchResultType.ebook:
        final openUrl = _firstValue([
          result.data['fileUrl'],
          result.data['file'],
          result.data['link'],
        ]);
        if (openUrl.isEmpty) return;
        await openNotePdf(context, openUrl, title: result.title);
        return;
    }
  }

  Future<void> _openQuiz(Map<String, dynamic> quiz) async {
    final quizId = _value(quiz['_id'] ?? quiz['id']);
    final categoryId = _idFromReference(quiz['categoryId']);
    final explicitGroupId =
        _idFromReference(quiz['categoryGroupId'] ?? quiz['groupId']);
    final groupId = explicitGroupId.isNotEmpty
        ? explicitGroupId
        : (_categoryGroupIds[categoryId] ?? '');

    if (!functions.hasCategoryAccess(
      FFAppState().planStatus,
      FFAppState().subsIsSelectedAll,
      FFAppState().allowedCategoryIds,
      categoryId.isEmpty ? quizId : categoryId,
      groupId.isEmpty ? null : groupId,
    )) {
      await showSubscriptionDialog(context);
      return;
    }

    if (!mounted) return;
    context.pushNamed(
      QuizQuestionsScreenWidget.routeName,
      queryParameters: {
        'quizID': quizId,
        'title': _firstValue([quiz['name'], quiz['title']]) is Map
            ? jsonEncode(_firstValue([quiz['name'], quiz['title']]))
            : _firstValue([quiz['name'], quiz['title']]),
        'catId': categoryId,
        'image': _value(quiz['image']),
        'quizTime': _value(quiz['minutes_per_quiz']),
        'description': quiz['description'] is Map
            ? jsonEncode(quiz['description'])
            : _value(quiz['description']),
      },
    );
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    _loadSearchIndex();
  }

  Widget _buildResultTile(_GlobalSearchResult result) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      leading: Container(
        width: 46.0,
        height: 46.0,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5FF),
          shape: BoxShape.circle,
        ),
        child: Icon(result.icon, color: Color(0xFF2563EB), size: 24.0),
      ),
      title: Text(
        result.title.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 15.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          '${_resultTypeLabel(result.type)} • ${result.subtitle}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.0),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      onTap: () => _openResult(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search exams, mock tests, news...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
          ),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: () => _searchController.clear(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Search across exam groups, categories, mock tests, news and e-books.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 15.0),
          ),
        ),
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasLoadError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text('Could not load search results.'),
            const SizedBox(height: 12),
            TextButton(onPressed: _retry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_visibleResults.isEmpty) {
      return const Center(
        child: Text(
          'No matching results found.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15.0),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
      itemCount: _visibleResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1.0, indent: 80.0),
      itemBuilder: (context, index) => _buildResultTile(_visibleResults[index]),
    );
  }
}
