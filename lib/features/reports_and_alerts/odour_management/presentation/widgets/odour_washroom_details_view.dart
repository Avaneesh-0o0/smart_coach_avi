import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourWashroomDetailsView extends StatefulWidget {
  final CoachToiletGroup group;
  const OdourWashroomDetailsView({super.key, required this.group});

  @override
  State<OdourWashroomDetailsView> createState() => _OdourWashroomDetailsViewState();
}

class _OdourWashroomDetailsViewState extends State<OdourWashroomDetailsView> {
  int _selectedIndex = 0;

  OdourCoachModel get _selected => widget.group.toilets[_selectedIndex];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': return Colors.green;
      case 'warning': return ColorConstants.statusWarning;
      case 'critical': return ColorConstants.statusCritical;
      default: return ColorConstants.iconGrey;
    }
  }

  String _fmtDt(String ts) {
    try { return DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(ts)); }
    catch (_) { return ts; }
  }

  @override
  Widget build(BuildContext context) {
    final wm = _selected;
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text('Coach ${widget.group.coachNumber} – Washrooms', style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Train info card
            _trainInfoCard(),
            const SizedBox(height: 12),

            // Washroom selector tabs
            _washroomSelector(),
            const SizedBox(height: 12),

            // 1. Hygiene Score
            _card(child: _hygieneSection(wm)),
            const SizedBox(height: 10),

            // 2. Sensor Readings (Now includes Thresholds)
            _card(child: _sensorSection(wm)),
            const SizedBox(height: 10),

            // 3. Door Activity
            _card(child: _doorSection(wm)),
            const SizedBox(height: 10),

            // 5. Device Information
            _card(child: _deviceInfoSection(wm)),
            const SizedBox(height: 10),

            // 6. System Health
            _card(child: _systemHealthSection(wm)),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(12)),
    child: child,
  );

  Widget _trainInfoCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ColorConstants.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SvgPicture.asset(AppIcons.train, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.primary, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Expanded(child: Text('${widget.group.trainNumber} - ${widget.group.trainName}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.primary))),
      ]),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _infoPill('Coach: ${widget.group.coachNumber}'),
          _infoPill(widget.group.coachType),
          _infoPill('Device: ${_selected.deviceId}'),
          _infoPill('Updated: ${_fmtDt(_selected.timestamp)}'),
        ],
      ),
    ]),
  );

  Widget _infoPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: AppTextStyles.bodySmall),
  );

  Widget _washroomSelector() {
    return Row(
      children: List.generate(widget.group.toilets.length, (i) {
        final t = widget.group.toilets[i];
        final isSelected = i == _selectedIndex;
        final color = _statusColor(t.hygieneScore >= 70 ? 'Good' : t.hygieneScore >= 50 ? 'Warning' : 'Critical');
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Container(
              margin: EdgeInsets.only(right: i < widget.group.toilets.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstants.primary : ColorConstants.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? ColorConstants.primary : ColorConstants.divider),
              ),
              child: Column(children: [
                Text(t.toiletPosition, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : ColorConstants.textPrimary)),
                const SizedBox(height: 2),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? Colors.white : color),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // ── 1. Hygiene Score ──
  Widget _hygieneSection(OdourCoachModel wm) {
    final score = wm.hygieneScore;
    final status = score >= 70 ? 'Good' : score >= 50 ? 'Warning' : 'Critical';
    final color = _statusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overall Hygiene Score', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${score.toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
                Text(status, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
              ]),
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Sensor Readings (With Thresholds) ──
  Widget _sensorSection(OdourCoachModel wm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Readings', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4,
          children: [
            _sensorTile('VOC', wm.voc, 'ppb', wm.vocThreshold, wm.vocStatus),
            _sensorTile('NH₃', wm.nh3, 'ppm', wm.nh3Threshold, wm.nh3Status),
            _sensorTile('H₂S', wm.h2s, 'ppm', wm.h2sThreshold, wm.h2sStatus),
            _sensorTile('Smoke', wm.smoke, 'mg/m³', wm.smokeThreshold, wm.smokeStatus),
            _sensorTile('Temp', wm.temperature, '°C', 40.0, wm.tempStatus),
            _sensorTile('Humidity', wm.humidity, '%', 90.0, wm.humidityStatus),
          ],
        ),
      ],
    );
  }

  Widget _sensorTile(String label, double value, String unit, double threshold, String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
              Icon(status.toLowerCase() == 'critical' ? Icons.warning : Icons.check_circle, size: 14, color: color)
            ]
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('${value.toStringAsFixed(1)} $unit', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('Threshold: ${threshold.toStringAsFixed(1)}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary)),
          ),
        ],
      ),
    );
  }



  // ── 4. Door Activity (Limit Switch) ──
  Widget _doorSection(OdourCoachModel wm) {
    final isOpen = wm.doorStatus.toLowerCase() == 'open';
    final doorColor = isOpen ? ColorConstants.statusWarning : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Door Activity', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: doorColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: doorColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(isOpen ? Icons.door_front_door : Icons.door_front_door_outlined, size: 28, color: doorColor),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Status', style: AppTextStyles.bodySmall),
                Text(wm.doorStatus, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: doorColor)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _dataRow('Open Events Today', '${wm.doorOpenEventsToday}'),
        const Divider(color: ColorConstants.divider),
        _dataRow('Last Opened', wm.lastOpenedTime),
        const Divider(color: ColorConstants.divider),
        _dataRow('Last Closed', wm.lastClosedTime),
      ],
    );
  }

  // ── 5. Device Information ──
  Widget _deviceInfoSection(OdourCoachModel wm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device Information', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        _dataRow('Device ID', wm.deviceId),
        const Divider(color: ColorConstants.divider),
        _dataRow('Sensor ID', wm.sensorId),
        const Divider(color: ColorConstants.divider),
        _dataRow('Train Number', wm.trainNumber),
        const Divider(color: ColorConstants.divider),
        _dataRow('Coach Number', wm.coachNumber),
        const Divider(color: ColorConstants.divider),
        _dataRow('Coach Type', wm.coachType),
        const Divider(color: ColorConstants.divider),
        _dataRow('GPS Location', wm.gpsCoordinates),
      ],
    );
  }

  // ── 6. System Health ──
  Widget _systemHealthSection(OdourCoachModel wm) {
    final onlineColor = wm.isOnline ? Colors.green : ColorConstants.statusCritical;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Health', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: onlineColor),
          ),
          const SizedBox(width: 8),
          Text(wm.isOnline ? 'Online' : 'Offline', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: onlineColor)),
        ]),
        const SizedBox(height: 8),
        _dataRow('Communication', wm.communicationStatus),
        const Divider(color: ColorConstants.divider),
        _dataRow('Last Data Received', wm.lastDataReceived),
      ],
    );
  }

  Widget _dataRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Flexible(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? ColorConstants.textPrimary), textAlign: TextAlign.right)),
      ],
    ),
  );
}
