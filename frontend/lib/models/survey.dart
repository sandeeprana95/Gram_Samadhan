enum SurveyCondition { good, fair, poor, damaged }

extension SurveyConditionLabel on SurveyCondition {
  String get label => switch (this) {
        SurveyCondition.good => 'Good',
        SurveyCondition.fair => 'Fair',
        SurveyCondition.poor => 'Poor',
        SurveyCondition.damaged => 'Damaged',
      };

  String get wireValue => name.toUpperCase();

  static SurveyCondition fromWireValue(String? value) {
    return SurveyCondition.values.firstWhere(
      (c) => c.wireValue == (value ?? '').toUpperCase(),
      orElse: () => SurveyCondition.good,
    );
  }
}

class Survey {
  const Survey({
    required this.id,
    required this.assetId,
    required this.assetTypeId,
    required this.assetName,
    required this.district,
    required this.panchayat,
    required this.village,
    this.latitude,
    this.longitude,
    this.photoUrls = const [],
    this.description,
    required this.condition,
    required this.surveyDate,
    this.surveyedById,
    this.surveyedByName,
    required this.createdAt,
  });

  final String id;
  final String assetId;
  final String assetTypeId;
  final String assetName;
  final String district;
  final String panchayat;
  final String village;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final String? description;
  final SurveyCondition condition;
  final DateTime surveyDate;
  final String? surveyedById;
  final String? surveyedByName;
  final DateTime createdAt;

  factory Survey.fromJson(Map<String, dynamic> json) {
    final photos = json['photoUrls'] as List<dynamic>? ?? const [];
    return Survey(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      assetTypeId: json['assetTypeId'] as String? ?? '',
      assetName: json['assetName'] as String? ?? '',
      district: json['district'] as String? ?? '',
      panchayat: json['panchayat'] as String? ?? '',
      village: json['village'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoUrls: photos.map((e) => e as String).toList(),
      description: json['description'] as String?,
      condition: SurveyConditionLabel.fromWireValue(json['condition'] as String?),
      surveyDate: DateTime.tryParse(json['surveyDate'] as String? ?? '') ??
          DateTime.now(),
      surveyedById: json['surveyedById'] as String?,
      surveyedByName: json['surveyedByName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
