// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class QuizModelStruct extends FFFirebaseStruct {
  QuizModelStruct({
    String? title,
    String? image,
    String? questions,
    String? minute,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _image = image,
        _questions = questions,
        _minute = minute,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "questions" field.
  String? _questions;
  String get questions => _questions ?? '';
  set questions(String? val) => _questions = val;

  bool hasQuestions() => _questions != null;

  // "minute" field.
  String? _minute;
  String get minute => _minute ?? '';
  set minute(String? val) => _minute = val;

  bool hasMinute() => _minute != null;

  static QuizModelStruct fromMap(Map<String, dynamic> data) => QuizModelStruct(
        title: data['title'] as String?,
        image: data['image'] as String?,
        questions: data['questions'] as String?,
        minute: data['minute'] as String?,
      );

  static QuizModelStruct? maybeFromMap(dynamic data) => data is Map
      ? QuizModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'image': _image,
        'questions': _questions,
        'minute': _minute,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'questions': serializeParam(
          _questions,
          ParamType.String,
        ),
        'minute': serializeParam(
          _minute,
          ParamType.String,
        ),
      }.withoutNulls;

  static QuizModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      QuizModelStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        questions: deserializeParam(
          data['questions'],
          ParamType.String,
          false,
        ),
        minute: deserializeParam(
          data['minute'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'QuizModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is QuizModelStruct &&
        title == other.title &&
        image == other.image &&
        questions == other.questions &&
        minute == other.minute;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([title, image, questions, minute]);
}

QuizModelStruct createQuizModelStruct({
  String? title,
  String? image,
  String? questions,
  String? minute,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    QuizModelStruct(
      title: title,
      image: image,
      questions: questions,
      minute: minute,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

QuizModelStruct? updateQuizModelStruct(
  QuizModelStruct? quizModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    quizModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addQuizModelStructData(
  Map<String, dynamic> firestoreData,
  QuizModelStruct? quizModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (quizModel == null) {
    return;
  }
  if (quizModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && quizModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final quizModelData = getQuizModelFirestoreData(quizModel, forFieldValue);
  final nestedData = quizModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = quizModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getQuizModelFirestoreData(
  QuizModelStruct? quizModel, [
  bool forFieldValue = false,
]) {
  if (quizModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(quizModel.toMap());

  // Add any Firestore field values
  quizModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getQuizModelListFirestoreData(
  List<QuizModelStruct>? quizModels,
) =>
    quizModels?.map((e) => getQuizModelFirestoreData(e, true)).toList() ?? [];
