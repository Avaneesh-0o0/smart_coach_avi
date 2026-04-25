import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';

class HotAxleDummyData {
  static const String trainName = '12615/6 Grand Trunk Express';
  static const String lastUpdated = '10:46 AM';


  static List<HotAxleCoachModel> generateCoaches() {
    return List.generate(20, (index) {
      final id = index + 1;
      return _buildCoach(id);
    });
  }

  static HotAxleCoachModel _buildCoach(int id) {
    String coachStatus = 'Good';
    String maxTemp = '${58 + id}°C';
    int axlesIssue = 0;

    if (id == 4)  { coachStatus = 'Warning';  maxTemp = '108°C'; axlesIssue = 1; }
    if (id == 11) { coachStatus = 'Warning';  maxTemp = '98°C';  axlesIssue = 1; }
    if (id == 7)  { coachStatus = 'Critical'; maxTemp = '112°C'; axlesIssue = 2; }
    if (id == 20) { coachStatus = 'Critical'; maxTemp = '108°C'; axlesIssue = 3; }

    return HotAxleCoachModel(
      coachNumber: 'Coach $id',
      status: coachStatus,
      maxTemp: maxTemp,
      axlesMonitored: 8,
      axlesIssue: axlesIssue,
      updateTime: '12m ago',
      axles: _buildAxles(id, coachStatus),
    );
  }

  static List<AxleModel> _buildAxles(int coachId, String coachStatus) {
    return List.generate(8, (i) {
      final axleNum = i + 1;
      String status = 'Good';

      if (coachStatus == 'Warning' && axleNum == 4) status = 'Warning';

      if (coachId == 7  && (axleNum == 3 || axleNum == 6)) status = 'Critical';
      if (coachId == 20 && (axleNum == 2 || axleNum == 5 || axleNum == 7)) status = 'Critical';

      final isIssue = status != 'Good';
      final normalTemp = '${60 + axleNum * 2}°C';
      final issueTemp = status == 'Critical' ? '112°C' : '108°C';

      return AxleModel(
        axleNumber: axleNum,
        status: status,
        maxTemp: isIssue ? issueTemp : normalTemp,
        currentTemp: isIssue ? issueTemp : normalTemp,
        sensorId: 'AX-C${coachId.toString().padLeft(2,'0')}-A0$axleNum',
        speed: '72 km/h',
        detectedAt: isIssue ? 'Today, 10:39 AM' : '-',
        location: isIssue ? _locations[coachId % _locations.length] : '-',
        lastMaintenance: '12 Jan, 2026',
        updateTime: '12m ago',
      );
    });
  }

  static const List<String> _locations = [
    'Near Nagda', 'Near Ratlam', 'Near Ujjain', 'Bhopal Junction',
    'Near Itarsi', 'Near Gwalior', 'Near Agra', 'Delhi Hazrat Nizamuddin',
  ];


  static List<AxleHistoryEntry> getHistory(
    String coachNumber,
    String period, {
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime(2026, 3, 12);
    final all = _allHistory[coachNumber] ?? [];

    DateTime cutoff;
    if (period == '7 Days') {
      cutoff = now.subtract(const Duration(days: 7));
    } else if (period == '30 Days') cutoff = now.subtract(const Duration(days: 30));
    else if (period == 'Custom' && from != null && to != null) {
      return all.where((e) => !e.date.isBefore(from) && !e.date.isAfter(to.add(const Duration(days: 1)))).toList();
    } else {
      cutoff = now.subtract(const Duration(days: 1)); // Live/default
    }
    return all.where((e) => e.date.isAfter(cutoff)).toList();
  }

  static final Map<String, List<AxleHistoryEntry>> _allHistory = {
    'Coach 4': [
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 4, sensorId: 'AX-C04-A04', maxTemp: '108°C', status: 'Warning',  speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',   date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 4, sensorId: 'AX-C04-A04', maxTemp: '102°C', status: 'Warning',  speed: '68 km/h', detectedAt: 'Yesterday | 08:15 AM', location: 'Near Ujjain',  date: DateTime(2026, 3, 11,  8, 15)),
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 2, sensorId: 'AX-C04-A02', maxTemp: '96°C',  status: 'Warning',  speed: '75 km/h', detectedAt: '10 Mar | 02:30 PM',   location: 'Near Ratlam',  date: DateTime(2026, 3, 10, 14, 30)),
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 4, sensorId: 'AX-C04-A04', maxTemp: '78°C',  status: 'Good',     speed: '70 km/h', detectedAt: '05 Mar | 11:00 AM',   location: 'Bhopal Jn',   date: DateTime(2026, 3,  5, 11,  0)),
      AxleHistoryEntry(coachNumber: 'Coach 4', axleNumber: 1, sensorId: 'AX-C04-A01', maxTemp: '70°C',  status: 'Good',     speed: '65 km/h', detectedAt: '20 Feb | 03:10 PM',   location: 'Near Agra',    date: DateTime(2026, 2, 20, 15, 10)),
    ],
    'Coach 7': [
      AxleHistoryEntry(coachNumber: 'Coach 7', axleNumber: 3, sensorId: 'AX-C07-A03', maxTemp: '112°C', status: 'Critical', speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',   date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 7', axleNumber: 6, sensorId: 'AX-C07-A06', maxTemp: '109°C', status: 'Critical', speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',   date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 7', axleNumber: 3, sensorId: 'AX-C07-A03', maxTemp: '104°C', status: 'Warning',  speed: '70 km/h', detectedAt: '09 Mar | 04:00 PM',   location: 'Near Gwalior', date: DateTime(2026, 3,  9, 16,  0)),
      AxleHistoryEntry(coachNumber: 'Coach 7', axleNumber: 5, sensorId: 'AX-C07-A05', maxTemp: '98°C',  status: 'Warning',  speed: '74 km/h', detectedAt: '01 Mar | 09:30 AM',   location: 'Near Noida',   date: DateTime(2026, 3,  1,  9, 30)),
      AxleHistoryEntry(coachNumber: 'Coach 7', axleNumber: 3, sensorId: 'AX-C07-A03', maxTemp: '88°C',  status: 'Good',     speed: '68 km/h', detectedAt: '15 Feb | 07:45 AM',   location: 'Near Delhi',   date: DateTime(2026, 2, 15,  7, 45)),
    ],
    'Coach 11': [
      AxleHistoryEntry(coachNumber: 'Coach 11', axleNumber: 4, sensorId: 'AX-C11-A04', maxTemp: '98°C',  status: 'Warning',  speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',  date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 11', axleNumber: 4, sensorId: 'AX-C11-A04', maxTemp: '94°C',  status: 'Warning',  speed: '69 km/h', detectedAt: '11 Mar | 01:15 PM',   location: 'Near Mathura',date: DateTime(2026, 3, 11, 13, 15)),
      AxleHistoryEntry(coachNumber: 'Coach 11', axleNumber: 2, sensorId: 'AX-C11-A02', maxTemp: '82°C',  status: 'Good',     speed: '71 km/h', detectedAt: '06 Mar | 11:00 AM',   location: 'Near Agra',   date: DateTime(2026, 3,  6, 11,  0)),
      AxleHistoryEntry(coachNumber: 'Coach 11', axleNumber: 4, sensorId: 'AX-C11-A04', maxTemp: '76°C',  status: 'Good',     speed: '67 km/h', detectedAt: '25 Feb | 08:30 AM',   location: 'Near Bhopal', date: DateTime(2026, 2, 25,  8, 30)),
    ],
    'Coach 20': [
      AxleHistoryEntry(coachNumber: 'Coach 20', axleNumber: 2, sensorId: 'AX-C20-A02', maxTemp: '108°C', status: 'Critical', speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',  date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 20', axleNumber: 5, sensorId: 'AX-C20-A05', maxTemp: '106°C', status: 'Critical', speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',  date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 20', axleNumber: 7, sensorId: 'AX-C20-A07', maxTemp: '103°C', status: 'Critical', speed: '72 km/h', detectedAt: 'Today | 10:39 AM',    location: 'Near Nagda',  date: DateTime(2026, 3, 12, 10, 39)),
      AxleHistoryEntry(coachNumber: 'Coach 20', axleNumber: 5, sensorId: 'AX-C20-A05', maxTemp: '96°C',  status: 'Warning',  speed: '70 km/h', detectedAt: '07 Mar | 02:45 PM',   location: 'Near Ujjain', date: DateTime(2026, 3,  7, 14, 45)),
      AxleHistoryEntry(coachNumber: 'Coach 20', axleNumber: 2, sensorId: 'AX-C20-A02', maxTemp: '78°C',  status: 'Good',     speed: '73 km/h', detectedAt: '28 Feb | 10:00 AM',   location: 'Near Nagpur', date: DateTime(2026, 2, 28, 10,  0)),
    ],
  };


  static const List<Map<String, dynamic>> alerts = [
    {
      'type': 'critical',
      'title': 'Critical: Axle 3 Overheat (Temp 112°C)',
      'coach': 'Coach 7',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 3  |  Sensor: AX-C07-A03  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 6 Overheat (Temp 109°C)',
      'coach': 'Coach 7',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 6  |  Sensor: AX-C07-A06  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 2 Overheat (Temp 108°C)',
      'coach': 'Coach 20',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 2  |  Sensor: AX-C20-A02  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'critical',
      'title': 'Critical: Axle 5 Overheat (Temp 106°C)',
      'coach': 'Coach 20',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 5  |  Sensor: AX-C20-A05  |  Speed: 72 km/h',
      'note': 'Immediate inspection required — Location: Near Nagda',
    },
    {
      'type': 'warning',
      'title': 'Warning: Axle 4 Overheat (Temp 108°C)',
      'coach': 'Coach 4',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 4  |  Sensor: AX-C04-A04  |  Speed: 72 km/h',
      'note': 'Monitor closely — Location: Near Nagda',
    },
    {
      'type': 'warning',
      'title': 'Warning: Axle 4 Overheat (Temp 98°C)',
      'coach': 'Coach 11',
      'time': 'Today, 10:39 AM',
      'detail': 'Axle 4  |  Sensor: AX-C11-A04  |  Speed: 72 km/h',
      'note': 'Monitor closely — Location: Near Nagda',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Critical Overheat',
      'coach': 'Coach 3',
      'time': 'Yesterday, 06:10 AM',
      'detail': 'Axle 2  |  Resolved by: Ramesh Kumar',
      'note': 'Axle cooled and re-lubricated — Normal temperature restored',
    },
    {
      'type': 'resolved',
      'title': 'Resolved: Axle Sensor Offline',
      'coach': 'Coach 9',
      'time': '10 Mar, 02:15 PM',
      'detail': 'Axle 6  |  Resolved by: Suresh Singh',
      'note': 'Sensor replaced — Data transmission restored',
    },
  ];

  // ── Summary ────────────────────────────────────────────────────────────────
  static Map<String, int> getSummary() => {
    'total': 20, 'good': 16, 'warning': 2, 'critical': 2,
    'totalAxles': 160, 'axlesGood': 153, 'axlesIssue': 7,
  };
}
