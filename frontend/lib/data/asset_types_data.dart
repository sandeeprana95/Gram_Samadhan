import 'package:flutter/material.dart';

import '../models/asset_type.dart';

/// Seeded Asset Types for Asset Survey (33+ entries including Amrit Sarovar).
const List<AssetType> assetTypes = [
  AssetType(id: 'ast_01', name: 'Govt. Primary School', iconKey: 'school'),
  AssetType(id: 'ast_02', name: 'Govt. High School', iconKey: 'school'),
  AssetType(id: 'ast_03', name: 'Govt. Sr. Sec. School', iconKey: 'school'),
  AssetType(id: 'ast_04', name: 'Anganwadi Center', iconKey: 'child_care'),
  AssetType(id: 'ast_05', name: 'Community Health Center', iconKey: 'local_hospital'),
  AssetType(id: 'ast_06', name: 'Public Health Center', iconKey: 'medical_services'),
  AssetType(id: 'ast_07', name: 'Veterinary Hospital', iconKey: 'pets'),
  AssetType(id: 'ast_08', name: 'Panchayat Ghar', iconKey: 'account_balance'),
  AssetType(id: 'ast_09', name: 'Community Center', iconKey: 'groups'),
  AssetType(id: 'ast_10', name: 'Women Chaupal', iconKey: 'woman'),
  AssetType(id: 'ast_11', name: 'SC Chaupal', iconKey: 'diversity_3'),
  AssetType(id: 'ast_12', name: 'BC Chaupal', iconKey: 'diversity_3'),
  AssetType(id: 'ast_13', name: 'General Chaupal', iconKey: 'forum'),
  AssetType(id: 'ast_14', name: 'Sports Stadium', iconKey: 'stadium'),
  AssetType(id: 'ast_15', name: 'Gymnasium', iconKey: 'fitness_center'),
  AssetType(id: 'ast_16', name: 'Park cum Vyayamshala', iconKey: 'park'),
  AssetType(id: 'ast_17', name: 'Religious Place', iconKey: 'temple_hindu'),
  AssetType(id: 'ast_18', name: 'Shamshan Ghat', iconKey: 'local_fire_department'),
  AssetType(id: 'ast_19', name: 'Kabristan', iconKey: 'church'),
  AssetType(id: 'ast_20', name: 'Zila Parishad Building', iconKey: 'domain'),
  AssetType(id: 'ast_21', name: 'Block Office Building', iconKey: 'business'),
  AssetType(id: 'ast_22', name: 'Patwar Bhawan', iconKey: 'home_work'),
  AssetType(id: 'ast_23', name: 'Tubewell', iconKey: 'water_drop'),
  AssetType(id: 'ast_24', name: 'Post Office', iconKey: 'local_post_office'),
  AssetType(id: 'ast_25', name: 'Street Network', iconKey: 'alt_route'),
  AssetType(id: 'ast_26', name: 'Open Space', iconKey: 'landscape'),
  AssetType(id: 'ast_27', name: 'Bus Queue Shelter', iconKey: 'directions_bus'),
  AssetType(id: 'ast_28', name: 'Solar Light Pole', iconKey: 'wb_sunny'),
  AssetType(id: 'ast_29', name: 'Library', iconKey: 'local_library'),
  AssetType(id: 'ast_30', name: 'Rajiv Gandhi Seva Kendra', iconKey: 'handshake'),
  AssetType(id: 'ast_31', name: 'Gram Sachivalaya', iconKey: 'gavel'),
  AssetType(id: 'ast_32', name: 'Mahila Sanskriti Kendra', iconKey: 'spa'),
  AssetType(id: 'ast_33', name: 'Old Age Home', iconKey: 'elderly'),
  AssetType(id: 'ast_34', name: 'Amrit Sarovar', iconKey: 'water_drop'),
];

AssetType? assetTypeById(String id) {
  for (final type in assetTypes) {
    if (type.id == id) return type;
  }
  return null;
}

IconData assetTypeIcon(String iconKey) {
  return switch (iconKey) {
    'school' => Icons.school,
    'child_care' => Icons.child_care,
    'local_hospital' => Icons.local_hospital,
    'medical_services' => Icons.local_hospital_outlined,
    'pets' => Icons.pets,
    'account_balance' => Icons.account_balance,
    'groups' => Icons.groups,
    'woman' => Icons.people,
    'diversity_3' => Icons.groups_outlined,
    'forum' => Icons.forum,
    'stadium' => Icons.sports_soccer,
    'fitness_center' => Icons.fitness_center,
    'park' => Icons.park,
    'temple_hindu' => Icons.temple_hindu,
    'local_fire_department' => Icons.local_fire_department,
    'church' => Icons.church,
    'domain' => Icons.domain,
    'business' => Icons.business,
    'home_work' => Icons.home_work,
    'water_drop' => Icons.water_drop,
    'local_post_office' => Icons.local_post_office,
    'alt_route' => Icons.alt_route,
    'landscape' => Icons.landscape,
    'directions_bus' => Icons.directions_bus,
    'wb_sunny' => Icons.wb_sunny,
    'local_library' => Icons.local_library,
    'handshake' => Icons.volunteer_activism,
    'gavel' => Icons.gavel,
    'spa' => Icons.spa,
    'elderly' => Icons.elderly,
    _ => Icons.apartment,
  };
}
