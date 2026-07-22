import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

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

class FirebasePerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = _toHttpMethod(options.method);
    final metric = FirebasePerformance.instance
        .newHttpMetric(Uri.encodeFull(options.uri.toString()), method);

    options.extra['firebase_metric'] = metric;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _finishMetric(response.requestOptions, response.statusCode,
        response.data?.toString().length);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _finishMetric(err.requestOptions, err.response?.statusCode, null);
    handler.next(err);
  }

  Future<void> _finishMetric(
    RequestOptions options,
    int? statusCode,
    int? payloadLength,
  ) async {
    final metric = options.extra['firebase_metric'] as HttpMetric?;
    if (metric == null) return;

    if (statusCode != null) {
      metric.httpResponseCode = statusCode;
    }
    if (payloadLength != null && payloadLength > 0) {
      metric.responsePayloadSize = payloadLength;
    }
    await metric.stop();
  }

  static HttpMethod _toHttpMethod(String method) {
    return switch (method.toUpperCase()) {
      'GET' => HttpMethod.Get,
      'POST' => HttpMethod.Post,
      'PUT' => HttpMethod.Put,
      'DELETE' => HttpMethod.Delete,
      'PATCH' => HttpMethod.Patch,
      'HEAD' => HttpMethod.Head,
      'OPTIONS' => HttpMethod.Options,
      _ => HttpMethod.Get,
    };
  }
}