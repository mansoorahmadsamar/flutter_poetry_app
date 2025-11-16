import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/app_colors.dart';
import 'tabs/feed_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/bookmarks_tab.dart';
import 'tabs/poets_tab.dart';
import 'tabs/profile_tab.dart';

/// Tab configuration data
class TabConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const TabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}

/// Main screen with bottom navigation tabs
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // Tab configurations
  static const List<TabConfig> _tabs = [
    TabConfig(
      label: 'Feed',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      screen: FeedTab(),
    ),
    TabConfig(
      label: 'Search',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      screen: SearchTab(),
    ),
    TabConfig(
      label: 'Bookmarks',
      icon: Icons.bookmark_border,
      activeIcon: Icons.bookmark,
      screen: BookmarksTab(),
    ),
    TabConfig(
      label: 'Poets',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      screen: PoetsTab(),
    ),
    TabConfig(
      label: 'Profile',
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      screen: ProfileTab(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        items: _tabs.map((tab) {
          final isSelected = _tabs[_currentIndex] == tab;
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                size: 24,
              ),
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
