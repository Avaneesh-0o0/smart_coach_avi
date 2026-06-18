# Dummy Data Report

## Modules Using Dummy Data (No GET APIs Exist)

### 1. BC Pressure
| | |
|---|---|
| **Dummy file** | `lib/features/reports_and_alerts/bc_pressure/data/datasource/bc_dummy_data.dart` |
| **Used in (5 files)** | `bc_pressure_screen.dart`, `bc_chart_view.dart`, `bc_coach_detail.dart`, `bc_alerts_view.dart`, `bc_report_generator.dart` |
| **Existing API** | Only `POST /pressure/receive-data` |
| **Needed API** | `GET /pressure/status` (with query params: train_no, coach_no, from_date, to_date, limit) |
| **Repository exists?** | No |
| **Remote data source exists?** | No |

### 2. Hot Axle
| | |
|---|---|
| **Dummy file** | `lib/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_dummy_data.dart` |
| **Used in (3 files)** | `hot_axle_detail_screen.dart`, `hot_axle_alert_view.dart`, `hot_axle_report_generator.dart` |
| **Existing API** | Only `POST /hotaxle/receive-data` |
| **Needed API** | `GET /hotaxle/status` (with query params: train_no, coach_no, from_date, to_date, limit) |
| **Repository exists?** | No |
| **Remote data source exists?** | No |

### 3. Water Level Indicator
| | |
|---|---|
| **Dummy file** | `lib/features/reports_and_alerts/water_lvl_indicator/data/datasource/wli_dummy_data.dart` |
| **Used in (1 file)** | `water_level_screen.dart` |
| **Existing API** | Only `POST /wli/receive-data` |
| **Needed API** | `GET /wli/status` (with query params: train_no, coach_no, from_date, to_date, limit) |
| **Repository exists?** | No |
| **Remote data source exists?** | No |

### 4. Odour Management
| | |
|---|---|
| **Dummy data** | Inline in `odour_management_screen.dart` (~155 lines) + hardcoded mock in `odour_repository.dart` |
| **Used in (2 files)** | `odour_management_screen.dart`, `odour_repository.dart` |
| **Existing API** | Only `POST /odour/logs/receive-data` |
| **Needed API** | `GET /odour/logs` or `GET /odour/status` |
| **Repository exists?** | Yes (returns hardcoded data) |
| **Remote data source exists?** | No |

---

## Dummy Data That Is Dead Code

### ACP Screen
| | |
|---|---|
| **Dummy file** | `lib/features/reports_and_alerts/acp_screen/data/datasource/acp_dummy_data.dart` |
| **Is it used?** | **No** — completely unused, never imported anywhere |
| **Real APIs exist?** | **Yes** — `GET /acp/logs`, `GET /acp/summary`, `GET /acp/filters`, `GET /acp/filtered-logs` |
| **Action** | Can safely delete `acp_dummy_data.dart` |

---

## Modules With No Dummy Data (Already on Real APIs)

| Module | Remote Data Source |
|--------|-------------------|
| break_binding | `break_binding_remote_data_source.dart` |
| level_indicator | `train_list_remote_data_source.dart` + `sensor_api_service.dart` |
| fsds_screen | `fsds_remote_data_source.dart` |
| train_configuration | `train_configuration_remote_data_source.dart` |
| coach_configuration | `coach_configuration_remote_data_source.dart` |
| master_module_configuration | `master_module_configuration_remote_data_source.dart` |
| sensor_device_configuration | `sensor_device_configuration_remote_data_source.dart` |
| device_configuration | `device_configuration_remote_data_source.dart` |
| sensor_type_configuration | `sensor_type_configuration_remote_data_source.dart` |
| rule_configuration | `rule_configuration_remote_data_source.dart` |
| auth/login | `login_remote_data_source.dart` |
| auth/register | `register_remote_data_source.dart` |
| profile | `profile_remote_data_source.dart` |
| user_management | `user_management_remote_data_source.dart` |
| drop_down_value | `drop_down_value_remote_data_source.dart` |

---

## Summary

- **4 modules need backend GET endpoints**: `bc_pressure`, `hot_axle`, `water_lvl_indicator`, `odour_management`
- **1 dummy file is dead code**: `acp_dummy_data.dart` (safe to delete)
- **14+ modules already use real APIs** with remote data sources and repositories
