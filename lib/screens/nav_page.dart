import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mindlyy/screens/contact_picker_screen.dart';
import 'package:mindlyy/screens/home_screen.dart';
import 'package:mindlyy/screens/settings_screen.dart';

import '../custom/customBottomNavBar.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int index = 0;

  List<Widget> _pagesList = [
    HomeScreen(),
    ContactPickerScreen(),
    SettingsPage(),
  ];

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pagesList[index],
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomBottomNavigationBar(
                    currentIndex: index,
                    onTap: (newIndex) {
                      print('Tapped index: $newIndex');
                      setState(() {
                        index = newIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
