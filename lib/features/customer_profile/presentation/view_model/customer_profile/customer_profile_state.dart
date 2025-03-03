import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

abstract class CustomerProfileState extends Equatable {
  const CustomerProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CustomerProfileInitial extends CustomerProfileState {}

/// Loading state while operations are in progress
class CustomerProfileLoading extends CustomerProfileState {}

/// State when profile data has been loaded
class CustomerProfileLoaded extends CustomerProfileState {
  final CustomerProfileEntity profile;

  const CustomerProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile update is successful
class ProfileUpdateSuccess extends CustomerProfileState {
  final CustomerProfileEntity profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object> get props => [profile];
}

/// State when profile image upload is successful
class ProfileImageUploadSuccess extends CustomerProfileState {
  final String imageUrl;

  const ProfileImageUploadSuccess(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class ProfileDeleteSuccess extends CustomerProfileState {}

/// Error state for any profile-related errors
class CustomerProfileError extends CustomerProfileState {
  final String message;

  const CustomerProfileError(this.message);

  @override
  List<Object> get props => [message];
}
