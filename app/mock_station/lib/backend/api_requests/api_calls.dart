import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start Quiz Group Code

class QuizGroup {
  static String getBaseUrl({
    String? token = '',
  }) =>
      'http://192.168.3.137:6900/api/';
  static Map<String, String> headers = {
    'Authorization': 'Bearer [token]',
  };
  static CheckregistereduserApiCall checkregistereduserApiCall =
      CheckregistereduserApiCall();
  static UsersigninApiCall usersigninApiCall = UsersigninApiCall();
  static UsersignupApiCall usersignupApiCall = UsersignupApiCall();
  static UserverificationApiCall userverificationApiCall =
      UserverificationApiCall();
  static UserforgotpasswordApiCall userforgotpasswordApiCall =
      UserforgotpasswordApiCall();
  static UserforgotpasswordverificationApiCall
      userforgotpasswordverificationApiCall =
      UserforgotpasswordverificationApiCall();
  static UserresetpasswordApiCall userresetpasswordApiCall =
      UserresetpasswordApiCall();
  static UploadimageApiCall uploadimageApiCall = UploadimageApiCall();
  static GetuserApiCall getuserApiCall = GetuserApiCall();
  static UsereditprofileApiCall usereditprofileApiCall =
      UsereditprofileApiCall();
  static GetallbannerApiCall getallbannerApiCall = GetallbannerApiCall();
  static GetallquizzesApiCall getallquizzesApiCall = GetallquizzesApiCall();
  static GetquizbycategoryApiCall getquizbycategoryApiCall =
      GetquizbycategoryApiCall();
  static GetallquestionsApiCall getallquestionsApiCall =
      GetallquestionsApiCall();
  static GetquestionsbyquizidApiCall getquestionsbyquizidApiCall =
      GetquestionsbyquizidApiCall();
  static GetquestionsbycategoryidApiCall getquestionsbycategoryidApiCall =
      GetquestionsbycategoryidApiCall();
  static GetfeaturedcategoryApiCall getfeaturedcategoryApiCall =
      GetfeaturedcategoryApiCall();
  static GetadssettingsApiCall getadssettingsApiCall = GetadssettingsApiCall();
  static GetpointssettingApiCall getpointssettingApiCall =
      GetpointssettingApiCall();
  static StartquizApiCall startquizApiCall = StartquizApiCall();
  static QuizhistoryApiCall quizhistoryApiCall = QuizhistoryApiCall();
  static AddPointsApiCall addPointsApiCall = AddPointsApiCall();
  static GetpointsApiCall getpointsApiCall = GetpointsApiCall();
  static AddfavouritequizApiCall addfavouritequizApiCall =
      AddfavouritequizApiCall();
  static GetfavouritequizApiCall getfavouritequizApiCall =
      GetfavouritequizApiCall();
  static RemovefavouritequizApiCall removefavouritequizApiCall =
      RemovefavouritequizApiCall();
  static SelfchallangequizApiCall selfchallangequizApiCall =
      SelfchallangequizApiCall();
  static LeaderboardApiCall leaderboardApiCall = LeaderboardApiCall();
  static GetuserrankApiCall getuserrankApiCall = GetuserrankApiCall();
  static GetAllCategoriesCall getAllCategoriesCall = GetAllCategoriesCall();
  static GetCategoryGroupsCall getCategoryGroupsCall = GetCategoryGroupsCall();
  static GetPlanCall getPlanCall = GetPlanCall();
  static BuyPlanCall buyPlanCall = BuyPlanCall();
  static GetIntroAPICall getIntroAPICall = GetIntroAPICall();
  static ResendOTPCall resendOTPCall = ResendOTPCall();
  static PlanHistoryAPICall planHistoryAPICall = PlanHistoryAPICall();
  static IsVerifyAccountCall isVerifyAccountCall = IsVerifyAccountCall();
  static GetAllPagesCall getAllPagesCall = GetAllPagesCall();
  static GetNotificationsCall getNotificationsCall = GetNotificationsCall();
  static GetAllEbooksCall getAllEbooksCall = GetAllEbooksCall();
  static GetCarouselBannersCall getCarouselBannersCall = GetCarouselBannersCall();
  static GetSubcategoriesCall getSubcategoriesCall = GetSubcategoriesCall();
  static GetQuizBySubcategoryCall getQuizBySubcategoryCall = GetQuizBySubcategoryCall();
  static VerifyPaymentCall verifyPaymentCall = VerifyPaymentCall();
  static FetchUserPlanCall fetchUserPlanCall = FetchUserPlanCall();
}

class CheckregistereduserApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckregistereduserApi',
      apiUrl: '${baseUrl}checkregistereduser',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class UsersigninApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
    String? registrationToken = '',
    String? deviceId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}",
  "password": "${password}",
  "registrationToken": "${registrationToken}",
  "deviceId": "${deviceId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UsersigninApi',
      apiUrl: '${baseUrl}usersignin',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  String? userId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.userDetails.id''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? token(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.token''',
      ));
  dynamic userDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.userDetails''',
      );
}

class UsersignupApiCall {
  Future<ApiCallResponse> call({
    String? firstname = '',
    String? lastname = '',
    String? username = '',
    String? email = '',
    String? password = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "firstname": "${firstname}",
  "lastname": "${lastname}",
  "username": "${username}",
  "phone": "<phone>",
  "email": "${email}",
  "password": "${password}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UsersignupApi',
      apiUrl: '${baseUrl}usersignup',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class UserverificationApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    int? otp,
    String? deviceId = '',
    String? registrationToken = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}",
  "otp": ${otp},
  "registrationToken": "${registrationToken}",
  "deviceId": "${deviceId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UserverificationApi',
      apiUrl: '${baseUrl}userverification',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  dynamic dataList(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  dynamic userDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.userDetails''',
      );
}

class UserforgotpasswordApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UserforgotpasswordApi',
      apiUrl: '${baseUrl}userforgotpassword',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class UserforgotpasswordverificationApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    int? otp,
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
    "email": "${email}",
    "otp": ${otp}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UserforgotpasswordverificationApi',
      apiUrl: '${baseUrl}userforgotpasswordverification',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class UserresetpasswordApiCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? newpassword = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}",
  "newpassword": "${newpassword}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UserresetpasswordApi',
      apiUrl: '${baseUrl}userresetpassword',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class UploadimageApiCall {
  Future<ApiCallResponse> call({
    FFUploadedFile? image,
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'UploadimageApi',
      apiUrl: '${baseUrl}uploadimage?image=',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {
        'image': image,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic success(dynamic response) => getJsonField(
        response,
        r'''$.data.success''',
      );
}

class GetuserApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetuserApi',
      apiUrl: '${baseUrl}getuser',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic userCred(dynamic response) => getJsonField(
        response,
        r'''$.data.user''',
      );
  String? userId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.user.id''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class UsereditprofileApiCall {
  Future<ApiCallResponse> call({
    String? id = '',
    String? firstname = '',
    String? lastname = '',
    String? username = '',
    String? phone = '',
    String? image = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "id": "${id}",
  "firstname": "${firstname}",
  "lastname": "${lastname}",
  "username": "${username}",
  "phone": "${phone}",
  "image": "${image}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UsereditprofileApi',
      apiUrl: '${baseUrl}usereditprofile',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetallbannerApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetallbannerApi',
      apiUrl: '${baseUrl}getallbanner',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? bannerDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.bannerDetails''',
        true,
      ) as List?;
  List? quizIdList(dynamic response) => getJsonField(
        response,
        r'''$.data.bannerDetails[:].quizId''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetallquizzesApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetallquizzesApi',
      apiUrl: '${baseUrl}getallquizzes',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? quizDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.quizDetails''',
        true,
      ) as List?;
}

class GetquizbycategoryApiCall {
  Future<ApiCallResponse> call({
    String? categoryId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "categoryId": "${categoryId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetquizbycategoryApi',
      apiUrl: '${baseUrl}getquizbycategory',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? quizDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.quizDetails''',
        true,
      ) as List?;
}

class GetallquestionsApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetallquestionsApi',
      apiUrl: '${baseUrl}getallquestions',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? questionsDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.questionsDetails''',
        true,
      ) as List?;
}

class GetquestionsbyquizidApiCall {
  Future<ApiCallResponse> call({
    String? quizId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "quizId": "${quizId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetquestionsbyquizidApi',
      apiUrl: '${baseUrl}getquestionsbyquizid',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? questionTitleList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].question_title''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? questionTypeList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].question_type''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? answerList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].answer''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List? optionList(dynamic response) => getJsonField(
        response,
        r'''$.data.questionsDetails[:].option''',
        true,
      ) as List?;
  List? questionDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.questionsDetails''',
        true,
      ) as List?;
  List<String>? quizId(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].quizId''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetquestionsbycategoryidApiCall {
  Future<ApiCallResponse> call({
    String? categoryId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "categoryId": "${categoryId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetquestionsbycategoryidApi',
      apiUrl: '${baseUrl}getquestionsbycategoryid',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? questionsDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.questionsDetails''',
        true,
      ) as List?;
  List<String>? answerList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].answer''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? optionaList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].option.a''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? optionbList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].option.b''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? optioncList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].option.c''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? optiondList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].option.d''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? questionsList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].question_title''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List? optionList(dynamic response) => getJsonField(
        response,
        r'''$.data.questionsDetails[:].option''',
        true,
      ) as List?;
  List<String>? quizIDList(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].quizId''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  List<String>? type(dynamic response) => (getJsonField(
        response,
        r'''$.data.questionsDetails[:].question_type''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetfeaturedcategoryApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetfeaturedcategoryApi',
      apiUrl: '${baseUrl}getfeaturedcategory',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? categoryDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.categoryDetails''',
        true,
      ) as List?;
  List? quizzessList(dynamic response) => getJsonField(
        response,
        r'''$.data.categoryDetails[:].quizzes''',
        true,
      ) as List?;
}

class GetadssettingsApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetadssettingsApi',
      apiUrl: '${baseUrl}getadssettings',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? adsDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.adsDetails''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  int? banner(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.adsDetails[:].banner_ad''',
      ));
  int? interstial(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.adsDetails[:].interstitial_ad''',
      ));
  int? rewarded(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.adsDetails[:].rewarded_video_ad''',
      ));
  int? points(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.adsDetails[:].rewarded_points_for_each_video_ads''',
      ));
}

class GetpointssettingApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetpointssettingApi',
      apiUrl: '${baseUrl}getpointssetting',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? settingDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.settingDetails''',
        true,
      ) as List?;
  int? selfMode(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.settingDetails[:].self_challenge_mode''',
      ));
  int? correctPoints(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.settingDetails[:].correct_ans_reward_per_question''',
      ));
  int? penaltyPoints(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.settingDetails[:].penalty_per_question''',
      ));
  int? selfChallengePoints(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.settingDetails[:].self_challenge_correct_ans_reward_per_question''',
      ));
  double? selfChallengePenalty(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.data.settingDetails[:].self_challenge_penalty_per_question''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class StartquizApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? quizId = '',
    dynamic questionsJson,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? score,
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final questions = _serializeJson(questionsJson, true);
    final ffApiRequestBody = '''
{
  "userId": "${userId}",
  "quizId": "${quizId}",
  "questions": ${questions},
  "total_questions": ${totalQuestions},
  "correct_answers": ${correctAnswers},
  "wrong_answers": ${wrongAnswers},
  "score": ${score}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'StartquizApi',
      apiUrl: '${baseUrl}startquiz',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? questionDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.quizDetails.questionDetails''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class QuizhistoryApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'QuizhistoryApi',
      apiUrl: '${baseUrl}quizhistory',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? quesList(dynamic response) => getJsonField(
        response,
        r'''$.data.historydetails[:].questionDetails''',
        true,
      ) as List?;
  List? quizDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.historydetails[:].quizDetails''',
        true,
      ) as List?;
  List<String>? nameList(dynamic response) => (getJsonField(
        response,
        r'''$.data.historydetails[:].quizDetails.name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? imageList(dynamic response) => (getJsonField(
        response,
        r'''$.data.historydetails[:].quizDetails.image''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? timeList(dynamic response) => (getJsonField(
        response,
        r'''$.data.historydetails[:].quizDetails.minutes_per_quiz''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? categoryId(dynamic response) => (getJsonField(
        response,
        r'''$.data.historydetails[:].quizDetails.categoryId''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? totalQues(dynamic response) => (getJsonField(
        response,
        r'''$.data.historydetails[:].total_questions''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List? historyDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.historydetails''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class AddPointsApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    double? points,
    String? description = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
    "userId": "${userId}",
    "points": ${points},
    "description": "${description}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddPointsApi',
      apiUrl: '${baseUrl}addPoints',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class GetpointsApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetpointsApi',
      apiUrl: '${baseUrl}getpoints',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  List? pointsDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.pointsDetails''',
        true,
      ) as List?;
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class AddfavouritequizApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? quizId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}",
  "quizId": "${quizId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddfavouritequizApi',
      apiUrl: '${baseUrl}addfavouritequiz',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetfavouritequizApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetfavouritequizApi',
      apiUrl: '${baseUrl}getfavouritequiz',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? favouriteQuizList(dynamic response) => getJsonField(
        response,
        r'''$.data.favouriteQuiz''',
        true,
      ) as List?;
}

class RemovefavouritequizApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? quizId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}",
  "quizId": "${quizId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'RemovefavouritequizApi',
      apiUrl: '${baseUrl}removefavouritequiz',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SelfchallangequizApiCall {
  Future<ApiCallResponse> call({
    String? quizId = '',
    String? totalQuestions = '',
    String? timer = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "quizId": "${quizId}",
  "total_questions": "${totalQuestions}",
  "timer": "${timer}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SelfchallangequizApi',
      apiUrl: '${baseUrl}selfchallangequiz',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? quizdetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.quizdetails''',
        true,
      ) as List?;
  List<String>? quizIdList(dynamic response) => (getJsonField(
        response,
        r'''$.data.quizdetails[:].quizId''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class LeaderboardApiCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'LeaderboardApi',
      apiUrl: '${baseUrl}leaderboard',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? userList(dynamic response) => getJsonField(
        response,
        r'''$.data.user''',
        true,
      ) as List?;
}

class GetuserrankApiCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetuserrankApi',
      apiUrl: '${baseUrl}getuserrank',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic points(dynamic response) => getJsonField(
        response,
        r'''$.data.user.points''',
      );
  dynamic user(dynamic response) => getJsonField(
        response,
        r'''$.data.user''',
      );
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class GetAllCategoriesCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetAllCategories',
      apiUrl: '${baseUrl}getallcategories',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? nameList(dynamic response) => (getJsonField(
        response,
        r'''$.data.categoryDetails[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List? category(dynamic response) => getJsonField(
        response,
        r'''$.data.categoryDetails''',
        true,
      ) as List?;
  List<String>? idList(dynamic response) => (getJsonField(
        response,
        r'''$.data.categoryDetails[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetCategoryGroupsCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    // Note: This endpoint is GET on backend as per apiRoute.js
    return ApiManager.instance.makeApiCall(
      callName: 'GetCategoryGroups',
      apiUrl: '${baseUrl.replaceAll('/api/', '')}/api/category-groups',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? groups(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

class GetPlanCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetPlan',
      apiUrl: '${baseUrl}get_plan',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? planDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.planDetails''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class BuyPlanCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? planId = '',
    int? points,
    int? price,
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}",
  "planId": "${planId}",
  "points": ${points},
  "price": ${price}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buy Plan',
      apiUrl: '${baseUrl}buyPlan',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? orderId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.orderId''',
      )) ?? castToType<String>(getJsonField(
        response,
        r'''$.data.orderId''',
      ));
  int? amount(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.amount''',
      )) ?? castToType<int>(getJsonField(
        response,
        r'''$.data.amount''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
}

class GetIntroAPICall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getIntroAPI',
      apiUrl: '${baseUrl}getintro',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? introDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.introDetails''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class ResendOTPCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'resendOTP',
      apiUrl: '${baseUrl}resendOtp',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class PlanHistoryAPICall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'planHistoryAPI',
      apiUrl: '${baseUrl}plan_history',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  List? planDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.planDetails''',
        true,
      ) as List?;
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class VerifyPaymentCall {
  Future<ApiCallResponse> call({
    String? razorpayOrderId = '',
    String? razorpayPaymentId = '',
    String? razorpaySignature = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "razorpay_order_id": "${razorpayOrderId}",
  "razorpay_payment_id": "${razorpayPaymentId}",
  "razorpay_signature": "${razorpaySignature}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Verify Payment',
      apiUrl: '${baseUrl}verifyPayment',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  String? planStatus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.planStatus''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
}

class FetchUserPlanCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'Fetch User Plan',
      apiUrl: '${baseUrl}fetchUserPlan',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  bool? isSelectedAll(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.isSelectedAll''',
      ));
  List? categoryGroupIds(dynamic response) => getJsonField(
        response,
        r'''$.categoryGroupIds''',
        true,
      ) as List?;
  String? planStatus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.planStatus''',
      ));
  int? price(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.price''',
      ));
  String? expiresAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.expiresAt''',
      ));
}

class IsVerifyAccountCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "email": "${email}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'isVerifyAccount',
      apiUrl: '${baseUrl}isVerifyAccount',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetAllPagesCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getAllPages',
      apiUrl: '${baseUrl}pages',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? termsAndConditions(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.pagesDetails[:].terms_and_conditions''',
      ));
  String? privacyPolicy(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.pagesDetails[:].privacy_policy''',
      ));
  String? aboutUs(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.pagesDetails[:].about_us''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetNotificationsCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    final ffApiRequestBody = '''
{
  "userId": "${userId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getNotifications',
      apiUrl: '${baseUrl}notifications',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? notificationsDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.notificationDetails''',
        true,
      ) as List?;
  String? timeStamp(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.notificationDetails[:].createdAt''',
      ));
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

/// End Quiz Group Code

class GetFeatureCategoryCall {
  static Future<ApiCallResponse> call({
    String? baseURL,
  }) async {
    baseURL ??= FFAppConstants.baseURL;

    return ApiManager.instance.makeApiCall(
      callName: 'getFeatureCategory',
      apiUrl: '${baseURL}api/getfeaturedcategory',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? quizzes(dynamic response) => getJsonField(
        response,
        r'''$.data.categoryDetails[:].quizzes''',
        true,
      ) as List?;
  static List? categoryDetails(dynamic response) => getJsonField(
        response,
        r'''$.data.categoryDetails''',
        true,
      ) as List?;
  static int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetquizbycategoryCall {
  static dynamic points(dynamic response) {
    return getJsonField(
      response,
      r'''$.data.user.points''',
    );
  }

  static int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));

  static Future<ApiCallResponse> call({
    String? baseURL,
    String? categoryId = '',
    String? token,
  }) async {
    baseURL ??= FFAppConstants.baseURL;
    print('GetquizbycategoryCall - Base URL: $baseURL');
    print('GetquizbycategoryCall - Category ID: $categoryId');

    final ffApiRequestBody = '''
{
  "categoryId": "${escapeStringForJson(categoryId)}"
}''';
    print('GetquizbycategoryCall - Request Body: $ffApiRequestBody');

    print('GetquizbycategoryCall - Auth Token: $token');

    try {
      final response = await ApiManager.instance.makeApiCall(
      callName: 'getquizbycategory',
        apiUrl: '${baseURL}api/getquizbycategory',
      callType: ApiCallType.POST,
        headers: {
          'Content-Type': 'application/json',
        },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      );

      print('GetquizbycategoryCall - Full Response: ${response.statusCode} - ${response.jsonBody}');
      return response;
    } catch (e) {
      print('GetquizbycategoryCall - Error: $e');
      rethrow;
    }
  }

  static List? quizDetailsList(dynamic response) => getJsonField(
        response,
        r'''$.data.quizDetails''',
        true,
      ) as List?;
  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

class GetAllEbooksCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetAllEbooks',
      apiUrl: '${baseUrl}getallebooks',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? ebooksList(dynamic response) => getJsonField(
        response,
        r'''$.data.ebooks''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GetCarouselBannersCall {
  Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(
      token: token,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'GetCarouselBanners',
      apiUrl: '${baseUrl}getcarouselbanners',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? bannersList(dynamic response) => getJsonField(
        response,
        r'''$.data.banners''',
        true,
      ) as List?;
  int? success(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.message''',
      ));
}

class GoogleSigninCall {
  static Future<ApiCallResponse> call({
    required String token,
    required String deviceId,
  }) async {
    try {
      print('Starting GoogleSigninCall...');
      final baseUrl = QuizGroup.getBaseUrl();
      print('Base URL: $baseUrl');
      print('Making Google Sign-In API call to: ${baseUrl}google-signin');
      
      // Force token refresh
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Current user status: ${currentUser != null ? 'Logged in' : 'Not logged in'}');
      
      if (currentUser != null) {
        print('Forcing token refresh...');
        try {
          final newToken = await currentUser.getIdToken(true); // Force refresh
          if (newToken != null) {
            print('New token obtained successfully');
            token = newToken;
          } else {
            print('Warning: Token refresh returned null, using existing token');
          }
        } catch (e) {
          print('Error refreshing token: $e');
          print('Using existing token as fallback');
        }
      } else {
        print('No current user found, using provided token');
      }
      
      final requestBody = jsonEncode({
        'token': token,
        'deviceId': deviceId,
      });
      
      print('Request body length: ${requestBody.length}');
      print('Device ID: $deviceId');

      print('Making API call...');
      final response = await ApiManager.instance.makeApiCall(
        callName: 'GoogleSignin',
        apiUrl: '${baseUrl}google-signin',
        callType: ApiCallType.POST,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        params: {},
        body: requestBody,
        bodyType: BodyType.JSON,
        returnBody: true,
        encodeBodyUtf8: true,
        decodeUtf8: true,
        cache: false,
      );

      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == -1) {
        print('Connection failed. Please check if the server is running and accessible.');
        throw Exception('Failed to connect to the server. Please check if the server is running and accessible.');
      }
      
      if (response.jsonBody != null) {
        print('API Response Body: ${response.jsonBody}');
        try {
          final responseData = jsonDecode(response.jsonBody);
          print('Parsed response data: $responseData');
        } catch (e) {
          print('Error parsing response JSON: $e');
        }
      } else {
        print('API Response Body is null');
      }

      print('GoogleSigninCall completed successfully');
      return response;
    } catch (e, stackTrace) {
      print('Error in GoogleSigninCall: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static bool success(dynamic response) {
    try {
      final responseData = jsonDecode(response.jsonBody);
      return responseData['success'] == 1;
    } catch (e) {
      print('Error parsing success from response: $e');
      return false;
    }
  }

  static String message(dynamic response) {
    try {
      final responseData = jsonDecode(response.jsonBody);
      return responseData['message'] ?? 'Unknown error occurred';
    } catch (e) {
      print('Error parsing message from response: $e');
      return 'Error parsing response';
    }
  }

  static String token(dynamic response) {
    try {
      final responseData = jsonDecode(response.jsonBody);
      return responseData['data']['token'] ?? '';
    } catch (e) {
      print('Error parsing token from response: $e');
      return '';
    }
  }

  static Map<String, dynamic> userDetails(dynamic response) {
    try {
      final responseData = jsonDecode(response.jsonBody);
      dynamic userData = responseData['data']['userDetails'];
      if (userData is List) {
        userData = userData.isNotEmpty ? userData[0] : null;
      }
      if (userData == null) {
        return {};
      }
      return {
        'id': userData['id']?.toString() ?? '',
        'email': userData['email']?.toString() ?? '',
        'firstname': userData['firstname']?.toString() ?? '',
        'lastname': userData['lastname']?.toString() ?? '',
        'username': userData['username']?.toString() ?? '',
        'image': userData['image']?.toString() ?? '',
        'phone': userData['phone']?.toString() ?? '',
        'points': userData['points']?.toString() ?? '0',
        'is_verified': userData['is_verified']?.toString() ?? '0',
        'created_at': userData['created_at']?.toString() ?? '',
        'updated_at': userData['updated_at']?.toString() ?? '',
      };
    } catch (e) {
      print('Error parsing user details from response: $e');
      return {};
    }
  }
}

class GetSubcategoriesCall {
  Future<ApiCallResponse> call({
    String? categoryId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(token: token);
    return ApiManager.instance.makeApiCall(
      callName: 'GetSubcategories',
      apiUrl: '${baseUrl}subcategories?categoryId=$categoryId',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? subcategoryList(dynamic response) => response as List?;
}

class GetQuizBySubcategoryCall {
  Future<ApiCallResponse> call({
    String? subcategoryId = '',
    String? token = '',
  }) async {
    final baseUrl = QuizGroup.getBaseUrl(token: token);
    final body = '{"subcategoryId": "$subcategoryId"}';
    return ApiManager.instance.makeApiCall(
      callName: 'GetQuizBySubcategory',
      apiUrl: '${baseUrl}getquizbysubcategory',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? quizList(dynamic response) => response != null && response['quizzes'] is List ? response['quizzes'] as List : [];
}
