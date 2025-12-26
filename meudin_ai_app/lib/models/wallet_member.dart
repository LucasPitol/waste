class WalletMember {
  String? id;
  String? name;
  String? email;

  WalletMember({
    this.id,
    this.name,
    this.email,
  });

  WalletMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
