import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soche_fam_songs/screens/favorites_screen.dart';
import 'package:soche_fam_songs/screens/home_screen.dart';
import 'package:soche_fam_songs/screens/info_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({Key? key}) : super(key: key);

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    InfoScreen(),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color(0xff939393),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: [
          BottomNavigationBarItem(
            label: 'Songs',
            icon: Column(
              children: [
                Container(
                  height: 2,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 4),
                  color: _selectedIndex == 0
                      ? Colors.green.shade900
                      : Colors.transparent,
                ),
                Icon(
                  _selectedIndex == 0
                      ? CupertinoIcons.music_house_fill
                      : CupertinoIcons.music_house,
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: 'Favorites',
            icon: Column(
              children: [
                Container(
                  height: 2,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 4),
                  color: _selectedIndex == 1
                      ? Colors.green.shade900
                      : Colors.transparent,
                ),
                Icon(
                  _selectedIndex == 1
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: 'About',
            icon: Column(
              children: [
                Container(
                  height: 2,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 4),
                  color: _selectedIndex == 2
                      ? Colors.green.shade900
                      : Colors.transparent,
                ),
                Icon(
                  _selectedIndex == 2
                      ? CupertinoIcons.info_circle_fill
                      : CupertinoIcons.info_circle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
