import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showReferralPromptOnce(BuildContext context) async {
  final email = getJsonField(
    FFAppState().userDetils,
    r'''$.email''',
  ).toString();
  final accountKey = email.isNotEmpty
      ? email
      : FFAppState().userId.isNotEmpty
          ? FFAppState().userId
          : 'unknown';
  final flagKey = 'referral_prompt_done_$accountKey';
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(flagKey) ?? false) return;

  final codeController = TextEditingController();
  var applying = false;

  Future<void> finish() async {
    await prefs.setBool(flagKey, true);
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setModalState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.card_giftcard, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 10),
            Text('Got a referral code?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If your friend invited you, enter their code & get up to 12% discount on any plan purchase.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. ABC12345',
                prefixIcon: const Icon(Icons.local_offer_outlined,
                    size: 18, color: Color(0xFF10B981)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: finish,
            child: const Text('Skip',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: finish,
            child: const Text("Don't show again",
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: applying
                ? null
                : () async {
                    if (codeController.text.trim().isEmpty) return;
                    setModalState(() => applying = true);
                    final res = await QuizGroup.applyReferralCodeCall.call(
                      token: FFAppState().loginToken,
                      referralCode: codeController.text.trim(),
                    );
                    final body = res.jsonBody;
                    setModalState(() => applying = false);
                    final success =
                        QuizGroup.applyReferralCodeCall.success(body) ?? false;
                    final msg = QuizGroup.applyReferralCodeCall.message(body) ??
                        'Failed to apply referral code';
                    if (success) {
                      await finish();
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Referral applied — you'll get 12% off!")),
                      );
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
            child: applying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Apply',
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
