import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_app/api/api_provider.dart';

import 'package:task_manager_app/features/auth/controllers/auth_controller.dart';
import 'package:task_manager_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthController authController;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authController = AuthController(authRepository: mockAuthRepository);
  });

  group('loginUsingPassword', () {
    final loginRequestMap = {'username': 'user', 'password': 'pass'};

    test('returns success ResponseModel when login is successful', () async {
      final responseBody = {
        "accessToken": "token123",
        "refreshToken": "def456",
        "id": 123,
        "username": "john_doe",
        "email": "john.doe@example.com",
        "firstName": "John",
        "lastName": "Doe",
        "gender": "male",
        "image": "https://example.com/john_doe.png"
      };
      final apiResponse = ApiResponse(statusCode: 200, body: responseBody);
      when(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .thenAnswer((_) async => apiResponse);
      when(() => mockAuthRepository.saveUserToken(any()))
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.saveUser(any()))
          .thenAnswer((_) async => Future.value());

      final response = await authController.loginUsingPassword(
          loginRequestModel: loginRequestMap);

      expect(response.isSuccess, isTrue);
      expect(response.message, 'Login successful');
      expect(authController.loginResponseModel?.accessToken, 'token123');
      verify(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .called(1);
      verify(() => mockAuthRepository.saveUserToken('token123')).called(1);
      verify(() => mockAuthRepository.saveUser(responseBody)).called(1);
      expect(authController.isLoading, isFalse);
    });

    test('returns failure ResponseModel when login response is not 200',
        () async {
      final responseBody = {'message': 'Invalid credentials'};
      final apiResponse = ApiResponse(statusCode: 400, body: responseBody);
      when(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .thenAnswer((_) async => apiResponse);

      final response = await authController.loginUsingPassword(
          loginRequestModel: loginRequestMap);

      expect(response.isSuccess, isFalse);
      expect(response.message, 'Invalid credentials');
      expect(authController.loginResponseModel, isNull);
      verify(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .called(1);
    });

    test('returns failure ResponseModel when exception is thrown', () async {
      when(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .thenThrow(Exception('Network error'));

      final response = await authController.loginUsingPassword(
          loginRequestModel: loginRequestMap);

      expect(response.isSuccess, isFalse);
      expect(response.message, contains('Network error'));
      verify(() => mockAuthRepository.loginUsingPassword(loginRequestMap))
          .called(1);
    });
  });

  group('getIsUserLoggedIn', () {
    test('returns token when available', () {
      when(() => mockAuthRepository.isUserLoggedIn()).thenReturn('token123');
      final token = authController.getIsUserLoggedIn();
      expect(token, 'token123');
      verify(() => mockAuthRepository.isUserLoggedIn()).called(1);
    });

    test('returns null when repository throws exception', () {
      when(() => mockAuthRepository.isUserLoggedIn())
          .thenThrow(Exception('error'));
      final token = authController.getIsUserLoggedIn();
      expect(token, isNull);
      verify(() => mockAuthRepository.isUserLoggedIn()).called(1);
    });
  });

  group('logout', () {
    test('returns true when logout is successful', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => true);
      final result = await authController.logout();
      expect(result, isTrue);
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('returns false when logout throws exception', () async {
      when(() => mockAuthRepository.logout())
          .thenThrow(Exception('Logout error'));
      final result = await authController.logout();
      expect(result, isFalse);
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });

  group('saveUserToken', () {
    test('calls repository.saveUserToken', () async {
      when(() => mockAuthRepository.saveUserToken('token123'))
          .thenAnswer((_) async => true);
      await authController.saveUserToken('token123');
      verify(() => mockAuthRepository.saveUserToken('token123')).called(1);
    });
  });

  group('toggleObsecureText', () {
    test('toggles obsecureText value', () async {
      final initial = authController.obsecureText;
      await authController.toggleObsecureText();
      expect(authController.obsecureText, !initial);
      await authController.toggleObsecureText();
      expect(authController.obsecureText, initial);
    });
  });
}
