import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import 'dashboard_view.dart';
import 'analytics_view.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final isDark = userVM.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final navColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryBlue = isDark ? const Color(0xFF6B8AFF) : const Color(0xFF4361EE);
    final unselectedColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardView(onAnalyticsTap: () {
            setState(() {
              _currentIndex = 1;
            });
          }),
          const AnalyticsView(),
          const SettingsView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: navColor,
            elevation: 0,
            selectedItemColor: primaryBlue,
            unselectedItemColor: unselectedColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_rounded),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
