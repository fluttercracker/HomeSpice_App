import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // for Clipboard

class AIBot extends StatefulWidget {
  const AIBot({super.key});

  @override
  State<AIBot> createState() => _AIBotState();
}

class _AIBotState extends State<AIBot> {
  final TextEditingController _ingredientController = TextEditingController();
  String _recipe = '';
  bool _isLoading = false;

  static const String apiKey =
      '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';

  Future<void> generateRecipe() async {
    final ingredients = _ingredientController.text.trim();

    if (ingredients.isEmpty) {
      showMessage('Please enter some ingredients.');
      return;
    }

    final ingredientList =
        ingredients
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (ingredientList.length < 4) {
      showMessage('Please enter at least 4 ingredients, separated by commas.');
      return;
    }

    setState(() {
      _isLoading = true;
      _recipe = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'your-app-name-or-domain', // Optional but recommended
          'X-Title':
              'recipe-bot-test', // Optional: title shown in your OpenRouter dashboard
        },
        body: json.encode({
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Generate a easy english recipe using these ingredients: $ingredients. Include a title, a list of ingredients, and step-by-step cooking instructions.",
            },
          ],
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() => _recipe = content);
      } else {
        showMessage('Failed to generate recipe. Please try again later.');
      }
    } catch (e) {
      showMessage('An error occurred. Check your internet connection.');
    }

    setState(() => _isLoading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Input Ingredients and Get Delicious Recipes, Cook Smart with AI',
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(
                labelText: 'Enter at least 4 ingredients',
                hintText: 'e.g., tomato, onion, garlic, basil',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ingredientController.clear();
                  },
                ),
              ),
              maxLines: 2,
              minLines: 1,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : generateRecipe,
              icon:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: Colors.white,
                      ),
              label:
                  _isLoading
                      ? const SizedBox.shrink()
                      : const Text(
                        'Generate Recipe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _recipe.isEmpty
                      ? const SizedBox.shrink()
                      : SingleChildScrollView(
                        child: Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gradient header with copy icon
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple,
                                      Colors.purpleAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recipe Details',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'Copy Recipe',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: _recipe),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Recipe copied to clipboard!',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Recipe content
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SelectableText(
                                  _recipe,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),

    );
  }
}
