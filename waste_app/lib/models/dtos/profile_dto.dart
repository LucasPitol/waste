class ProfileDto {
  double totalWaste;
  Map<String, double> spendsByCategoryMap;

  ProfileDataDto() {
    this.spendsByCategoryMap = Map<String, double>();
  }
}
