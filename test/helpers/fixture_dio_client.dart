import 'package:dio/dio.dart';
import 'package:flutter_poetry_app/core/network/dio_client.dart';

/// A [DioClient] stand-in that answers every GET with a canned JSON body and
/// records the requested paths. Never touches the network; any other call
/// fails loudly through [noSuchMethod].
class FixtureDioClient implements DioClient {
  FixtureDioClient(this.body);

  final Map<String, dynamic> body;
  final List<String> requestedPaths = [];

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    requestedPaths.add(path);
    return Response<T>(
      data: body as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
