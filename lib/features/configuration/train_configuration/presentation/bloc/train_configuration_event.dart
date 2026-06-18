import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';

abstract class CoachConfigurationEvent {}

class LoadInitialData extends CoachConfigurationEvent {}

class LoadTrainConfigurationList extends CoachConfigurationEvent {}

class CreateEditTrainConfiguration extends CoachConfigurationEvent {
  final dynamic trainId; //for edit (dynamic to handle int/string from API)
  final TrainConfigurationRequest trainConfigurationRequest;

  CreateEditTrainConfiguration(this.trainConfigurationRequest, {this.trainId});
}

class DeleteTrainConfiguration extends CoachConfigurationEvent {
  final dynamic trainId;

  DeleteTrainConfiguration(this.trainId);
}
