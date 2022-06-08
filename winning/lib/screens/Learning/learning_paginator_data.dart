import 'package:dio/dio.dart';

class PaginationData {
  List<dynamic>? data;
  int? statusCode;
  String? errorMessage;
  int? total;
  int? nItems;

  PaginationData.fromResponse(Response response) {
    this.statusCode = response.statusCode;
    data = response.data['learning']['data'];
    total = response.data['learning']['total'];
    nItems = data!.length;
  }

  PaginationData.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}
