import 'package:flutter/material.dart';
import '../Graph_screen/graph_screen.dart';
import '../History_file/history_screen.dart';
import '../home_screen.dart';

class NavigationRoutePage extends StatefulWidget {
  const NavigationRoutePage({super.key});

  @override
  State<NavigationRoutePage> createState() => _NavigationRoutePageState();
}

class _NavigationRoutePageState extends State<NavigationRoutePage> {
  int _selectedIndex = 0;

  final _screens = const [
    HomeScreen(),
    GraphScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0, // Allow exit only on the Home tab
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0; // Navigate to Home tab on back press
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// Separate Bottom Navigation Bar Widget
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Today",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "Graph",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History",
        ),
      ],
    );
  }
}