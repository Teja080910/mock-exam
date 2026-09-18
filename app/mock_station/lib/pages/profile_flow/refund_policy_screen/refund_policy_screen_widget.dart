import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RefundPolicyScreenWidget extends StatefulWidget {
  const RefundPolicyScreenWidget({super.key});

  static String routeName = 'refund_policy_Screen';
  static String routePath = '/refundPolicyScreen';

  @override
  State<RefundPolicyScreenWidget> createState() =>
      _RefundPolicyScreenWidgetState();
}

class _RefundPolicyScreenWidgetState extends State<RefundPolicyScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBarWidget(
            title: 'Refund Policy',
            backIcon: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 28.0),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 22.0,
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'All subscription plans purchased through the Mock Station app are Non-Refundable. Once a subscription plan is purchased, no refund, cancellation, or payment reversal will be provided.',
                          style: TextStyle(
                            fontSize: 15.0,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildParagraph(
                  'This includes subscriptions for Mock Tests, Notes, eBooks and other Premium Content.',
                ),
                const SizedBox(height: 20.0),
                _buildContactParagraph(),
                const SizedBox(height: 20.0),
                _buildParagraph(
                  'Users are advised to carefully check the subscription plan, price, validity, and available features before making a payment.',
                ),
                const SizedBox(height: 20.0),
                _buildParagraph(
                  'By purchasing any subscription, the user agrees to this Refund Policy.',
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, {FontWeight? fontWeight}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.5,
        height: 1.6,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildContactParagraph() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.6,
          color: Color(0xFF334155),
        ),
        children: [
          const TextSpan(
            text:
                'However, in case of Payment Failure, Duplicate Payment, Unauthorized Transaction, or any other payment-related issue, users can contact us at ',
          ),
          TextSpan(
            text: 'support@mockstation.com',
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchURL('mailto:support@mockstation.com'),
          ),
          const TextSpan(
            text:
                ' with the payment screenshot and transaction details. The issue will be reviewed, and appropriate action will be taken after verification.',
          ),
        ],
      ),
    );
  }
}
