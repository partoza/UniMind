import 'package:flutter/material.dart';

Map<String, dynamic> mapFromSnapshotData(Object? raw) {
  if (raw == null) return <String, dynamic>{};
  
  try {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    
    if (raw is Map) {
      // Use Map.from to create a new map with proper typing
      final converted = Map<String, dynamic>.from(raw);
      return converted;
    }
    
    return <String, dynamic>{};
  } catch (e) {
    debugPrint('Error converting map: $e');
    return <String, dynamic>{};
  }
}