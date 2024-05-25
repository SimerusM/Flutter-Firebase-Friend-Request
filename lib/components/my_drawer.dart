import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {

  // logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // drawer header
          const DrawerHeader(
            child: Icon(Icons.favorite)
          ),

          // home tile
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              // this is already the home screen so pop drawer
              Navigator.pop(context);
            }
          ),

          // profile tile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              // pop drawer
              Navigator.pop(context);

              // Navigate to profile page
              Navigator.pushNamed(context, '/profile_page');
            }
          ),

          // user tile
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Users"),
            onTap: () {
              // pop drawer
              Navigator.pop(context);

              // Navigate to profile page
              Navigator.pushNamed(context, '/users_page');
            }
          ),

          // friends tile
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Friends"),
            onTap: () {
              // pop drawer
              Navigator.pop(context);

              // Navigate to profile page
              Navigator.pushNamed(context, '/friends_page');
            }
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Logout"),
            onTap: () {
              // pop drawer
              Navigator.pop(context);

              // Logout
              logout();
            }
          )
        ],
      )
    );
  }
}