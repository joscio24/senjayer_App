class InvitationItem {
  final String id;
  final int quantity;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  InvitationItem({
    required this.id,
    required this.quantity,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory InvitationItem.fromJson(Map<String, dynamic> json) {
    return InvitationItem(
      id: json['id'],
      quantity: json['quantity'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
