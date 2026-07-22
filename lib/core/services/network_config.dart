import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

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
