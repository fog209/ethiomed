import 'dart:io';

import 'package:dio/dio.dart';

/// Network resilience configuration for Supabase HTTP calls.
/// Provides generous timeouts suitable for weak 3G networks.
class NetworkConfig {
  static const int connectTimeoutMilliseconds = 30 * 1000;
  static const int receiveTimeoutMilliseconds = 30 * 1000;
  static const int sendTimeoutMilliseconds = 30 * 1000;
}

/// Executes a request with network retry logic and exponential backoff.
/// Retries on SocketException, timeout errors, and 5xx HTTP responses.
Future<T> withNetworkRetry<T>(
  Future<T> Function() request, {
  int maxRetries = 3,
  Duration baseDelay = const Duration(seconds: 2),
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await request();
    } on SocketException {
      if (attempt >= maxRetries) rethrow;
      await Future.delayed(baseDelay * (1 << attempt));
      attempt++;
    } on DioException catch (e) {
      final shouldRetry = (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.response?.statusCode != null &&
                  e.response!.statusCode! >= 500 &&
                  e.response!.statusCode! < 600)) &&
          attempt < maxRetries;
      if (!shouldRetry) rethrow;
      await Future.delayed(baseDelay * (1 << attempt));
      attempt++;
    }
  }
}