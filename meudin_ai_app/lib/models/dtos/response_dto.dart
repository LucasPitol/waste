class ResponseDto {
  late dynamic data;
  late bool success;
  late String? errorMessage;
  late String? warningMessage;
  late bool wasAdjusted;
  late String? effectiveStartDate;
  late String? effectiveEndDate;

  ResponseDto({
    this.success = false,
    this.errorMessage,
    this.data,
    this.warningMessage,
    this.wasAdjusted = false,
    this.effectiveStartDate,
    this.effectiveEndDate,
  });

  ResponseDto.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    errorMessage = json['errorMsg'];
    warningMessage = json['warningMessage'];
    wasAdjusted = json['wasAdjusted'] ?? false;
    effectiveStartDate = json['effectiveStartDate'];
    effectiveEndDate = json['effectiveEndDate'];
    data = success ? json['data'] : '';

    if (!success && errorMessage == null) {
      errorMessage = 'Erro inesperado, tente novamente mais tarde';
    }
  }
}
