import 'environment.dart';

class ApiEndpoints {

  static String baseURL = Environment.apiBaseUrl;

  /// Home APIs ///
  static const String addCharterer = "/charterers";
  static const String getCharterers = "/charterers/search";

}