

/// Required Detail
class IPLocation {
  final String ip;
  final String country;
  final String region;
  final String regionCode;
  final String city;

  IPLocation({
    required this.ip,
    required this.country,
    required this.region,
    required this.regionCode,
    required this.city,
  });

  factory IPLocation.fromJson(Map<String, dynamic> json) {
    return IPLocation(
      ip: json['ip'] ?? '',
      country: json['country'] ?? '',
      region: json['region'] ?? '',
      regionCode: json['region_code'] ?? '',
      city: json['city'] ?? '',
    );
  }
}