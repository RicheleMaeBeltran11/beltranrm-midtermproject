import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light Grey Background
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF9CAF88), // Sage Green
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Expanded(
            child: _responsiveNav(
                context), // Calls a responsive navigation function
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == "settings") {
                // Handle settings
              } else if (value == "help") {
                // Handle help
              } else if (value == "logout") {
                Navigator.pop(context); // Log out action
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "settings", child: Text("Settings")),
              const PopupMenuItem(value: "help", child: Text("Help & Support")),
              const PopupMenuItem(value: "logout", child: Text("Log Out")),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double imageSize = constraints.maxWidth * 0.4; // 40% of screen width
          imageSize =
              imageSize.clamp(150, 300); // Ensure it stays within 150-300px

          return Center(
            child: Image.asset(
              'assets/girl.jpg',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Text("Image not found",
                    style: TextStyle(color: Colors.red));
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF9CAF88), // Sage Green Footer
        padding: const EdgeInsets.all(10),
        child: const Center(
          child: Text("© 2025 RMBeltran",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  // 🔥 Improved Responsive Navigation Bar
  Widget _responsiveNav(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _navItem(Icons.search, "Search", isSmallScreen),
          _navItem(Icons.home, "Home", isSmallScreen),
          _navItem(Icons.info, "About", isSmallScreen),
          _navItem(Icons.restaurant_menu, "Menu", isSmallScreen),
          _navItem(Icons.contact_mail, "Contact", isSmallScreen),
        ],
      ),
    );
  }

  // 🔥 Responsive Navigation Item
  Widget _navItem(IconData icon, String label, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: isSmallScreen
          ? IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: () {},
              tooltip: label, // Shows tooltip on hover/long-press
            )
          : TextButton.icon(
              onPressed: () {},
              icon: Icon(icon, color: Colors.white),
              label: Text(label, style: const TextStyle(color: Colors.white)),
            ),
    );
  }
}
