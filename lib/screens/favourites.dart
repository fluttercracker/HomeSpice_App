import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homespice/screens/recipes_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteRecipes();
  }

  Future<void> refreshData() async {
   await fetchFavoriteRecipes();             // Refresh meals list based on filters
}


  Future<void> fetchFavoriteRecipes() async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final ids = List<String>.from(doc.data()?['RecipesIDs'] ?? []);

    List<Map<String, dynamic>> recipes = [];

    for (String id in ids) {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          recipes.add(data['meals'][0]);
        }
      }
    }

    setState(() {
      favoriteRecipes = recipes;
      isLoading = false;
    });
  }

  Future<void> removeFromFavorites(String mealId, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.update({
      'RecipesIDs': FieldValue.arrayRemove([mealId]),
    });

    final removedItem = favoriteRecipes.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildRecipeCard(removedItem, index, animation),
      duration: const Duration(milliseconds: 500),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites')),
    );
    refreshData();
  }

  Widget _buildRecipeCard(
    Map<String, dynamic> meal,
    int index,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetail(mealId: meal['idMeal']),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    meal['strMealThumb'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const Icon(Icons.timer,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text(
                            "20 min",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () =>
                                removeFromFavorites(meal['idMeal'], index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchFavoriteRecipes,
              child: favoriteRecipes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No favourites yet.")),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final meal = favoriteRecipes[index];
                        return _buildRecipeCard(
                          meal, index, kAlwaysCompleteAnimation);
                      },
                    ),
            ),
    );
  }
}

const kAlwaysCompleteAnimation = AlwaysStoppedAnimation(1.0);
