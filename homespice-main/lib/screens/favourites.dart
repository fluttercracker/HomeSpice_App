import 'package:flutter/material.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Card(
      elevation: 4,
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/images/pasta.jpg', // Replace with your image path
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Title and time
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Delicious Pasta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("30 min", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          // Favorite button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // Add to favorites logic
              },
              icon: const Icon(Icons.favorite_border, color: Colors.deepPurple),
              label: const Text("Add to Favourite", style: TextStyle(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
      ),
      ),
      ),
    );
  }
}