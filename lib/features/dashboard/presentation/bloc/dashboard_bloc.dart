import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/repositories/train_configuration_repository.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/repositories/coach_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/repositories/device_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_bindinng_repository.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AcpRepository acpRepository;
  final CoachConfigurationRepository trainRepository;
  final SensorDeviceConfigurationRepository coachRepository;
  final DeviceConfigurationRepository deviceRepository;
  final SensorTypeConfigurationRepository sensorRepository;
  final BreakBindinngRepository breakBindingRepository;

  DashboardBloc(
    this.acpRepository,
    this.trainRepository,
    this.coachRepository,
    this.deviceRepository,
    this.sensorRepository,
    this.breakBindingRepository,
  ) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<NavigateToNotifications>(_onNavigateToNotifications);
    on<NavigateToSettings>(_onNavigateToSettings);
    on<NavigateToProfile>(_onNavigateToProfile);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    // Instantly return sample data as requested
    await Future.delayed(const Duration(milliseconds: 300)); // Slight delay for smooth UX transition

    final dummyAcpLogs = [
      AcpLogData(
        logId: 1,
        lastUpdated: DateTime.now().toIso8601String(),
        rawAssetName: "ACP_ASSET_1",
        acpStatus: "Active",
        trainNo: "12951",
        commCoachNo: "B1",
        techCoachNo: "LHB-1029",
        trainLocation: "New Delhi",
        powerCarNo: "PC-01",
        totalCount: "5",
        deviceId: "DEV_ACP_001",
      ),
      AcpLogData(
        logId: 2,
        lastUpdated: DateTime.now().toIso8601String(),
        rawAssetName: "ACP_ASSET_2",
        acpStatus: "Normal",
        trainNo: "12952",
        commCoachNo: "B2",
        techCoachNo: "LHB-1030",
        trainLocation: "Mumbai Central",
        powerCarNo: "PC-02",
        totalCount: "0",
        deviceId: "DEV_ACP_002",
      ),
    ];

    final dummyPneumaticLogs = [
      PneumaticHistoryData(
        createdAt: DateTime.now().toIso8601String(),
        deviceId: "DEV_PN_001",
        trainNo: "12951",
        coachNo: "B1",
        brakeFault: "Brake Binding",
        brakeStatus: "Critical",
      ),
    ];

    emit(
      DashboardDataLoaded(
        totalTrains: 5,
        smartCoaches: 24,
        activeDevices: 42,
        activeSensors: 108,
        criticalAlerts: 2,
        warnings: 1,
        moderate: 0,
        normalState: 45,
        recentAlerts: dummyAcpLogs,
        recentPneumaticAlerts: dummyPneumaticLogs,
      ),
    );
  }

  void _onNavigateToNotifications(
    NavigateToNotifications event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigateToNotifications());
  }

  void _onNavigateToSettings(
    NavigateToSettings event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigateToSettings());
  }

  void _onNavigateToProfile(
    NavigateToProfile event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigateToProfile());
  }
}
