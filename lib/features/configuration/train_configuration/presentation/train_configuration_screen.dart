import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_toggle_buttons.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_event.dart';

import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/configure_train.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/train_list.dart';class TrainConfigurationScreen extends StatefulWidget {	const TrainConfigurationScreen({super.key});	@override	State<TrainConfigurationScreen> createState() =>			_TrainConfigurationScreenState();}class _TrainConfigurationScreenState extends State<TrainConfigurationScreen> {
	int selectedTab = 0;
	TrainConfigsEntity? selectedTrainItem;

	Future<void> _exportToExcel() async {
		final bloc = context.read<TrainConfigurationBloc>();
		final items = bloc.state.trainList;
		if (items.isEmpty) return;

		final excel = Excel.createExcel();
		final sheet = excel['Trains'];

		final headers = [
			'Train Number', 'Train Name', 'Departure Station', 'Destination Station',
			'Line', 'Train Operator', 'Loco Number', 'Number of Coaches',
			'Created', 'Created By', 'Updated', 'Updated By',
		];
		sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

		for (final item in items) {
			sheet.appendRow([
				TextCellValue(item.trainNumber ?? ''),
				TextCellValue(item.trainName ?? ''),
				TextCellValue(item.departureStationName ?? ''),
				TextCellValue(item.destinationStationName ?? ''),
				TextCellValue(item.line ?? ''),
				TextCellValue(item.trainOperator ?? ''),
				TextCellValue(item.engineNumber ?? ''),
				TextCellValue(item.coaches?.length.toString() ?? item.numberOfCoaches?.toString() ?? ''),
				TextCellValue(item.createdAt ?? ''),
				TextCellValue(item.createdBy?.toString() ?? ''),
				TextCellValue(item.updatedAt ?? ''),
				TextCellValue(item.updatedBy?.toString() ?? ''),
			]);
		}

		final dir = await getTemporaryDirectory();
		final file = File('${dir.path}/trains.xlsx');
		await file.writeAsBytes(excel.encode()!);
		await Share.shareXFiles([XFile(file.path)], text: 'Trains Export');
	}	@override	Widget build(BuildContext context) {		return Scaffold(			backgroundColor: const Color(0xFFF8F9FA),			appBar: AppBar(				backgroundColor: Colors.white,				elevation: 0.5,				leading: IconButton(					icon: Icon(Icons.arrow_back, color: Colors.black),					onPressed: () => Navigator.of(context).pop(),				),				centerTitle: true,				title: Text(					"Train Configuration",					style: TextStyle(						color: Colors.black,						fontSize: 14.sp,						fontWeight: FontWeight.normal,					),				),				automaticallyImplyLeading: false,			),			body: SafeArea(				child: Padding(					padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),					child: Column(						children: [							Container(								width: double.infinity,								padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.0.h),								decoration: BoxDecoration(									color: Colors.white,									borderRadius: BorderRadius.circular(3.w),									boxShadow: [										BoxShadow(											color: Colors.black.withValues(alpha: 0.05),											blurRadius: 12,										),									],								),								child: Column(									crossAxisAlignment: CrossAxisAlignment.start,									children: [										Text(											'Train Configuration',											style: TextStyle(												fontSize: 14.sp,												fontWeight: FontWeight.bold,											),										),										SizedBox(height: 1.0.h),										Text(											'Manage and configure train details for the Smart Coach system',											style: TextStyle(												fontSize: 12.sp,												color: Colors.black,												// fontWeight: FontWeight.w500,											),										),									],								),							),							SizedBox(height: 2.h),							Container(								width: double.infinity,								padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.0.h),								decoration: BoxDecoration(									color: Colors.white,									borderRadius: BorderRadius.circular(3.w),									boxShadow: [										BoxShadow(											color: Colors.black.withValues(alpha: 0.05),											blurRadius: 12,										),									],								),								child: Row(									crossAxisAlignment: CrossAxisAlignment.center,									children: [																				Expanded(
											child: CustomToggleButtons(
												selectedIndex: selectedTab,
												labels: const ['Configure', 'List'],
												onTap: (index) {
													selectedTrainItem = null;
													selectedTab = index;
													if (index == 1) {
														context.read<TrainConfigurationBloc>().add(LoadTrainConfigurationList());
													}
													setState(() {});
												},
											),										),										if (selectedTab == 1)											SizedBox(												width: 4.w,											),										if (selectedTab == 1)											CustomButton(												text: 'Export',												color: Colors.white,												textColor: Colors.black,												textSize: 12,												showBorder: true,												prefixIcon: Icons.download_outlined,												iconSize: 4,												padding: EdgeInsets.symmetric(													vertical: 1.3.h,													horizontal: 3.w,												),												radius: 8,												onPressed: _exportToExcel,											),									],								),							),							SizedBox(height: 2.h),							Expanded(								child: selectedTab == 0										? ConfigureTrain(									selectedTrainItem: selectedTrainItem,																		onGoToListAndRefresh: () {
										selectedTab = 1;
										context.read<TrainConfigurationBloc>().add(LoadTrainConfigurationList());
										setState(
													() {},
										);
									},								)										                    : TrainList(
                  onTapEdit: (TrainConfigsEntity trainEntity) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TrainConfigurationBloc>(),
                          child: Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.white,
                              elevation: 0.5,
                              leading: IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () => Navigator.pop(context),
                              ),
                              title: Text(
                                "Edit Train Configuration",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              centerTitle: true,
                            ),
                            body: SafeArea(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                child: ConfigureTrain(
                                  selectedTrainItem: trainEntity,
                                  onGoToListAndRefresh: () {
                                    Navigator.pop(context);
                                    context.read<TrainConfigurationBloc>().add(LoadTrainConfigurationList());
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),							),						],					),				),			),		);	}}