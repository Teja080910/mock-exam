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

// import 'package:quiz_zee/custom_code/actions/rewarded_video_ad_init_action.dart';
// import 'package:quiz_zee/flutter_flow/admob_util.dart';

Future showRewardedVideoAd(
  int points,
  Future Function() onDismiss,
  Future Function() onFailed,
) async {
  // Add your function code here!

  // if (rewardedAd == null) {
  //   print('Rewarded Video Ad is not loaded yet.');
  //   await onFailed();
  //   return;
  // }

  // Assign callbacks before showing the ad
  // rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //   onAdDismissedFullScreenContent: (ad) async {
  //     ad.dispose();
  //     await onDismiss();
  //   },
  //   onAdFailedToShowFullScreenContent: (ad, error) async {
  //     ad.dispose();
  //     print('Failed to show full-screen content: ${error.message}');
  //     await onFailed();
  //     rewardedVideoAdInitAction(); // Reinitialize the ad after a failure
  //   },
  // );

  // Show the ad and reward the user
  // rewardedAd!.show(onUserEarnedReward: (ad, reward) {
  //   FFAppState().overAllPoints += points;
  //   print('User rewarded with $points points.');
  // });

  // rewardedAd = null;
}
