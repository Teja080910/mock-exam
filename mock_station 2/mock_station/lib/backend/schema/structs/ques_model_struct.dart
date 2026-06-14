// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class OptionModel {
  final String text;
  final String image;
  OptionModel({required this.text, required this.image});

  factory OptionModel.fromMap(Map<String, dynamic> data) => OptionModel(
    text: data['text'] ?? '',
    image: data['image'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'text': text,
    'image': image,
  };
}

class QuesModelStruct extends FFFirebaseStruct {
  QuesModelStruct({
    String? questionTitle,
    String? questionType,
    String? answer,
    OptionModel? optionA,
    OptionModel? optionB,
    OptionModel? optionC,
    OptionModel? optionD,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _questionTitle = questionTitle,
        _questionType = questionType,
        _answer = answer,
        _optionA = optionA,
        _optionB = optionB,
        _optionC = optionC,
        _optionD = optionD,
        super(firestoreUtilData);

  // "question_title" field.
  String? _questionTitle;
  String get questionTitle => _questionTitle ?? '';
  set questionTitle(String? val) => _questionTitle = val;

  bool hasQuestionTitle() => _questionTitle != null;

  // "question_type" field.
  String? _questionType;
  String get questionType => _questionType ?? '';
  set questionType(String? val) => _questionType = val;

  bool hasQuestionType() => _questionType != null;

  // "answer" field.
  String? _answer;
  String get answer => _answer ?? '';
  set answer(String? val) => _answer = val;

  bool hasAnswer() => _answer != null;

  OptionModel? _optionA;
  OptionModel? _optionB;
  OptionModel? _optionC;
  OptionModel? _optionD;
  OptionModel? get optionA => _optionA;
  OptionModel? get optionB => _optionB;
  OptionModel? get optionC => _optionC;
  OptionModel? get optionD => _optionD;

  static QuesModelStruct fromMap(Map<String, dynamic> data) => QuesModelStruct(
        questionTitle: data['question_title'] as String?,
        questionType: data['question_type'] as String?,
        answer: data['answer'] as String?,
        optionA: data['option'] != null && data['option']['a'] != null ? OptionModel.fromMap(data['option']['a']) : null,
        optionB: data['option'] != null && data['option']['b'] != null ? OptionModel.fromMap(data['option']['b']) : null,
        optionC: data['option'] != null && data['option']['c'] != null ? OptionModel.fromMap(data['option']['c']) : null,
        optionD: data['option'] != null && data['option']['d'] != null ? OptionModel.fromMap(data['option']['d']) : null,
      );

  static QuesModelStruct? maybeFromMap(dynamic data) => data is Map
      ? QuesModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'question_title': _questionTitle,
        'question_type': _questionType,
        'answer': _answer,
        'option': {
          'a': _optionA?.toMap(),
          'b': _optionB?.toMap(),
          'c': _optionC?.toMap(),
          'd': _optionD?.toMap(),
        },
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'question_title': serializeParam(
          _questionTitle,
          ParamType.String,
        ),
        'question_type': serializeParam(
          _questionType,
          ParamType.String,
        ),
        'answer': serializeParam(
          _answer,
          ParamType.String,
        ),
      }.withoutNulls;

  static QuesModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      QuesModelStruct(
        questionTitle: deserializeParam(
          data['question_title'],
          ParamType.String,
          false,
        ),
        questionType: deserializeParam(
          data['question_type'],
          ParamType.String,
          false,
        ),
        answer: deserializeParam(
          data['answer'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'QuesModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is QuesModelStruct &&
        questionTitle == other.questionTitle &&
        questionType == other.questionType &&
        answer == other.answer;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([questionTitle, questionType, answer]);
}

QuesModelStruct createQuesModelStruct({
  String? questionTitle,
  String? questionType,
  String? answer,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    QuesModelStruct(
      questionTitle: questionTitle,
      questionType: questionType,
      answer: answer,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

QuesModelStruct? updateQuesModelStruct(
  QuesModelStruct? quesModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    quesModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addQuesModelStructData(
  Map<String, dynamic> firestoreData,
  QuesModelStruct? quesModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (quesModel == null) {
    return;
  }
  if (quesModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && quesModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final quesModelData = getQuesModelFirestoreData(quesModel, forFieldValue);
  final nestedData = quesModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = quesModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getQuesModelFirestoreData(
  QuesModelStruct? quesModel, [
  bool forFieldValue = false,
]) {
  if (quesModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(quesModel.toMap());

  // Add any Firestore field values
  quesModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getQuesModelListFirestoreData(
  List<QuesModelStruct>? quesModels,
) =>
    quesModels?.map((e) => getQuesModelFirestoreData(e, true)).toList() ?? [];
