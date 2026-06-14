// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!\

import 'dart:io';

import 'package:image_picker/image_picker.dart';

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

File? _image;

final ImagePicker _picker = ImagePicker();

Future<void> pickImage(String source) async {
  if (source == "Gallery") {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        FFAppState().profileImage = _image!.path;
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  } else {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        FFAppState().profileImage = _image!.path;
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}
