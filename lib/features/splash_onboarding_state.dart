part of 'splash_onboarding_cubit.dart';

abstract class SplashOnboardingState extends Equatable {
  const SplashOnboardingState();
  
  @override
  List<Object> get props => [];
}

class SplashOnboardingInitial extends SplashOnboardingState {}

class SplashVideoLoadingState extends SplashOnboardingState {
  final bool isLoaded;

  const SplashVideoLoadingState(this.isLoaded);

  @override
  List<Object> get props => [isLoaded];
}

class OnboardingNotCompletedState extends SplashOnboardingState {}

class OnboardingCompletedState extends SplashOnboardingState {}

class SplashOnboardingErrorState extends SplashOnboardingState {
  final String errorMessage;

  const SplashOnboardingErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}