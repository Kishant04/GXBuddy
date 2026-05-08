class CategoryBudget {
  const CategoryBudget({required this.category, required this.spent, required this.limit});

  factory CategoryBudget.fromJson(String category, Map<String, dynamic> json) => CategoryBudget(
        category: category,
        spent: (json['spent'] as num).toDouble(),
        limit: (json['limit'] as num).toDouble(),
      );

  final String category;
  final double spent;
  final double limit;

  double get percent => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
  int get percentInt => (percent * 100).round().clamp(0, 999);

  CategoryBudget copyWith({String? category, double? spent, double? limit}) => CategoryBudget(
        category: category ?? this.category,
        spent: spent ?? this.spent,
        limit: limit ?? this.limit,
      );
}

class WeeklyBudget {
  const WeeklyBudget({
    required this.totalSpent,
    required this.totalBudget,
    required this.categories,
  });

  factory WeeklyBudget.fromJson(Map<String, dynamic> json) {
    final byCategory = json['by_category'] as Map<String, dynamic>? ?? {};
    return WeeklyBudget(
      totalSpent: (json['total'] as num).toDouble(),
      totalBudget: (json['budget'] as num).toDouble(),
      categories: byCategory.entries
          .map((e) => CategoryBudget.fromJson(e.key, e.value as Map<String, dynamic>))
          .toList(),
    );
  }

  final double totalSpent;
  final double totalBudget;
  final List<CategoryBudget> categories;

  double get overallPercent => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.5) : 0.0;
  int get overallPercentInt => (overallPercent * 100).round().clamp(0, 999);

  CategoryBudget? category(String name) =>
      categories.where((c) => c.category.toLowerCase() == name.toLowerCase()).firstOrNull;

  WeeklyBudget copyWith({double? totalSpent, double? totalBudget, List<CategoryBudget>? categories}) =>
      WeeklyBudget(
        totalSpent: totalSpent ?? this.totalSpent,
        totalBudget: totalBudget ?? this.totalBudget,
        categories: categories ?? this.categories,
      );
}
