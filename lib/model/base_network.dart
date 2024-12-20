import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static final String baseUrl = "https://computers-shop.vercel.app/computers";

  // Mengembalikan List<dynamic> sesuai respons API
  static Future<List<dynamic>> get(String endpoint) async {
    final String fullUrl =
        baseUrl; // Tidak perlu menambahkan endpoint karena sudah lengkap
    debugPrint("BaseNetwork - fullUrl : $fullUrl");
    final response = await http.get(Uri.parse(fullUrl));

    debugPrint("BaseNetwork - response : ${response.body}");

    if (response.statusCode == 200) {
      // Parsing body respons menjadi List<dynamic>
      return json.decode(response.body) as List<dynamic>;
    } else {
      // Melempar Exception jika ada masalah
      throw Exception(
          "Failed to fetch data. Status code: ${response.statusCode}");
    }
  }

  static void debugPrint(String value) {
    print("[BASE_NETWORK] - $value");
  }
}
