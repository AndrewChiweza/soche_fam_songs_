import 'dart:convert';
import 'package:http/http.dart' as http;

class PayChanguService {
  // ⚠️ Replace with your live Secret Key from your PayChangu Dashboard Settings Panel
  static const String _secretKey = "sec-test-FTyE4KlX49cQEUtnvw6lJgM5HByaS4A4";
  static const String _baseUrl = "https://paychangu.com";

  /// Initializes a mobile checkout request and yields a web payment tunnel string URL
  static Future<String?> initializePayment({
    required double amount,
    required String email,
    required String name,
    required String phoneNumber,
    required String paymentTitle,
    required String transactionReference,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/payment');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "amount": amount,
          "currency": "MWK",
          "email": email.isEmpty ? "info@sochefam.com" : email,
          "first_name": name,
          "last_name": "Member",
          "tx_ref": transactionReference,
          "callback_url": "https://paychangu.com", // Fallback complete screen
          "phone_number": phoneNumber,
          "customization": {
            "title": paymentTitle,
            "description": "Soche Fam Group Collection System"
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          // Extracts the hosted terminal URL to point our user's UI layout toward
          return responseData['data']['checkout_url'];
        }
      }
      return null;
    } catch (e) {
      print("PayChangu Initialization Error: $e");
      return null;
    }
  }
}
