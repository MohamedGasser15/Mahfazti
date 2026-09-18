import 'package:dio/dio.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';

class CategoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.categories,
        requiresAuth: true,
      );
      final List data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<Category> createCategory(String nameAr, String nameEn) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.categories,
        {'nameAr': nameAr, 'nameEn': nameEn},
        requiresAuth: true,
      );
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<Category> updateCategory(int id, String nameAr, String nameEn) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.categoryById}/$id',
        {'id': id, 'nameAr': nameAr, 'nameEn': nameEn},
        requiresAuth: true,
      );
      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiService.delete(
        '${ApiEndpoints.categoryById}/$id',
        requiresAuth: true,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }
}