class ApiConstants {
  static const String loginApiEndpoint = '/auth/login';
  static const String registerApiEndpoint = '/auth/register';
  static const String getZonesApiEndpoint = '/masters/zones';
  static const String getGetDivisionsApiEndpoint = '/masters/divisions';
  static const String getGetRegionsApiEndpoint = '/masters/regions';
  static const String getGetRolesApiEndpoint = '/masters/roles';
  static const String getApprovalListApiEndpoint = '/auth/users/pending';
  static const String approveUserApiEndpoint = '/auth/users';
  static const String acpLogsApiEndpoint = '/acp/logs';
  static const String acpSummaryApiEndpoint = '/acp/summary';
  static const String acpFiltersApiEndpoint = '/acp/filters';
  static const String acpFilteredLogsApiEndpoint = '/acp/filtered-logs';
  static const String pneumaticStatusApiEndpoint = '/pneumatic/status';
  static const String trainConfigsApiEndpoint = '/trains';
  static const String coachesApiEndpoint = '/coaches';
  static const String sensorConfigsApiEndpoint = '/sensors-config';
  static const String devicesApiEndpoint = '/devices';
  static const String sensorsApiEndpoint = '/sensors';
  static const String rulesApiEndpoint = '/rules';
  static const String masterModulesApiEndpoint = '/master-modules';
  static const String allRegionsApiEndpoint = '/regions';
  static const String allStationsApiEndpoint = '/stations';
  static const String coachMakesApiEndpoint = '/coach-makes';
  static const String coachTypesApiEndpoint = '/coach-types';
  static const String sensorMakesApiEndpoint = '/sensors-make';
  static const String odourReceiveDataApiEndpoint = '/odour/logs/receive-data';
  static const String fsdsReceiveDataApiEndpoint = '/fsds/receive-data';
  static const String fsdsStatusApiEndpoint = '/fsds/status';
  static const String coachConfigApiEndpoint = '/coach-config';
  static const String hotAxleReceiveDataApiEndpoint = '/hotaxle/receive-data';
  static const String pressureReceiveDataApiEndpoint = '/pressure/receive-data';
  static const String wliReceiveDataApiEndpoint = '/wli/receive-data';

  //API PARAMETERS
  static const String email = 'email';
  static const String password = 'password';
  static const String userId = 'user_id';

  static const String devUrl =
      'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
  // static const String devUrl2 = 'https://smartcoachez.com/smart_coach_api/api';
// static const String devUrl = 'http://192.168.1.5:3000/smart_coach_api/api';
}
