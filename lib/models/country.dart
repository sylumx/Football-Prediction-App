class Country {
  final String code;
  final String name;
  final String flag;

  Country({required this.code, required this.name, required this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'],
      name: json['name'],
      flag: json['flag'],
    );
  }
}
