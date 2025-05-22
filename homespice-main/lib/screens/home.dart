import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homespice/screens/drawer.dart';
import 'package:homespice/screens/recipes.dart';
import 'package:homespice/screens/ai_bot.dart';
import 'package:homespice/screens/favourites.dart';
import 'package:homespice/screens/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Map<String, dynamic>> _appBarItems = [
    {'title': 'Home Spice', 'icon': Icons.home},
    {'title': 'Recipes', 'icon': Icons.restaurant_sharp},
    {'title': '  AI Recipes', 'icon': FontAwesomeIcons.robot},
    {'title': 'Favourites', 'icon': Icons.favorite_border_rounded},
    {'title': 'User Profile', 'icon': Icons.verified_user_outlined},
  ];

  late final List<Widget> _pages = [
    _HomePageContent(onExploreTap: () => _onItemTapped(1)),
    const Recipes(),
    const AIBot(),
    const Favourites(),
    const Profile(),
  ];

  final List<Widget> _navBarItems = const [
    Icon(Icons.home, size: 30, color: Colors.white),
    Icon(Icons.restaurant_menu, size: 30, color: Colors.white),
    Icon(FontAwesomeIcons.brain, size: 30, color: Colors.white),
    Icon(Icons.favorite, size: 30, color: Colors.white),
    Icon(Icons.person, size: 30, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Row(
          children: [
            Icon(_appBarItems[_selectedIndex]['icon'], color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _appBarItems[_selectedIndex]['title'],
              style: GoogleFonts.aBeeZee(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.deepPurple.shade700,
        animationDuration: const Duration(milliseconds: 300),
        items: _navBarItems,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final VoidCallback onExploreTap;

  const _HomePageContent({required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Welcome to Home Spice!\nReady to Cook Something Delicious today?',
            textAlign: TextAlign.start,
            style: GoogleFonts.aBeeZee(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 75),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              35.0, // Adjust the radius value as needed
            ), // You can adjust the radius value
            child: Image.asset(
              'assets/images/home3.png',
              height: 220,
              width: 210,
              fit: BoxFit.fitWidth, // Optional: adjusts how the image is fit
            ),
          ),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: onExploreTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FontAwesomeIcons.explosion, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Explore Recipes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
