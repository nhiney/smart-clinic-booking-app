import 'dart:math' as math;

/// Sort modes for patient doctor discovery.
enum DoctorCatalogSort {
  /// Highest rating first (tie-break: total reviews).
  ratingDesc,

  /// Highest review count first.
  popular,

  /// Nearest first using [DoctorCatalogQuery.userLatitude] / [userLongitude].
  nearest,
  
  /// Most experienced first.
  experienceDesc,

  /// Least experienced first (rarely used but good for completeness).
  experienceAsc,
}

/// Filters + sort for querying the `doctors` Firestore collection.
class DoctorCatalogQuery {
  final String? searchText;
  final String? specialty;
  final double? minRating;
  final String? locationSubstring;
  final DoctorCatalogSort sort;
  final double? userLatitude;
  final double? userLongitude;

  const DoctorCatalogQuery({
    this.searchText,
    this.specialty,
    this.minRating,
    this.locationSubstring,
    this.sort = DoctorCatalogSort.ratingDesc,
    this.userLatitude,
    this.userLongitude,
  });

  static double? haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (lat1 == 0 && lon1 == 0 || lat2 == 0 && lon2 == 0) return null;
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}
