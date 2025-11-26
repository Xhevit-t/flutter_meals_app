import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/categories.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categoriesJson = data['categories'] ?? [];
      return categoriesJson.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/filter.php?c=$category');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'] ?? [];
      return mealsJson.map((e) => MealSummary.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<MealSummary>> searchMealsInCategory(
      String query, String category) async {
    if (query.trim().isEmpty) {
      return fetchMealsByCategory(category);
    }
    final uri = Uri.parse('$baseUrl/search.php?s=$query');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson == null) {
        return [];
      }
      return mealsJson
          .where((e) =>
      (e['strCategory'] as String?)?.toLowerCase() ==
          category.toLowerCase())
          .map<MealSummary>((e) => MealSummary.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final uri = Uri.parse('$baseUrl/lookup.php?i=$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'] ?? [];
      if (mealsJson.isEmpty) {
        throw Exception('Meal not found');
      }
      return MealDetail.fromJson(mealsJson.first);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  Future<MealDetail> fetchRandomMeal() async {
    final uri = Uri.parse('$baseUrl/random.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List mealsJson = data['meals'] ?? [];
      if (mealsJson.isEmpty) {
        throw Exception('Random meal not found');
      }
      return MealDetail.fromJson(mealsJson.first);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
