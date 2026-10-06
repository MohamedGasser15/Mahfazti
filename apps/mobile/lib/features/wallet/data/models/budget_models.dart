class BudgetDto {
  final double monthlyBudget;
  final double currentSpending;
  final List<CategoryBudgetDto> categoryBudgets;

  BudgetDto({
    required this.monthlyBudget,
    required this.currentSpending,
    required this.categoryBudgets,
  });

  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    return BudgetDto(
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      currentSpending: (json['currentSpending'] as num?)?.toDouble() ?? 0.0,
      categoryBudgets: (json['categoryBudgets'] as List?)
              ?.map((e) => CategoryBudgetDto.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyBudget': monthlyBudget,
        'currentSpending': currentSpending,
        'categoryBudgets': categoryBudgets.map((e) => e.toJson()).toList(),
      };

  BudgetDto copyWith({
    double? monthlyBudget,
    double? currentSpending,
    List<CategoryBudgetDto>? categoryBudgets,
  }) {
    return BudgetDto(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currentSpending: currentSpending ?? this.currentSpending,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  /// Default 4-item seed data so the user has realistic, lively initial budgets (including one unset category and unset monthly budget)
  static BudgetDto defaultSeed() {
    return BudgetDto(
      monthlyBudget: 0.0,
      currentSpending: 7300.0,
      categoryBudgets: [
        CategoryBudgetDto(
          id: 1,
          categoryId: 1,
          categoryNameAr: 'طعام ومطاعم',
          categoryNameEn: 'Food & Dining',
          budget: 5000.0,
          spent: 3200.0,
        ),
        CategoryBudgetDto(
          id: 2,
          categoryId: 2,
          categoryNameAr: 'تسوق ومستلزمات',
          categoryNameEn: 'Shopping & Retail',
          budget: 4000.0,
          spent: 2150.0,
        ),
        CategoryBudgetDto(
          id: 3,
          categoryId: 3,
          categoryNameAr: 'فواتير وخدمات',
          categoryNameEn: 'Bills & Utilities',
          budget: 2500.0,
          spent: 1500.0,
        ),
        CategoryBudgetDto(
          id: 4,
          categoryId: 4,
          categoryNameAr: 'مواصلات وسيارة',
          categoryNameEn: 'Transportation',
          budget: 0.0,
          spent: 450.0,
        ),
      ],
    );
  }
}

class CategoryBudgetDto {
  final int id;
  final int categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  final double budget;
  final double spent;
  final String? groupName;

  CategoryBudgetDto({
    required this.id,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.budget,
    required this.spent,
    this.groupName,
  });

  factory CategoryBudgetDto.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetDto(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoryNameAr: json['categoryNameAr'] ?? '',
      categoryNameEn: json['categoryNameEn'] ?? '',
      budget: (json['budgetAmount'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      groupName: json['groupName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryNameAr': categoryNameAr,
        'categoryNameEn': categoryNameEn,
        'budgetAmount': budget,
        'budget': budget,
        'spent': spent,
        if (groupName != null) 'groupName': groupName,
      };

  CategoryBudgetDto copyWith({
    int? id,
    int? categoryId,
    String? categoryNameAr,
    String? categoryNameEn,
    double? budget,
    double? spent,
    String? groupName,
    bool clearGroup = false,
  }) {
    return CategoryBudgetDto(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      groupName: clearGroup ? null : (groupName ?? this.groupName),
    );
  }
}