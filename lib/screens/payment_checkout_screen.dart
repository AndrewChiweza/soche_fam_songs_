import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soche_fam_songs/components/app_snack_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payment_due.dart';
import '../services/paychangu_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final PaymentDue payment;
  final String currentMemberName;
  final String currentMemberEmail;

  const PaymentCheckoutScreen({
    super.key,
    required this.payment,
    required this.currentMemberName,
    required this.currentMemberEmail,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;
  String? _checkoutUrl;
  WebViewController? _webViewController;

  String _detectedOperator = "Enter Number";
  Color _operatorColor = Colors.grey;

  /// Detect Malawian telecommunications mobile network operators dynamically based on the starting digits
  void _detectOperator(String value) {
    final cleanNum = value.replaceAll(RegExp(r'\s+'), '');
    if (cleanNum.startsWith('08') || cleanNum.startsWith('+2658')) {
      setState(() {
        _detectedOperator = "TNM Mpamba";
        _operatorColor = Colors.green.shade700;
      });
    } else if (cleanNum.startsWith('09') || cleanNum.startsWith('+2659')) {
      setState(() {
        _detectedOperator = "Airtel Money";
        _operatorColor = Colors.red.shade700;
      });
    } else {
      setState(() {
        _detectedOperator = "Unknown/Not Specified";
        _operatorColor = Colors.grey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the web checkout URL is verified, swap out the form layer for a secure interactive WebView portal
    if (_checkoutUrl != null) {
      _webViewController ??= WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              // Intercept callbacks when successful confirmation responses are retrieved
              if (url.contains('success')) {
                AppSnackBar.showSuccess(
                    context, "Payment completed successfully!");
                Navigator.pop(context);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(_checkoutUrl!));

      return Scaffold(
        appBar: AppBar(title: Text(widget.payment.title)),
        body: WebViewWidget(controller: _webViewController!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contribution Details Card
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.payment.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(widget.payment.description,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Amount Due:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(
                            "MWK ${widget.payment.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00674F)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text("Mobile Money Credentials",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Phone Field with Dynamic Operator Indicator Tag UI
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number (08XXX / 09XXX)",
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: _operatorColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: UnconstrainedBox(
                      child: Text(
                        _detectedOperator,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                onChanged: _detectOperator,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Please enter your number";
                  if (v.length < 9)
                    return "Enter a valid Malawian phone formatting sequence";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submission Button Control
              _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00674F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isProcessing = true);

                          final uniqueRef =
                              "soche-${DateTime.now().millisecondsSinceEpoch}";

                          final url = await PayChanguService.initializePayment(
                            amount: widget.payment.amount,
                            email: widget.currentMemberEmail,
                            name: widget.currentMemberName,
                            phoneNumber: _phoneCtrl.text.trim(),
                            paymentTitle: widget.payment.title,
                            transactionReference: uniqueRef,
                          );

                          setState(() => _isProcessing = false);

                          if (url != null) {
                            setState(() {
                              _checkoutUrl = url;
                            });
                          } else {
                            AppSnackBar.showError(context,
                                "Could not initialize payment with PayChangu. Try again.");
                          }
                        },
                        child: const Text("Pay via Mobile Money",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
