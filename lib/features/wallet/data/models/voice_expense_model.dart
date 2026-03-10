class VoiceExpenseResult {
  final double? amount;
  final String transactionType; // ✅ جديد
  final int? categoryId;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final String? note;
  final String? title;
  final bool isSuccess;
  final String? errorMessage;

  VoiceExpenseResult({
    this.amount,
    this.transactionType = 'Withdrawal', // ✅
    this.categoryId,
    this.categoryNameAr,
    this.categoryNameEn,
    this.note,
    this.title,
    required this.isSuccess,
    this.errorMessage,
  });

  factory VoiceExpenseResult.fromJson(Map<String, dynamic> json) {
    return VoiceExpenseResult(
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      transactionType: json['transactionType'] ?? 'Withdrawal', // ✅
      categoryId: json['categoryId'],
      categoryNameAr: json['categoryNameAr'],
      categoryNameEn: json['categoryNameEn'],
      note: json['note'],
      title: json['title'],
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}