import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'config/app_config.dart' as config;
import 'custom_code/utils/kiosk_helper.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _isInite = prefs.getBool('ff_isInite') ?? _isInite;
    });
    _safeInit(() {
      _isLogin = prefs.getBool('ff_isLogin') ?? _isLogin;
    });
    _safeInit(() {
      _introIndex = prefs.getInt('ff_introIndex') ?? _introIndex;
    });
    _safeInit(() {
      _favoriteList = prefs
              .getStringList('ff_favoriteList')
              ?.map((x) {
                try {
                  return QuizModelStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _favoriteList;
    });
    _safeInit(() {
      _userId = prefs.getString('ff_userId') ?? _userId;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_userDetils')) {
        try {
          _userDetils = jsonDecode(prefs.getString('ff_userDetils') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _profileImage = prefs.getString('ff_profileImage') ?? _profileImage;
    });
    _safeInit(() {
      _overAllPoints = prefs.getInt('ff_overAllPoints') ?? _overAllPoints;
    });
    _safeInit(() {
      _completedQuiz = prefs.getStringList('ff_completedQuiz')?.map((x) {
            try {
              return jsonDecode(x);
            } catch (e) {
              print("Can't decode persisted json. Error: $e.");
              return {};
            }
          }).toList() ??
          _completedQuiz;
    });
    _safeInit(() {
      _isQuizFirstTime =
          prefs.getBool('ff_isQuizFirstTime') ?? _isQuizFirstTime;
    });
    _safeInit(() {
      _profilePicture = prefs.getString('ff_profilePicture') ?? _profilePicture;
    });
    _safeInit(() {
      _isFirstTimeAds = prefs.getBool('ff_isFirstTimeAds') ?? _isFirstTimeAds;
    });
    _safeInit(() {
      _isSkipped = prefs.getBool('ff_isSkipped') ?? _isSkipped;
    });
    _safeInit(() {
      _isSelfModeChallenge =
          prefs.getBool('ff_isSelfModeChallenge') ?? _isSelfModeChallenge;
    });
    _safeInit(() {
      _loginToken = prefs.getString('ff_loginToken') ?? _loginToken;
    });
    _safeInit(() {
      _currentPassword =
          prefs.getString('ff_currentPassword') ?? _currentPassword;
    });
    _safeInit(() {
      _isReward = prefs.getBool('ff_isReward') ?? _isReward;
    });
    _safeInit(() {
      _Points = prefs.getInt('ff_Points') ?? _Points;
    });
    _safeInit(() {
      _countAd = prefs.getInt('ff_countAd') ?? _countAd;
    });
    _safeInit(() {
      _correctQuesPoints =
          prefs.getDouble('ff_correctQuesPoints') ?? _correctQuesPoints;
    });
    _safeInit(() {
      _wrongQuesPoints = prefs.getDouble('ff_wrongQuesPoints') ?? _wrongQuesPoints;
    });
    _safeInit(() {
      _isPremium = prefs.getBool('ff_isPremium') ?? _isPremium;
    });
    _safeInit(() {
      _countryCode = prefs.getString('ff_countryCode') ?? _countryCode;
    });
    _safeInit(() {
      _isBannerAd = prefs.getInt('ff_isBannerAd') ?? _isBannerAd;
    });
    _safeInit(() {
      _isInterstialAd = prefs.getInt('ff_isInterstialAd') ?? _isInterstialAd;
    });
    _safeInit(() {
      _isRewardedVideoAd =
          prefs.getInt('ff_isRewardedVideoAd') ?? _isRewardedVideoAd;
    });
    _safeInit(() {
      _rewardedPoints = prefs.getInt('ff_rewardedPoints') ?? _rewardedPoints;
    });
    _safeInit(() {
      _planStatus = prefs.getString('ff_planStatus') ?? _planStatus;
    });
    _safeInit(() {
      _subsIsSelectedAll =
          prefs.getBool('ff_subsIsSelectedAll') ?? _subsIsSelectedAll;
    });
    _safeInit(() {
      _allowedCategoryIds =
          prefs.getStringList('ff_allowedCategoryIds') ?? _allowedCategoryIds;
    });
    _safeInit(() {
      _expiresAt = prefs.getString('ff_expiresAt') ?? _expiresAt;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;
  set isInitializing(bool value) {
    _isInitializing = value;
    notifyListeners();
  }

  bool _isInite = false;
  bool get isInite => _isInite;
  set isInite(bool value) {
    _isInite = value;
    prefs.setBool('ff_isInite', value);
  }

  bool _isLogin = false;
  bool get isLogin => _isLogin;
  set isLogin(bool value) {
    _isLogin = value;
    prefs.setBool('ff_isLogin', value);
  }

  int _introIndex = 0;
  int get introIndex => _introIndex;
  set introIndex(int value) {
    _introIndex = value;
    prefs.setInt('ff_introIndex', value);
  }

  List<CategoriesModelStruct> _CategoriesList = [
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/7kciz8wqs06n/maths.png\",\"title\":\"Mathematic\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/ajmvrttxhwvf/english.png\",\"title\":\"English\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/zlxrsoflyywb/physics.png\",\"title\":\"Science\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/h1q0tzpeasr4/history.png\",\"title\":\"History\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/6eyep4elhwhv/medical.png\",\"title\":\"Medical\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/eeo13va7t22b/proggramming.png\",\"title\":\"Programing\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/yfd4s5dh01h4/run_1.png\",\"title\":\"Sports\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/gzongsf6cxvo/fi_4252973.png\",\"title\":\"Technology\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/zy5w86yqf6t5/fi_3418754.png\",\"title\":\"Academic\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/wnw1akqiloge/hindu.png\",\"title\":\"Religion\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/czzvofuu1l3c/coding_1.png\",\"title\":\"Codding\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/a9e8xsm9unc2/painting_1.png\",\"title\":\"Art\"}'))
  ];
  List<CategoriesModelStruct> get CategoriesList => _CategoriesList;
  set CategoriesList(List<CategoriesModelStruct> value) {
    _CategoriesList = value;
  }

  void addToCategoriesList(CategoriesModelStruct value) {
    CategoriesList.add(value);
  }

  void removeFromCategoriesList(CategoriesModelStruct value) {
    CategoriesList.remove(value);
  }

  void removeAtIndexFromCategoriesList(int index) {
    CategoriesList.removeAt(index);
  }

  void updateCategoriesListAtIndex(
    int index,
    CategoriesModelStruct Function(CategoriesModelStruct) updateFn,
  ) {
    CategoriesList[index] = updateFn(_CategoriesList[index]);
  }

  void insertAtIndexInCategoriesList(int index, CategoriesModelStruct value) {
    CategoriesList.insert(index, value);
  }

  List<QuizModelStruct> _academicQuiz = [
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Get smarter answer with science quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/77rwvzfs892k/Rectangle_5462.png\",\"questions\":\"06\",\"minute\":\"14\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Your knowledge with our ultimate quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/yl90zcisvn4n/Rectangle_5462-1.png\",\"questions\":\"25\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Test your brainpower with our engaging quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/dqrhgyxix1t7/Rectangle_5462-2.png\",\"questions\":\"06\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Take a free test your knowledge of science \",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/3tmktd91j8ea/Rectangle_5462-3.png\",\"questions\":\"25\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Take on our fun and exciting trivia challenge\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/7nnlcznbn0sp/Rectangle_5462-4.png\",\"questions\":\"06\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Find out with the ultimate  quiz showdown\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/mokte22jqxik/Rectangle_5462-5.png\",\"questions\":\"11\",\"minute\":\"11\"}'))
  ];
  List<QuizModelStruct> get academicQuiz => _academicQuiz;
  set academicQuiz(List<QuizModelStruct> value) {
    _academicQuiz = value;
  }

  void addToAcademicQuiz(QuizModelStruct value) {
    academicQuiz.add(value);
  }

  void removeFromAcademicQuiz(QuizModelStruct value) {
    academicQuiz.remove(value);
  }

  void removeAtIndexFromAcademicQuiz(int index) {
    academicQuiz.removeAt(index);
  }

  void updateAcademicQuizAtIndex(
    int index,
    QuizModelStruct Function(QuizModelStruct) updateFn,
  ) {
    academicQuiz[index] = updateFn(_academicQuiz[index]);
  }

  void insertAtIndexInAcademicQuiz(int index, QuizModelStruct value) {
    academicQuiz.insert(index, value);
  }

  List<QuizModelStruct> _popularQuiz = [
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Take a free test your know ledge of science \",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/3tmktd91j8ea/Rectangle_5462-3.png\",\"questions\":\"16\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Test your brainpower with \\nour engaging quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/gvto9tbbsihq/Rectangle_546211.png\",\"questions\":\"6\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Expand your knowledge with this educational quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/3gsoxa25wany/Rectangle_5462-111.png\",\"questions\":\"25\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Exercise your mind with this ultimate english quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/m9zhwpjcv6q4/Rectangle_5462-211.png\",\"questions\":\"30\",\"minute\":\"10\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Test your brain power with this tricky quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/3nbed30hanyw/Rectangle_5462-311.png\",\"questions\":\"6\",\"minute\":\"12\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Exciting journey of know ledge with doctor quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/njuh5mntmmqg/Rectangle_5462-411.png\",\"questions\":\"11\",\"minute\":\"11\"}'))
  ];
  List<QuizModelStruct> get popularQuiz => _popularQuiz;
  set popularQuiz(List<QuizModelStruct> value) {
    _popularQuiz = value;
  }

  void addToPopularQuiz(QuizModelStruct value) {
    popularQuiz.add(value);
  }

  void removeFromPopularQuiz(QuizModelStruct value) {
    popularQuiz.remove(value);
  }

  void removeAtIndexFromPopularQuiz(int index) {
    popularQuiz.removeAt(index);
  }

  void updatePopularQuizAtIndex(
    int index,
    QuizModelStruct Function(QuizModelStruct) updateFn,
  ) {
    popularQuiz[index] = updateFn(_popularQuiz[index]);
  }

  void insertAtIndexInPopularQuiz(int index, QuizModelStruct value) {
    popularQuiz.insert(index, value);
  }

  List<QuizModelStruct> _Discoverquiz = [
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"World of facts and trivia with our quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/ym9eai2hlqx2/Rectangle_115462.png\",\"questions\":\"5\",\"minute\":\"8\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Take on our codding quiz and prove your quiz iq\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/zstlsce4z6vi/Rectangle_115462-1.png\",\"questions\":\"7\",\"minute\":\"11\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Join the elite ranks of knowledge seekers\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/csvhfyqalhye/Rectangle11_5462-2.png\",\"questions\":\"4\",\"minute\":\"7\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Take a free test your knowledge of science \",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/dr4hfnzjnlwp/Rectangle_115462-3.png\",\"questions\":\"8\",\"minute\":\"5\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Test your trivia skills in our entertaining quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/98f95nbc7r4i/Rectangle11_5462-4.png\",\"questions\":\"4\",\"minute\":\"9\"}')),
    QuizModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Show your knowledge with our sport quiz\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/71i9evg2s5wa/Rectangle_115462-5.png\",\"questions\":\"4\",\"minute\":\"4\"}'))
  ];
  List<QuizModelStruct> get Discoverquiz => _Discoverquiz;
  set Discoverquiz(List<QuizModelStruct> value) {
    _Discoverquiz = value;
  }

  void addToDiscoverquiz(QuizModelStruct value) {
    Discoverquiz.add(value);
  }

  void removeFromDiscoverquiz(QuizModelStruct value) {
    Discoverquiz.remove(value);
  }

  void removeAtIndexFromDiscoverquiz(int index) {
    Discoverquiz.removeAt(index);
  }

  void updateDiscoverquizAtIndex(
    int index,
    QuizModelStruct Function(QuizModelStruct) updateFn,
  ) {
    Discoverquiz[index] = updateFn(_Discoverquiz[index]);
  }

  void insertAtIndexInDiscoverquiz(int index, QuizModelStruct value) {
    Discoverquiz.insert(index, value);
  }

  List<CategoriesModelStruct> _Categoriesdetiles = [
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/n33wol9nzmp7/bio.png\",\"title\":\"Biology\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/v2j4vlwevh27/sceince.png\",\"title\":\"Chemistry\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/390ccxar0gvc/physics1.png\",\"title\":\"Physics\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/bkm4arm0fcwm/education.png\",\"title\":\"Zoology\"}')),
    CategoriesModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/quiz-zee-clone-yox60p/assets/tgre4vecj42g/botany_1.png\",\"title\":\"Botany\"}'))
  ];
  List<CategoriesModelStruct> get Categoriesdetiles => _Categoriesdetiles;
  set Categoriesdetiles(List<CategoriesModelStruct> value) {
    _Categoriesdetiles = value;
  }

  void addToCategoriesdetiles(CategoriesModelStruct value) {
    Categoriesdetiles.add(value);
  }

  void removeFromCategoriesdetiles(CategoriesModelStruct value) {
    Categoriesdetiles.remove(value);
  }

  void removeAtIndexFromCategoriesdetiles(int index) {
    Categoriesdetiles.removeAt(index);
  }

  void updateCategoriesdetilesAtIndex(
    int index,
    CategoriesModelStruct Function(CategoriesModelStruct) updateFn,
  ) {
    Categoriesdetiles[index] = updateFn(_Categoriesdetiles[index]);
  }

  void insertAtIndexInCategoriesdetiles(
      int index, CategoriesModelStruct value) {
    Categoriesdetiles.insert(index, value);
  }

  List<QuizModelStruct> _favoriteList = [];
  List<QuizModelStruct> get favoriteList => _favoriteList;
  set favoriteList(List<QuizModelStruct> value) {
    _favoriteList = value;
    prefs.setStringList(
        'ff_favoriteList', value.map((x) => x.serialize()).toList());
  }

  void addToFavoriteList(QuizModelStruct value) {
    favoriteList.add(value);
    prefs.setStringList(
        'ff_favoriteList', _favoriteList.map((x) => x.serialize()).toList());
  }

  void removeFromFavoriteList(QuizModelStruct value) {
    favoriteList.remove(value);
    prefs.setStringList(
        'ff_favoriteList', _favoriteList.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromFavoriteList(int index) {
    favoriteList.removeAt(index);
    prefs.setStringList(
        'ff_favoriteList', _favoriteList.map((x) => x.serialize()).toList());
  }

  void updateFavoriteListAtIndex(
    int index,
    QuizModelStruct Function(QuizModelStruct) updateFn,
  ) {
    favoriteList[index] = updateFn(_favoriteList[index]);
    prefs.setStringList(
        'ff_favoriteList', _favoriteList.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInFavoriteList(int index, QuizModelStruct value) {
    favoriteList.insert(index, value);
    prefs.setStringList(
        'ff_favoriteList', _favoriteList.map((x) => x.serialize()).toList());
  }

  String _deviceId = '';
  String get deviceId => _deviceId;
  set deviceId(String value) {
    _deviceId = value;
  }

  String _userId = '';
  String get userId => _userId;
  set userId(String value) {
    _userId = value;
    prefs.setString('ff_userId', value);
  }

  dynamic _userDetils;
  dynamic get userDetils => _userDetils;
  set userDetils(dynamic value) {
    _userDetils = value;
    prefs.setString('ff_userDetils', jsonEncode(value));
  }

  String _userEmail = '';
  String get userEmail => _userEmail;
  set userEmail(String value) {
    _userEmail = value;
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
  }

  String _profileImage = '';
  String get profileImage => _profileImage;
  set profileImage(String value) {
    _profileImage = value;
    prefs.setString('ff_profileImage', value);
  }

  int _Index = 0;
  int get Index => _Index;
  set Index(int value) {
    _Index = value;
  }

  String _categoryID = '';
  String get categoryID => _categoryID;
  set categoryID(String value) {
    _categoryID = value;
  }

  Color _buttonColor = Color(4294243572);
  Color get buttonColor => _buttonColor;
  set buttonColor(Color value) {
    _buttonColor = value;
  }

  Color _buttonColor1 = Color(4294243572);
  Color get buttonColor1 => _buttonColor1;
  set buttonColor1(Color value) {
    _buttonColor1 = value;
  }

  Color _buttonColor2 = Color(4294243572);
  Color get buttonColor2 => _buttonColor2;
  set buttonColor2(Color value) {
    _buttonColor2 = value;
  }

  Color _buttonColor3 = Color(4294243572);
  Color get buttonColor3 => _buttonColor3;
  set buttonColor3(Color value) {
    _buttonColor3 = value;
  }

  int _quesIndex = 0;
  int get quesIndex => _quesIndex;
  set quesIndex(int value) {
    _quesIndex = value;
  }

  int _correctQues = 0;
  int get correctQues => _correctQues;
  set correctQues(int value) {
    _correctQues = value;
  }

  String _questionType = '';
  String get questionType => _questionType;
  set questionType(String value) {
    _questionType = value;
  }

  bool _isButton1 = false;
  bool get isButton1 => _isButton1;
  set isButton1(bool value) {
    _isButton1 = value;
  }

  bool _isButton2 = false;
  bool get isButton2 => _isButton2;
  set isButton2(bool value) {
    _isButton2 = value;
  }

  bool _isButton3 = false;
  bool get isButton3 => _isButton3;
  set isButton3(bool value) {
    _isButton3 = value;
  }

  bool _isButton4 = false;
  bool get isButton4 => _isButton4;
  set isButton4(bool value) {
    _isButton4 = value;
  }

  int _notAnswerQues = 0;
  int get notAnswerQues => _notAnswerQues;
  set notAnswerQues(int value) {
    _notAnswerQues = value;
  }

  String _catID = '';
  String get catID => _catID;
  set catID(String value) {
    _catID = value;
  }

  String _quizID = '';
  String get quizID => _quizID;
  set quizID(String value) {
    _quizID = value;
  }

  String _selectedQuizType = '';
  String get selectedQuizType => _selectedQuizType;
  set selectedQuizType(String value) {
    _selectedQuizType = value;
  }

  String _selectedQuizAmount = '';
  String get selectedQuizAmount => _selectedQuizAmount;
  set selectedQuizAmount(String value) {
    _selectedQuizAmount = value;
  }

  String _selectedQuizDuration = '';
  String get selectedQuizDuration => _selectedQuizDuration;
  set selectedQuizDuration(String value) {
    _selectedQuizDuration = value;
  }

  int _selfquiztime = 0;
  int get selfquiztime => _selfquiztime;
  set selfquiztime(int value) {
    _selfquiztime = value;
  }

  int _selfIndex = 0;
  int get selfIndex => _selfIndex;
  set selfIndex(int value) {
    _selfIndex = value;
  }

  String _userFirstName = '';
  String get userFirstName => _userFirstName;
  set userFirstName(String value) {
    _userFirstName = value;
  }

  String _userLastName = '';
  String get userLastName => _userLastName;
  set userLastName(String value) {
    _userLastName = value;
  }

  int _userPoints = 50;
  int get userPoints => _userPoints;
  set userPoints(int value) {
    _userPoints = value;
  }

  List<dynamic> _quesList = [];
  List<dynamic> get quesList => _quesList;
  set quesList(List<dynamic> value) {
    _quesList = value;
  }

  void addToQuesList(dynamic value) {
    quesList.add(value);
  }

  void removeFromQuesList(dynamic value) {
    quesList.remove(value);
  }

  void removeAtIndexFromQuesList(int index) {
    quesList.removeAt(index);
  }

  void updateQuesListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    quesList[index] = updateFn(_quesList[index]);
  }

  void insertAtIndexInQuesList(int index, dynamic value) {
    quesList.insert(index, value);
  }

  List<String> _usersAnswers = [];
  List<String> get usersAnswers => _usersAnswers;
  set usersAnswers(List<String> value) {
    _usersAnswers = value;
  }

  void addToUsersAnswers(String value) {
    usersAnswers.add(value);
  }

  void removeFromUsersAnswers(String value) {
    usersAnswers.remove(value);
  }

  void removeAtIndexFromUsersAnswers(int index) {
    usersAnswers.removeAt(index);
  }

  void updateUsersAnswersAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    usersAnswers[index] = updateFn(_usersAnswers[index]);
  }

  void insertAtIndexInUsersAnswers(int index, String value) {
    usersAnswers.insert(index, value);
  }

  int _overAllPoints = 50;
  int get overAllPoints => _overAllPoints;
  set overAllPoints(int value) {
    _overAllPoints = value;
    prefs.setInt('ff_overAllPoints', value);
  }

  String _userAnswer = '';
  String get userAnswer => _userAnswer;
  set userAnswer(String value) {
    _userAnswer = value;
  }

  String _userAns = '';
  String get userAns => _userAns;
  set userAns(String value) {
    _userAns = value;
  }

  List<dynamic> _completedQuiz = [];
  List<dynamic> get completedQuiz => _completedQuiz;
  set completedQuiz(List<dynamic> value) {
    _completedQuiz = value;
    prefs.setStringList(
        'ff_completedQuiz', value.map((x) => jsonEncode(x)).toList());
  }

  void addToCompletedQuiz(dynamic value) {
    completedQuiz.add(value);
    prefs.setStringList(
        'ff_completedQuiz', _completedQuiz.map((x) => jsonEncode(x)).toList());
  }

  void removeFromCompletedQuiz(dynamic value) {
    completedQuiz.remove(value);
    prefs.setStringList(
        'ff_completedQuiz', _completedQuiz.map((x) => jsonEncode(x)).toList());
  }

  void removeAtIndexFromCompletedQuiz(int index) {
    completedQuiz.removeAt(index);
    prefs.setStringList(
        'ff_completedQuiz', _completedQuiz.map((x) => jsonEncode(x)).toList());
  }

  void updateCompletedQuizAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    completedQuiz[index] = updateFn(_completedQuiz[index]);
    prefs.setStringList(
        'ff_completedQuiz', _completedQuiz.map((x) => jsonEncode(x)).toList());
  }

  void insertAtIndexInCompletedQuiz(int index, dynamic value) {
    completedQuiz.insert(index, value);
    prefs.setStringList(
        'ff_completedQuiz', _completedQuiz.map((x) => jsonEncode(x)).toList());
  }

  bool _isQuizFirstTime = false;
  bool get isQuizFirstTime => _isQuizFirstTime;
  set isQuizFirstTime(bool value) {
    _isQuizFirstTime = value;
    prefs.setBool('ff_isQuizFirstTime', value);
  }

  bool _isQuizActive = false;
  bool get isQuizActive => _isQuizActive;
  set isQuizActive(bool value) {
    _isQuizActive = value;
    // When a quiz starts, lock the device into kiosk mode (blocks the
    // notification shade, recents and home button). When it ends, unlock.
    if (value) {
      KioskHelper.start();
    } else {
      KioskHelper.stop();
    }
    notifyListeners();
  }

  /// Language selected in the exam UI ('en' or 'hi').
  String _quizLang = 'en';
  String get quizLang => _quizLang;
  set quizLang(String value) {
    _quizLang = value;
    notifyListeners();
  }

  int _LinearBarTimer = 6;
  int get LinearBarTimer => _LinearBarTimer;
  set LinearBarTimer(int value) {
    _LinearBarTimer = value;
  }

  String _profilePicture = '';
  String get profilePicture => _profilePicture;
  set profilePicture(String value) {
    _profilePicture = value;
    prefs.setString('ff_profilePicture', value);
  }

  String _keyId = config.AppConfig.razorpayKeyID;
  String get keyId => _keyId;
  set keyId(String value) {
    _keyId = value;
  }

  String _clientId = config.AppConfig.paypalClientId;
  String get clientId => _clientId;
  set clientId(String value) {
    _clientId = value;
  }

  String _secretKey = config.AppConfig.paypalSecretKey;
  String get secretKey => _secretKey;
  set secretKey(String value) {
    _secretKey = value;
  }

  String _cardHolderName = '';
  String get cardHolderName => _cardHolderName;
  set cardHolderName(String value) {
    _cardHolderName = value;
  }

  String _expiryDate = '';
  String get expiryDate => _expiryDate;
  set expiryDate(String value) {
    _expiryDate = value;
  }

  String _cardNumber = '';
  String get cardNumber => _cardNumber;
  set cardNumber(String value) {
    _cardNumber = value;
  }

  String _cvvCode = '';
  String get cvvCode => _cvvCode;
  set cvvCode(String value) {
    _cvvCode = value;
  }

  String _publishableKey = config.AppConfig.stripePublishableKey;

  String _planStatus = 'none';
  String get planStatus => _planStatus;
  set planStatus(String value) {
    _planStatus = value;
    prefs.setString('ff_planStatus', value);
    notifyListeners();
  }

  bool _subsIsSelectedAll = false;
  bool get subsIsSelectedAll => _subsIsSelectedAll;
  set subsIsSelectedAll(bool value) {
    _subsIsSelectedAll = value;
    prefs.setBool('ff_subsIsSelectedAll', value);
    notifyListeners();
  }

  List<String> _allowedCategoryIds = [];
  List<String> get allowedCategoryIds => _allowedCategoryIds;
  set allowedCategoryIds(List<String> value) {
    _allowedCategoryIds = value;
    prefs.setStringList('ff_allowedCategoryIds', value);
  }

  void addToAllowedCategoryIds(String value) {
    allowedCategoryIds.add(value);
    prefs.setStringList('ff_allowedCategoryIds', _allowedCategoryIds);
  }

  void removeFromAllowedCategoryIds(String value) {
    allowedCategoryIds.remove(value);
    prefs.setStringList('ff_allowedCategoryIds', _allowedCategoryIds);
  }

  void removeAtIndexFromAllowedCategoryIds(int index) {
    allowedCategoryIds.removeAt(index);
    prefs.setStringList('ff_allowedCategoryIds', _allowedCategoryIds);
  }

  void updateAllowedCategoryIdsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    allowedCategoryIds[index] = updateFn(_allowedCategoryIds[index]);
    prefs.setStringList('ff_allowedCategoryIds', _allowedCategoryIds);
  }

  void insertAtIndexInAllowedCategoryIds(int index, String value) {
    allowedCategoryIds.insert(index, value);
    prefs.setStringList('ff_allowedCategoryIds', _allowedCategoryIds);
  }

  String _expiresAt = '';
  String get expiresAt => _expiresAt;
  set expiresAt(String value) {
    _expiresAt = value;
    prefs.setString('ff_expiresAt', value);
    notifyListeners();
  }
  String get publishableKey => _publishableKey;
  set publishableKey(String value) {
    _publishableKey = value;
  }

  String _skip = 'skipped';
  String get skip => _skip;
  set skip(String value) {
    _skip = value;
  }

  String _stripeSecretKey = config.AppConfig.stripePublishableKey;
  String get stripeSecretKey => _stripeSecretKey;
  set stripeSecretKey(String value) {
    _stripeSecretKey = value;
  }

  String _tokenFcm = '';
  String get tokenFcm => _tokenFcm;
  set tokenFcm(String value) {
    _tokenFcm = value;
  }

  String _apiKey = config.AppConfig.firebaseApiKey;
  String get apiKey => _apiKey;
  set apiKey(String value) {
    _apiKey = value;
  }

  String _appID = config.AppConfig.firebaseAppId;
  String get appID => _appID;
  set appID(String value) {
    _appID = value;
  }

  String _projectID = config.AppConfig.firebaseProjectId;
  String get projectID => _projectID;
  set projectID(String value) {
    _projectID = value;
  }

  String _messagingSenderId = config.AppConfig.firebaseMessagingSenderId;
  String get messagingSenderId => _messagingSenderId;
  set messagingSenderId(String value) {
    _messagingSenderId = value;
  }

  String _adsBannerAndroidId = 'ca-app-pub-3940256099942544/9214589741';
  String get adsBannerAndroidId => _adsBannerAndroidId;
  set adsBannerAndroidId(String value) {
    _adsBannerAndroidId = value;
  }

  String _adsBannerIosId = 'ca-app-pub-3940256099942544/2435281174';
  String get adsBannerIosId => _adsBannerIosId;
  set adsBannerIosId(String value) {
    _adsBannerIosId = value;
  }

  String _adsInterstitialAndroidId = 'ca-app-pub-3940256099942544/1033173712';
  String get adsInterstitialAndroidId => _adsInterstitialAndroidId;
  set adsInterstitialAndroidId(String value) {
    _adsInterstitialAndroidId = value;
  }

  String _adsInterstitialIosId = 'ca-app-pub-3940256099942544/4411468910';
  String get adsInterstitialIosId => _adsInterstitialIosId;
  set adsInterstitialIosId(String value) {
    _adsInterstitialIosId = value;
  }

  bool _isFirstTimeAds = true;
  bool get isFirstTimeAds => _isFirstTimeAds;
  set isFirstTimeAds(bool value) {
    _isFirstTimeAds = value;
    prefs.setBool('ff_isFirstTimeAds', value);
  }

  List<dynamic> _notAnswerQuestion = [];
  List<dynamic> get notAnswerQuestion => _notAnswerQuestion;
  set notAnswerQuestion(List<dynamic> value) {
    _notAnswerQuestion = value;
  }

  void addToNotAnswerQuestion(dynamic value) {
    notAnswerQuestion.add(value);
  }

  void removeFromNotAnswerQuestion(dynamic value) {
    notAnswerQuestion.remove(value);
  }

  void removeAtIndexFromNotAnswerQuestion(int index) {
    notAnswerQuestion.removeAt(index);
  }

  void updateNotAnswerQuestionAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    notAnswerQuestion[index] = updateFn(_notAnswerQuestion[index]);
  }

  void insertAtIndexInNotAnswerQuestion(int index, dynamic value) {
    notAnswerQuestion.insert(index, value);
  }

  bool _isSkipped = false;
  bool get isSkipped => _isSkipped;
  set isSkipped(bool value) {
    _isSkipped = value;
    prefs.setBool('ff_isSkipped', value);
  }

  String _adsNativeVideoAndroid = 'ca-app-pub-3940256099942544/1044960115';
  String get adsNativeVideoAndroid => _adsNativeVideoAndroid;
  set adsNativeVideoAndroid(String value) {
    _adsNativeVideoAndroid = value;
  }

  String _adsRewardedVideoAndroidId = 'ca-app-pub-3940256099942544/5224354917';
  String get adsRewardedVideoAndroidId => _adsRewardedVideoAndroidId;
  set adsRewardedVideoAndroidId(String value) {
    _adsRewardedVideoAndroidId = value;
  }

  String _adsRewardedVideoIOSId = 'ca-app-pub-3940256099942544/1712485313';
  String get adsRewardedVideoIOSId => _adsRewardedVideoIOSId;
  set adsRewardedVideoIOSId(String value) {
    _adsRewardedVideoIOSId = value;
  }

  bool _isSelfModeChallenge = false;
  bool get isSelfModeChallenge => _isSelfModeChallenge;
  set isSelfModeChallenge(bool value) {
    _isSelfModeChallenge = value;
    prefs.setBool('ff_isSelfModeChallenge', value);
  }

  int _wrongQues = 0;
  int get wrongQues => _wrongQues;
  set wrongQues(int value) {
    _wrongQues = value;
  }

  int _correctSelfQues = 0;
  int get correctSelfQues => _correctSelfQues;
  set correctSelfQues(int value) {
    _correctSelfQues = value;
  }

  int _wrongSelfques = 0;
  int get wrongSelfques => _wrongSelfques;
  set wrongSelfques(int value) {
    _wrongSelfques = value;
  }

  String _loginToken = '';
  String get loginToken => _loginToken;
  set loginToken(String value) {
    _loginToken = value;
    _saveLoginToken(value);
    notifyListeners();
  }

  Future<void> _saveLoginToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ff_loginToken', token);
  }

  Future<void> loadLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    _loginToken = prefs.getString('ff_loginToken') ?? '';
    notifyListeners();
  }

  String _rewardedInterstitialAndroidId =
      'ca-app-pub-3940256099942544/5354046379';
  String get rewardedInterstitialAndroidId => _rewardedInterstitialAndroidId;
  set rewardedInterstitialAndroidId(String value) {
    _rewardedInterstitialAndroidId = value;
  }

  String _rewardedInterstitialIOSId = 'ca-app-pub-3940256099942544/6978759866';
  String get rewardedInterstitialIOSId => _rewardedInterstitialIOSId;
  set rewardedInterstitialIOSId(String value) {
    _rewardedInterstitialIOSId = value;
  }

  List<dynamic> _tfquesList = [];
  List<dynamic> get tfquesList => _tfquesList;
  set tfquesList(List<dynamic> value) {
    _tfquesList = value;
  }

  void addToTfquesList(dynamic value) {
    tfquesList.add(value);
  }

  void removeFromTfquesList(dynamic value) {
    tfquesList.remove(value);
  }

  void removeAtIndexFromTfquesList(int index) {
    tfquesList.removeAt(index);
  }

  void updateTfquesListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    tfquesList[index] = updateFn(_tfquesList[index]);
  }

  void insertAtIndexInTfquesList(int index, dynamic value) {
    tfquesList.insert(index, value);
  }

  List<dynamic> _imagequesList = [];
  List<dynamic> get imagequesList => _imagequesList;
  set imagequesList(List<dynamic> value) {
    _imagequesList = value;
  }

  void addToImagequesList(dynamic value) {
    imagequesList.add(value);
  }

  void removeFromImagequesList(dynamic value) {
    imagequesList.remove(value);
  }

  void removeAtIndexFromImagequesList(int index) {
    imagequesList.removeAt(index);
  }

  void updateImagequesListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    imagequesList[index] = updateFn(_imagequesList[index]);
  }

  void insertAtIndexInImagequesList(int index, dynamic value) {
    imagequesList.insert(index, value);
  }

  List<dynamic> _audioquesList = [];
  List<dynamic> get audioquesList => _audioquesList;
  set audioquesList(List<dynamic> value) {
    _audioquesList = value;
  }

  void addToAudioquesList(dynamic value) {
    audioquesList.add(value);
  }

  void removeFromAudioquesList(dynamic value) {
    audioquesList.remove(value);
  }

  void removeAtIndexFromAudioquesList(int index) {
    audioquesList.removeAt(index);
  }

  void updateAudioquesListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    audioquesList[index] = updateFn(_audioquesList[index]);
  }

  void insertAtIndexInAudioquesList(int index, dynamic value) {
    audioquesList.insert(index, value);
  }

  List<String> _quesType = [];
  List<String> get quesType => _quesType;
  set quesType(List<String> value) {
    _quesType = value;
  }

  void addToQuesType(String value) {
    quesType.add(value);
  }

  void removeFromQuesType(String value) {
    quesType.remove(value);
  }

  void removeAtIndexFromQuesType(int index) {
    quesType.removeAt(index);
  }

  void updateQuesTypeAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    quesType[index] = updateFn(_quesType[index]);
  }

  void insertAtIndexInQuesType(int index, String value) {
    quesType.insert(index, value);
  }

  int _selectedColorIndex = -1;
  int get selectedColorIndex => _selectedColorIndex;
  set selectedColorIndex(int value) {
    _selectedColorIndex = value;
  }

  int _noOfQues = 0;
  int get noOfQues => _noOfQues;
  set noOfQues(int value) {
    _noOfQues = value;
  }

  List<dynamic> _quesResponse = [];
  List<dynamic> get quesResponse => _quesResponse;
  set quesResponse(List<dynamic> value) {
    _quesResponse = value;
  }

  void addToQuesResponse(dynamic value) {
    quesResponse.add(value);
  }

  void removeFromQuesResponse(dynamic value) {
    quesResponse.remove(value);
  }

  void removeAtIndexFromQuesResponse(int index) {
    quesResponse.removeAt(index);
  }

  void updateQuesResponseAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    quesResponse[index] = updateFn(_quesResponse[index]);
  }

  void insertAtIndexInQuesResponse(int index, dynamic value) {
    quesResponse.insert(index, value);
  }

  List<dynamic> _quesReviewList = [];
  List<dynamic> get quesReviewList => _quesReviewList;
  set quesReviewList(List<dynamic> value) {
    _quesReviewList = value;
  }

  void addToQuesReviewList(dynamic value) {
    quesReviewList.add(value);
  }

  void removeFromQuesReviewList(dynamic value) {
    quesReviewList.remove(value);
  }

  void removeAtIndexFromQuesReviewList(int index) {
    quesReviewList.removeAt(index);
  }

  void updateQuesReviewListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    quesReviewList[index] = updateFn(_quesReviewList[index]);
  }

  void insertAtIndexInQuesReviewList(int index, dynamic value) {
    quesReviewList.insert(index, value);
  }

  String _token = '';
  String get token => _token;
  set token(String value) {
    _token = value;
  }

  String _currentPassword = '';
  String get currentPassword => _currentPassword;
  set currentPassword(String value) {
    _currentPassword = value;
    prefs.setString('ff_currentPassword', value);
  }

  bool _isReward = true;
  bool get isReward => _isReward;
  set isReward(bool value) {
    _isReward = value;
    prefs.setBool('ff_isReward', value);
  }

  int _Points = 0;
  int get Points => _Points;
  set Points(int value) {
    _Points = value;
    prefs.setInt('ff_Points', value);
  }

  int _countAd = 91;
  int get countAd => _countAd;
  set countAd(int value) {
    _countAd = value;
    prefs.setInt('ff_countAd', value);
  }

  double _correctQuesPoints = 0.0;
  double get correctQuesPoints => _correctQuesPoints;
  set correctQuesPoints(double value) {
    _correctQuesPoints = value;
    prefs.setDouble('ff_correctQuesPoints', value);
  }

  double _wrongQuesPoints = 0.0;
  double get wrongQuesPoints => _wrongQuesPoints;
  set wrongQuesPoints(double value) {
    _wrongQuesPoints = value;
    prefs.setDouble('ff_wrongQuesPoints', value);
  }

  bool _isAdLoad = false;
  bool get isAdLoad => _isAdLoad;
  set isAdLoad(bool value) {
    _isAdLoad = value;
  }

  bool _isPremium = false;
  bool get isPremium => _isPremium;
  set isPremium(bool value) {
    _isPremium = value;
    prefs.setBool('ff_isPremium', value);
  }

  String _phone = '';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
  }

  String _countryCode = '91';
  String get countryCode => _countryCode;
  set countryCode(String value) {
    _countryCode = value;
    prefs.setString('ff_countryCode', value);
  }

  int _isBannerAd = 0;
  int get isBannerAd => _isBannerAd;
  set isBannerAd(int value) {
    _isBannerAd = value;
    prefs.setInt('ff_isBannerAd', value);
  }

  int _isInterstialAd = 0;
  int get isInterstialAd => _isInterstialAd;
  set isInterstialAd(int value) {
    _isInterstialAd = value;
    prefs.setInt('ff_isInterstialAd', value);
  }

  int _isRewardedVideoAd = 0;
  int get isRewardedVideoAd => _isRewardedVideoAd;
  set isRewardedVideoAd(int value) {
    _isRewardedVideoAd = value;
    prefs.setInt('ff_isRewardedVideoAd', value);
  }

  int _rewardedPoints = 0;
  int get rewardedPoints => _rewardedPoints;
  set rewardedPoints(int value) {
    _rewardedPoints = value;
    prefs.setInt('ff_rewardedPoints', value);
  }

  int _selfChallengePoints = 0;
  int get selfChallengePoints => _selfChallengePoints;
  set selfChallengePoints(int value) {
    _selfChallengePoints = value;
  }

  int _selfChallengePenaltyPoints = 0;
  int get selfChallengePenaltyPoints => _selfChallengePenaltyPoints;
  set selfChallengePenaltyPoints(int value) {
    _selfChallengePenaltyPoints = value;
  }

  dynamic _pointJSON = jsonDecode('{\"point\":10}');
  dynamic get pointJSON => _pointJSON;
  set pointJSON(dynamic value) {
    _pointJSON = value;
  }

  List<String> _createdTimeStamp = [];
  List<String> get createdTimeStamp => _createdTimeStamp;
  set createdTimeStamp(List<String> value) {
    _createdTimeStamp = value;
  }

  void addToCreatedTimeStamp(String value) {
    createdTimeStamp.add(value);
  }

  void removeFromCreatedTimeStamp(String value) {
    createdTimeStamp.remove(value);
  }

  void removeAtIndexFromCreatedTimeStamp(int index) {
    createdTimeStamp.removeAt(index);
  }

  void updateCreatedTimeStampAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    createdTimeStamp[index] = updateFn(_createdTimeStamp[index]);
  }

  void insertAtIndexInCreatedTimeStamp(int index, String value) {
    createdTimeStamp.insert(index, value);
  }

  bool _connected = true;
  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
  }

  String _countryName = 'IN';
  String get countryName => _countryName;
  set countryName(String value) {
    _countryName = value;
  }

  String _country = '91';
  String get country => _country;
  set country(String value) {
    _country = value;
  }

  final _categoryViewallManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> categoryViewall({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _categoryViewallManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCategoryViewallCache() => _categoryViewallManager.clear();
  void clearCategoryViewallCacheKey(String? uniqueKey) =>
      _categoryViewallManager.clearRequest(uniqueKey);

  final _bannerManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> banner({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _bannerManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearBannerCache() => _bannerManager.clear();
  void clearBannerCacheKey(String? uniqueKey) =>
      _bannerManager.clearRequest(uniqueKey);

  final _completeManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> complete({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _completeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCompleteCache() => _completeManager.clear();
  void clearCompleteCacheKey(String? uniqueKey) =>
      _completeManager.clearRequest(uniqueKey);

  final _detailsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> details({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _detailsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearDetailsCache() => _detailsManager.clear();
  void clearDetailsCacheKey(String? uniqueKey) =>
      _detailsManager.clearRequest(uniqueKey);

  final _b2Manager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> b2({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _b2Manager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearB2Cache() => _b2Manager.clear();
  void clearB2CacheKey(String? uniqueKey) => _b2Manager.clearRequest(uniqueKey);

  final _featuredManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> featured({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _featuredManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFeaturedCache() => _featuredManager.clear();
  void clearFeaturedCacheKey(String? uniqueKey) =>
      _featuredManager.clearRequest(uniqueKey);

  final _notifyManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> notify({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _notifyManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearNotifyCache() => _notifyManager.clear();
  void clearNotifyCacheKey(String? uniqueKey) =>
      _notifyManager.clearRequest(uniqueKey);

  final _coinsManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> coins({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _coinsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCoinsCache() => _coinsManager.clear();
  void clearCoinsCacheKey(String? uniqueKey) =>
      _coinsManager.clearRequest(uniqueKey);

  final _coinsHistoryManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> coinsHistory({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _coinsHistoryManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearCoinsHistoryCache() => _coinsHistoryManager.clear();
  void clearCoinsHistoryCacheKey(String? uniqueKey) =>
      _coinsHistoryManager.clearRequest(uniqueKey);

  final _selfChalangeManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> selfChalange({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _selfChalangeManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearSelfChalangeCache() => _selfChalangeManager.clear();
  void clearSelfChalangeCacheKey(String? uniqueKey) =>
      _selfChalangeManager.clearRequest(uniqueKey);

  Map<String, dynamic>? _userData;
  bool _isLoggedIn = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _isLoggedIn;

  set userData(Map<String, dynamic>? value) {
    _userData = value;
    notifyListeners();
  }

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

Color? _colorFromIntValue(int? val) {
  if (val == null) {
    return null;
  }
  return Color(val);
}
