import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../constants/app_constants.dart';
import '../error/exceptions.dart' as app_errors;

class ApiClient {
  final http.Client _client;
  final SupabaseClient _supabase;

  ApiClient(this._client, this._supabase);

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = _supabase.auth.currentSession?.accessToken;
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      // Free ngrok tunnels answer browser-like clients with an HTML interstitial
      // instead of the API response; this opts out. No-op off a tunnel.
      'ngrok-skip-browser-warning': '1',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('${AppConstants.apiBaseUrl}$path');
    if (query == null || query.isEmpty) return base;
    // An Iterable value becomes a repeated parameter (`?tech=flutter&tech=dart`),
    // which is how FastAPI receives a `list[str]` query argument. Stringifying
    // it instead would send the literal "[flutter, dart]".
    final normalized = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        final items = value.map((v) => '$v').toList();
        if (items.isNotEmpty) normalized[key] = items;
      } else {
        normalized[key] = '$value';
      }
    });
    if (normalized.isEmpty) return base;
    return base.replace(queryParameters: normalized);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() async => _client.get(
            _uri(path, query),
            headers: await _headers(json: false),
          ));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() async => _client.post(
            _uri(path),
            headers: await _headers(),
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() async => _client.patch(
            _uri(path),
            headers: await _headers(),
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> delete(String path) =>
      _send(() async => _client.delete(
            _uri(path),
            headers: await _headers(json: false),
          ));

  Future<dynamic> _send(Future<http.Response> Function() send) async {
    try {
      final resp = await send().timeout(AppConstants.httpTimeout);
      return _handle(resp);
    } on SocketException {
      throw const app_errors.NetworkException();
    } on TimeoutException {
      throw const app_errors.NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw app_errors.NetworkException(e.message);
    }
  }

  dynamic _handle(http.Response resp) {
    final code = resp.statusCode;
    if (code >= 200 && code < 300) {
      if (resp.body.isEmpty) return null;
      return jsonDecode(resp.body);
    }
    final message = _extractMessage(resp.body) ?? 'Request failed';
    if (code == 401 || code == 403) throw app_errors.AuthException(message);
    throw app_errors.ServerException(message, statusCode: code);
  }

  String? _extractMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      // not JSON, fall through
    }
    return body;
  }
}
