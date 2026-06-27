import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/auth/login/domain/usecases/login_usecase.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_event.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/features/auth/login/data/models/user_model.dart';
import '../../../../../core/network/api_constants.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Prefs prefs;
  final PermissionBloc permissionBloc;
  bool isLoginWithEmail = true;

  // We are not using the old LoginUseCase API since we moved to Firebase
  LoginBloc({
    required LoginUseCase loginUseCase, // Kept for DI injection compatibility
    required this.prefs,
    required this.permissionBloc,
  }) : super(LoginInitial()) {
    on<LoginRequested>(_onLogin);
    on<LoginWithEmailOrNumberToggled>(_onLoginWithEmailOrNumberToggled);
  }

  void _onLogin(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final email = event.emailOrPhoneNumber.trim();
      final password = event.password.trim();

      // Hardcoded bypass for our tester account to avoid Firebase Auth config errors
      if (email == 'tester@example.com' && password == '123456') {
        print('Tester account bypass activated!');
        final userModel = UserModel(
          userId: 1,
          firstName: 'Tester',
          lastName: 'Account',
          email: email,
          mobileNumber: '0000000000',
          organisationType: 'Testing',
          organisationName: 'Smart Coach',
          zoneId: 1,
          divisionId: 1,
          regionId: 1,
          roleId: 1, // Admin role
          status: 'Active',
          approvalStatus: 'Approved',
          createdDate: DateTime.now().toIso8601String(),
          employeeId: 'EMP-001',
          panCardNo: 'ABCDE1234F',
          panCardImage: null,
          userImage: null,
        );
        
        await prefs.saveToken('tester-mock-token-123456');
        await prefs.saveUser(userModel);

        permissionBloc.add(InitializePermissions(
          roleId: userModel.roleId ?? 0,
          roleName: 'Admin',
        ));

        emit(LoginSuccess('Successfully logged in as Tester!'));
        return; // Exit early, skipping Firebase Auth entirely
      }

      // For any other email, sign in using Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Supabase authentication failed. User is null.');
      }

      final sbUser = response.user!;
      
      // Get the session token
      final String idToken = response.session?.accessToken ?? '';
      await prefs.saveToken(idToken);

      // Create a mock UserModel for the app's internal logic
      final userModel = UserModel(
        userId: 1, // Supabase uid is string, but model expects int
        firstName: sbUser.userMetadata?['first_name'] ?? 'Tester',
        lastName: sbUser.userMetadata?['last_name'] ?? 'Account',
        email: sbUser.email ?? email,
        mobileNumber: sbUser.phone ?? '0000000000',
        organisationType: 'Testing',
        organisationName: 'Smart Coach',
        zoneId: 1,
        divisionId: 1,
        regionId: 1,
        roleId: 1, // 1 for Admin/Super User for full module access
        status: 'Active',
        approvalStatus: 'Approved',
        createdDate: DateTime.now().toIso8601String(),
        employeeId: 'EMP-001',
        panCardNo: 'ABCDE1234F',
        panCardImage: null,
        userImage: null,
      );
      
      await prefs.saveUser(userModel);

      // Initialize permissions based on user role
      permissionBloc.add(InitializePermissions(
        roleId: userModel.roleId ?? 0,
        roleName: 'Admin',
      ));

      try {
        final fcmToken = await _messaging.getToken();
        if (fcmToken != null) {
          await http.post(
            Uri.parse("${ApiConstants.devUrl}/fcm/fcm-token"),
            body: {
              'user_id': sbUser.id,
              'fcm_token': fcmToken,
            },
          );
        }
      } catch (_) {
        print('FCM Token sync failed, ignoring for database migration.');
      }

      emit(LoginSuccess('Successfully logged in via Supabase!'));
    } on AuthException catch (e) {
      print('❌ SUPABASE LOGIN ERROR: ${e.message}');
      emit(LoginFailure(message: e.message));
    } catch (e, stackTrace) {
      print('❌ LOGIN ERROR: $e');
      print('❌ STACK TRACE: $stackTrace');
      emit(LoginFailure(message: e.toString()));
    }
  }

  void _onLoginWithEmailOrNumberToggled(
      LoginWithEmailOrNumberToggled event, Emitter<LoginState> emit) {
    isLoginWithEmail = event.isLoginWithEmail;
    emit(LoginWithFormState(isLoginWithEmail: isLoginWithEmail));
  }
}
