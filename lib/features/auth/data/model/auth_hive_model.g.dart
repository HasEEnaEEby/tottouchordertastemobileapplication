// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 0;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      id: fields[0] as String?,
      email: fields[1] as String,
      userType: fields[2] as String,
      status: fields[3] as String,
      profile: fields[4] as UserProfileHiveModel,
      metadata: fields[5] as AuthMetadataHiveModel,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.userType)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.profile)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileHiveModelAdapter extends TypeAdapter<UserProfileHiveModel> {
  @override
  final int typeId = 1;

  @override
  UserProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileHiveModel(
      username: fields[0] as String?,
      displayName: fields[1] as String?,
      phoneNumber: fields[2] as String?,
      profileImage: fields[3] as String?,
      additionalInfo: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.profileImage)
      ..writeByte(4)
      ..write(obj.additionalInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthMetadataHiveModelAdapter extends TypeAdapter<AuthMetadataHiveModel> {
  @override
  final int typeId = 2;

  @override
  AuthMetadataHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthMetadataHiveModel(
      createdAt: fields[0] as DateTime?,
      lastLoginAt: fields[1] as DateTime?,
      lastUpdatedAt: fields[2] as DateTime?,
      lastLoginIp: fields[3] as String?,
      securitySettings: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AuthMetadataHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.lastLoginAt)
      ..writeByte(2)
      ..write(obj.lastUpdatedAt)
      ..writeByte(3)
      ..write(obj.lastLoginIp)
      ..writeByte(4)
      ..write(obj.securitySettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthMetadataHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
