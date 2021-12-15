import 'dart:convert';

import 'package:http/http.dart';

class ResponseDto {
  late int statusCode;
  late bool success;
  late String errorMsg;
  late dynamic data;

  ResponseDto(Response res) {
    print(res.body);
    this.statusCode = res.statusCode;
    var body = json.decode(res.body);
    this.success = body['success'];
    this.errorMsg = body['errorMsg'];
    this.data = success ? body['data'] : '';
  }
}