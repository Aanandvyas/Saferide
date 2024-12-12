import 'package:flutter/material.dart';
import 'package:driver_app/tabpages/home_tab.dart'; // Ensure this is implemented
import 'package:driver_app/tabpages/rating_tab.dart'; // Ensure this is implemented
import 'package:driver_app/tabpages/profile_tab.dart'; // Ensure this is implemented
import 'package:driver_app/tabpages/earning_tab.dart'; // Ensure this is implemented

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  // Method to update the selected index and tab
  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController?.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController?.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine theme brightness
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
        controller: tabController,
        children: const [
          HomeTabPage(),
          RatingTab(),
          ProfileTab(),
          EarningTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rating"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earnings"),
        ],
        unselectedItemColor: isDarkTheme ? Colors.black54 : Colors.white54,
        selectedItemColor: isDarkTheme ? Colors.black : Colors.white,
        backgroundColor: isDarkTheme ? Colors.amber.shade400 : Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showSelectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
