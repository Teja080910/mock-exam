import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';
import '/pages/category_flow/category_viewall/current_affairs_widget.dart';
import '/pages/profile_flow/books_screen/books_screen_widget.dart';
import '/pages/profile_flow/notes_screen/notes_screen_widget.dart';
import '/pages/category_flow/subcategory_detail_page/subcategory_detail_page_widget.dart';
import '/pages/category_flow/group_detail_page/group_detail_page_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => SplashScreenWidget(),
      redirect: (context, state) {
        // While a quiz is active, block navigation to everything outside
        // the quiz flow (quiz questions, review, result screens). This
        // keeps the app locked to the quiz until it is submitted/ended.
        final quizRoutes = {
          '/quizQuestionsScreen',
          '/quizquestionsScreenCopy',
          '/selfChallengeQuizPage',
          '/quizReviewScreen',
          '/quizReviewScreenCopyCopy',
          '/quizResult',
          '/selfQuizResult',
        };
        if (FFAppState().isQuizActive &&
            !quizRoutes.contains(state.uri.path)) {
          return state.uri.toString();
        }
        return null;
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => SplashScreenWidget(),
        ),
        FFRoute(
          name: SplashScreenWidget.routeName,
          path: SplashScreenWidget.routePath,
          builder: (context, params) => SplashScreenWidget(),
        ),
        FFRoute(
          name: ProfileScreenWidget.routeName,
          path: ProfileScreenWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'profile_screen')
              : ProfileScreenWidget(),
        ),
        FFRoute(
          name: FogotpasswordScreenWidget.routeName,
          path: FogotpasswordScreenWidget.routePath,
          builder: (context, params) => FogotpasswordScreenWidget(),
        ),
        FFRoute(
          name: VerificationScreenWidget.routeName,
          path: VerificationScreenWidget.routePath,
          builder: (context, params) => VerificationScreenWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SettingPageWidget.routeName,
          path: SettingPageWidget.routePath,
          builder: (context, params) => SettingPageWidget(),
        ),
        FFRoute(
          name: MySubscriptionScreenWidget.routeName,
          path: MySubscriptionScreenWidget.routePath,
          builder: (context, params) => MySubscriptionScreenWidget(),
        ),
        FFRoute(
          name: PlansScreenWidget.routeName,
          path: PlansScreenWidget.routePath,
          builder: (context, params) => PlansScreenWidget(),
        ),
        FFRoute(
          name: PrivacyPolicyScreenWidget.routeName,
          path: PrivacyPolicyScreenWidget.routePath,
          builder: (context, params) => PrivacyPolicyScreenWidget(),
        ),
        FFRoute(
          name: ResetPasswordScreenWidget.routeName,
          path: ResetPasswordScreenWidget.routePath,
          builder: (context, params) => ResetPasswordScreenWidget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LoginScreenWidget.routeName,
          path: LoginScreenWidget.routePath,
          builder: (context, params) => LoginScreenWidget(),
        ),
        FFRoute(
          name: HelplineCenterScreenWidget.routeName,
          path: HelplineCenterScreenWidget.routePath,
          builder: (context, params) => HelplineCenterScreenWidget(),
        ),
        FFRoute(
          name: ReferAndEarnScreenWidget.routeName,
          path: ReferAndEarnScreenWidget.routePath,
          builder: (context, params) => ReferAndEarnScreenWidget(),
        ),
        FFRoute(
          name: AboutusScreenWidget.routeName,
          path: AboutusScreenWidget.routePath,
          builder: (context, params) => AboutusScreenWidget(),
        ),
        FFRoute(
          name: TermsConditionScreenWidget.routeName,
          path: TermsConditionScreenWidget.routePath,
          builder: (context, params) => TermsConditionScreenWidget(),
        ),
        FFRoute(
          name: 'books_screen',
          path: '/booksScreen',
          builder: (context, params) => BooksScreenWidget(),
        ),
        FFRoute(
          name: NotesScreenWidget.routeName,
          path: NotesScreenWidget.routePath,
          builder: (context, params) => NotesScreenWidget(),
        ),
        FFRoute(
          name: SignupScreenWidget.routeName,
          path: SignupScreenWidget.routePath,
          builder: (context, params) => SignupScreenWidget(),
        ),
        FFRoute(
          name: HomeScreenWidget.routeName,
          path: HomeScreenWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'home_screen')
              : HomeScreenWidget(),
        ),
        FFRoute(
          name: CategoryViewallWidget.routeName,
          path: CategoryViewallWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'category_viewall')
              : CategoryViewallWidget(),
        ),
        FFRoute(
          name: CurrentAffairsWidget.routeName,
          path: CurrentAffairsWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'current_affairs')
              : CurrentAffairsWidget(),
        ),
        FFRoute(
          name: NewsScreenWidget.routeName,
          path: NewsScreenWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'news_screen')
              : NewsScreenWidget(),
        ),
        FFRoute(
          name: CategoryDetailPageWidget.routeName,
          path: CategoryDetailPageWidget.routePath,
          builder: (context, params) => CategoryDetailPageWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            catId: params.getParam(
              'catId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GroupDetailPageWidget.routeName,
          path: GroupDetailPageWidget.routePath,
          builder: (context, params) => GroupDetailPageWidget(
            groupName: params.getParam('groupName', ParamType.String),
            groupId: params.getParam('groupId', ParamType.String),
          ),
        ),
        FFRoute(
          name: SubcategoryDetailPageWidget.routeName,
          path: SubcategoryDetailPageWidget.routePath,
          builder: (context, params) => SubcategoryDetailPageWidget(
            key: ValueKey(params.getParam('subcategoryId', ParamType.String)),
            subcategoryId: params.getParam('subcategoryId', ParamType.String),
            subcategoryName: params.getParam('subcategoryName', ParamType.String),
          ),
        ),
        FFRoute(
          name: QuizQuestionsScreenWidget.routeName,
          path: QuizQuestionsScreenWidget.routePath,
          builder: (context, params) => QuizQuestionsScreenWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            catId: params.getParam(
              'catId',
              ParamType.String,
            ),
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            quizTime: params.getParam(
              'quizTime',
              ParamType.String,
            ),
            description: params.getParam(
              'description',
              ParamType.String,
            ),
            ques: params.getParam(
              'ques',
              ParamType.int,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            timerStatus: params.getParam(
              'timerStatus',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: QuizResultWidget.routeName,
          path: QuizResultWidget.routePath,
          builder: (context, params) => QuizResultWidget(
            correctAnswer: params.getParam(
              'correctAnswer',
              ParamType.int,
            ),
            wrongAnswer: params.getParam(
              'wrongAnswer',
              ParamType.int,
            ),
            totalQuestion: params.getParam(
              'totalQuestion',
              ParamType.int,
            ),
            notAnswer: params.getParam(
              'notAnswer',
              ParamType.int,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            quizTime: params.getParam(
              'quizTime',
              ParamType.String,
            ),
            catID: params.getParam(
              'catID',
              ParamType.String,
            ),
            correctAnsReward: params.getParam(
              'correctAnsReward',
              ParamType.double,
            ),
            penaltyPerQuestion: params.getParam(
              'penaltyPerQuestion',
              ParamType.double,
            ),
          ),
        ),
        FFRoute(
          name: PaymentScreenWidget.routeName,
          path: PaymentScreenWidget.routePath,
          builder: (context, params) => PaymentScreenWidget(
            paymentPrice: params.getParam(
              'paymentPrice',
              ParamType.int,
            ),
            points: params.getParam(
              'points',
              ParamType.int,
            ),
            planId: params.getParam(
              'planId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SelfChellengeWidget.routeName,
          path: SelfChellengeWidget.routePath,
          builder: (context, params) => SelfChellengeWidget(),
        ),
        FFRoute(
          name: MyProfileWidget.routeName,
          path: MyProfileWidget.routePath,
          builder: (context, params) => MyProfileWidget(
            fname: params.getParam(
              'fname',
              ParamType.String,
            ),
            lname: params.getParam(
              'lname',
              ParamType.String,
            ),
            profilePicture: params.getParam(
              'profilePicture',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: CompletedQuizzesScreenWidget.routeName,
          path: CompletedQuizzesScreenWidget.routePath,
          builder: (context, params) => CompletedQuizzesScreenWidget(),
        ),
        FFRoute(
          name: NotificationScreenWidget.routeName,
          path: NotificationScreenWidget.routePath,
          builder: (context, params) => NotificationScreenWidget(),
        ),
        FFRoute(
          name: EditProfileWidget.routeName,
          path: EditProfileWidget.routePath,
          builder: (context, params) => EditProfileWidget(
            userFirstName: params.getParam(
              'userFirstName',
              ParamType.String,
            ),
            userLastName: params.getParam(
              'userLastName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DetailScreenWidget.routeName,
          path: DetailScreenWidget.routePath,
          builder: (context, params) => DetailScreenWidget(
            catId: params.getParam(
              'catId',
              ParamType.String,
            ),
            name: params.getParam(
              'name',
              ParamType.String,
            ),
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            quizTime: params.getParam(
              'quizTime',
              ParamType.String,
            ),
            description: params.getParam(
              'description',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            ques: params.getParam(
              'ques',
              ParamType.int,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            timerStatus: params.getParam(
              'timerStatus',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: SelfChallengeQuizPageWidget.routeName,
          path: SelfChallengeQuizPageWidget.routePath,
          builder: (context, params) => SelfChallengeQuizPageWidget(
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            totalQues: params.getParam(
              'totalQues',
              ParamType.String,
            ),
            timer: params.getParam(
              'timer',
              ParamType.int,
            ),
            questime: params.getParam(
              'questime',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: UserVerificationScreenWidget.routeName,
          path: UserVerificationScreenWidget.routePath,
          builder: (context, params) => UserVerificationScreenWidget(
            useremail: params.getParam(
              'useremail',
              ParamType.String,
            ),
            password: params.getParam(
              'password',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SelfQuizResultWidget.routeName,
          path: SelfQuizResultWidget.routePath,
          builder: (context, params) => SelfQuizResultWidget(
            correctAnswer: params.getParam(
              'correctAnswer',
              ParamType.int,
            ),
            wrongAnswer: params.getParam(
              'wrongAnswer',
              ParamType.int,
            ),
            totalQuestion: params.getParam(
              'totalQuestion',
              ParamType.int,
            ),
            notAnswer: params.getParam(
              'notAnswer',
              ParamType.int,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            quizTime: params.getParam(
              'quizTime',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: QuizReviewScreenWidget.routeName,
          path: QuizReviewScreenWidget.routePath,
          builder: (context, params) => QuizReviewScreenWidget(
            catID: params.getParam(
              'catID',
              ParamType.String,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            correctAnsReward: params.getParam(
              'correctAnsReward',
              ParamType.double,
            ),
            penaltyPerQuestion: params.getParam(
              'penaltyPerQuestion',
              ParamType.double,
            ),
            quizTime: params.getParam(
              'quizTime',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: QuizquestionsScreenCopyWidget.routeName,
          path: QuizquestionsScreenCopyWidget.routePath,
          builder: (context, params) => QuizquestionsScreenCopyWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            catId: params.getParam(
              'catId',
              ParamType.String,
            ),
            image: params.getParam(
              'image',
              ParamType.String,
            ),
            time: params.getParam(
              'time',
              ParamType.String,
            ),
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: QuizReviewScreenCopyCopyWidget.routeName,
          path: QuizReviewScreenCopyCopyWidget.routePath,
          builder: (context, params) => QuizReviewScreenCopyCopyWidget(),
        ),
        FFRoute(
          name: CompletedquizzesScreenDetailWidget.routeName,
          path: CompletedquizzesScreenDetailWidget.routePath,
          builder: (context, params) => CompletedquizzesScreenDetailWidget(
            quesList: params.getParam<dynamic>(
              'quesList',
              ParamType.JSON,
              isList: true,
            ),
            title: params.getParam(
              'title',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SelfChallengeQuizPageCopyWidget.routeName,
          path: SelfChallengeQuizPageCopyWidget.routePath,
          builder: (context, params) => SelfChallengeQuizPageCopyWidget(
            quizID: params.getParam(
              'quizID',
              ParamType.String,
            ),
            totalQues: params.getParam(
              'totalQues',
              ParamType.String,
            ),
            timer: params.getParam(
              'timer',
              ParamType.int,
            ),
            questime: params.getParam(
              'questime',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: FeaturedCategoryDetailWidget.routeName,
          path: FeaturedCategoryDetailWidget.routePath,
          builder: (context, params) => FeaturedCategoryDetailWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            quizList: params.getParam<dynamic>(
              'quizList',
              ParamType.JSON,
              isList: true,
            ),
            index: params.getParam(
              'index',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: OnBordingScreenWidget.routeName,
          path: OnBordingScreenWidget.routePath,
          builder: (context, params) => OnBordingScreenWidget(
            introsList: params.getParam<dynamic>(
              'introsList',
              ParamType.JSON,
              isList: true,
            ),
          ),
        ),
        FFRoute(
          name: ExplanationPageWidget.routeName,
          path: ExplanationPageWidget.routePath,
          builder: (context, params) => ExplanationPageWidget(
            explanation: params.getParam(
              'explanation',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PointsHistoryPageWidget.routeName,
          path: PointsHistoryPageWidget.routePath,
          builder: (context, params) => PointsHistoryPageWidget(),
        ),
        FFRoute(
          name: DetailCategoryViewallWidget.routeName,
          path: DetailCategoryViewallWidget.routePath,
          builder: (context, params) => DetailCategoryViewallWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
      observers: [routeObserver],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
