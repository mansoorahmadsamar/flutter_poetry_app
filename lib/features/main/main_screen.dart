import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/app_colors.dart';
import 'tabs/feed_tab.dart';
import 'tabs/bookmarks_tab.dart';
import 'tabs/poets_tab.dart';
import 'tabs/profile_tab.dart';
import '../discover/screens/discover_screen.dart';

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

/// Main screen with bottom navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  static final List<TabConfig> _tabs = [
    const TabConfig(
      label: 'Feed',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      screen: FeedTab(),
    ),
    TabConfig(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      screen: DiscoverScreen(),
    ),
    const TabConfig(
      label: 'Bookmarks',
      icon: Icons.bookmark_border,
      activeIcon: Icons.bookmark,
      screen: BookmarksTab(),
    ),
    const TabConfig(
      label: 'Poets',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      screen: PoetsTab(),
    ),
    const TabConfig(
      label: 'Profile',
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      screen: ProfileTab(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
            isDark ? AppColors.textSecondaryDark : Colors.grey[500],
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 8,
        items: _tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}
