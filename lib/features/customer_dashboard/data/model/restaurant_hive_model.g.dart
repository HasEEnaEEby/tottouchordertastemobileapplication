// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestaurantHiveModelAdapter extends TypeAdapter<RestaurantHiveModel> {
  @override
  final int typeId = 10;

  @override
  RestaurantHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestaurantHiveModel()
      ..id = fields[0] as String
      ..username = fields[1] as String
      ..restaurantName = fields[2] as String
      ..location = fields[3] as String
      ..contactNumber = fields[4] as String
      ..quote = fields[5] as String
      ..status = fields[6] as String
      ..email = fields[7] as String
      ..createdAt = fields[8] as DateTime
      ..updatedAt = fields[9] as DateTime;
  }

  @override
  void write(BinaryWriter writer, RestaurantHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.restaurantName)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.contactNumber)
      ..writeByte(5)
      ..write(obj.quote)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
