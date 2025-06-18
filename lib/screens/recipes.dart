import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homespice/screens/recipes_details.dart';
import 'package:http/http.dart' as http;

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  List meals = [];
  List<String> categories = ['All'];
  List<String> areas = ['All'];
  String selectedCategory = 'All';
  String selectedArea = 'All';
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  Set<String> favoriteRecipeIds = {};
  final user = FirebaseAuth.instance.currentUser;
  final List<String> timeOptions = [
    "15 min",
    "20 min",
    "25 min",
    "30 min",
    "35 min",
    "40 min",
  ];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchAreas();
    fetchMeals();
    fetchFavoriteRecipeIds();
   
  }

  Future<void> refreshData() async {
    await fetchMeals();
    await fetchFavoriteRecipeIds(); // Refresh meals list based on filters
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final catList =
          data['meals']
              .map<String>((item) => item['strCategory'].toString())
              .toList();
      setState(() {
        categories = ['All', ...catList];
      });
    }
  }

  Future<void> fetchAreas() async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final areaList =
          data['meals']
              .map<String>((item) => item['strArea'].toString())
              .toList();
      setState(() {
        areas = ['All', ...areaList];
      });
    }
  }

  Future<void> fetchMeals({String? search}) async {
    setState(() => isLoading = true);
    Uri url;

    if (search != null && search.isNotEmpty) {
      url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=$search',
      );
    } else if (selectedCategory != 'All') {
      url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$selectedCategory',
      );
    } else if (selectedArea != 'All') {
      url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?a=$selectedArea',
      );
    } else {
      url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=');
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        meals = data['meals'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> fetchFavoriteRecipeIds() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      final data = doc.data();
      if (data != null && data['RecipesIDs'] != null) {
        setState(() {
          favoriteRecipeIds = Set<String>.from(data['RecipesIDs']);
        });
      }
    }
  }

  Widget buildScrollableButtonRow({
    required List<String> options,
    required String selectedValue,
    required void Function(String value) onSelected,
    required Color activeColor,
  }) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selectedValue;

          return ElevatedButton(
            onPressed: () {
              onSelected(option);
              fetchMeals();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSelected
                      ? activeColor
                      : const Color.fromARGB(255, 252, 251, 251),
              foregroundColor: isSelected ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? activeColor : Colors.grey,
                  width: 1.2,
                ),
              ),
              elevation: isSelected ? 3 : 0,
            ),
            child: Text(option, style: const TextStyle(fontSize: 14)),
          );
        },
      ),
    );
  }

  Future<void> handleFavoriteToggle(
    String recipeId,
    String recipeName,
    bool currentlyFavorite,
  ) async {
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid);
      if (currentlyFavorite) {
        await docRef.update({
          'RecipesIDs': FieldValue.arrayRemove([recipeId]),
        });
      } else {
        await docRef.update({
          'RecipesIDs': FieldValue.arrayUnion([recipeId]),
        });
      }
      await fetchFavoriteRecipeIds(); // Refresh favorites after change

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyFavorite
                ? '$recipeName removed from favorites!'
                : '$recipeName added to favorites!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            buildScrollableButtonRow(
              options: areas,
              selectedValue: selectedArea,
              onSelected: (val) => setState(() => selectedArea = val),
              activeColor: Colors.deepOrange,
            ),
            const SizedBox(height: 10),
            buildScrollableButtonRow(
              options: categories,
              selectedValue: selectedCategory,
              onSelected: (val) => setState(() => selectedCategory = val),
              activeColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    fetchMeals();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) => fetchMeals(search: value),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await fetchFavoriteRecipeIds();
                  await fetchMeals();
                },
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : meals.isEmpty
                        ? const Center(child: Text('No recipes found'))
                        : ListView.builder(
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            final recipeId = meal['idMeal'];
                            final isFavorite = favoriteRecipeIds.contains(
                              recipeId,
                            );
                            final time =
                                timeOptions[random.nextInt(timeOptions.length)];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => RecipeDetail(
                                          mealId: meal['idMeal'],
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        meal['strMealThumb'],
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              meal['strMeal'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.timer,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                time,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  isFavorite
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: Colors.deepPurple,
                                                ),
                                                onPressed: () async {
                                                  await handleFavoriteToggle(
                                                    recipeId,
                                                    meal['strMeal'],
                                                    isFavorite,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
