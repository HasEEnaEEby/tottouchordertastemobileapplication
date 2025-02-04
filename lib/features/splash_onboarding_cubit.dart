import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_onboarding_state.dart';

class SplashOnboardingCubit extends Cubit<SplashOnboardingState> {
  SplashOnboardingCubit() : super(SplashOnboardingInitial());

  Future<void> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      if (onboardingCompleted) {
        emit(OnboardingCompletedState());
      } else {
        emit(OnboardingNotCompletedState());
      }
    } catch (e) {
      emit(OnboardingNotCompletedState());
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      emit(OnboardingCompletedState());
    } catch (e) {
      emit(SplashOnboardingErrorState(e.toString()));
    }
  }
  void updateVideoLoadingState(bool isLoaded) {
    emit(SplashVideoLoadingState(isLoaded));
  }
}
