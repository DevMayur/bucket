/// Represents pagination information for file listings
class Pagination {
  /// Current page number
  final int currentPage;
  
  /// Total number of pages
  final int totalPages;
  
  /// Total count of items
  final int totalCount;
  
  /// Number of items per page
  final int perPage;
  
  /// Whether there is a next page
  final bool hasNext;
  
  /// Whether there is a previous page
  final bool hasPrevious;

  const Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.perPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Creates a Pagination from JSON data
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalCount: json['total_count'] as int,
      perPage: json['per_page'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }

  /// Converts the Pagination to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_count': totalCount,
      'per_page': perPage,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }

  @override
  String toString() {
    return 'Pagination(page: $currentPage/$totalPages, total: $totalCount, perPage: $perPage)';
  }
} 