// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComputerAdapter extends TypeAdapter<Computers> {
  @override
  final int typeId = 2;

  @override
  Computers read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Computers(
      id: fields[0] as String?,
      nama: fields[1] as String?,
      harga: fields[2] as String?,
      gambar: fields[3] as String?,
      tipe: fields[4] as String?,
      deskripsi: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Computers obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.harga)
      ..writeByte(3)
      ..write(obj.gambar)
      ..writeByte(4)
      ..write(obj.tipe)
      ..writeByte(5)
      ..write(obj.deskripsi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
