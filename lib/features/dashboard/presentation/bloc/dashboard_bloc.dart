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
    final prevState = state;
    if (prevState is! DashboardDataLoaded) {
      emit(DashboardLoading());
    }

    try {
      // We use individual try-catches or a custom wrapper to be more resilient
      Future<T?> safeFetch<T>(Future<T> Function() call) async {
        try {
          return await call();
        } catch (e) {
          print("Dashboard fetch error: $e");
          return null;
        }
      }

      final results = await Future.wait([
        safeFetch(() => trainRepository.fetchTrainList()),
        safeFetch(() => coachRepository.fetchCoachList()),
        safeFetch(() => deviceRepository.fetchDevice()),
        safeFetch(() => sensorRepository.fetchSensor()),
        safeFetch(() => acpRepository.getAcpSummary()),
        safeFetch(() => breakBindingRepository.getPneumaticStatus()),
      ]);

      // If all failed and we have no old data, THEN show error
      if (results.every((element) => element == null) && prevState is! DashboardDataLoaded) {
        emit(DashboardError("Failed to connect to server. Please check your internet."));
        return;
      }

      // If some failed but we have previous data, we can blend or just fallback
      // For simplicity, if we have old data and new fetch failed significantly, we keep old
      if (results.any((e) => e == null) && prevState is DashboardDataLoaded) {
        // You could also emit a 'partial success' or snackbar here
        emit(prevState); 
        return;
      }

      final trains = (results[0] as List?) ?? (prevState is DashboardDataLoaded ? List.filled(prevState.totalTrains, null) : []);
      final allCoaches = (results[1] as List<CoachEntity>?) ?? [];
      final allDevices = (results[2] as List<DeviceEntity>?) ?? [];
      final allSensors = (results[3] as List<SensorTypeEntity>?) ?? [];
      final acpLogs = (results[4] as List<AcpLogData>?) ?? (prevState is DashboardDataLoaded ? prevState.recentAlerts : []);
      final pneumaticResponse = results[5] as PneumaticStatusResponse?;
      final allPneumaticLogs = pneumaticResponse?.history?.data ?? (prevState is DashboardDataLoaded ? prevState.recentPneumaticAlerts : []);

      // Filter: only configured coaches (with unique ID)
      final coaches = allCoaches.where((c) => c.coachUniqueId != null && c.coachUniqueId!.isNotEmpty).toList();
      // Filter: only active devices
      final devices = allDevices.where((d) => d.isActive == 1).toList();

      // Filter pneumatic logs: only Brake Binding and DV/BC Defect relevant alerts
      final pneumaticLogs = allPneumaticLogs.where((pLog) {
        final fault = pLog.brakeFault?.toString().toLowerCase() ?? '';
        final status = pLog.brakeStatus?.toString().toLowerCase() ?? '';
        final isRelevant = fault.contains('brake binding') ||
            fault.contains('dv/bc') ||
            fault.contains('dv_bc') ||
            fault.contains('bc defect') ||
            status.contains('brake binding') ||
            status.contains('dv/bc');
        // Also include if fault exists and is not "none"/"null" (catch-all for relevant issues)
        return isRelevant || (fault.isNotEmpty && fault != 'null' && fault != 'none' && fault != 'brake release system');
      }).toList();

      // Simple alert categorization logic
      int critical = 0;
      int warnings = 0;
      int moderate = 0;
      int normal = 0;

      for (var log in acpLogs) {
        final status = log.acpStatus?.toString().toLowerCase() ?? "";
        if (status.contains("active") || status.contains("pulled")) {
          critical++;
        } else if (status.contains("suspected")) {
          warnings++;
        } else if (status.contains("moderate")) {
          moderate++;
        } else {
          normal++;
        }
      }

      for (var pLog in pneumaticLogs) {
        final fault = pLog.brakeFault?.toString().toLowerCase() ?? "";
        final status = pLog.brakeStatus?.toString().toLowerCase() ?? "";
        if (fault.isNotEmpty && fault != "null" && fault != "none") {
          critical++;
        } else if (status.contains("fault") || status.contains("critical")) {
          critical++;
        }
      }

      emit(
        DashboardDataLoaded(
          totalTrains: trains.length,
          smartCoaches: coaches.length,
          activeDevices: devices.length,
          activeSensors: allSensors.length,
          criticalAlerts: critical,
          warnings: warnings,
          moderate: moderate,
          normalState: normal,
          recentAlerts: acpLogs.take(5).toList(),
          recentPneumaticAlerts: pneumaticLogs.take(5).toList(),
        ),
      );
    } catch (e) {
      if (prevState is DashboardDataLoaded) {
        emit(prevState);
      } else {
        emit(DashboardError("Failed to load dashboard data: ${e.toString()}"));
      }
    }
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
