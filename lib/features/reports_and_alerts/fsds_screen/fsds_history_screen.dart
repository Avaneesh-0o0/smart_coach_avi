import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'data/models/fsds_model.dart';

class FsdsHistoryScreen extends StatefulWidget {
  final FsdsAssetModel asset;
  const FsdsHistoryScreen({super.key, required this.asset});

  @override
  State<FsdsHistoryScreen> createState() => _FsdsHistoryScreenState();
}

class _FsdsHistoryScreenState extends State<FsdsHistoryScreen> {
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;
  List<FsdsHistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMockHistory();
  }

  void _loadMockHistory() {
    final now = DateTime.now();
    setState(() {
      _historyEntries = [
        FsdsHistoryEntry(
          deviceId: widget.asset.deviceId,
          deviceName: widget.asset.deviceName,
          coachNumber: widget.asset.coachNumber,
          location: widget.asset.location,
          bypassStatus: widget.asset.bypassStatus,
          alertStatus: widget.asset.alertStatus,
          timestamp: widget.asset.timestamp,
          date: _tryParseDate(widget.asset.timestamp) ?? now,
          remarks: widget.asset.remarks.isNotEmpty ? widget.asset.remarks : 'Status update',
        ),
      ];
      _isLoading = false;
    });
  }

  DateTime? _tryParseDate(String s) {
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  List<FsdsHistoryEntry> get entries {
    if (selectedPeriod == 'All') return _historyEntries;
    
    DateTime now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    if (selectedPeriod == '7 Days') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (selectedPeriod == '30 Days') {
      startDate = now.subtract(const Duration(days: 30));
    } else if (selectedPeriod == 'Custom' && customRange != null) {
      startDate = customRange!.start;
      endDate = customRange!.end.add(const Duration(days: 1));
    }

    if (startDate == null) return _historyEntries;

    return _historyEntries.where((entry) {
      bool afterStart = entry.date.isAfter(startDate!);
      bool beforeEnd = endDate == null || entry.date.isBefore(endDate);
      return afterStart && beforeEnd;
    }).toList();
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        customRange = range;
        selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('FSDS Bypass History', style: AppTextStyles.header1),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeviceInfoCard(),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.asset.deviceName.isNotEmpty ? widget.asset.deviceName : widget.asset.deviceId} (Bypass History)',
                            style: AppTextStyles.header2,
                          ),
                          const SizedBox(height: 16),
                          PeriodFilter(
                            selected: selectedPeriod,
                            periods: const ['7 Days', '30 Days', 'Custom'],
                            onChanged: (value) async {
                              if (value == 'Custom') {
                                await _pickCustomRange();
                              } else {
                                setState(() {
                                  selectedPeriod = value;
                                  customRange = null;
                                });
                              }
                            },
                          ),
                          if (selectedPeriod == 'Custom' && customRange != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorConstants.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_fmt(customRange!.start)}  →  ${_fmt(customRange!.end)}',
                                style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.primary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          if (_isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ))
                          else if (entries.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(Icons.history, size: 48, color: ColorConstants.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('No bypass events in this period', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...entries.asMap().entries.map((e) => _buildHistoryCard(e.value, e.key + 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: child,
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppIcons.train, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.primary, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Text(widget.asset.deviceName.isNotEmpty ? widget.asset.deviceName : widget.asset.deviceId, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Train: ${widget.asset.trainNo}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(4)),
                child: Text('Device: ${widget.asset.deviceId}', style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.asset.isBypassOn ? Colors.orange.withValues(alpha: 0.1) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.asset.bypassStatusText,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: widget.asset.isBypassOn ? Colors.orange.shade700 : const Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(FsdsHistoryEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConstants.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildRow('Device ID', entry.deviceId),
                _buildRow('Device Name', entry.deviceName),
                _buildRow('Coach', entry.coachNumber.isNotEmpty ? entry.coachNumber : 'N/A'),
                const Divider(color: ColorConstants.divider),
                _buildRow('FSDS Bypass', entry.bypassStatus ? 'ON' : 'OFF',
                  valueColor: entry.bypassStatus ? Colors.orange : Colors.green),
                _buildRow('Alert Status', entry.alertStatus ? 'YES' : 'NO',
                  valueColor: entry.alertStatus ? Colors.red : Colors.green),
                const Divider(color: ColorConstants.divider),
                _buildRow('Location', entry.location),
                _buildRow('Date & Time', entry.timestamp),
                if (entry.remarks.isNotEmpty) _buildRow('Remarks', entry.remarks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? ColorConstants.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class FsdsHistoryEntry {
  final String deviceId;
  final String deviceName;
  final String coachNumber;
  final String location;
  final bool bypassStatus;
  final bool alertStatus;
  final String timestamp;
  final DateTime date;
  final String remarks;

  FsdsHistoryEntry({
    required this.deviceId,
    required this.deviceName,
    required this.coachNumber,
    required this.location,
    required this.bypassStatus,
    required this.alertStatus,
    required this.timestamp,
    required this.date,
    this.remarks = '',
  });
}
