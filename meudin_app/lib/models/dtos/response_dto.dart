class ResponseDto {
  late int statusCode;
  late bool success;
  late String errorMsg;
  late dynamic data;

  ResponseDto() {
    success = false;
  }
}