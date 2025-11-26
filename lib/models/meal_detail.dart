class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtubeUrl;
  final List<String> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtubeUrl,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final ingredientText = ingredient.toString().trim();
        final measureText = measure == null ? '' : measure.toString().trim();
        final combined = measureText.isNotEmpty
            ? '$ingredientText - $measureText'
            : ingredientText;
        ingredients.add(combined);
      }
    }

    return MealDetail(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      thumbnail: json['strMealThumb']?.toString() ?? '',
      youtubeUrl: json['strYoutube']?.toString() ?? '',
      ingredients: ingredients,
    );
  }
}
