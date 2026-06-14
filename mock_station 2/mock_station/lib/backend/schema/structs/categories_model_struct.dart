// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class CategoriesModelStruct extends FFFirebaseStruct {
  CategoriesModelStruct({
    String? image,
    String? title,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _image = image,
        _title = title,
        super(firestoreUtilData);

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  static CategoriesModelStruct fromMap(Map<String, dynamic> data) =>
      CategoriesModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
      );

  static CategoriesModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CategoriesModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
      }.withoutNulls;

  static CategoriesModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      CategoriesModelStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CategoriesModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CategoriesModelStruct &&
        image == other.image &&
        title == other.title;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title]);
}

CategoriesModelStruct createCategoriesModelStruct({
  String? image,
  String? title,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CategoriesModelStruct(
      image: image,
      title: title,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CategoriesModelStruct? updateCategoriesModelStruct(
  CategoriesModelStruct? categoriesModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    categoriesModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCategoriesModelStructData(
  Map<String, dynamic> firestoreData,
  CategoriesModelStruct? categoriesModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (categoriesModel == null) {
    return;
  }
  if (categoriesModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && categoriesModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final categoriesModelData =
      getCategoriesModelFirestoreData(categoriesModel, forFieldValue);
  final nestedData =
      categoriesModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = categoriesModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCategoriesModelFirestoreData(
  CategoriesModelStruct? categoriesModel, [
  bool forFieldValue = false,
]) {
  if (categoriesModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(categoriesModel.toMap());

  // Add any Firestore field values
  categoriesModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCategoriesModelListFirestoreData(
  List<CategoriesModelStruct>? categoriesModels,
) =>
    categoriesModels
        ?.map((e) => getCategoriesModelFirestoreData(e, true))
        .toList() ??
    [];
