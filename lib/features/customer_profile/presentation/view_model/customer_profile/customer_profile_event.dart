import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

abstract class CustomerProfileEvent extends Equatable {
  const CustomerProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerProfileEvent extends CustomerProfileEvent {}

class UpdateCustomerProfileEvent extends CustomerProfileEvent {
  final CustomerProfileEntity profile;
  final File? imageFile;

  const UpdateCustomerProfileEvent(this.profile, {this.imageFile});

  @override
  List<Object?> get props => [profile, imageFile];
}

class UploadProfileImageEvent extends CustomerProfileEvent {
  final File imageFile;

  const UploadProfileImageEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class DeleteCustomerProfileEvent extends CustomerProfileEvent {
  final String userId;

  const DeleteCustomerProfileEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
