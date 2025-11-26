import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/meal_api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String? mealId;
  final MealDetail? meal;

  const MealDetailScreen({
    super.key,
    this.mealId,
    this.meal,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _service = MealApiService();

  MealDetail? _meal;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      _meal = widget.meal;
      _isLoading = false;
    } else if (widget.mealId != null) {
      _loadMeal();
    } else {
      _errorMessage = 'No meal id provided';
      _isLoading = false;
    }
  }

  Future<void> _loadMeal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final meal = await _service.fetchMealDetail(widget.mealId!);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openYoutube() async {
    if (_meal == null || _meal!.youtubeUrl.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(_meal!.youtubeUrl);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_meal?.name ?? 'Recipe'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _meal == null
          ? const Center(child: Text('No data'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _meal!.thumbnail,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _meal!.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_meal!.category.isNotEmpty)
                  Chip(
                    label: Text(_meal!.category),
                  ),
                const SizedBox(width: 8),
                if (_meal!.area.isNotEmpty)
                  Chip(
                    label: Text(_meal!.area),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _meal!.ingredients
                      .map(
                        (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3),
                      child: Text('• $ingredient'),
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Instructions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _meal!.instructions,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_meal!.youtubeUrl.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openYoutube,
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('Watch on YouTube'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
