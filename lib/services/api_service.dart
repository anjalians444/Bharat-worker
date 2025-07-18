import 'dart:convert';
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<dynamic> get(String endpoint, {Map<String, String>? headers, String? token}) async {
    String token = await PreferencesServices.getPreferencesData(PreferencesServices.userToken);
    print("token...${token}");
    print("url...${ApiPaths.baseUrl + endpoint}");
    final url = Uri.parse(ApiPaths.baseUrl + endpoint);
    final mergedHeaders = <String, String>{};
    if (headers != null) mergedHeaders.addAll(headers);
    if (token != null) mergedHeaders['Authorization'] = 'Bearer $token';
    final response = await http.get(url, headers: mergedHeaders);
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, {Map<String, String>? headers, dynamic body,bool isToken = true}) async {
    var token;
    if(isToken){
       token = await PreferencesServices.getPreferencesData(PreferencesServices.userToken)??null;
    }

    final url = Uri.parse(ApiPaths.baseUrl + endpoint);
    print("url...$url");
    final mergedHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) mergedHeaders.addAll(headers);
    if(isToken) {
      if (token != null)
        mergedHeaders['Authorization'] = 'Bearer $token';
    }
    print("body..$body");
    final response = await http.post(
      url,
      headers: mergedHeaders,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, {Map<String, String>? headers, dynamic body, String? token}) async {
    final url = Uri.parse(ApiPaths.baseUrl + endpoint);
    final mergedHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) mergedHeaders.addAll(headers);
    if (token != null) mergedHeaders['Authorization'] = 'Bearer $token';
    final response = await http.put(
      url,
      headers: mergedHeaders,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers, dynamic body, String? token}) async {
    final url = Uri.parse(ApiPaths.baseUrl + endpoint);
    final mergedHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) mergedHeaders.addAll(headers);
    if (token != null) mergedHeaders['Authorization'] = 'Bearer $token';
    final response = await http.delete(
      url,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  Future<dynamic> postMultipart(String endpoint, {Map<String, String>? headers, required Map<String, String> fields, required List<http.MultipartFile> files}) async {
   String token = await PreferencesServices.getPreferencesData(PreferencesServices.userToken);

   print("token...$token");
    final url = Uri.parse(ApiPaths.baseUrl + endpoint);
    var request = http.MultipartRequest('POST', url);
    if (headers != null) request.headers.addAll(headers);
    if (token != null && token != "null" && token.toString().isNotEmpty) request.headers['Authorization'] = 'Bearer $token';
    print("request.headers....$headers");
    print("fields....$fields");
    print("files....$files");
    request.fields.addAll(fields);
    request.files.addAll(files);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("response...${response.body}");
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    print("response...${jsonDecode(response.body)}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('API Error: \\${response.statusCode} - \\${response.body}');
      throw Exception('API Error: \\${response.statusCode} - \\${response.body}');
    }
  }
} 