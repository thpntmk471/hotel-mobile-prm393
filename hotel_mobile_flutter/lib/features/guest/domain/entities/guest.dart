class Guest {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String documentNumber;
  final String address;
  final String rowVersion;

  const Guest({
    required this.id,
    required this.fullName,
    this.phoneNumber = '',
    this.email = '',
    this.documentNumber = '',
    this.address = '',
    this.rowVersion = '',
  });
}

