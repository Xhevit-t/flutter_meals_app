import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_grid_item.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final Category category;

  const MealsByCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final MealApiService _service = MealApiService();
  final TextEditingController _searchController = TextEditingController();

  List<MealSummary> _allMeals = [];
  List<MealSummary> _filteredMeals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final meals =
      await _service.fetchMealsByCategory(widget.category.name);
      setState(() {
        _allMeals = meals;
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _allMeals;
      });
    } else {
      setState(() {
        _filteredMeals = _allMeals
            .where(
              (meal) => meal.name.toLowerCase().contains(query),
        )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      body: Container(
        color: const Color(0xFFFDF6EC),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFFDF6EC),
                elevation: 0,
                title: Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.category.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                      'Search meals in ${widget.category.name}',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (_filteredMeals.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No meals found')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final meal = _filteredMeals[index];
                        return MealGridItem(
                          meal: meal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealDetailScreen(
                                  mealId: meal.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: _filteredMeals.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
