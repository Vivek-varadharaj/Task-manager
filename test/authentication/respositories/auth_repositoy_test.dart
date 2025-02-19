import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_provider.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager_app/util/app_constants.dart';
import 'package:task_manager_app/util/app_texts.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthRepository authRepository;
  late MockApiClient mockApiClient;
  late MockSharedPreferences mockSharedPreferences;
  String? storedToken;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSharedPreferences = MockSharedPreferences();
    authRepository = AuthRepository(
      apiClient: mockApiClient,
      sharedPreferences: mockSharedPreferences,
    );
    storedToken = null;
    when<String?>(() => mockApiClient.token).thenAnswer((_) => storedToken);
    when(() => mockApiClient.token = any()).thenAnswer((invocation) {
      storedToken = invocation.positionalArguments.first as String?;
    });
    when(() => mockApiClient.updateHeader(any(),
        setHeader: any(named: 'setHeader'))).thenAnswer((_) => {});
  });

  group('loginUsingPassword', () {
    final loginBody = {'username': 'user', 'password': 'pass'};

    test('should return response and save token when successful with token',
        () async {
      final response = ApiResponse(statusCode: 200, body: {
        'token': {'access': 'test_token'},
      });
      when(() => mockApiClient.postData(
              AppConstants.loginUsingPasswordApi, any(), handleError: false))
          .thenAnswer((_) async => response);
      when(() =>
              mockSharedPreferences.setString(AppConstants.token, 'test_token'))
          .thenAnswer((_) async => true);
      final result = await authRepository.loginUsingPassword(loginBody);
      expect(result, response);
      verify(() =>
              mockSharedPreferences.setString(AppConstants.token, 'test_token'))
          .called(1);
      expect(mockApiClient.token, 'test_token');
    });

    test('should return response when successful without token', () async {
      final response = ApiResponse(statusCode: 200, body: {});
      when(() => mockApiClient.postData(
              AppConstants.loginUsingPasswordApi, any(), handleError: false))
          .thenAnswer((_) async => response);
      final result = await authRepository.loginUsingPassword(loginBody);
      expect(result, response);
      verifyNever(
          () => mockSharedPreferences.setString(AppConstants.token, any()));
    });

    test('should throw exception on non-200 response', () async {
      final response = ApiResponse(
          statusCode: 400, body: {'message': 'Invalid credentials'});
      when(() => mockApiClient.postData(
              AppConstants.loginUsingPasswordApi, any(), handleError: false))
          .thenAnswer((_) async => response);
      expect(
          () => authRepository.loginUsingPassword(loginBody), throwsException);
    });

    test('should rethrow exception from apiClient.postData', () async {
      when(() => mockApiClient.postData(
              AppConstants.loginUsingPasswordApi, any(), handleError: false))
          .thenThrow(Exception('Network error'));
      expect(
          () => authRepository.loginUsingPassword(loginBody), throwsException);
    });

    test('should rethrow exception when saveUserToken fails', () async {
      final response = ApiResponse(statusCode: 200, body: {
        'token': {'access': 'test_token'},
      });
      when(() => mockApiClient.postData(
              AppConstants.loginUsingPasswordApi, any(), handleError: false))
          .thenAnswer((_) async => response);
      when(() =>
              mockSharedPreferences.setString(AppConstants.token, 'test_token'))
          .thenThrow(Exception('Storage error'));
      expect(
          () => authRepository.loginUsingPassword(loginBody), throwsException);
    });
  });

  group('isUserLoggedIn', () {
    test('should return token if available', () {
      when(() => mockSharedPreferences.getString(AppConstants.token))
          .thenReturn('test_token');
      final result = authRepository.isUserLoggedIn();
      expect(result, 'test_token');
    });

    test('should throw exception if getString fails', () {
      when(() => mockSharedPreferences.getString(AppConstants.token))
          .thenThrow(Exception('Read error'));
      expect(() => authRepository.isUserLoggedIn(), throwsException);
    });
  });

  group('logout', () {
    test('should remove token and user data and return true', () async {
      when(() => mockSharedPreferences.remove(AppConstants.token))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.remove(AppTexts.userData))
          .thenAnswer((_) async => true);
      final result = await authRepository.logout();
      expect(result, true);
      verify(() => mockSharedPreferences.remove(AppConstants.token)).called(1);
      verify(() => mockSharedPreferences.remove(AppTexts.userData)).called(1);
    });

    test('should throw exception if remove fails', () async {
      when(() => mockSharedPreferences.remove(AppConstants.token))
          .thenThrow(Exception('Remove error'));
      expect(() => authRepository.logout(), throwsException);
    });
  });

  group('saveUser', () {
    final userData = {'id': 1, 'name': 'Test User'};
    test('should save user data', () async {
      when(() => mockSharedPreferences.setString(
              AppTexts.userData, jsonEncode(userData)))
          .thenAnswer((_) async => true);
      await authRepository.saveUser(userData);
      verify(() => mockSharedPreferences.setString(
          AppTexts.userData, jsonEncode(userData))).called(1);
    });

    test('should throw exception if saving user data fails', () async {
      when(() => mockSharedPreferences.setString(
              AppTexts.userData, jsonEncode(userData)))
          .thenThrow(Exception('Storage error'));
      expect(() => authRepository.saveUser(userData), throwsException);
    });
  });
}
