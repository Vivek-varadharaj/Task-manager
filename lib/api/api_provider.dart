import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/api/api_checker.dart';
import 'package:task_manager_app/common/models/error_response_model.dart';
import 'package:task_manager_app/util/app_constants.dart';

class ApiResponse {
  final dynamic body;
  final String? bodyString;
  final int statusCode;
  final String? statusText;

  ApiResponse({
    required this.body,
    this.bodyString,
    required this.statusCode,
    this.statusText,
  });
}

class ApiClient extends ChangeNotifier {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage = 'connection_to_api_server_failed';
  final int timeoutInSeconds = 40;
  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      print('Token: $token');
    }
    updateHeader(token);
  }

  Map<String, String> updateHeader(String? token, {bool setHeader = true}) {
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Future<ApiResponse> getData(String uri,
      {Map<String, dynamic>? query,
      Map<String, String>? headers,
      bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nQuery: $query\nHeader: $_mainHeaders');
      }

      Uri url = Uri.https(AppConstants.getBaseUrl, uri, query);

      http.Response response = await http
          .get(
            url,
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('Error in GET: ${e.toString()}');
      }
      return ApiResponse(
        statusCode: 1,
        body: null,
        bodyString: '',
        statusText: noInternetMessage,
      );
    }
  }

  Future<ApiResponse> postData(String uri, dynamic body,
      {Map<String, String>? headers,
      int? timeout,
      bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('Error in POST: ${e.toString()}');
      }
      return ApiResponse(
        statusCode: 1,
        body: null,
        bodyString: '',
        statusText: noInternetMessage,
      );
    }
  }

  Future<ApiResponse> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
        print('====> API Body: $body');
      }
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('Error in PUT: ${e.toString()}');
      }
      return ApiResponse(
        statusCode: 1,
        body: null,
        bodyString: '',
        statusText: noInternetMessage,
      );
    }
  }

  Future<ApiResponse> deleteData(String uri,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $_mainHeaders');
      }
      http.Response response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: headers ?? _mainHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('Error in DELETE: ${e.toString()}');
      }
      return ApiResponse(
        statusCode: 1,
        body: null,
        bodyString: '',
        statusText: noInternetMessage,
      );
    }
  }

  ApiResponse handleResponse(
      http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }
    ApiResponse apiResponse = ApiResponse(
      body: body,
      bodyString: response.body.toString(),
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (apiResponse.statusCode != 200 &&
        apiResponse.body != null &&
        apiResponse.body is! String) {
      if (apiResponse.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(apiResponse.body);
        apiResponse = ApiResponse(
          statusCode: apiResponse.statusCode,
          body: apiResponse.body,
          bodyString: response.body.toString(),
          statusText: errorResponse.errors?[0].message,
        );
      } else if (apiResponse.body.toString().startsWith('{message')) {
        apiResponse = ApiResponse(
          statusCode: apiResponse.statusCode,
          body: apiResponse.body,
          bodyString: response.body.toString(),
          statusText: apiResponse.body['message'],
        );
      }
    } else if (apiResponse.statusCode != 200 && apiResponse.body == null) {
      apiResponse = ApiResponse(
        statusCode: 0,
        body: null,
        bodyString: '',
        statusText: noInternetMessage,
      );
    }
    if (kDebugMode) {
      log('====> API Response: [${apiResponse.statusCode}] $uri');
      if (response.statusCode != 500) {
        log(apiResponse.body.toString());
      }
    }
    if (handleError) {
      if (apiResponse.statusCode == 200) {
        return apiResponse;
      } else {
        ApiChecker.checkApi(apiResponse);
        return apiResponse;
      }
    } else {
      return apiResponse;
    }
  }
}
