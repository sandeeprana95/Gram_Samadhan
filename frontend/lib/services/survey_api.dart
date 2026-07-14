import '../data/asset_types_data.dart';
import '../models/asset_type.dart';
import '../models/survey.dart';

/// Stub API layer for Asset Survey.
///
/// Endpoints:
/// - GET  /api/asset-types
/// - GET  /api/surveys/existing-assets
/// - POST /api/surveys
/// - POST /api/surveys/draft
/// - POST /api/surveys/sync
class SurveyApi {
  SurveyApi._();

  static final List<Survey> _localSurveys = [];
  static final List<Survey> _offlineQueue = [];

  /// GET /api/asset-types
  static Future<List<AssetType>> getAssetTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List<AssetType>.unmodifiable(assetTypes);
  }

  /// GET /api/asset-types/:id/instances
  ///
  /// Returns surveyed asset instances for the given asset type.
  static Future<List<Survey>> getAssetTypeInstances(String assetTypeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final fromLocal = _localSurveys
        .where(
          (s) =>
              s.assetTypeId == assetTypeId &&
              s.status == SurveyStatus.submitted,
        )
        .toList();
    final fromSeed = _seedExistingAssets()
        .where((s) => s.assetTypeId == assetTypeId)
        .toList();

    final byId = <String, Survey>{};
    for (final s in [...fromSeed, ...fromLocal]) {
      byId[s.id] = s;
    }
    return List<Survey>.unmodifiable(byId.values.toList());
  }

  /// Resolves a surveyed asset instance by id (seed + local submissions).
  static Survey? getAssetInstance(String? assetInstanceId) {
    if (assetInstanceId == null || assetInstanceId.isEmpty) return null;
    for (final s in _localSurveys) {
      if (s.id == assetInstanceId) return s;
    }
    for (final s in _seedExistingAssets()) {
      if (s.id == assetInstanceId) return s;
    }
    return null;
  }

  /// GET /api/surveys/existing-assets
  static Future<List<Survey>> getExistingAssets() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final submitted = _localSurveys
        .where((s) => s.status == SurveyStatus.submitted)
        .toList(growable: false);
    if (submitted.isNotEmpty) return submitted;
    return List<Survey>.unmodifiable(_seedExistingAssets());
  }

  /// POST /api/surveys
  static Future<Survey> submitSurvey(Survey survey) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final submitted = survey.copyWith(
      status: SurveyStatus.submitted,
      synced: true,
    );
    _upsert(_localSurveys, submitted);
    _offlineQueue.removeWhere((s) => s.id == submitted.id);
    return submitted;
  }

  /// POST /api/surveys/draft
  static Future<Survey> saveDraft(Survey survey) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final draft = survey.copyWith(
      status: SurveyStatus.draft,
      synced: false,
    );
    _upsert(_localSurveys, draft);
    return draft;
  }

  /// POST /api/surveys/sync
  static Future<List<Survey>> syncOfflineQueue([List<Survey>? queue]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final pending = queue ?? List<Survey>.from(_offlineQueue);
    final synced = <Survey>[];

    for (final item in pending) {
      final result = item.copyWith(
        status: SurveyStatus.submitted,
        synced: true,
      );
      _upsert(_localSurveys, result);
      synced.add(result);
    }

    if (queue == null) {
      _offlineQueue.clear();
    } else {
      final syncedIds = synced.map((s) => s.id).toSet();
      _offlineQueue.removeWhere((s) => syncedIds.contains(s.id));
    }

    return synced;
  }

  static Future<Survey> enqueueOfflineSubmit(Survey survey) async {
    final queued = survey.copyWith(
      status: SurveyStatus.submitted,
      synced: false,
    );
    _upsert(_offlineQueue, queued);
    _upsert(_localSurveys, queued);
    return queued;
  }

  static void _upsert(List<Survey> list, Survey survey) {
    final index = list.indexWhere((s) => s.id == survey.id);
    if (index >= 0) {
      list[index] = survey;
    } else {
      list.insert(0, survey);
    }
  }

  static List<Survey> _seedExistingAssets() {
    final now = DateTime.now();
    return [
      Survey(
        id: 'SVY-SEED-001',
        assetTypeId: 'ast_01',
        district: 'Gurugram',
        gramPanchayat: 'Bhondsi',
        gpsLat: 28.3521,
        gpsLng: 77.0642,
        gpsAccuracy: 8.2,
        conditionRating: 3,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Near main chowk',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Survey(
        id: 'SVY-SEED-001b',
        assetTypeId: 'ast_01',
        district: 'Gurugram',
        gramPanchayat: 'Sohna',
        gpsLat: 28.2474,
        gpsLng: 77.0659,
        conditionRating: 4,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Near school road',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      Survey(
        id: 'SVY-SEED-002',
        assetTypeId: 'ast_04',
        district: 'Gurugram',
        gramPanchayat: 'Bhondsi',
        gpsLat: 28.3510,
        gpsLng: 77.0630,
        conditionRating: 4,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Ward 3',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Survey(
        id: 'SVY-SEED-023a',
        assetTypeId: 'ast_23',
        district: 'Gurugram',
        gramPanchayat: 'Bhondsi',
        gpsLat: 28.3530,
        gpsLng: 77.0610,
        conditionRating: 3,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Khera side',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Survey(
        id: 'SVY-SEED-023b',
        assetTypeId: 'ast_23',
        district: 'Gurugram',
        gramPanchayat: 'Rampur',
        conditionRating: 2,
        functionalStatus: 'Under Repair',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Village pond bank',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      Survey(
        id: 'SVY-SEED-025',
        assetTypeId: 'ast_25',
        district: 'Gurugram',
        gramPanchayat: 'Bhondsi',
        conditionRating: 3,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Main street stretch',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 11)),
      ),
      Survey(
        id: 'SVY-SEED-003',
        assetTypeId: 'ast_34',
        district: 'Hisar',
        gramPanchayat: 'Adampur',
        conditionRating: 5,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Amrit Sarovar · north bund',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Survey(
        id: 'SVY-SEED-028',
        assetTypeId: 'ast_28',
        district: 'Gurugram',
        gramPanchayat: 'Bhondsi',
        conditionRating: 4,
        functionalStatus: 'Active',
        prInstitutionLevel: 'Gram Panchayat',
        notes: 'Bus stand road',
        status: SurveyStatus.submitted,
        synced: true,
        createdBy: 'citizen',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }
}
