import 'dart:convert';
import 'dart:io';
import 'package:charterer/core/utils/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'failure.dart';

enum RequestType { get, post, delete }

class Helpers{

  static toast(String text) {
    return Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }



  static validateEmail(String value) {
    if (value.isEmpty) {
      return "field required";
    }
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]'
        r'+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'invalid email';
  }

  static validateField(String value) {


    if (value.isEmpty || value == 'null') {
      return "field required";
    }
    return null;
  }

  static validatePhone(String value) {
    if (value.length < 10 || value.length > 10) {
      return 'Please Enter Valid Mobile Number';
    } else {
      return null;
    }
  }


  static Future<Map<String, dynamic>?> sendRequest(
      Dio dio,
      RequestType type,
      String path, {
        Map<String, dynamic>? queryParams,
        Map<String, dynamic>? headers,
        dynamic data,
      }) async {

    final logger = Logger(
      printer: PrettyPrinter(
          methodCount: 2, // number of method calls to be displayed
          errorMethodCount: 8, // number of method calls if stacktrace is provided
          lineLength: 200, // width of the output
          colors: true, // Colorful log messages
          printEmojis: true, // Print an emoji for each log message
          printTime: false // Should each log print contain a timestamp
      ),
    );

    debugPrint("Payload ${queryParams ?? data}");


    try {
      Response response;

      switch (type) {
        case RequestType.get:
          response = await dio.get(
            path,
            queryParameters: queryParams,
            options: Options(headers: headers),
          );
          break;

        case RequestType.post:
          response = await dio.post(
            path,
            options: Options(headers: headers, validateStatus: (code) => true),
            data: queryParams ?? data,
          );
          break;

        case RequestType.delete:
          response = await dio.delete(
            path,
            queryParameters: queryParams,
            options: Options(headers: headers),
          );
          break;

        default:
          return null;
      }

      debugPrint("$path response ${response.statusCode} with ${response.statusMessage}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i(jsonEncode(response.data as Map<String, dynamic>));
        return response.data as Map<String, dynamic>;
      }else if (response.statusCode == 400  || response.statusCode == 401 || response.statusCode == 202) {
        logger.i('Failed Response ${const JsonEncoder().convert(response.data as Map<String, dynamic>)}');
        throw ServerException(
          message: response.data['error']['message'],
          code: response.statusCode,
        );
      }else {
        throw ServerException(
          message: response.data['message'],
          code: response.statusCode,
        );
      }
    } on ServerException catch (e) {
      throw ServerException(message: e.message, code: e.code);
    } on DioError catch (e) {
      throw ServerException(message: e.error is SocketException ? 'No Internet Connection' : e.error.toString());
    }
  }


  static Future getApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiToken');
  }

  static Future getApiHeaders() async {
    String token =
        "eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5NmFkY2U5OTk5YmJmNWNkMzBmMjlmNDljZDM3ZjRjNWU2NDI3NDAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbWFybG8tYmFuay1kZXYiLCJhdWQiOiJtYXJsby1iYW5rLWRldiIsImF1dGhfdGltZSI6MTY2OTg5ODMwMiwidXNlcl9pZCI6IlJoSGdiY1U0cHZNMGR3RE90d1piTlhPOTlRMjMiLCJzdWIiOiJSaEhnYmNVNHB2TTBkd0RPdHdaYk5YTzk5UTIzIiwiaWF0IjoxNjY5ODk4MzAyLCJleHAiOjE2Njk5MDE5MDIsImVtYWlsIjoieGlob2g1NTQ5NkBkaW5lcm9hLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJ4aWhvaDU1NDk2QGRpbmVyb2EuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.me5S0Sx-tfFhoWpQdxnMZPXnkFg6Mrkskp8yj0N3DyJI0qZpb5AvFVCoVkGngGr2EeGMLjowk1kwuaVJAqdi73oLsFwxViTRok8GEOW1ZkO2on5VjtQ19VNjEP1WKApt6Iqlw2aGAVObZ8xjAsltj_QaFvBvBRyBil5I4EwlXrM42ylNmSYRS6ZtKLSJfODa6eOF2vnmXDyEZWgGi9VhSlJQMWc_kp7pCWXmxSZA7J_GkJdGoJ4030BGJPN1Tx-7igoJQ_HfOo_4FqiGOMAOtb6Sd5JN9VB4Qw8_ttDUai1_wtRgYd7SCbfSq8-UcC7PtlsRNEbEibYUrclzx87MvA";
    final Map<String, dynamic> headers = {
      'authtoken' : token,
    };
    return headers;
  }

  static String convertFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return "Unknown error occurred";
  }

  static loader(){
    SmartDialog.showLoading();
  }

  static hideLoader(){
    SmartDialog.dismiss();
  }



}