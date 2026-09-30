import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/componants/app_dialog_shell/app_dialog_shell.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreenWidget extends StatefulWidget {
  const ReferAndEarnScreenWidget({super.key});

  static String routeName = 'refer_and_earn_screen';
  static String routePath = '/referAndEarnScreen';

  @override
  State<ReferAndEarnScreenWidget> createState() => _ReferAndEarnScreenWidgetState();
}

class _ReferAndEarnScreenWidgetState extends State<ReferAndEarnScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String referralCode = '';
  int cashbackPercent = 20;
  int discountPercent = 12;
  double totalCashback = 0;
  double totalRedeemed = 0;
  double walletBalance = 0;
  List<dynamic> cashbackRecords = [];
  List<dynamic> walletTransactions = [];
  bool hasReferrer = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralInfo();
  }

  Future<void> _loadReferralInfo() async {
    final token = FFAppState().loginToken;
    if (token.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final localCode = getJsonField(
      FFAppState().userDetils,
      r'''$.referral_code''',
    )?.toString() ?? '';
    if (localCode.isNotEmpty && referralCode.isEmpty) {
      setState(() {
        referralCode = localCode;
      });
    }

    final infoRes = await QuizGroup.getReferralInfoCall.call(token: token);
    final infoBody = infoRes.jsonBody;
    if (infoBody != null) {
      final code = QuizGroup.getReferralInfoCall.referralCode(infoBody) ?? '';
      setState(() {
        if (code.isNotEmpty) {
          referralCode = code;
        }
        cashbackPercent =
            QuizGroup.getReferralInfoCall.cashbackPercent(infoBody) ?? 20;
        discountPercent =
            QuizGroup.getReferralInfoCall.discountPercent(infoBody) ?? 12;
        hasReferrer = QuizGroup.getReferralInfoCall.hasReferrer(infoBody) ?? false;
        walletBalance =
            (QuizGroup.getReferralInfoCall.walletBalancePaise(infoBody) ?? 0) / 100;
      });
    }

    final cashRes = await QuizGroup.getReferralCashbacksCall.call(token: token);
    final cashBody = cashRes.jsonBody;
    if (cashBody != null) {
      setState(() {
        totalCashback = QuizGroup.getReferralCashbacksCall.totalEarned(cashBody) ?? 0;
        totalRedeemed = QuizGroup.getReferralCashbacksCall.totalRedeemed(cashBody) ?? 0;
        walletBalance =
            (QuizGroup.getReferralCashbacksCall.walletBalancePaise(cashBody) ?? 0) / 100;
        cashbackRecords =
            QuizGroup.getReferralCashbacksCall.cashbacks(cashBody) ?? [];
        walletTransactions =
            QuizGroup.getReferralCashbacksCall.transactions(cashBody) ?? [];
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AppBarWidget(
              title: 'Refer & Earn',
              backIcon: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // REFER & EARN pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.card_giftcard,
                                        size: 16.0, color: Color(0xFF059669)),
                                    SizedBox(width: 6.0),
                                    Text(
                                      'REFER & EARN',
                                      style: TextStyle(
                                        color: Color(0xFF059669),
                                        fontWeight: FontWeight.w800,
                                        fontSize: FFFont.f12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: FFFont.f24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                    height: 1.15,
                                  ),
                                  children: [
                                    TextSpan(text: 'Share More.\n'),
                                    TextSpan(
                                      text: 'Earn More.',
                                      style: TextStyle(color: Color(0xFF059669)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: FFFont.f14,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: 'Invite your friends to join '),
                                    TextSpan(
                                      text: 'Mock Station App',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                    TextSpan(text: ' and unlock exciting rewards!'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 150,
                          height: 170,
                          child: Image.asset(
                            'assets/images/refer_promo.jpeg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.card_giftcard_rounded,
                              size: 90.0,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Step 1
                    _buildStepCard(
                      icon: Icons.group_rounded,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF059669),
                      title: 'Invite Your Friends',
                      subtitle:
                          'Share Mock Station App with your friends',
                      stepNumber: '01',
                      stepColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 10.0),

                    // Step 2
                    _buildStepCard(
                      icon: Icons.percent_rounded,
                      iconBg: const Color(0xFFEDE9FE),
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Earn Up to $cashbackPercent% Cashback',
                      subtitle:
                          'You get up to $cashbackPercent% of the purchase amount as UPI cashback on your friend\'s purchase',
                      stepNumber: '02',
                      stepColor: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 10.0),

                    // Step 3
                    _buildStepCard(
                      icon: Icons.local_offer_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'They Get Up to $discountPercent% Discount',
                      subtitle:
                          'Your friends get up to $discountPercent% discount on their purchase with your code',
                      stepNumber: '03',
                      stepColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 20.0),

                    // Cashback Wallet Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 10.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded,
                                color: Color(0xFF059669), size: 24.0),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cashback Wallet Balance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: FFFont.f14,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '\u20b9${walletBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: FFFont.f24,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                const SizedBox(height: 3.0),
                                const Text(
                                  'Auto-applied on your next plan purchase',
                                  style: TextStyle(
                                    fontSize: FFFont.f12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Discount Active Banner
                    if (!_loading && hasReferrer) ...[
                      _buildDiscountBanner(),
                      const SizedBox(height: 16.0),
                    ],

                    // Cashback Summary
                    if (!_loading && referralCode.isNotEmpty) ...[
                      _buildCashbackSummary(),
                      const SizedBox(height: 20.0),
                    ],

                    // Bottom Referral Code & Invite Bar
                    Row(
                      children: [
                        // Referral Code Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Referral Code',
                                style: TextStyle(
                                    fontSize: FFFont.f10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4.0),
                               Row(
                                children: [
                                  Text(
                                    referralCode.isNotEmpty
                                        ? referralCode
                                        : (_loading ? 'Loading...' : '--------'),
                                    style: const TextStyle(
                                      fontSize: FFFont.f16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF059669),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  InkWell(
                                    onTap: () {
                                      if (referralCode.isNotEmpty) {
                                        Clipboard.setData(
                                            ClipboardData(text: referralCode));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Referral code copied to clipboard!')),
                                        );
                                      }
                                    },
                                    child: const Icon(Icons.copy_rounded,
                                        size: 18.0, color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Invite Button with WhatsApp style icon
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0)),
                            ),
                            onPressed: () {
                              if (referralCode.isNotEmpty) {
                                Share.share(
                                  'Use my referral code *$referralCode* to join Mock Station App and get up to $discountPercent% discount on your purchase! Download now: https://play.google.com/store/apps/details?id=com.mock.exam.app',
                                  subject: 'Mock Station Referral',
                                );
                              } else {
                                Share.share(
                                  'Join Mock Station App and get exciting test series and mock exams! Download now: https://play.google.com/store/apps/details?id=com.mock.exam.app',
                                  subject: 'Mock Station Referral',
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.chat_bubble_rounded,
                                        color: Color(0xFF059669), size: 18.0),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Invite Your Friends',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: FFFont.f14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Share Now & Start Earning',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: FFFont.f10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Footer security tag
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified_user_outlined,
                              size: 16.0, color: Color(0xFF059669)),
                          SizedBox(width: 6.0),
                          Text(
                            'Secure. Simple. Rewarding.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: FFFont.f12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.verified_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your referral is active!',
                  style: const TextStyle(
                    fontSize: FFFont.f14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You get $discountPercent% off on all plan purchases.',
                  style: const TextStyle(
                    fontSize: FFFont.f12,
                    color: Color(0xFF047857),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22059669),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 18.0),
              SizedBox(width: 8.0),
              Text(
                'Cashback Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: FFFont.f14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u20b9${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: FFFont.f20,
                      ),
                    ),
                    const Text(
                      'Available',
                      style: TextStyle(color: Colors.white70, fontSize: FFFont.f11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u20b9${totalRedeemed.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: FFFont.f20,
                      ),
                    ),
                    const Text(
                      'Used',
                      style: TextStyle(color: Colors.white70, fontSize: FFFont.f11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u20b9${totalCashback.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: FFFont.f20,
                      ),
                    ),
                    const Text(
                      'Total Earned',
                      style: TextStyle(color: Colors.white70, fontSize: FFFont.f11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (walletTransactions.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10.0),
            ...walletTransactions.take(6).map((tx) {
              final item = tx as Map;
              final isEarn = item['type'] == 'earn';
              final amountPaise =
                  int.tryParse((item['amountPaise'] ?? 0).toString()) ?? 0;
              final amount = (amountPaise / 100).toStringAsFixed(2);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                        isEarn
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 16.0,
                        color: Colors.white70),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        (item['title'] ?? '').toString().isNotEmpty
                            ? item['title'].toString()
                            : (isEarn ? 'Cashback earned' : 'Cashback used'),
                        style: const TextStyle(
                            color: Colors.white, fontSize: FFFont.f12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                        '${isEarn ? '+' : '-'}\u20b9$amount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: FFFont.f12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String stepNumber,
    required Color stepColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: iconColor, size: 24.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FFFont.f16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: FFFont.f12,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: stepColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: stepColor,
                  fontWeight: FontWeight.bold,
                  fontSize: FFFont.f14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
