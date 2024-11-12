class ResponseDto {
  late dynamic data;
  late bool success;
  late String? errorMessage;

  ResponseDto() {}

  ResponseDto.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorMessage = json['errorMessage'];
    data = success ? json['data'] : '';

    if (!success && errorMessage == null) {
      errorMessage = 'Erro inesperado, tente novamente mais tarde';
    }
  }
}
