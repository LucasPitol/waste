class ResponseDto {
  late dynamic data;
  late bool success;
  late String? errorMessage;
  late String? warningMessage;

  ResponseDto({
    this.success = false,
    this.errorMessage,
    this.data,
    this.warningMessage,
  });

  ResponseDto.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    errorMessage = json['errorMsg'];
    warningMessage = json['warningMessage'];
    data = success ? json['data'] : '';

    if (!success && errorMessage == null) {
      errorMessage = 'Erro inesperado, tente novamente mais tarde';
    }
  }
}
