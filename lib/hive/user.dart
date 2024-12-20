import 'package:hive/hive.dart';
import 'package:tugas_akhir_pm/model/product_model.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String noTelepon;

  @HiveField(2)
  String alamat;

  @HiveField(3)
  String email;

  @HiveField(4)
  String password;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  List<Computers>? carts;

  User({
    required this.username,
    required this.noTelepon,
    required this.alamat,
    required this.email,
    required this.password,
    this.imagePath,
    required this.carts,
  });
}
