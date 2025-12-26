class WalletMember {
  String? id;
  String? name;
  String? email;
  String? role; // 'owner' or 'viewer'

  WalletMember({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  WalletMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  bool get isOwner => role == 'owner';
}
