import 'package:tugas_akhir_pm/model/base_network.dart';

class ApiDataSource {
  static ApiDataSource instance = ApiDataSource();

  Future<List<dynamic>> loadProducts() {
    return BaseNetwork.get(""); // Tidak perlu menambahkan endpoint
  }
}
