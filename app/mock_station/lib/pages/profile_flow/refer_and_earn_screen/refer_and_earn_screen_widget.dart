import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
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
  final String referralCode = 'NNV9DB';
  String? upiId;

  void _showAddUpiDialog() {
    final textController = TextEditingController(text: upiId ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text('Add Your UPI ID', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your UPI ID to receive direct cashback into your bank account.',
              style: TextStyle(fontSize: 13.0, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'e.g. username@oksbi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                setState(() {
                  upiId = textController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID saved successfully!')),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        backgroundColor: const Color(0xFFF8FBFF),
        body: Column(
          children: [
            AppBarWidget(
              title: 'Refer & Earn',
              backIcon: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Pill & Hero Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F8F0), Color(0xFFF3F9FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.card_giftcard, size: 16.0, color: Color(0xFF059669)),
                                    SizedBox(width: 6.0),
                                    Text(
                                      'REFER & EARN',
                                      style: TextStyle(
                                        color: Color(0xFF059669),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 28.0,
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
                                    fontSize: 13.5,
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
                          Positioned(
                            right: -10,
                            top: 10,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 56.0,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Step 1
                    _buildStepCard(
                      icon: Icons.group_rounded,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF059669),
                      title: 'Invite Your Friends',
                      subtitle: 'Share Mock Station App with your friends',
                      stepNumber: '01',
                      stepColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 12.0),

                    // Step 2
                    _buildStepCard(
                      icon: Icons.percent_rounded,
                      iconBg: const Color(0xFFEDE9FE),
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Earn Up to 20% Cashback',
                      subtitle: 'You get up to 20% of the purchase amount as UPI cashback on your friend\'s purchase',
                      stepNumber: '02',
                      stepColor: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 12.0),

                    // Step 3
                    _buildStepCard(
                      icon: Icons.local_offer_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'They Get Up to 12% Discount',
                      subtitle: 'Your friends get up to 12% discount on their purchase with your code',
                      stepNumber: '03',
                      stepColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 20.0),

                    // Add UPI ID Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          style: BorderStyle.solid,
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
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF059669), size: 24.0),
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Icon(Icons.add_circle, size: 14.0, color: Color(0xFF059669)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upiId != null ? 'UPI ID: $upiId' : 'Add Your UPI ID',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  upiId != null ? 'Tap to edit your payout UPI' : 'Add your UPI ID to get cashback directly into your bank account!',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                            onPressed: _showAddUpiDialog,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Add UPI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0)),
                                SizedBox(width: 4.0),
                                Icon(Icons.chevron_right, color: Colors.white, size: 16.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Bottom Referral Code & Invite Bar
                    Row(
                      children: [
                        // Referral Code Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                                style: TextStyle(fontSize: 10.0, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Text(
                                    referralCode,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF059669),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: referralCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Referral code copied to clipboard!')),
                                      );
                                    },
                                    child: const Icon(Icons.copy_rounded, size: 18.0, color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Invite Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                            ),
                            onPressed: () {
                              Share.share(
                                'Use my referral code *$referralCode* to join Mock Station App and get up to 12% discount on your purchase! Download now: https://play.google.com/store/apps/details?id=com.mock.exam.app',
                                subject: 'Mock Station Referral',
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.share, color: Colors.white, size: 20.0),
                                SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invite Your Friends',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    Text(
                                      'Share Now & Start Earning',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ],
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
                          Icon(Icons.verified_user_outlined, size: 16.0, color: Color(0xFF059669)),
                          SizedBox(width: 6.0),
                          Text(
                            'Secure. Simple. Rewarding.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
                    fontSize: 15.0,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
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
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
