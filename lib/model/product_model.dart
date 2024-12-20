import 'package:hive/hive.dart';

part 'product_model.g.dart';

class Computers {
  String? id;
  String? nama;
  String? harga;
  String? gambar;
  String? tipe;
  String? deskripsi;

  Computers({
    this.id,
    this.nama,
    this.harga,
    this.gambar,
    this.tipe,
    this.deskripsi,
  });

  Computers.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    nama = json['nama'] as String?;
    harga = json['harga'] as String?;
    gambar = json['gambar'] as String?;
    tipe = json['tipe'] as String?;
    deskripsi = json['deskripsi'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['nama'] = nama;
    json['harga'] = harga;
    json['gambar'] = gambar;
    json['tipe'] = tipe;
    json['deskripsi'] = deskripsi;
    return json;
  }
}
