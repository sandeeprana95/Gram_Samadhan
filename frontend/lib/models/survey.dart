enum SurveyStatus { draft, submitted }

class GeoTaggedPhoto {
  const GeoTaggedPhoto({
    required this.url,
    this.latitude,
    this.longitude,
  });

  final String url;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
        'url': url,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory GeoTaggedPhoto.fromJson(Map<String, dynamic> json) {
    return GeoTaggedPhoto(
      url: json['url'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class Survey {
  const Survey({
    required this.id,
    required this.assetTypeId,
    required this.district,
    required this.gramPanchayat,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    required this.conditionRating,
    required this.functionalStatus,
    this.prInstitutionLevel,
    this.notes = '',
    this.photos = const [],
    required this.status,
    required this.synced,
    this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String assetTypeId;
  final String district;
  final String gramPanchayat;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;
  final int conditionRating;
  final String functionalStatus;
  final String? prInstitutionLevel;
  final String notes;
  final List<GeoTaggedPhoto> photos;
  final SurveyStatus status;
  final bool synced;
  final String? createdBy;
  final DateTime createdAt;

  Survey copyWith({
    String? id,
    String? assetTypeId,
    String? district,
    String? gramPanchayat,
    double? gpsLat,
    double? gpsLng,
    double? gpsAccuracy,
    int? conditionRating,
    String? functionalStatus,
    String? prInstitutionLevel,
    String? notes,
    List<GeoTaggedPhoto>? photos,
    SurveyStatus? status,
    bool? synced,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Survey(
      id: id ?? this.id,
      assetTypeId: assetTypeId ?? this.assetTypeId,
      district: district ?? this.district,
      gramPanchayat: gramPanchayat ?? this.gramPanchayat,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      conditionRating: conditionRating ?? this.conditionRating,
      functionalStatus: functionalStatus ?? this.functionalStatus,
      prInstitutionLevel: prInstitutionLevel ?? this.prInstitutionLevel,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      synced: synced ?? this.synced,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'asset_type_id': assetTypeId,
        'district': district,
        'gram_panchayat': gramPanchayat,
        'gps_lat': gpsLat,
        'gps_lng': gpsLng,
        'gps_accuracy': gpsAccuracy,
        'condition_rating': conditionRating,
        'functional_status': functionalStatus,
        'pr_institution_level': prInstitutionLevel,
        'notes': notes,
        'photos': photos.map((p) => p.toJson()).toList(),
        'status': status.name,
        'synced': synced,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };

  factory Survey.fromJson(Map<String, dynamic> json) {
    final photosJson = json['photos'] as List<dynamic>? ?? const [];
    return Survey(
      id: json['id'] as String,
      assetTypeId: json['asset_type_id'] as String,
      district: json['district'] as String? ?? '',
      gramPanchayat: json['gram_panchayat'] as String? ?? '',
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      gpsAccuracy: (json['gps_accuracy'] as num?)?.toDouble(),
      conditionRating: json['condition_rating'] as int? ?? 3,
      functionalStatus: json['functional_status'] as String? ?? 'Active',
      prInstitutionLevel: json['pr_institution_level'] as String?,
      notes: json['notes'] as String? ?? '',
      photos: photosJson
          .map((e) => GeoTaggedPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: SurveyStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SurveyStatus.draft,
      ),
      synced: json['synced'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
