class MemberDto {
  late String id;
  late String name;
  late String email;

  MemberDto() {}

  MemberDto.fromJson(Map<String, dynamic> memberMap) {
    this.id = memberMap['id'];
    this.name = memberMap['name'];
    this.email = memberMap['email'];
  }
}
