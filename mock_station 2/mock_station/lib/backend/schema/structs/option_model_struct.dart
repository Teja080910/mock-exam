// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class OptionModelStruct extends FFFirebaseStruct {
  OptionModelStruct({
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _optionA = optionA,
        _optionB = optionB,
        _optionC = optionC,
        _optionD = optionD,
        super(firestoreUtilData);

  // "optionA" field.
  String? _optionA;
  String get optionA => _optionA ?? '';
  set optionA(String? val) => _optionA = val;

  bool hasOptionA() => _optionA != null;

  // "optionB" field.
  String? _optionB;
  String get optionB => _optionB ?? '';
  set optionB(String? val) => _optionB = val;

  bool hasOptionB() => _optionB != null;

  // "optionC" field.
  String? _optionC;
  String get optionC => _optionC ?? '';
  set optionC(String? val) => _optionC = val;

  bool hasOptionC() => _optionC != null;

  // "optionD" field.
  String? _optionD;
  String get optionD => _optionD ?? '';
  set optionD(String? val) => _optionD = val;

  bool hasOptionD() => _optionD != null;

  static OptionModelStruct fromMap(Map<String, dynamic> data) =>
      OptionModelStruct(
        optionA: data['optionA'] as String?,
        optionB: data['optionB'] as String?,
        optionC: data['optionC'] as String?,
        optionD: data['optionD'] as String?,
      );

  static OptionModelStruct? maybeFromMap(dynamic data) => data is Map
      ? OptionModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'optionA': _optionA,
        'optionB': _optionB,
        'optionC': _optionC,
        'optionD': _optionD,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'optionA': serializeParam(
          _optionA,
          ParamType.String,
        ),
        'optionB': serializeParam(
          _optionB,
          ParamType.String,
        ),
        'optionC': serializeParam(
          _optionC,
          ParamType.String,
        ),
        'optionD': serializeParam(
          _optionD,
          ParamType.String,
        ),
      }.withoutNulls;

  static OptionModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      OptionModelStruct(
        optionA: deserializeParam(
          data['optionA'],
          ParamType.String,
          false,
        ),
        optionB: deserializeParam(
          data['optionB'],
          ParamType.String,
          false,
        ),
        optionC: deserializeParam(
          data['optionC'],
          ParamType.String,
          false,
        ),
        optionD: deserializeParam(
          data['optionD'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'OptionModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OptionModelStruct &&
        optionA == other.optionA &&
        optionB == other.optionB &&
        optionC == other.optionC &&
        optionD == other.optionD;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([optionA, optionB, optionC, optionD]);
}

OptionModelStruct createOptionModelStruct({
  String? optionA,
  String? optionB,
  String? optionC,
  String? optionD,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    OptionModelStruct(
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

OptionModelStruct? updateOptionModelStruct(
  OptionModelStruct? optionModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    optionModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addOptionModelStructData(
  Map<String, dynamic> firestoreData,
  OptionModelStruct? optionModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (optionModel == null) {
    return;
  }
  if (optionModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && optionModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final optionModelData =
      getOptionModelFirestoreData(optionModel, forFieldValue);
  final nestedData =
      optionModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = optionModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getOptionModelFirestoreData(
  OptionModelStruct? optionModel, [
  bool forFieldValue = false,
]) {
  if (optionModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(optionModel.toMap());

  // Add any Firestore field values
  optionModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getOptionModelListFirestoreData(
  List<OptionModelStruct>? optionModels,
) =>
    optionModels?.map((e) => getOptionModelFirestoreData(e, true)).toList() ??
    [];
