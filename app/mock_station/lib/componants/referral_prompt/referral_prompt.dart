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

  // Don't ask users who already have a referrer on their account.
  final token = FFAppState().loginToken;
  if (token.isEmpty) return;
  var discountPercent = 10;
  try {
    final infoRes = await QuizGroup.getReferralInfoCall.call(token: token);
    discountPercent =
        QuizGroup.getReferralInfoCall.discountPercent(infoRes.jsonBody) ?? 10;
    final hasReferrer =
        QuizGroup.getReferralInfoCall.hasReferrer(infoRes.jsonBody) ?? false;
    if (hasReferrer) {
      await prefs.setBool(flagKey, true);
      return;
    }
  } catch (_) {
    // If the check fails, still allow the user to apply a code.
  }

  final codeController = TextEditingController();
  var applying = false;

  Future<void> finish() async {
    await prefs.setBool(flagKey, true);
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setModalState) {
        void closeDialog() {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        }

        Future<void> skip() async {
          await finish();
          closeDialog();
        }

        Future<void> applyCode() async {
          final code = codeController.text.trim();
          if (code.isEmpty) {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              const SnackBar(content: Text('Enter a referral code')),
            );
            return;
          }
          setModalState(() => applying = true);
          final res = await QuizGroup.applyReferralCodeCall.call(
            token: FFAppState().loginToken,
            referralCode: code,
          );
          final body = res.jsonBody;
          if (!dialogContext.mounted) return;
          setModalState(() => applying = false);
          final success =
              QuizGroup.applyReferralCodeCall.success(body) ?? false;
          final msg = QuizGroup.applyReferralCodeCall.message(body) ??
              'Failed to apply referral code';
          if (success) {
            await finish();
            closeDialog();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Referral applied — discount will apply on your first purchase!")),
              );
            }
          } else {
            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
        }

        const navy = Color(0xFF07133F);
        const blue = Color(0xFF087BFF);
        const orange = Color(0xFFFF8700);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = MediaQuery.sizeOf(context).width < 400;
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE5F7FF), Color(0xFFC8EAFF)],
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 12 : 16,
                            compact ? 10 : 14,
                            compact ? 12 : 16,
                            compact ? 10 : 14,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/referral_gift_reference.png',
                                width: compact ? 128 : 160,
                                height: compact ? 68 : 86,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: compact ? 5 : 7),
                              Text(
                                'Got a referral code?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: navy,
                                  fontSize: compact ? 19 : 22,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: const Color(0xFF34466F),
                                    fontSize: compact ? 12 : 14,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text:
                                            'If your friend invited you, enter their code & get up to '),
                                    TextSpan(
                                      text: '$discountPercent% discount',
                                      style: const TextStyle(
                                        color: blue,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const TextSpan(
                                        text: ' on any plan purchase.'),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: compact ? 8 : 12),
                              TextField(
                                controller: codeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. ABC12345',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7182A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.local_offer_outlined,
                                    color: blue,
                                    size: 26,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF269AFF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: const BorderSide(
                                        color: blue, width: 2.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: compact ? 8 : 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: compact ? 36 : 40,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: orange,
                                          disabledBackgroundColor:
                                              const Color(0xFFB5C4D7),
                                          elevation: 3,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(17)),
                                        ),
                                        onPressed: applying ? null : skip,
                                        child: Text(
                                          'Do not show again',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: compact ? 11 : 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: compact ? 36 : 40,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: blue,
                                          disabledBackgroundColor:
                                              const Color(0xFF9ABCE0),
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(17)),
                                        ),
                                        onPressed:
                                            applying ? null : applyCode,
                                        child: applying
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                'Apply  ›',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      compact ? 14 : 16,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        top: -42,
                        left: -42,
                        child: _ReferralCircle(size: 115),
                      ),
                      const Positioned(
                        bottom: -48,
                        right: -38,
                        child: _ReferralCircle(size: 125),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

class _ReferralCircle extends StatelessWidget {
  const _ReferralCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0x33269AFF),
            shape: BoxShape.circle,
          ),
        ),
      );
}
