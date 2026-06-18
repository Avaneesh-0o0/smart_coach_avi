import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/features/dashboard/presentation/widgets/custom_drawer.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_bloc.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_event.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_state.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CoachDashboardBloc>().add(LoadCoachDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text('Coach Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: BlocConsumer<CoachDashboardBloc, CoachDashboardState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.coachList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(state.errorMessage!, textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CoachDashboardBloc>().add(LoadCoachDashboardData()),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(context, state),
                const SizedBox(height: 24),
                if (state.selectedCoach != null) ...[
                  _buildCoachInfoCard(state.selectedCoach!),
                  const SizedBox(height: 24),
                  _buildDeviceListSection(state.filteredDevices),
                ] else
                  _buildNoSelectionState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, CoachDashboardState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Search Coach", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Enter Coach Unique ID...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<CoachDashboardBloc>().add(SearchCoachById(_searchController.text));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Filter", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CoachEntity>(
            decoration: InputDecoration(
              hintText: "Select Coach from list",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: state.coachList.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c.coachUniqueId ?? "N/A"),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<CoachDashboardBloc>().add(SelectCoach(val));
                _searchController.text = val.coachUniqueId ?? "";
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoachInfoCard(CoachEntity coach) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("COACH UNIQUE ID", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1.2)),
                  Text(coach.coachUniqueId ?? "N/A", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(coach.coachStatus?.toUpperCase() ?? "ACTIVE", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Type", coach.typeOfCoach ?? "--"),
              _infoTile("Make", coach.makeOfCoach ?? "--"),
              _infoTile("Year", coach.manufacturingYear?.toString() ?? "--"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDeviceListSection(List<DeviceEntity> devices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INSTALLED DEVICES (${devices.length})", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        const SizedBox(height: 16),
        if (devices.isEmpty)
           const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("No devices found for this coach")))
        else
          ...devices.map((d) => _buildDeviceCard(d)),
      ],
    );
  }

  Widget _buildDeviceCard(DeviceEntity device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.settings_input_hdmi, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.fullName ?? device.shortName ?? "Unknown Device", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                Text("UID: ${device.deviceUniqueId ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(device.deviceTypeName ?? "Module", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: (device.isActive == 1) ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text((device.isActive == 1) ? "ONLINE" : "OFFLINE", style: TextStyle(color: (device.isActive == 1) ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.directions_railway_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Select a coach to view installed devices", style: GoogleFonts.poppins(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
