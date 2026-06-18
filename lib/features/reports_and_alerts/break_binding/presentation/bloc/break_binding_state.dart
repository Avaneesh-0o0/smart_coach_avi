abstract class BrakeBindingState {}
class BrakeBindingInitial extends BrakeBindingState {}
class BrakeBindingLoading extends BrakeBindingState {}
class BrakeBindingLoaded extends BrakeBindingState {}
class BrakeBindingError extends BrakeBindingState {
  final String error;
  BrakeBindingError(this.error);
}
