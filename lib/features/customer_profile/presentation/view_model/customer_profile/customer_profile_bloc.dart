import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/fetch_customer_profile_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/update_customer_profile_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/upload_profile_image_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_state.dart';

class CustomerProfileBloc
    extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  final FetchCustomerProfileUseCase _fetchProfileUseCase;
  final UpdateCustomerProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final AuthTokenManager _tokenManager;

  CustomerProfileBloc({
    required FetchCustomerProfileUseCase fetchProfileUseCase,
    required UpdateCustomerProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required AuthTokenManager tokenManager,
  })  : _fetchProfileUseCase = fetchProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _tokenManager = tokenManager,
        super(CustomerProfileInitial()) {
    on<FetchCustomerProfileEvent>(_onFetchProfile);
    on<UpdateCustomerProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
  }

  Future<void> _onFetchProfile(
    FetchCustomerProfileEvent event,
    Emitter<CustomerProfileState> emit,
  ) async {
    try {
      emit(CustomerProfileLoading());

      // Instead of getUserDataAsync(), use getUserData() which is available in your code
      final userData = _tokenManager.getUserData();
      final userId = userData?['id'];
      if (userId == null) {
        emit(const CustomerProfileError(
            'User ID not found. Please login again.'));
        return;
      }

      final result = await _fetchProfileUseCase(userId);

      result.fold(
        (failure) => emit(CustomerProfileError(failure.message)),
        (profile) => emit(CustomerProfileLoaded(profile)),
      );
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      emit(CustomerProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateCustomerProfileEvent event,
    Emitter<CustomerProfileState> emit,
  ) async {
    try {
      emit(CustomerProfileLoading());

      // Create a new variable for the updated profile rather than modifying the event.profile
      var updatedProfile = event.profile;

      // Process image upload first if there's an image file
      if (event.imageFile != null) {
        final imageResult = await _uploadProfileImageUseCase(event.imageFile!);

        imageResult.fold(
          (failure) {
            // Log error but continue with profile update
            debugPrint('Image upload failed: ${failure.message}');
          },
          (imageUrl) {
            // If image upload was successful, create new profile with the image URL
            updatedProfile = updatedProfile.copyWith(imageUrl: imageUrl);
          },
        );
      }

      // Now update the profile data with possibly updated profile
      final result = await _updateProfileUseCase(updatedProfile);

      result.fold(
        (failure) => emit(CustomerProfileError(failure.message)),
        (profile) {
          emit(ProfileUpdateSuccess(profile));
          emit(CustomerProfileLoaded(profile));
        },
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      emit(CustomerProfileError(e.toString()));
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<CustomerProfileState> emit,
  ) async {
    try {
      emit(CustomerProfileLoading());

      final imageResult = await _uploadProfileImageUseCase(event.imageFile);

      imageResult.fold(
        (failure) => emit(CustomerProfileError(failure.message)),
        (imageUrl) {
          // If we have the current profile state as loaded, update it with the new image URL
          final currentState = state;
          if (currentState is CustomerProfileLoaded) {
            final updatedProfile = currentState.profile.copyWith(
              imageUrl: imageUrl,
            );
            emit(ProfileImageUploadSuccess(imageUrl));
            emit(CustomerProfileLoaded(updatedProfile));
          } else {
            // Just emit the image upload success and trigger a profile fetch
            emit(ProfileImageUploadSuccess(imageUrl));
            add(FetchCustomerProfileEvent());
          }
        },
      );
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      emit(CustomerProfileError(e.toString()));
    }
  }
}
