import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/auth/login/domain/usecases/login_usecase.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_event.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/features/auth/login/data/models/user_model.dart';

import '../../../../../core/network/api_constants.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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

      // For any other email, sign in using Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Firebase authentication failed. User is null.');
      }

      final fbUser = userCredential.user!;
      
      // Get the firebase token
      final String idToken = await fbUser.getIdToken() ?? '';
      await prefs.saveToken(idToken);

      // Create a mock UserModel for the app's internal logic
      final userModel = UserModel(
        userId: 1, // Firebase uid is string, but model expects int
        firstName: fbUser.displayName?.split(' ').first ?? 'Tester',
        lastName: fbUser.displayName?.split(' ').last ?? 'Account',
        email: fbUser.email ?? email,
        mobileNumber: fbUser.phoneNumber ?? '0000000000',
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
          // You can also write this to Firebase Realtime Database:
          // FirebaseDatabase.instance.ref().child('users/${fbUser.uid}/fcmToken').set(fcmToken);
          
          await http.post(
            Uri.parse("${ApiConstants.devUrl}/fcm/fcm-token"),
            body: {
              'user_id': fbUser.uid,
              'fcm_token': fcmToken,
            },
          );
        }
      } catch (_) {
        print('FCM Token sync failed, ignoring for Firebase migration.');
      }

      emit(LoginSuccess('Successfully logged in via Firebase!'));
    } on FirebaseAuthException catch (e) {
      print('❌ FIREBASE LOGIN ERROR: ${e.message}');
      emit(LoginFailure(message: e.message ?? 'Authentication failed'));
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
