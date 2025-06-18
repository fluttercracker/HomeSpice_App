import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:homespice/screens/drawer.dart';
import 'package:homespice/screens/recipes.dart';
import 'package:homespice/screens/ai_bot.dart';
import 'package:homespice/screens/favourites.dart';
import 'package:homespice/screens/profile.dart';
 // <-- make sure this import points to your NotePage

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
    {'title': 'HomeSpice', 'icon': Icons.home},
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
      //drawer: const SideMenu(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      
      // ✅ ADDING THE FLOATING ACTION BUTTON HERE
      floatingActionButton:Padding(
        padding: const EdgeInsets.only(bottom: 10.0), 
      child:FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, 
          '/Notes'); // Navigate to the Notes page
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add Note',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 5,
        heroTag: 'addNoteButton',
        
        label: Text(
          'Save Recipe',
          style: GoogleFonts.aBeeZee(color: Colors.white,fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.save_alt, color: Colors.white),
      ),
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
          const SizedBox(height: 60),
          ClipRRect(
            borderRadius: BorderRadius.circular(35.0),
            child: Image.asset(
              'assets/images/home3.png',
              height: 220,
              width: 210,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 30),
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
