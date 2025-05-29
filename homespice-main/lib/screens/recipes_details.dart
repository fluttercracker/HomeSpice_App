import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';

class RecipeDetail extends StatefulWidget {
  final String mealId;
  const RecipeDetail({super.key, required this.mealId});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  bool isUrdu = false;
  bool isTranslating = false;

  final translator = GoogleTranslator();

  List<String> englishIngredients = [];
  List<String> englishInstructions = [];

  List<String> urduIngredients = [];
  List<String> urduInstructions = [];

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fetched = data['meals'][0];

      final ingList = <String>[];
      for (int i = 0; i < 20; i++) {
        final ingredient = fetched['strIngredient${i + 1}'];
        final measure = fetched['strMeasure${i + 1}'];
        if (ingredient != null &&
            ingredient.toString().trim().isNotEmpty &&
            measure.toString().trim().isNotEmpty) {
          ingList.add('• $ingredient (${measure.trim()})');
        }
      }

      final instrList = parseInstructions(fetched['strInstructions']);

      setState(() {
        recipe = fetched;
        englishIngredients = ingList;
        englishInstructions = instrList;
        isLoading = false;
      });
    }
  }

  List<String> parseInstructions(String? instructions) {
    if (instructions == null || instructions.trim().isEmpty) return [];
    return instructions
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> translateToUrdu() async {
    if (recipe == null) return;

    final translatedIng = <String>[];
    final translatedInstr = <String>[];

    for (final text in englishIngredients) {
      final translated = await translator.translate(text, to: 'ur');
      translatedIng.add(translated.text);
    }

    for (final step in englishInstructions) {
      final translated = await translator.translate(step, to: 'ur');
      translatedInstr.add(translated.text);
    }

    setState(() {
      urduIngredients = translatedIng;
      urduInstructions = translatedInstr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIngredients = isUrdu ? urduIngredients : englishIngredients;
    final currentInstructions = isUrdu ? urduInstructions : englishInstructions;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Recipe Details',
                style: GoogleFonts.aBeeZee(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : recipe == null
              ? const Center(child: Text('Recipe not found'))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                                child: Image.network(
                                  recipe!['strMealThumb'],
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(24),
                                    bottomRight: Radius.circular(24),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withAlpha(
                                          (0.6 * 255).toInt()),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Text(
                                  recipe!['strMeal'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.language,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Translate into Urdu',
                                          style: GoogleFonts.aBeeZee(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                         const SizedBox(width: 8),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if (isTranslating)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                           const SizedBox(width: 8),
                                        Switch(
                                          value: isUrdu,
                                          onChanged: (val) async {
                                            if (val &&
                                                urduIngredients.isEmpty) {
                                              setState(() {
                                                isTranslating = true;
                                              });
                                              await translateToUrdu();
                                              setState(() {
                                                isTranslating = false;
                                              });
                                            }
                                            setState(() {
                                              isUrdu = val;
                                            });
                                          },
                                          activeColor: Colors.blue,
                                        ),
                                        
                                        
                                      ],
                                    ),
                                   
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ingredients',
                                          style: GoogleFonts.aBeeZee(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            shadows: [
                                              Shadow(
                                                offset: const Offset(1.5, 1.5),
                                                blurRadius: 3.0,
                                                color: Colors.black.withAlpha(
                                                  (0.3 * 255).toInt(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...currentIngredients.map(
                                          (text) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3,
                                            ),
                                            child: Text(
                                              text,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Instructions',
                                          style: GoogleFonts.aBeeZee(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            shadows: [
                                              Shadow(
                                                offset: const Offset(1.5, 1.5),
                                                blurRadius: 3.0,
                                                color: Colors.black.withAlpha(
                                                  (0.3 * 255).toInt(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...currentInstructions.map(
                                          (step) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "•  ",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    step,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
