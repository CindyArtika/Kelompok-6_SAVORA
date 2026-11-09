
import 'package:flutter/material.dart';
import 'package:tubes_pemmob/admin/admin_home.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentIndex = 0;

  static const Color primary = Color(0xFF143126);
  static const Color inactive = Color(0xFF526258);

  late final List<Widget> _pages = [
    const AdminHome(),
    const _PlaceholderPage(title: 'Bahan'),
    const _PlaceholderPage(title: 'Resep'),
    const _PlaceholderPage(title: 'Pengadaan'),
    const _PlaceholderPage(title: 'Laba & Rugi'),
  ];

  static const List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.menu_book_outlined,
    Icons.local_shipping_outlined,
    Icons.show_chart,
  ];

  static const List<String> _labels = [
    'Beranda',
    'Bahan',
    'Resep',
    'Pengadaan',
    'Laba & Rugi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: primary,
        unselectedItemColor: inactive,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: List.generate(
          _labels.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index], size: 25),
            label: _labels[index],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF143126),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Halaman $title',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF143126),
          ),
        ),
      ),
    );
  }
}
