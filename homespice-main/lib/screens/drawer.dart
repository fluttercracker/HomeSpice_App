import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key,});
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      

        child:ListView(


          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: const EdgeInsets.only(bottom: 0.0),
              padding: const EdgeInsets.only(bottom: 0.0),
              
              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(1.0),
                  bottomRight: Radius.circular(1.0),

                ),
              ),
              child: Center(
        
                  child: Image.asset(
                    'assets/images/white_pic.png',
                    height: 150,
                    width: 135,
                    fit: BoxFit.cover,
                  ),
                
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 1.5,
              child:ListTile(
             leading: const Icon(Icons.home_filled),
              title: const Text('Home'),
              onTap: () {
                 Navigator.pushNamed(context, '/home');
              },
            ),),

                 const SizedBox(height: 10),

            Card(elevation: 1.5,
            child:ListTile(
              leading: const Icon(Icons.food_bank_outlined),
              title: const Text('Recipes'),
              onTap: () {
                Navigator.pushNamed(context, '/recipes');
              },
            ),),

                 const SizedBox(height: 10),

            Card(
            elevation: 1.5,

            child:ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('AI Bot'),
              onTap: () {
               Navigator.pushNamed(context, '/aibot');
              },
            ),),

                 const SizedBox(height: 10),

            Card(
               elevation: 1.5,
              child:ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favourites'),
              onTap: () {
                Navigator.pushNamed(context, '/favourites');
              },
            ), 
            ), 

                 const SizedBox(height: 10),

            Card(
               elevation: 1.5,
              child:ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ), 
            ), 

          ],


        ),
    );
  }
}