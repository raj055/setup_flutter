import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

import 'api.dart';
import 'auth.dart';

class Vapor {
  static Future<dynamic> upload(
    File? file, {
    void progressCallback(int? completed, int? total)?,
  }) async {
    String contentType = lookupMimeType(file!.path);

    Response signedUrlResponse = await Api.http.post(
      'vapor/signed-storage-url?token=' + Auth.token()!,
      data: {'content_type': contentType},
    ).then((res) {
      return res;
    });
    String fileName = "${signedUrlResponse.data['uuid']}\.${file.path.split(".").last}";

    Dio dio = new Dio();
    dio.options.headers = {
      'x-amz-acl': 'private',
      'content-type': contentType,
      'content-length': file.lengthSync(),
    };

    MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    );
    Response uploadResponse = await dio.put(
      signedUrlResponse.data['url'],
      data: multipartFile.finalize(),
      onSendProgress: (completed, total) {
        progressCallback!(completed, total);
      },
    );

    if (uploadResponse.statusCode == 200) {
      return fileName;
    }

    return false;
  }
}
