import 'package:tottouchordertastemobileapplication/model/onboarding_step.dart';
import 'package:tottouchordertastemobileapplication/usecase/get_onboarding_steps_use_case.dart';

class OnboardingController {
  final GetOnboardingStepsUseCase getOnboardingStepsUseCase;

  OnboardingController(this.getOnboardingStepsUseCase);

  List<OnboardingStep> get steps => getOnboardingStepsUseCase.execute();

  void onNextPage(int currentPage, Function goToNextPage,
      Function navigateToRoleSelection) {
    if (currentPage < steps.length - 1) {
      goToNextPage();
    } else {
      navigateToRoleSelection();
    }
  }
}
