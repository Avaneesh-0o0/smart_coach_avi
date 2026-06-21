import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/datasources/break_binding_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/data/models/pneumatic_status_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/break_binding/domain/repositories/break_bindinng_repository.dart';
import 'package:firebase_database/firebase_database.dart';

@Injectable(as: BreakBindinngRepository)
class BreakBindinngRepositoryImpl implements BreakBindinngRepository {
  final BreakBindingRemoteDataSourceImpl remoteDataSource; // Kept for DI compatibility
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules/break_binding/coaches');

  BreakBindinngRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PneumaticStatusResponse> getPneumaticStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockData();
  }

  Future<void> _seedFirebaseWithMockData() async {
    final mockData = {
      "B1": {
        "coach_info": {
          "coach_type": "SL",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "BB-DEV-001": {
            "device_id": "BB-DEV-001",
            "brake_fault": "None",
            "brake_status": "Normal",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      },
      "B2": {
        "coach_info": {
          "coach_type": "SL",
          "train_number": "12951",
          "train_name": "Rajdhani Express",
        },
        "devices": {
          "BB-DEV-002": {
            "device_id": "BB-DEV-002",
            "brake_fault": "Air Leak",
            "brake_status": "Binding",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      }
    };
    try {
      await _dbRef.set(mockData);
    } catch (e) {
      print("Could not seed Break Binding Firebase data: $e");
    }
  }

  PneumaticStatusResponse _getMockData() {
    return PneumaticStatusResponse(
      success: true,
      history: PneumaticHistory(
        data: [
          PneumaticHistoryData(
            deviceId: 'BB-DEV-001',
            coachNo: 'B1',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-002',
            coachNo: 'B2',
            trainNo: '12951',
            brakeFault: 'Air Leak',
            brakeStatus: 'Binding',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-003',
            coachNo: 'B3',
            trainNo: '12951',
            brakeFault: 'Wheel Skid',
            brakeStatus: 'Critical',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-004',
            coachNo: 'B4',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-005',
            coachNo: 'B5',
            trainNo: '12951',
            brakeFault: 'Piston Stroke Issue',
            brakeStatus: 'Warning',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-006',
            coachNo: 'B6',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-007',
            coachNo: 'B7',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-008',
            coachNo: 'B8',
            trainNo: '12951',
            brakeFault: 'Air Leak',
            brakeStatus: 'Warning',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-009',
            coachNo: 'B9',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
          PneumaticHistoryData(
            deviceId: 'BB-DEV-010',
            coachNo: 'B10',
            trainNo: '12951',
            brakeFault: 'None',
            brakeStatus: 'Normal',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ]
      )
    );
  }
}
